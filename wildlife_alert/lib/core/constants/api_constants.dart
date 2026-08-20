class ApiConstants {
  // Replace this with your actual Render URL later
  // For Android emulator testing local backend, use 10.0.2.2 instead of localhost
  static const String baseUrl = 'https://wildlife-81wn.onrender.com/api';
  
  static const String getZones = '$baseUrl/zones';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String getAlerts = '$baseUrl/alerts';
}