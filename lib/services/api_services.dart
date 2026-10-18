import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class ApiService {
  /// Set from app startup. Called when a premium route returns HTTP 402.
  static void Function()? onPaymentRequired;

  final SharedPreferences sharedPreferences;

  ApiService({required this.sharedPreferences});

  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration authTimeout = Duration(seconds: 60);
  static const Duration _uploadTimeout = Duration(minutes: 3);
  static const Duration _analyzeTimeout = Duration(minutes: 3);

  Duration get analyzeTimeout => _analyzeTimeout;

  // GET request
  Future<dynamic> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers ?? await _getHeaders(),
          )
          .timeout(timeout ?? _defaultTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  // POST request
  Future<dynamic> post(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers ?? await _getHeaders(),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(timeout ?? _defaultTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  // Multipart request (supports POST, PATCH, etc.)
  Future<dynamic> multipartRequest(
    String url, {
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, String>? files,
    Map<String, String>? headers,
    Map<String, MediaType>? fileContentTypes,
    Map<String, String>? fileNames,
    Duration? timeout,
  }) async {
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));

      final defaultHeaders = await _getHeaders();
      defaultHeaders.remove('Content-Type');
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }
      request.headers.addAll(defaultHeaders);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        for (final entry in files.entries) {
          if (entry.value.isEmpty) continue;
          final file = File(entry.value);
          if (!await file.exists()) {
            throw ApiError(
              message: 'Video file not found. Please record again.',
              statusCode: 0,
            );
          }
          final size = await file.length();
          if (size <= 0) {
            throw ApiError(
              message: 'Recorded video is empty. Please record again.',
              statusCode: 0,
            );
          }

          final explicitType = fileContentTypes?[entry.key];
          final guessed = mime(entry.value);
          final contentType = explicitType ??
              (guessed != null ? MediaType.parse(guessed) : null) ??
              MediaType('application', 'octet-stream');

          final filename = fileNames?[entry.key] ??
              _safeFilename(entry.value, fallback: '${entry.key}.bin');

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              entry.value,
              filename: filename,
              contentType: contentType,
            ),
          );
        }
      }

      final streamedResponse =
          await request.send().timeout(timeout ?? _uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(timeout ?? _uploadTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  String _safeFilename(String path, {required String fallback}) {
    final name = path.replaceAll('\\', '/').split('/').last.trim();
    if (name.isEmpty) return fallback;
    if (!name.contains('.')) return '$name.mp4';
    return name;
  }

  Future<dynamic> multipartPost(
    String url, {
    Map<String, String>? fields,
    Map<String, String>? files,
    Map<String, String>? headers,
  }) async {
    return multipartRequest(
      url,
      method: 'POST',
      fields: fields,
      files: files,
      headers: headers,
    );
  }

  Future<dynamic> put(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers ?? await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_defaultTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  /// Streams a file to a pre-signed URL. No auth header — the URL is the credential.
  Future<void> putFile(
    String url,
    String filePath, {
    String contentType = 'video/mp4',
    Duration? timeout,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ApiError(
        message: 'Video file not found. Please record again.',
        statusCode: 0,
      );
    }
    final length = await file.length();
    if (length <= 0) {
      throw ApiError(
        message: 'Recorded video is empty. Please record again.',
        statusCode: 0,
      );
    }

    try {
      final request = http.StreamedRequest('PUT', Uri.parse(url));
      request.headers['Content-Type'] = contentType;
      request.contentLength = length;
      final sinkDone = file.openRead().pipe(request.sink);
      final streamed = await request.send().timeout(timeout ?? _uploadTimeout);
      await sinkDone;
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw ApiError(
          message: 'Video upload failed (${streamed.statusCode}).',
          statusCode: streamed.statusCode,
        );
      }
      await streamed.stream.drain<void>();
    } catch (e) {
      throw _toApiError(e);
    }
  }

  Future<dynamic> delete(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers ?? await _getHeaders(),
          )
          .timeout(_defaultTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  Future<dynamic> patch(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(url),
            headers: headers ?? await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_defaultTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final rawBody = response.body.trim();

    if (rawBody.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return <String, dynamic>{};
      }
      if (statusCode == 402) {
        ApiService.onPaymentRequired?.call();
      }
      throw ApiError(
        message: statusCode == 502 || statusCode == 503 || statusCode == 504
            ? 'Server is temporarily unavailable ($statusCode). Please try again in a moment.'
            : 'Something went wrong ($statusCode)',
        statusCode: statusCode,
      );
    }

    dynamic body;
    try {
      body = jsonDecode(rawBody);
    } catch (_) {
      debugPrint('ApiService non-JSON response ($statusCode): $rawBody');
      throw ApiError(
        message: statusCode == 502 || statusCode == 503 || statusCode == 504
            ? 'Server is temporarily unavailable ($statusCode). Please try again in a moment.'
            : statusCode >= 500
                ? 'Server error ($statusCode). Please try again.'
                : 'Invalid server response ($statusCode).',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    debugPrint('ApiService error $statusCode: $rawBody');

    String errorMessage = 'Something went wrong';
    if (body is Map) {
      final details = <String>[];

      void collectConstraint(dynamic item) {
        if (item is! Map) {
          if (item != null) details.add(item.toString());
          return;
        }
        final property = item['property']?.toString();
        final constraints = item['constraints'];
        if (constraints is Map && constraints.isNotEmpty) {
          final text = constraints.values.map((e) => e.toString()).join(', ');
          details.add(property == null || property.isEmpty
              ? text
              : '$property: $text');
        } else if (item['message'] != null) {
          details.add(item['message'].toString());
        }
      }

      final message = body['message'];
      if (message is List) {
        for (final item in message) {
          collectConstraint(item);
        }
      } else if (message != null) {
        details.add(message.toString());
      }

      final errors = body['errors'] ?? body['error'];
      if (errors is List) {
        for (final item in errors) {
          collectConstraint(item);
        }
      } else if (errors != null && message is! String) {
        details.add(errors.toString());
      }

      final errorMessages = body['errorMessages'];
      if (errorMessages is List) {
        for (final item in errorMessages) {
          collectConstraint(item);
        }
      }

      if (details.isNotEmpty) {
        // Prefer concrete field messages over generic "Validation Error".
        final concrete = details
            .where((e) => e.trim().isNotEmpty && e != 'Validation Error')
            .toList();
        errorMessage =
            (concrete.isNotEmpty ? concrete : details).join('\n');
      }
    }

    if (statusCode == 402) {
      ApiService.onPaymentRequired?.call();
    }

    throw ApiError(
      message: errorMessage,
      statusCode: statusCode,
    );
  }

  ApiError _toApiError(dynamic error) {
    if (error is ApiError) return error;
    debugPrint('ApiService request failed: $error');
    if (error is TimeoutException) {
      return ApiError(
        message:
            'Request timed out. The server did not respond in time — check '
            'your internet, or try again in a moment.',
        statusCode: 0,
      );
    }
    if (error is SocketException || error is http.ClientException) {
      return ApiError(
        message: 'Network error. Please check your connection.',
        statusCode: 0,
      );
    }
    if (error is FormatException) {
      return ApiError(
        message: 'Invalid response format.',
        statusCode: 0,
      );
    }
    return ApiError(
      message: error.toString().isNotEmpty
          ? error.toString()
          : 'An unexpected error occurred.',
      statusCode: 0,
    );
  }

  Future<Map<String, String>> _getHeaders() async {
    final accessToken =
        sharedPreferences.getString(ApiConstants.keyAccessToken);

    return {
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String accessTokenExpiresAt,
    required String refreshTokenExpiresAt,
  }) async {
    await sharedPreferences.setString(ApiConstants.keyAccessToken, accessToken);
    await sharedPreferences.setString(
        ApiConstants.keyRefreshToken, refreshToken);
    await sharedPreferences.setString(
        ApiConstants.keyAccessTokenExpiresAt, accessTokenExpiresAt);
    await sharedPreferences.setString(
        ApiConstants.keyRefreshTokenExpiresAt, refreshTokenExpiresAt);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await sharedPreferences.setString(
        ApiConstants.keyUserData, jsonEncode(userData));
    await sharedPreferences.setBool(ApiConstants.keyIsLoggedIn, true);
  }

  String? getAccessToken() {
    return sharedPreferences.getString(ApiConstants.keyAccessToken);
  }

  bool get isLoggedIn =>
      sharedPreferences.getBool(ApiConstants.keyIsLoggedIn) ?? false;

  Map<String, dynamic>? getUserData() {
    final raw = sharedPreferences.getString(ApiConstants.keyUserData);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  Future<void> saveGuestId(String guestId) async {
    await sharedPreferences.setString(ApiConstants.keyGuestId, guestId);
  }

  String? getGuestId() {
    final id = sharedPreferences.getString(ApiConstants.keyGuestId);
    if (id == null || id.isEmpty) return null;
    return id;
  }

  Future<void> clearGuestId() async {
    await sharedPreferences.remove(ApiConstants.keyGuestId);
  }

  Future<void> clearUserData() async {
    await sharedPreferences.remove(ApiConstants.keyAccessToken);
    await sharedPreferences.remove(ApiConstants.keyRefreshToken);
    await sharedPreferences.remove(ApiConstants.keyAccessTokenExpiresAt);
    await sharedPreferences.remove(ApiConstants.keyRefreshTokenExpiresAt);
    await sharedPreferences.remove(ApiConstants.keyUserData);
    await sharedPreferences.remove(ApiConstants.keyGuestId);
    await sharedPreferences.setBool(ApiConstants.keyIsLoggedIn, false);
  }
}

class ApiError implements Exception {
  final String message;
  final int statusCode;

  ApiError({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
