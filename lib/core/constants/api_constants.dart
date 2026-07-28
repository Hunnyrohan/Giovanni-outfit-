class ApiConstants {
  ApiConstants._();

  // The dev backend is reached through an adb USB tunnel, because this
  // network blocks direct phone->PC traffic (verified: ping 100% loss).
  // The tunnel maps the device's 127.0.0.1:3000 to the PC's port 3000:
  //
  //   adb reverse tcp:3000 tcp:3000
  //
  // Run that once after (re)connecting the USB cable - it works for both
  // real phones and the emulator. If you ever run the app untethered on
  // Wi-Fi instead, switch baseUrl to the PC's LAN IP (e.g.
  // http://192.168.1.87:3000/api) and allow port 3000 through the Windows
  // firewall as administrator.
  static const String baseUrl = 'http://127.0.0.1:3000/api';

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