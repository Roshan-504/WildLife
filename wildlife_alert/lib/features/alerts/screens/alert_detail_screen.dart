import 'package:flutter/material.dart';
import 'dart:convert'; // Required for base64Decode

class AlertDetailScreen extends StatelessWidget {
  final Map<String, dynamic> alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isCritical = alert['severity'] == 'CRITICAL';
    final base64String = alert['image_base64'];

    return Scaffold(
      appBar: AppBar(
        title: Text(alert['species'].toString().toUpperCase()),
        backgroundColor: isCritical ? Colors.red.shade700 : Colors.orange.shade700,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Base64 Image Renderer
            if (base64String != null && base64String.isNotEmpty)
              Image.memory(
                base64Decode(base64String),
                height: 250,
                fit: BoxFit.cover,
                // Fallback if the base64 string is corrupted
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Data
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert['location']['area_name'] ?? 'Unknown Location',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Timestamp
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        alert['timestamp'] != null 
                            ? DateTime.parse(alert['timestamp']).toLocal().toString().split('.')[0]
                            : 'Unknown time',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 40, thickness: 1),

                  // Standard Operating Procedures (SOPs)
                  const Text(
                    'Standard Operating Procedure',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const ListTile(
                    leading: Icon(Icons.home, color: Colors.black54),
                    title: Text('Stay indoors and securely lock all doors and windows.'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const ListTile(
                    leading: Icon(Icons.pets, color: Colors.black54),
                    title: Text('Bring small pets inside immediately.'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const ListTile(
                    leading: Icon(Icons.groups, color: Colors.black54),
                    title: Text('Do not form crowds or approach the sighting area.'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}