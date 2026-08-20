import 'package:flutter/material.dart';
import '../screens/alert_detail_screen.dart'; 

class AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isCritical = alert['severity'] == 'CRITICAL';
    
    // Retaining the red/orange danger colors for severity
    final accentColor = isCritical ? Colors.red.shade500 : Colors.orange.shade500;
    final iconBgColor = isCritical ? Colors.red.withOpacity(0.15) : Colors.orange.withOpacity(0.15);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00150F).withOpacity(0.6), // Very dark teal/slate background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Ensures the left accent strip clips to the border radius
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlertDetailScreen(alert: alert),
              ),
            );
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Left Accent Strip indicating severity
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.5),
                        blurRadius: 6,
                      )
                    ]
                  ),
                ),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Stylized Icon Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor.withOpacity(0.3)),
                          ),
                          child: Icon(
                            isCritical ? Icons.warning_rounded : Icons.error_outline_rounded,
                            color: accentColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Text Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                alert['species'].toString().toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              
                              // Location Row
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: Colors.tealAccent.withOpacity(0.7)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      alert['location']['area_name'] ?? 'Unknown location',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8), 
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              
                              // Timestamp Row
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withOpacity(0.4)),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateTime.parse(alert['timestamp']).toLocal().toString().split('.')[0], 
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5), 
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Trailing Icon
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.tealAccent.withOpacity(0.3),
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}