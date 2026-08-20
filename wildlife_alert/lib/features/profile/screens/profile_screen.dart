import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

import '../../splash/screens/splash_screen.dart';
import '../../onboarding/screens/zone_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _currentZone = 'Loading...';
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentZone();
  }

  Future<void> _loadCurrentZone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentZone = prefs.getString('current_zone') ?? 'No Zone Selected';
    });
  }

  Future<void> _changeZone() async {
    final prefs = await SharedPreferences.getInstance();
    final oldZone = prefs.getString('current_zone');

    // Unsubscribe from the old zone so they don't get alerts for two places
    if (!kIsWeb && oldZone != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(oldZone);
    }

    // Clear local storage for the zone
    await prefs.remove('current_zone');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ZoneSelectionScreen()),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final oldZone = prefs.getString('current_zone');

    // Unsubscribe before logging out
    if (!kIsWeb && oldZone != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(oldZone);
    }

    // Clear all local data and sign out of Firebase
    await prefs.clear();
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    // Route back to Splash, which will detect the logout and show the Login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'USER PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Premium Avatar
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                        )
                      ]
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded, 
                      size: 60, 
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // User Email
                const Text(
                  'ACCOUNT EMAIL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white54,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Unknown User',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w600, 
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 48),

                const Text(
                  'NETWORK STATUS',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white54,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Premium Zone Info Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00150F).withOpacity(0.6), // Dark teal background
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Colors.tealAccent, size: 24),
                    ),
                    title: const Text(
                      'Active Alert Zone',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _currentZone,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          color: Colors.white,
                        ),
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: _changeZone,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.tealAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CHANGE',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),

                // Premium Logout Button (Kept red for destructive action context)
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: Icon(Icons.logout_rounded, color: Colors.red.shade400),
                  label: Text(
                    'SECURE LOG OUT',
                    style: TextStyle(
                      color: Colors.red.shade400, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(color: Colors.red.shade900, width: 1.5),
                    backgroundColor: Colors.red.shade900.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}