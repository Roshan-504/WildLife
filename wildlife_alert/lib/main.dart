import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/alerts/screens/alert_detail_screen.dart';
import 'core/services/api_service.dart';

// ============================================================
// GLOBAL NAVIGATION
// ============================================================

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

// ============================================================
// LOCAL NOTIFICATIONS
// ============================================================

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Android notification channel
const AndroidNotificationChannel wildlifeAlertChannel =
    AndroidNotificationChannel(
  'critical_alerts',
  'Critical Wildlife Alerts',
  description: 'Notifications for wildlife alerts in your area.',
  importance: Importance.max,
);

// ============================================================
// FIREBASE BACKGROUND MESSAGE HANDLER
// ============================================================

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  // Firebase must be initialized inside the background isolate.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    '[FCM BACKGROUND] Message received: ${message.messageId}',
  );
}

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ----------------------------------------------------------
  // 1. Initialize Firebase
  // ----------------------------------------------------------

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ----------------------------------------------------------
  // 2. Register Firebase background message handler
  // ----------------------------------------------------------

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // ----------------------------------------------------------
  // 3. Initialize Local Notifications
  // ----------------------------------------------------------

  if (!kIsWeb) {
    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ),
      ),
      onDidReceiveNotificationResponse:
          (NotificationResponse response) {
        final String? alertId = response.payload;

        debugPrint(
          '[LOCAL NOTIFICATION TAP] alertId: $alertId',
        );

        if (alertId != null && alertId.isNotEmpty) {
          _handleNotificationTap(alertId);
        }
      },
    );

    // --------------------------------------------------------
    // 4. Create Android notification channel
    // --------------------------------------------------------

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          wildlifeAlertChannel,
        );
  }

  // ----------------------------------------------------------
  // 5. Request notification permission
  // ----------------------------------------------------------

  final NotificationSettings notificationSettings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  debugPrint(
    '[FCM] Permission status: '
    '${notificationSettings.authorizationStatus}',
  );

  // ----------------------------------------------------------
  // 6. Start Flutter application
  // ----------------------------------------------------------

  runApp(const WildlifeApp());
}

// ============================================================
// NOTIFICATION TAP HANDLER
// ============================================================

Future<void> _handleNotificationTap(String alertId) async {
  debugPrint(
    '[NOTIFICATION TAP] Fetching alert: $alertId',
  );

  try {
    // Fetch complete alert information from backend.
    final alertData =
        await ApiService.fetchAlertById(alertId);

    if (alertData == null) {
      debugPrint(
        '[NOTIFICATION TAP] Alert not found: $alertId',
      );
      return;
    }

    // Make sure navigator is available.
    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      debugPrint(
        '[NOTIFICATION TAP] Navigator is not ready.',
      );
      return;
    }

    // Navigate to alert details.
    navigator.push(
      MaterialPageRoute(
        builder: (context) => AlertDetailScreen(
          alert: alertData,
        ),
      ),
    );
  } catch (e) {
    debugPrint(
      '[NOTIFICATION TAP] Error: $e',
    );
  }
}

// ============================================================
// WILDLIFE APP
// ============================================================

class WildlifeApp extends StatefulWidget {
  const WildlifeApp({super.key});

  @override
  State<WildlifeApp> createState() => _WildlifeAppState();
}

// ============================================================
// APP STATE
// ============================================================

class _WildlifeAppState extends State<WildlifeApp> {
  @override
  void initState() {
    super.initState();

    // Register notification listeners after the app starts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationListeners();
    });

    // Check if app was launched by tapping a notification
    // while the application was completely terminated.
    _checkInitialNotification();
  }

  // ==========================================================
  // NOTIFICATION LISTENERS
  // ==========================================================

  void _setupNotificationListeners() {
    // --------------------------------------------------------
    // A. Firebase foreground message
    // --------------------------------------------------------

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        debugPrint(
          '[FCM FOREGROUND] Message received',
        );

        debugPrint(
          '[FCM FOREGROUND] Data: ${message.data}',
        );

        final RemoteNotification? notification =
            message.notification;

        final AndroidNotification? android =
            message.notification?.android;

        // Show local notification on Android when app
        // is currently in the foreground.
        if (!kIsWeb &&
            notification != null &&
            android != null) {
          final String? alertId =
              message.data['alert_id']?.toString();

          flutterLocalNotificationsPlugin.show(
            id: notification.hashCode,
            title: notification.title ??
                'Wildlife Alert',
            body: notification.body ??
                'Wildlife detected near your area.',
            notificationDetails:
                const NotificationDetails(
              android: AndroidNotificationDetails(
                'critical_alerts',
                'Critical Wildlife Alerts',
                channelDescription:
                    'Notifications for wildlife alerts in your area.',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
              ),
            ),
            payload: alertId,
          );

          debugPrint(
            '[LOCAL NOTIFICATION] '
            'Displayed. alertId: $alertId',
          );
        }
      },
    );

    // --------------------------------------------------------
    // B. App opened from background notification
    // --------------------------------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint(
          '[FCM BACKGROUND TAP] '
          '${message.data}',
        );

        final String? alertId =
            message.data['alert_id']?.toString();

        if (alertId != null && alertId.isNotEmpty) {
          _handleNotificationTap(alertId);
        }
      },
    );

    // --------------------------------------------------------
    // C. Listen for token refresh
    // --------------------------------------------------------

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (String token) {
        debugPrint(
          '[FCM] Token refreshed:',
        );

        debugPrint(token);

        // Later:
        // Send this token to your Node.js backend.
      },
    );
  }

  // ==========================================================
  // CHECK TERMINATED-APP NOTIFICATION
  // ==========================================================

  Future<void> _checkInitialNotification() async {
    final RemoteMessage? message =
        await FirebaseMessaging.instance
            .getInitialMessage();

    if (message == null) {
      return;
    }

    debugPrint(
      '[FCM INITIAL] App opened from notification',
    );

    debugPrint(
      '[FCM INITIAL] Data: ${message.data}',
    );

    final String? alertId =
        message.data['alert_id']?.toString();

    if (alertId == null || alertId.isEmpty) {
      return;
    }

    // Wait until the first frame has rendered before navigating.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(alertId);
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Global navigation key.
      navigatorKey: navigatorKey,

      title: 'Wildlife Alerts',

      debugShowCheckedModeBanner: false,

      // ------------------------------------------------------
      // Temporary theme
      // We'll move this to core/theme.dart later.
      // ------------------------------------------------------

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),

        useMaterial3: true,

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // ------------------------------------------------------
      // Initial screen
      // ------------------------------------------------------

      home: const SplashScreen(),
    );
  }
}