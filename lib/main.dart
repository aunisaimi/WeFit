import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/screen/Theme/theme_provider.dart';
import 'package:diet_app/screen/main_tab/main_tab_view.dart';
import 'package:diet_app/screen/on_boarding/started_view.dart';

import 'package:diet_app/firebase_options.dart';  // Adjust the import path as necessary

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('logo');
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'workout_channel', // id
    'Workout Notifications', // name
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // runApp(
  //   ChangeNotifierProvider(
  //     create: (context) => ThemeProvider(),
  //     child: MyApp(),
  //   ),
  // );
  runApp(
    MultiProvider(providers: [
      // theme
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      // database provider
      ChangeNotifierProvider(create: (context) => DatabaseProvider()),
    ],
     child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email != null) {
      // user has previously logged in, show the main screen
      return const MainTabView();
    } else {
      // user not logged in
      return const StartedView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return MaterialApp(
            title: 'Fitness with Me',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              primaryColor: TColor.primaryColor1,
              fontFamily: "Poppins",
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primaryColor: TColor.primaryColor1,
              fontFamily: "Poppins",
              brightness: Brightness.dark,
            ),
            home: snapshot.data,
            //onGenerateRoute: Routes.onGenerateRoute,
          );
        }
      },
    );
  }
}

// test
Future<void> scheduleNotification(String name, DateTime date) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'workout_channel',
    'Workout Notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Workout Reminder',
    '$name at ${DateFormat('h:mm aa').format(date)}',
    tz.TZDateTime.from(date, tz.local), // Convert to local time zone
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
