import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

import 'features/splash/screens/splash_screen.dart';
import 'features/alerts/screens/alert_detail_screen.dart';
import 'core/services/api_service.dart';

// 1. Create a Global Navigation Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'critical_alerts',
    'Critical Wildlife Alerts',
    importance: Importance.max,
  );

  if (!kIsWeb) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  await FirebaseMessaging.instance.requestPermission();
  runApp(const WildlifeApp());
}

class WildlifeApp extends StatefulWidget {
  const WildlifeApp({super.key});
  @override
  State<WildlifeApp> createState() => _WildlifeAppState();
}

class _WildlifeAppState extends State<WildlifeApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationListeners();
  }

  // 2. Unified Navigation Handler
  Future<void> _handleNotificationTap(String? alertId) async {
    if (alertId == null) return;
    
    // Fetch full data using the API Service
    final alertData = await ApiService.fetchAlertById(alertId);
    
    if (alertData != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => AlertDetailScreen(alert: alertData),
        ),
      );
    }
  }

  void _setupNotificationListeners() {
    // A. Handle tap when app is in Foreground via Local Notifications
    if (!kIsWeb) {
      flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            _handleNotificationTap(response.payload);
          }
        },
      );
    }

    // B. Handle Firebase Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (!kIsWeb && notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'critical_alerts',
              'Critical Wildlife Alerts',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: message.data['alert_id'], // Pass the ID to the payload
        );
      }
    });

    // C. Handle tap when app is in Background (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data['alert_id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 3. Attach the key here
      title: 'Wildlife Alerts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(), 
    );
  }
}