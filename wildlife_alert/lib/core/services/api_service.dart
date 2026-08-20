import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  
  // --- Fetch Zones for Onboarding ---
  static Future<List<dynamic>> fetchZones() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.getZones));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        return data['data']; // Returns the list of zone objects
      } else {
        throw Exception('Failed to load zones');
      }
    } catch (e) {
      print('Error fetching zones: $e');
      return [];
    }
  }

  // --- Link User to Zone on Backend ---
  static Future<bool> updateUserProfile({
    required String firebaseUid,
    required String email,
    required String topicId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.updateProfile),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebase_uid': firebaseUid,
          'email': email,
          'current_zone': topicId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchAlertById(String id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.getAlerts}/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching single alert: $e');
      return null;
    }
  }

  // --- Fetch Paginated & Filtered Alerts ---
  static Future<List<dynamic>> fetchAlerts({String? zone, int page = 1, String? severity}) async {
    try {
      // Start with the base URL and page
      String url = '${ApiConstants.getAlerts}?page=$page';
      
      // Append filters only if they are provided
      if (zone != null && zone.isNotEmpty) url += '&zone=$zone';
      if (severity != null && severity.isNotEmpty) url += '&severity=$severity';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['data']);
        return data['data']; 
      }
      return [];
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }
}