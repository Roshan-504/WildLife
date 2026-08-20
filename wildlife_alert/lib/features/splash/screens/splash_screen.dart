import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/login_screen.dart';
import '../../onboarding/screens/zone_selection_screen.dart';
import '../../../core/screens/main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Add a slight delay for smooth visual transition
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    
    if (!mounted) return;

    if (user == null) {
      // Not logged in -> Go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Logged in -> Check if they have a zone selected
      final prefs = await SharedPreferences.getInstance();
      final hasZone = prefs.containsKey('current_zone');

      if (hasZone) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ZoneSelectionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // Premium Deep Forest Teal Gradient
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glassmorphic Logo Container
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: Colors.tealAccent.withOpacity(0.2), 
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: const Icon(
                Icons.pets_rounded, 
                size: 70, 
                color: Colors.tealAccent, // Bright accent for the logo
              ),
            ),
            const SizedBox(height: 40),
            
            // Refined Typography
            const Text(
              'WILDLIFE ALERT',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SAFETY NETWORK',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.tealAccent.withOpacity(0.7),
                letterSpacing: 2.0,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Minimalist Loader
            const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: Colors.tealAccent,
                strokeWidth: 2.5, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}