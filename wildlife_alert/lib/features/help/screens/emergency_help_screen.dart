import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHelpScreen extends StatelessWidget {
  const EmergencyHelpScreen({super.key});

  Future<void> _callHelpline(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch dialer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'SAFETY & HELP',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Icon
                Center(
                  child: Container(
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
                      Icons.support_agent_rounded,
                      size: 44,
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  'EMERGENCY CONTACTS',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white54,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildEmergencyCard(
                  title: 'Forest Department',
                  subtitle: '1926 (Toll-Free)',
                  icon: Icons.shield_outlined,
                  iconColor: Colors.blue.shade400,
                  number: '1926',
                ),
                _buildEmergencyCard(
                  title: 'Medical Emergency',
                  subtitle: '108 (Ambulance)',
                  icon: Icons.medical_services_outlined,
                  iconColor: Colors.red.shade400,
                  number: '108',
                ),
                
                const SizedBox(height: 40),
                
                const Text(
                  'WILDLIFE GUIDELINES',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white54,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildGuideline(
                  icon: Icons.directions_walk_rounded,
                  title: 'Avoid late-night walks',
                  desc: 'Leopards and other apex predators are most active between dusk and dawn. Avoid walking alone near forest buffer zones during these hours.',
                ),
                _buildGuideline(
                  icon: Icons.pets_rounded,
                  title: 'Protect your pets',
                  desc: 'Stray dogs and free-roaming pets attract predators. Keep pets securely indoors at night.',
                ),
                _buildGuideline(
                  icon: Icons.delete_outline_rounded,
                  title: 'Manage garbage properly',
                  desc: 'Open garbage dumps attract wild boars and dogs, which in turn attract leopards. Keep your surroundings clean.',
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Premium Emergency Contact Card
  Widget _buildEmergencyCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color iconColor, 
    required String number
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00150F).withOpacity(0.6), // Dark teal/slate background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withOpacity(0.3)),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ]
          ),
          child: IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.tealAccent, size: 28),
            onPressed: () => _callHelpline(number),
          ),
        ),
        onTap: () => _callHelpline(number),
      ),
    );
  }

  // Premium Guideline Card
  Widget _buildGuideline({required IconData icon, required String title, required String desc}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00150F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.tealAccent.shade400, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.4, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}