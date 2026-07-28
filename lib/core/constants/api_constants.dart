class ApiConstants {
  ApiConstants._();

  /// Port the dev backend listens on.
  static const int apiPort = 3000;

  /// Host used when nothing has been probed yet. Overridable at build time:
  ///
  ///   flutter run --dart-define=API_HOST=192.168.1.69
  ///
  /// An explicit override is always tried first and is the escape hatch for a
  /// setup the candidate list below doesn't cover.
  static const String _configuredHost = String.fromEnvironment('API_HOST');

  /// The PC's LAN address, used when the app runs untethered over Wi-Fi.
  /// This changes whenever the DHCP lease does, so it is only a fallback -
  /// override it with `--dart-define=API_LAN_HOST=...` when it drifts.
  static const String _lanHost = String.fromEnvironment(
    'API_LAN_HOST',
    defaultValue: '192.168.1.69',
  );

  /// Hosts to probe, in priority order. There is no single address that is
  /// correct in every situation, which is why these are tried rather than
  /// picked:
  ///
  ///   * `10.0.2.2`  - the Android emulator's alias for the PC's loopback.
  ///                   Needs no tunnel and no firewall rule.
  ///   * `127.0.0.1` - a real phone tethered over USB, valid only while
  ///                   `adb reverse tcp:3000 tcp:3000` is alive (see
  ///                   phone_tunnel.ps1). That mapping dies on every USB
  ///                   reconnect, so it must never be assumed.
  ///   * the LAN IP  - same Wi-Fi network, needs port 3000 open in the
  ///                   Windows firewall.
  ///
  /// See ApiHostResolver, which probes these and caches the winner.
  static const List<String> hostCandidates = <String>[
    _configuredHost,
    '10.0.2.2',
    '127.0.0.1',
    _lanHost,
  ];

  /// Base URL for all API calls. Mutable because the reachable host is only
  /// known at runtime - [ApiHostResolver] rewrites this via [useHost] on
  /// startup and again whenever the current host stops responding.
  static String baseUrl = 'http://${_configuredHost.isNotEmpty ? _configuredHost : '10.0.2.2'}:$apiPort/api';

  /// The host portion of [baseUrl].
  static String get host => Uri.parse(baseUrl).host;

  /// Repoints every subsequent request at [host].
  static void useHost(String host) {
    baseUrl = 'http://$host:$apiPort/api';
  }

  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String profileMe = '/profile';
  static const String profilePicture = '/profile/picture';
  static const String changePassword = '/profile/password';

  // Two-Factor Authentication Endpoints
  static const String twoFactorSetup = '/auth/2fa/setup';
  static const String twoFactorEnable = '/auth/2fa/enable';
  static const String twoFactorDisable = '/auth/2fa/disable';
  static const String twoFactorVerify = '/auth/2fa/verify';

  static const String googleClientId =
      '892533108858-5h30ipg1rsafobi5h13c6n1lj51fqcup.apps.googleusercontent.com';

  /// The API host without the `/api` path prefix, used to resolve
  /// host-relative media paths (e.g. uploaded profile pictures) returned
  /// by the backend against whichever host this client used to reach it.
  static String get mediaBaseUrl =>
      baseUrl.endsWith('/api') ? baseUrl.substring(0, baseUrl.length - 4) : baseUrl;

  /// Resolves a possibly host-relative media path (e.g. `/uploads/profile/x.png`)
  /// into an absolute URL. Already-absolute URLs (e.g. Google profile photos) are
  /// returned unchanged.
  static String? resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '$mediaBaseUrl$path';
  }

  // Wardrobe Endpoints
  static const String wardrobe = '/wardrobe';
  static String wardrobeItem(String id) => '/wardrobe/$id';

  // Outfit Analysis Endpoints
  static const String analyzeOutfit = '/outfit/analyze';
  static const String outfitHistory = '/outfit/history';
  static String outfitHistoryItem(String id) => '/outfit/history/$id';

  // Suggestions Endpoints
  static const String generateSuggestions = '/suggestions/generate';
  static const String saveSuggestion = '/suggestions/save';
  static const String savedSuggestions = '/suggestions/saved';

  // AI Stylist Endpoints
  static const String aiChat = '/ai/chat';
  static const String aiAnalyze = '/ai/analyze';
  static const String aiRecommend = '/ai/recommend';
  static const String aiHistory = '/ai/history';
  static String aiHistoryItem(String id) => '/ai/history/$id';

  // Virtual Try-On Endpoints
  static const String virtualTryOn = '/virtual-tryon';
  static const String virtualTryOnHistory = '/virtual-tryon/history';
  static String virtualTryOnItem(String id) => '/virtual-tryon/$id';
  static String virtualTryOnImage(String id) => '/virtual-tryon/$id/image';
  static String virtualTryOnSave(String id) => '/virtual-tryon/$id/save';
}