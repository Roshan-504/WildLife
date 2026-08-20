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
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            // User Email
            Text(
              user?.email ?? 'Unknown User',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Zone Info Card
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.my_location, color: Colors.red),
                title: const Text('Active Alert Zone'),
                subtitle: Text(
                  _currentZone,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: _changeZone,
                  child: const Text('CHANGE'),
                ),
              ),
            ),
            
            const Spacer(),

            // Logout Button
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}