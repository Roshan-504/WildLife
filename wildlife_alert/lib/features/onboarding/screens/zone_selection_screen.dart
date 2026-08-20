import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../alerts/screens/alert_feed_screen.dart';
import '../../../core/screens/main_nav_screen.dart';

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
        MaterialPageRoute(builder: (context) => const MainNavScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving zone: $e'),
          backgroundColor: const Color(0xFF00251A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent going back to splash
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF004D40), // Deep Teal
              Color(0xFF00251A), // Dark Forest Green
              Color(0xFF0A0E11), // Premium Slate/Black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.tealAccent,
                    strokeWidth: 3,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.tealAccent.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.radar_outlined,
                          size: 44,
                          color: Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'Select Your Zone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Help us keep your neighborhood safe. Select your residential area to receive instant alerts when wildlife is detected nearby.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.tealAccent.withOpacity(0.7),
                          height: 1.4,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 36),
                      
                      // Dropdown to select the zone
                      DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF00251A), // Deep forest container
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.tealAccent),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.06),
                          labelText: 'Residential Zone',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: Icon(
                            Icons.location_on_outlined, 
                            color: Colors.tealAccent.withOpacity(0.8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.tealAccent, 
                              width: 1.5,
                            ),
                          ),
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
                      ElevatedButton(
                        onPressed: (_selectedTopicId == null || _isSaving)
                            ? null
                            : _confirmSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00796B),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white.withOpacity(0.08),
                          disabledForegroundColor: Colors.white.withOpacity(0.3),
                          elevation: 8,
                          shadowColor: Colors.tealAccent.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.tealAccent,
                                ),
                              )
                            : const Text(
                                'CONFIRM ZONE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}