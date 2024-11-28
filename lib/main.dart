import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:top_sale/core/preferences/preferences.dart';
import 'package:top_sale/injector.dart' as injector;
import 'app.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'app_bloc_observer.dart';
import 'package:timezone/timezone.dart' as tz;
import 'core/utils/restart_app_class.dart';
/// flutter local notification
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize time zones before using tz.local
  tz_data.initializeTimeZones();
  await EasyLocalization.ensureInitialized();
  await injector.setup();
  Bloc.observer = AppBlocObserver();
  // don't forget to add the app icon image to "android\app\src\main\res\drawable\app_icon.png"
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) async {
      print('Notification clicked: ${details.payload}');
    },
  );

  if (Platform.isAndroid) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
  if (Platform.isIOS) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  scheduleDailyTenAMNotification();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar', ''), Locale('en', '')],
      path: 'assets/lang',
      saveLocale: true,
      startLocale: const Locale('ar', ''),
      fallbackLocale: const Locale('ar', ''),
      child: HotRestartController(child: const MyApp()),
    ),
  );
}

int id = 0;

Future<void> showNotification(
    {required String body, title, String? payload}) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('your channel id', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'app_icon',
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin
      .show(id++, title, body, notificationDetails, payload: payload);
}

Future<void> scheduleDailyTenAMNotification() async {
  print("rrrrrrrrrr localll");
  print("rrrrrrrrrr ${tz.TZDateTime.now(tz.local).toString()}");

  Preferences.instance.getNewTasks().then((value) async {
    if (value.tasks != null) {
      for (int i = 0; i < value.tasks!.length; i++) {
        // If the task has a valid deadline, parse the date and extract the day
        DateTime taskDeadline =
            DateTime.parse(value.tasks![i].deadline ?? '2024-11-27');
        int day = taskDeadline.day; // Extract the day from the task's deadline
        int month = taskDeadline.month;
        int year =
            taskDeadline.year; // Extract the month from the task's deadline
        await flutterLocalNotificationsPlugin.zonedSchedule(
          i, // Use the index as the unique ID
          'هناك مهمة جديدة',
          '${value.tasks![i].taskName}',
          _nextInstanceOfTenAM(year, month, day),
          const NotificationDetails(
            android: AndroidNotificationDetails('daily notification channel id',
                'daily notification channel name',
                channelDescription: 'daily notification description'),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  });
}
Future<void> scheduleOrdersNotification() async {
  print("rrrrrrrrrr localll");
  print("rrrrrrrrrr ${tz.TZDateTime.now(tz.local).toString()}");

  Preferences.instance.getAllOrders().then((value) async {
    if (value.result != null) {
      for (int i = 0; i < value.result!.length; i++) {
        // if (value.result![i].state.toString() == 'draft'){

        // If the task has a valid deadline, parse the date and extract the day, month, year, and time
        DateTime taskDeadline = DateTime.parse(value.result![i].expectedDate.toString() != "false" ? value.result![i].expectedDate.toString(): "2024-11-19");
        // Extract the date components (day, month, year)
        int day = taskDeadline.day;
        int month = taskDeadline.month;
        int year = taskDeadline.year;




        // Schedule the notification at the extracted time
        await flutterLocalNotificationsPlugin.zonedSchedule(
          i, // Use the index as the unique ID
          'هناك طلب جديد',
          '${value.result![i].displayName}',
          _nextOrders(year, month, day), // Schedule the notification at the extracted time
          const NotificationDetails(
            android: AndroidNotificationDetails('daily notification channel id',
                'daily notification channel name',
                channelDescription: 'daily notification description'),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    // }
  }});
}


tz.TZDateTime _nextInstanceOfTenAM(int year, int month, int day) {
  print("get notification ");

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, year, month, day, 6);



  return scheduledDate;
}
tz.TZDateTime _nextOrders(int year, int month, int day) {
  print("get notification ");

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, 2024, 11, 28, 12 ,8);



  return scheduledDate;
}
