import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class ApiService {
  final SharedPreferences sharedPreferences;

  ApiService({required this.sharedPreferences});

  // GET request
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  // POST request
  Future<dynamic> post(String url,
      {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers ?? await _getHeaders(),
        body: jsonEncode(body),
      );
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
      }) async {
    try {
      var request = http.MultipartRequest(method, Uri.parse(url));

      // Add headers
      var defaultHeaders = await _getHeaders();
      defaultHeaders.remove('Content-Type'); // MultipartRequest sets its own Content-Type
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }
      request.headers.addAll(defaultHeaders);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          if (entry.value.isNotEmpty) {
            String? mimeType = mime(entry.value);
            request.files.add(await http.MultipartFile.fromPath(
              entry.key,
              entry.value,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ));
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  // Multipart POST request (deprecated in favor of multipartRequest)
  Future<dynamic> multipartPost(String url,
      {Map<String, String>? fields,
        Map<String, String>? files,
        Map<String, String>? headers}) async {
    return multipartRequest(url,
        method: 'POST', fields: fields, files: files, headers: headers);
  }

  // PUT request
  Future<dynamic> put(String url,
      {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers ?? await _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers ?? await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  // PATCH request
  Future<dynamic> patch(String url,
      {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers ?? await _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _toApiError(e);
    }
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final rawBody = response.body.trim();

    if (rawBody.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return <String, dynamic>{};
      }
      throw ApiError(
        message: 'Something went wrong',
        statusCode: statusCode,
      );
    }

    final body = jsonDecode(rawBody);

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      String errorMessage = 'Something went wrong';

      // Handle different error response formats
      if (body['message'] != null) {
        if (body['message'] is List) {
          // Handle validation errors array format
          List messages = body['message'];
          if (messages.isNotEmpty) {
            var firstError = messages[0];
            if (firstError['constraints'] != null) {
              // Extract first constraint message
              var constraints = firstError['constraints'];
              errorMessage = constraints.values.first;
            } else if (firstError['message'] != null) {
              errorMessage = firstError['message'];
            } else {
              errorMessage = firstError.toString();
            }
          }
        } else {
          // Simple string message
          errorMessage = body['message'];
        }
      } else if (body['error'] != null) {
        errorMessage = body['error'];
      }

      throw ApiError(
        message: errorMessage,
        statusCode: statusCode,
      );
    }
  }

  ApiError _toApiError(dynamic error) {
    if (error is ApiError) return error;
    if (error is http.ClientException) {
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
      message: 'An unexpected error occurred.',
      statusCode: 0,
    );
  }

  // Get headers
  Future<Map<String, String>> _getHeaders() async {
    String? accessToken =
    sharedPreferences.getString(ApiConstants.keyAccessToken);

    return {
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  // Save tokens
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

  // Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await sharedPreferences.setString(
        ApiConstants.keyUserData, jsonEncode(userData));
    await sharedPreferences.setBool(ApiConstants.keyIsLoggedIn, true);
  }

  // Get access token
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

  // Clear user data (logout)
  Future<void> clearUserData() async {
    await sharedPreferences.remove(ApiConstants.keyAccessToken);
    await sharedPreferences.remove(ApiConstants.keyRefreshToken);
    await sharedPreferences.remove(ApiConstants.keyAccessTokenExpiresAt);
    await sharedPreferences.remove(ApiConstants.keyRefreshTokenExpiresAt);
    await sharedPreferences.remove(ApiConstants.keyUserData);
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