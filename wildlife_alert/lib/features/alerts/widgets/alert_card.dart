import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isCritical = alert['severity'] == 'CRITICAL';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isCritical ? Colors.red.shade100 : Colors.orange.shade100,
          child: Icon(
            Icons.warning_amber_rounded,
            color: isCritical ? Colors.red : Colors.orange,
          ),
        ),
        title: Text(
          alert['species'].toString().toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(alert['location']['area_name'] ?? 'Unknown location'),
            const SizedBox(height: 4),
            Text(
              // Simple date formatting for now
              DateTime.parse(alert['timestamp']).toLocal().toString().split('.')[0], 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to AlertDetailScreen
        },
      ),
    );
  }
}