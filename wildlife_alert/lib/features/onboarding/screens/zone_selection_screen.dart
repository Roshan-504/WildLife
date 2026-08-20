import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../alerts/screens/alert_feed_screen.dart'; // We will build this next
import '../../../core/screens/main_nav_screen.dart'; // Add this import

class ZoneSelectionScreen extends StatefulWidget {
  const ZoneSelectionScreen({super.key});

  @override
  State<ZoneSelectionScreen> createState() => _ZoneSelectionScreenState();
}

class _ZoneSelectionScreenState extends State<ZoneSelectionScreen> {
  List<dynamic> _zones = [];
  String? _selectedTopicId;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    final zones = await ApiService.fetchZones();
    setState(() {
      _zones = zones;
      _isLoading = false;
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedTopicId == null) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // 1. Update the user profile on your Node.js backend
      final success = await ApiService.updateUserProfile(
        firebaseUid: user.uid,
        email: user.email ?? 'unknown@email.com',
        topicId: _selectedTopicId!,
      );

      if (!success) throw Exception("Failed to update profile on backend");

      // 2. Subscribe the device to the chosen Firebase FCM topic
      if (!kIsWeb) {
        await FirebaseMessaging.instance.subscribeToTopic(_selectedTopicId!);
      } else {
        debugPrint("Running on Web: Skipped FCM subscription. Saving locally instead.");
      }
      // 3. Save locally so Splash Screen knows to skip this page next time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_zone', _selectedTopicId!);

      if (!mounted) return;

      // 4. Navigate to the main Alert Feed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavScreen()), // CHANGED
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving zone: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Zone'),
        automaticallyImplyLeading: false, // Prevent going back to splash
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Help us keep your neighborhood safe.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select your residential area to receive instant alerts when apex predators are detected nearby.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  
                  // Dropdown to select the zone
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Residential Zone',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTopicId,
                    items: _zones.map((zone) {
                      return DropdownMenuItem<String>(
                        value: zone['topic_id'],
                        child: Text(zone['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTopicId = value;
                      });
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_selectedTopicId == null || _isSaving)
                          ? null
                          : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm Zone',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}