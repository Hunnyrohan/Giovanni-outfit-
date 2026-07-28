import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

/// Works out which dev-backend host *this* device can actually reach, instead
/// of trusting a single hard-coded address.
///
/// The dev backend can be reached in several different ways depending on how
/// the app happens to be running, and the right one changes without warning:
///
///   * `10.0.2.2`      - the Android emulator's alias for the PC's loopback.
///                       Always available on an emulator, needs no tunnel.
///   * `127.0.0.1`     - only valid while `adb reverse tcp:3000 tcp:3000` is
///                       alive. That mapping dies on every USB reconnect,
///                       emulator restart and `adb kill-server`.
///   * the PC's LAN IP - works over Wi-Fi, but the address changes whenever
///                       the DHCP lease does.
///
/// Pinning any one of these is why login intermittently failed with
/// "No internet connection or server unreachable". This resolver probes the
/// candidates and remembers the winner, so a stale host heals itself.
class ApiHostResolver {
  ApiHostResolver(this._prefs);

  final SharedPreferences _prefs;

  static const String _lastGoodHostKey = 'api_last_good_host';

  /// How long a single candidate gets to accept a TCP connection. Kept short
  /// because unreachable hosts are the common case and every candidate after
  /// the first pays this cost.
  static const Duration _probeTimeout = Duration(milliseconds: 900);

  Future<String>? _inFlight;

  /// Resolves a reachable host and applies it to [ApiConstants.baseUrl].
  ///
  /// Concurrent callers share a single resolution pass. If nothing responds
  /// the previously configured host is kept, so behaviour degrades to the old
  /// "try it and surface the error" path rather than breaking outright.
  Future<String> resolve({bool forceRefresh = false}) {
    if (forceRefresh) {
      _inFlight = null;
    }
    return _inFlight ??= _resolve(forceRefresh: forceRefresh);
  }

  Future<String> _resolve({required bool forceRefresh}) async {
    try {
      for (final host in _candidates(forceRefresh: forceRefresh)) {
        if (await _isReachable(host)) {
          ApiConstants.useHost(host);
          await _prefs.setString(_lastGoodHostKey, host);
          return host;
        }
      }
      return ApiConstants.host;
    } finally {
      _inFlight = null;
    }
  }

  /// Candidate hosts in priority order, most-likely-to-work first and without
  /// duplicates.
  List<String> _candidates({required bool forceRefresh}) {
    final ordered = <String>[
      // A host that worked last time is retried first so the usual launch
      // costs a single probe. Skipped on a forced refresh, because that only
      // happens after the cached host has just failed us.
      if (!forceRefresh) ?_prefs.getString(_lastGoodHostKey),
      ...ApiConstants.hostCandidates,
    ];

    final seen = <String>{};
    return [
      for (final host in ordered)
        if (host.isNotEmpty && seen.add(host)) host,
    ];
  }

  Future<bool> _isReachable(String host) async {
    try {
      final socket = await Socket.connect(
        host,
        ApiConstants.apiPort,
        timeout: _probeTimeout,
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
