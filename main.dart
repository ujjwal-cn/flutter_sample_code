import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go4sheq/bloc/bloc.dart';
import 'package:go4sheq/firebase_options.dart';
import 'package:go4sheq/util/helper_notification.dart';
import 'package:go4sheq/l10n/l10n.dart';
import 'package:go4sheq/util/app_constant.dart';
import 'package:go4sheq/util/app_util.dart';
import 'package:go4sheq/view/home/screen_home.dart';
import 'package:go4sheq/view/login/screen_login.dart';
import 'package:go4sheq/view/splash/screen_splash.dart';
import 'package:go4sheq/view/task/screen_task_list.dart';

// Handle background notification
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppUtil.log('Got a message whilst in the background!');
  AppUtil.log('Message data: ${message.data}');

  if (message.notification != null) {
    AppUtil.log('Message also contained a notification: ${message.notification}');
    await DBProvider.db.insertNotification(NotificationDetails(
      title: message.notification?.title,
      body: message.notification?.body,
      date: DateTime.now(),
    ));
  }
}

// Starting the app from here
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await HelperNotification.initialize();

  runApp(
    MultiProvider(
      // Initialize Providers
      providers: [
        ChangeNotifierProvider(create: (_) => AppBloc()),
        ChangeNotifierProvider(create: (_) => LanguageBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go4SHEQ',
      // Set theme
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        primaryColor: kColorBlueDeep,
        brightness: Brightness.light,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      // Set multi-language
      locale: context.watch<LanguageBloc>().locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Set initial screen
      home: const ScreenSplash(),
      // Define routes
      routes: {
        ScreenSplash.id: (context) => const ScreenSplash(),
        ScreenHome.id: (context) => const ScreenHome(),
        ScreenLogin.id: (context) => const ScreenLogin(),
        ScreenTaskList.id: (context) => const ScreenTaskList(),
      },
    );
  }
}
