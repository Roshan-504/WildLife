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
      appBar: AppBar(
        title: const Text('Safety & Help'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_police, color: Colors.blue),
                title: const Text('Forest Department Helpline'),
                subtitle: const Text('1926 (Toll-Free)'),
                trailing: const Icon(Icons.call, color: Colors.green),
                onTap: () => _callHelpline('1926'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.medical_services, color: Colors.red),
                title: const Text('Medical Emergency'),
                subtitle: const Text('108'),
                trailing: const Icon(Icons.call, color: Colors.green),
                onTap: () => _callHelpline('108'),
              ),
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              'General Wildlife Guidelines',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildGuideline(
              icon: Icons.directions_walk,
              title: 'Avoid late-night walks',
              desc: 'Leopards and other apex predators are most active between dusk and dawn. Avoid walking alone near forest buffer zones during these hours.',
            ),
            _buildGuideline(
              icon: Icons.pets,
              title: 'Protect your pets',
              desc: 'Stray dogs and free-roaming pets attract predators. Keep pets securely indoors at night.',
            ),
            _buildGuideline(
              icon: Icons.delete_outline,
              title: 'Manage garbage properly',
              desc: 'Open garbage dumps attract wild boars and dogs, which in turn attract leopards. Keep your surroundings clean.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}