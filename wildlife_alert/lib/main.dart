import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; // Gives us access to kIsWeb

// Import your splash screen based on the new folder structure
import 'features/splash/screens/splash_screen.dart';

// 1. Initialize local notifications for foreground alerts
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// 2. Background message handler (Must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Background message received: ${message.messageId}");
}

void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using the CLI-generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register the background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Configure Android notification channel for maximum priority (heads-up banner + sound)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'critical_alerts', // id
    'Critical Wildlife Alerts', // name
    description: 'Bypasses silent mode for critical apex predators.', 
    importance: Importance.max,
  );

  if (!kIsWeb) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  // Request user permissions for notifications (Crucial for iOS and Android 13+)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Run the app
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

    // 4. Listen for foreground messages and trigger a local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (!kIsWeb && notification != null && android != null) {
        
        print("FCM Message Received in Foreground: ${notification.title}");
        
        // UNCOMMENT THIS WHEN RUNNING ON ANDROID/SCRCPY
        /*
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
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
        */
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wildlife Alerts',
      debugShowCheckedModeBanner: false, // Cleaner look for production
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      // App starts at the Splash Screen to handle auth & routing logic
      home: const SplashScreen(), 
    );
  }
}