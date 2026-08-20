import 'package:flutter/material.dart';
import '../../features/alerts/screens/alert_feed_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/help/screens/emergency_help_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  // List of screens for the bottom navigation
  final List<Widget> _screens = [
    const AlertFeedScreen(),
    const EmergencyHelpScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E11), // Seamless blend with the screens
      
      // IndexedStack keeps screens alive in memory so they don't reload when switching tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E11),
          border: Border(
            top: BorderSide(
              color: Colors.tealAccent.withOpacity(0.1), // Subtle teal divider line
              width: 1,
            ),
          ),
        ),
        child: Theme(
          // Removes the default ripple splash effect for a cleaner feel
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF0A0E11),
            currentIndex: _currentIndex,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Colors.tealAccent,
            unselectedItemColor: Colors.white.withOpacity(0.4),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 11, 
              letterSpacing: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 11, 
              letterSpacing: 1.0,
            ),
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                  child: Icon(Icons.radar_outlined, size: 26),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
                  child: Icon(Icons.radar_rounded, color: Colors.tealAccent, size: 26),
                ),
                label: 'ALERTS',
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                  child: Icon(Icons.shield_outlined, size: 26),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
                  child: Icon(Icons.shield_rounded, color: Colors.tealAccent, size: 26),
                ),
                label: 'SAFETY',
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                  child: Icon(Icons.person_outline_rounded, size: 26),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
                  child: Icon(Icons.person_rounded, color: Colors.tealAccent, size: 26),
                ),
                label: 'PROFILE',
              ),
            ],
          ),
        ),
      ),
    );
  }
}