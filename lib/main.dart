import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

/// 🔥 REQUIRED for background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("🔴 Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Waiting for message...";
  String image = "assets/images/default.png";

  @override
  void initState() {
    super.initState();

    // 🔐 Request permission (important for Android 13+ & iOS)
    FirebaseMessaging.instance.requestPermission();

    // 📱 Get FCM Token
    FirebaseMessaging.instance.getToken().then((token) {
      print("🔥 FCM TOKEN: $token");
    });

    /// 🟢 FOREGROUND (app open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🟢 Foreground message received");

      updateUI(message, "Foreground message");
    });

    /// 🟡 BACKGROUND (user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🟡 Opened from background");

      updateUI(message, "Opened from notification");
    });

    /// 🔴 TERMINATED (app was closed)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("🔴 App launched from notification");

        updateUI(message, "App launched from notification");
      }
    });
  }

  /// 🔄 Central UI update function
  void updateUI(RemoteMessage message, String fallbackText) {
    final assetName = message.data['asset'] ?? 'default';

    // Prevent crashes if wrong asset sent
    final allowed = {'default', 'promo'};

    setState(() {
      text = message.notification?.title ?? fallbackText;
      image = allowed.contains(assetName)
          ? "assets/images/$assetName.png"
          : "assets/images/default.png";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Task Manager FCM"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Image.asset(
                image,
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}