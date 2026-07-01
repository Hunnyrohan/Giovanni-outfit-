class ApiConstants {
  ApiConstants._();

  // Change this to your local server IP (e.g. 10.0.2.2 for Android Emulator, or localhost)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

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
}
