import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_ai_app/core/constants/api_constants.dart';
import 'package:outfit_ai_app/core/network/api_host_resolver.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// These run on the desktop VM, where `10.0.2.2` (the emulator-only alias) is
/// unreachable and `127.0.0.1` is not. That asymmetry is what lets us assert
/// the resolver actually skips dead candidates instead of taking the first one.
Future<bool> _accepts(String host) async {
  try {
    final socket = await Socket.connect(
      host,
      ApiConstants.apiPort,
      timeout: const Duration(milliseconds: 500),
    );
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The dev backend may already own port 3000. When it does we probe against
  // it instead of standing up our own stub.
  HttpServer? server;
  final originalBaseUrl = ApiConstants.baseUrl;

  Future<HttpServer?> bindStub() async {
    try {
      final stub = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        ApiConstants.apiPort,
      );
      stub.listen((request) => request.response.close());
      return stub;
    } on SocketException {
      return null; // Port already serving - good enough to probe.
    }
  }

  setUpAll(() async {
    server = await bindStub();
  });

  tearDownAll(() async {
    await server?.close(force: true);
    ApiConstants.baseUrl = originalBaseUrl;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApiConstants.baseUrl = originalBaseUrl;
  });

  test('skips unreachable candidates and points baseUrl at a live host', () async {
    final resolver = ApiHostResolver(await SharedPreferences.getInstance());

    final host = await resolver.resolve();

    expect(host, '127.0.0.1');
    expect(ApiConstants.baseUrl, 'http://127.0.0.1:3000/api');
    expect(ApiConstants.host, '127.0.0.1');
  });

  test('remembers the winning host across resolver instances', () async {
    final prefs = await SharedPreferences.getInstance();
    await ApiHostResolver(prefs).resolve();

    // A fresh resolver reading the same prefs should trust the cached host.
    final stopwatch = Stopwatch()..start();
    final host = await ApiHostResolver(prefs).resolve();
    stopwatch.stop();

    expect(host, '127.0.0.1');
    // Cache hit means one successful probe, not a walk through dead candidates.
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 800)));
  });

  test('forceRefresh re-probes instead of returning the cached host', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_last_good_host', '10.0.2.2');

    final host = await ApiHostResolver(prefs).resolve(forceRefresh: true);

    expect(host, '127.0.0.1');
  });

  test('falls back to the current host when nothing answers', () async {
    await server?.close(force: true);
    server = null;

    // The dev backend may be serving port 3000 too, in which case "no host
    // answers" cannot be staged here and the assertion would be meaningless.
    if (await _accepts('127.0.0.1')) {
      markTestSkipped('dev backend is serving port ${ApiConstants.apiPort}');
      server = await bindStub();
      return;
    }

    ApiConstants.useHost('10.0.2.2');

    final host = await ApiHostResolver(
      await SharedPreferences.getInstance(),
    ).resolve();

    expect(host, '10.0.2.2');
    expect(ApiConstants.baseUrl, 'http://10.0.2.2:3000/api');

    server = await bindStub();
  });
}
