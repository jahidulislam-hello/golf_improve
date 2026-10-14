import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Phones often fail API calls that the emulator completes.
///
/// The emulator has no IPv6 route, so Dart connects to `golf.ssh.bd` over IPv4.
/// A real device has IPv6 addresses and `getaddrinfo` can fail or stall on those
/// before it ever tries IPv4, which surfaces as "Network error".
///
/// This client resolves and dials IPv4 first, then IPv6, then DNS-over-HTTPS.
class DeviceHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 30)
      ..connectionFactory = _connect;
  }
}

Future<ConnectionTask<Socket>> _connect(
  Uri uri,
  String? proxyHost,
  int? proxyPort,
) {
  if (proxyHost != null && proxyPort != null) {
    return Socket.startConnect(proxyHost, proxyPort);
  }
  return Future<ConnectionTask<Socket>>.value(_DirectConnect(uri).start());
}

class _DirectConnect {
  _DirectConnect(this.uri);

  final Uri uri;
  final Completer<Socket> _socket = Completer<Socket>();
  final List<Socket> _opened = <Socket>[];
  var _cancelled = false;
  Object? _lastError;

  ConnectionTask<Socket> start() {
    unawaited(_run());
    return ConnectionTask.fromSocket(_socket.future, _cancel);
  }

  void _cancel() {
    _cancelled = true;
    for (final socket in _opened) {
      _destroy(socket);
    }
    if (!_socket.isCompleted) {
      _socket.completeError(
        const SocketException('Connection attempt cancelled'),
      );
    }
  }

  Future<void> _run() async {
    try {
      final host = uri.host;
      final v4Lookup = _lookup(host, InternetAddressType.IPv4);
      final v6Lookup = _lookup(host, InternetAddressType.IPv6);

      final v4 = await v4Lookup;
      final connected = await _dialAll(v4) ??
          await _dialAll(await v6Lookup) ??
          await _dialAll(await _dnsOverHttps(host));

      if (_cancelled || _socket.isCompleted) {
        if (connected != null) _destroy(connected);
        return;
      }
      if (connected != null) {
        _socket.complete(connected);
        return;
      }
      final error = _lastError ??
          SocketException("Failed host lookup: '$host'");
      _socket.completeError(error);
    } catch (error, stack) {
      if (!_socket.isCompleted) {
        _socket.completeError(error, stack);
      }
    }
  }

  Future<Socket?> _dialAll(List<InternetAddress> addresses) async {
    final tls = uri.scheme == 'https';
    for (final address in addresses) {
      if (_cancelled) return null;
      Socket? raw;
      try {
        raw = await Socket.connect(
          address,
          uri.port,
          timeout: const Duration(seconds: 6),
        );
        if (_cancelled) {
          _destroy(raw);
          return null;
        }
        _opened.add(raw);
        if (!tls) return raw;

        final secure = await SecureSocket.secure(
          raw,
          host: uri.host,
        ).timeout(const Duration(seconds: 10));
        if (_cancelled) {
          _destroy(secure);
          return null;
        }
        _opened.add(secure);
        return secure;
      } catch (error) {
        _lastError = error;
        if (raw != null) _destroy(raw);
        if (kDebugMode) {
          debugPrint(
            'DeviceHttpOverrides: ${uri.host} via $address failed: $error',
          );
        }
      }
    }
    return null;
  }

  void _destroy(Socket socket) {
    try {
      socket.destroy();
    } catch (_) {}
  }
}

Future<List<InternetAddress>> _lookup(
  String host,
  InternetAddressType type,
) async {
  final parsed = InternetAddress.tryParse(host);
  if (parsed != null) {
    return parsed.type == type ? <InternetAddress>[parsed] : const [];
  }
  try {
    return await InternetAddress.lookup(host, type: type)
        .timeout(const Duration(seconds: 4));
  } catch (error) {
    if (kDebugMode) {
      debugPrint('DeviceHttpOverrides: $type lookup for $host failed: $error');
    }
    return const [];
  }
}

/// Used when the phone's resolver returns nothing usable.
Future<List<InternetAddress>> _dnsOverHttps(String host) async {
  if (InternetAddress.tryParse(host) != null) return const [];

  final addresses = <InternetAddress>[];
  for (final recordType in const ['A', 'AAAA']) {
    try {
      addresses.addAll(await _queryCloudflare(host, recordType));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('DeviceHttpOverrides: DoH $recordType for $host failed: $error');
      }
    }
  }
  return addresses;
}

Future<List<InternetAddress>> _queryCloudflare(
  String host,
  String recordType,
) async {
  final raw = await Socket.connect(
    InternetAddress('1.1.1.1'),
    443,
    timeout: const Duration(seconds: 5),
  );
  final secure = await SecureSocket.secure(
    raw,
    host: 'cloudflare-dns.com',
  ).timeout(const Duration(seconds: 8));
  try {
    final path =
        '/dns-query?name=${Uri.encodeQueryComponent(host)}&type=$recordType';
    secure.write(
      'GET $path HTTP/1.1\r\n'
      'Host: cloudflare-dns.com\r\n'
      'Accept: application/dns-json\r\n'
      'Connection: close\r\n'
      '\r\n',
    );
    final bytes = await secure.fold<List<int>>(
      <int>[],
      (previous, chunk) => previous..addAll(chunk),
    );
    return _addressesFromDnsJson(_httpBody(utf8.decode(bytes)));
  } finally {
    secure.destroy();
  }
}

String _httpBody(String response) {
  final splitAt = response.indexOf('\r\n\r\n');
  if (splitAt < 0) return '';
  final headers = response.substring(0, splitAt).toLowerCase();
  final body = response.substring(splitAt + 4);
  if (headers.contains('transfer-encoding: chunked')) {
    return _decodeChunked(body);
  }
  return body;
}

String _decodeChunked(String body) {
  final buffer = StringBuffer();
  var rest = body;
  while (rest.isNotEmpty) {
    final lineBreak = rest.indexOf('\r\n');
    if (lineBreak < 0) break;
    final size = int.tryParse(rest.substring(0, lineBreak).trim(), radix: 16);
    if (size == null || size == 0) break;
    final start = lineBreak + 2;
    final end = start + size;
    if (end > rest.length) break;
    buffer.write(rest.substring(start, end));
    rest = rest.substring(end);
    if (rest.startsWith('\r\n')) rest = rest.substring(2);
  }
  return buffer.toString();
}

List<InternetAddress> _addressesFromDnsJson(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map) return const [];
  final answers = decoded['Answer'];
  if (answers is! List) return const [];

  final addresses = <InternetAddress>[];
  for (final answer in answers) {
    if (answer is! Map) continue;
    final data = answer['data'];
    if (data is! String) continue;
    final address = InternetAddress.tryParse(data);
    if (address != null) addresses.add(address);
  }
  return addresses;
}
