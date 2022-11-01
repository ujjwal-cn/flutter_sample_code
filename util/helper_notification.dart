import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go4sheq/util/app_util.dart';

class HelperNotification {
  static Future<void> initialize() async {
    /// Flutter Local Notifications
    /// https://pub.dev/packages/flutter_local_notifications
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(/*onDidReceiveLocalNotification: onDidReceiveLocalNotification*/);
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin, linux: initializationSettingsLinux);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);

    /// Firebase Cloud Messaging
    /// https://firebase.flutter.dev/docs/messaging/usage
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppUtil.log('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppUtil.log('Got a message whilst in the foreground!');
      AppUtil.log('Message data: ${message.data}');

      if (message.notification != null) {
        AppUtil.log('Message also contained a notification: ${message.notification}');
        _showNotification(message, flutterLocalNotificationsPlugin);
      }
    });

    // Subscribe to topic on each app start-up
    // await FirebaseMessaging.instance.subscribeToTopic('weather');
    // Unsubscribing from topics
    // await FirebaseMessaging.instance.unsubscribeFromTopic('weather');
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      AppUtil.log('Notification payload: $payload');
    }
    // await Navigator.push(context, MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)));
  }

  static Future<void> _showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      message.notification?.title ?? '',
      message.notification?.body ?? '',
    );
    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await fln.show(0, message.notification?.title ?? '', message.notification?.body ?? '', notificationDetails, payload: '${message.data}');
    // await DBProvider.db.insertNotification(model_notification_details.NotificationDetails(
    //   title: message.notification?.title,
    //   body: message.notification?.body,
    //   date: DateTime.now(),
    // ));
  }
}
