import 'package:flutter/material.dart';
import 'dart:convert';

class AlertDetailScreen extends StatelessWidget {
  final Map<String, dynamic> alert;
  
  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isCritical = alert['severity'] == 'CRITICAL';
    final accentColor = isCritical ? Colors.red.shade500 : Colors.orange.shade500;
    
    final rawBase64 = alert['image_base64'];
    
    // --- SANITIZE THE BASE64 STRING ---
    String? cleanBase64;
    if (rawBase64 != null && rawBase64.isNotEmpty) {
      String tempString = rawBase64.contains(',') ? rawBase64.split(',').last : rawBase64;
      cleanBase64 = tempString.replaceAll(RegExp(r'\s+'), '');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E11), // Premium Slate/Black Background
      appBar: AppBar(
        title: Text(
          alert['species'].toString().toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF00251A), // Dark Forest Green
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FULL UNCROPPED IMAGE SECTION ---
            Container(
              width: double.infinity,
              color: Colors.black, // Pure black background for any letterboxing
              // We removed the fixed height and changed to BoxFit.contain
              child: (cleanBase64 != null && cleanBase64.isNotEmpty)
                  ? Image.memory(
                      base64Decode(cleanBase64),
                      width: double.infinity,
                      fit: BoxFit.contain, // Guarantees the entire frame and bounding boxes are visible
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Image decode error: $error');
                        return _buildImagePlaceholder();
                      },
                    )
                  : _buildImagePlaceholder(),
            ),
            
            // --- CONTENT SECTION ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Severity Badge (Moved below the image so it doesn't block the view)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCritical ? Icons.warning_rounded : Icons.error_outline_rounded,
                          color: accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          alert['severity'].toString().toUpperCase(),
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Meta Data Card (Location & Time)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00150F), // Very dark teal
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.tealAccent.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        // Location Data
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.my_location_rounded, color: Colors.tealAccent.shade400, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DETECTED LOCATION',
                                    style: TextStyle(fontSize: 12, color: Colors.tealAccent.withOpacity(0.5), letterSpacing: 1.0, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert['location']['area_name'] ?? 'Unknown Location',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: Colors.white12, height: 1),
                        ),
                        // Timestamp
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.access_time_filled_rounded, color: Colors.tealAccent.withOpacity(0.5), size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TIME OF DETECTION',
                                    style: TextStyle(fontSize: 12, color: Colors.tealAccent.withOpacity(0.5), letterSpacing: 1.0, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert['timestamp'] != null 
                                        ? DateTime.parse(alert['timestamp']).toLocal().toString().split('.')[0]
                                        : 'Unknown time',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Standard Operating Procedures (SOPs)
                  const Text(
                    'STANDARD OPERATING PROCEDURE',
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSOPCard(
                    icon: Icons.shield_rounded,
                    title: 'Stay Indoors',
                    desc: 'Securely lock all doors and windows immediately.',
                  ),
                  _buildSOPCard(
                    icon: Icons.pets_rounded,
                    title: 'Protect Pets',
                    desc: 'Bring small pets inside. Do not leave them unattended.',
                  ),
                  _buildSOPCard(
                    icon: Icons.groups_rounded,
                    title: 'Avoid Area',
                    desc: 'Do not form crowds or approach the sighting location.',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Image Placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: const Color(0xFF00150F), // Dark Teal
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.satellite_alt_rounded, size: 64, color: Colors.tealAccent.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'NO VISUAL DATA',
              style: TextStyle(
                color: Colors.tealAccent.withOpacity(0.3),
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper Widget for SOP Cards
  Widget _buildSOPCard({required IconData icon, required String title, required String desc}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00150F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.05)),
      ),
      child: Row(
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}