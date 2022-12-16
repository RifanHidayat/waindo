// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:siscom_operasional/controller/init_controller.dart';
// import 'package:siscom_operasional/controller/kontrol_controller.dart';
// import 'package:siscom_operasional/fireabase_option.dart';
// import 'package:siscom_operasional/model/notification_model.dart';
// import 'package:siscom_operasional/screen/absen/izin.dart';
// import 'package:siscom_operasional/screen/init_screen.dart';
// import 'package:siscom_operasional/screen/pesan/pesan.dart';
// import 'package:siscom_operasional/utils/api.dart';
// import 'package:siscom_operasional/utils/constans.dart';
// import 'package:siscom_operasional/utils/local_storage.dart';
// import 'package:siscom_operasional/utils/widget_textButton.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'dart:io';

// import 'utils/app_data.dart';

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   LocalStorage.prefs = await SharedPreferences.getInstance();

//   if (Platform.isIOS) {
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.ios);
//   } else {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.android,
//     );
//   }

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   setupInteractedMessage();
//   // AppData.clearAllData();
//   runApp(const MyApp());
// }

// Future showNotification(message) async {
//   RemoteNotification notification = message.notification;
//   AndroidNotification android = message.notification?.android;

//   flutterLocalNotificationsPlugin.show(
//       0,
//       notification.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//             DateTime.now().millisecondsSinceEpoch.toString(), "",
//             playSound: true,
//             priority: Priority.high,
//             importance: Importance.high,
//             icon: '@mipmap/ic_launcher'

//             // TODO add a proper drawable resource to android, for now using
//             //      one that already exists in example app.
//             ),
//       ),
//       payload: "${message}");
// }

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   var info = message.data['body'];
//   // showNotification(message);
//   FlutterRingtonePlayer.playNotification();
//   await Firebase.initializeApp();
// }

// Future<void> setupInteractedMessage() async {
//   flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//   var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
//   var iOS = const IOSInitializationSettings(
//     requestSoundPermission: false,
//     requestBadgePermission: false,
//     requestAlertPermission: false,
//   );
//   var initSetttings = new InitializationSettings(android: android, iOS: iOS);
//   flutterLocalNotificationsPlugin.initialize(initSetttings,
//       onSelectNotification: onSelectNotification);

//   // Get any messages which caused the application to open from
//   // a terminated state.
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();

//   // If the message also contains a data property with a "type" of "chat",
//   // navigate to a chat screen
//   if (initialMessage != null) {
//     _handleMessage(initialMessage);
//   }

//   // Also handle any interaction when the app is in the background via a
//   // Stream listener
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     showNotification(message);
//     FlutterRingtonePlayer.playNotification();
//   });
//   FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
// }

// void _handleMessage(RemoteMessage message) {}

// Future onSelectNotification(var payload) async {
//   Get.offAll(InitScreen());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//         title: 'Aplikasi Operasional Siscom',
//         theme: ThemeData(
//           textTheme: GoogleFonts.poppinsTextTheme(
//             Theme.of(context).textTheme,
//           ),
//         ),
//         localizationsDelegates: [
//           GlobalWidgetsLocalizations.delegate,
//           GlobalMaterialLocalizations.delegate,
//         ],
//         supportedLocales: [
//           Locale('en'),
//         ],
//         debugShowCheckedModeBanner: false,
//         home: SplashScreen());
//   }
// }

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   final controller = Get.put(InitController());

//   @override
//   void initState() {
//     controller.loadDashboard();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: <Widget>[
//           Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             decoration: const BoxDecoration(
//                 image: DecorationImage(
//                     alignment: Alignment.topCenter,
//                     image: AssetImage('assets/Splash.png'),
//                     fit: BoxFit.cover)),
//           ),
//           SizedBox(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: Container(
//                       alignment: Alignment.bottomCenter,
//                       child: Image.asset(
//                         'assets/logo_splash.png',
//                         width: 160,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       alignment: Alignment.bottomCenter,
//                       child: Container(
//                         alignment: Alignment.bottomCenter,
//                         child: Padding(
//                           padding: EdgeInsets.only(bottom: 20),
//                           child: Text(
//                               "© Copyright 2022 PT. Shan Informasi Sistem",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 10)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ))
//         ],
//       ),
//     );
//   }
// }

/// Copyright (C) 2018-2022 Jason C.H
///
/// This library is free software; you can redistribute it and/or
/// modify it under the terms of the GNU Lesser General Public
/// License as published by the Free Software Foundation; either
/// version 2.1 of the License, or (at your option) any later version.
///
/// This library is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
/// Lesser General Public License for more details.
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:openvpn_flutter/openvpn_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late OpenVPN engine;
  VpnStatus? status;
  VPNStage? stage;
  bool _granted = false;
  @override
  void initState() {
    engine = OpenVPN(
      onVpnStatusChanged: (data) {
        setState(() {
          status = data;
        });
      },
      onVpnStageChanged: (data, raw) {
        setState(() {
          stage = data;
        });
      },
    );

    engine.initialize(
      groupIdentifier: "group.com.laskarmedia.vpn",
      providerBundleIdentifier:
          "id.laskarmedia.openvpnFlutterExample.VPNExtension",
      localizedDescription: "VPN by Nizwar",
      lastStage: (stage) {
        setState(() {
          this.stage = stage;
        });
      },
      lastStatus: (status) {
        setState(() {
          this.status = status;
        });
      },
    );
    super.initState();
  }

  Future<void> initPlatformState() async {
    engine.connect(config, "IND",
        username: defaultVpnUsername,
        password: defaultVpnPassword,
        certIsRequired: true);
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(stage?.toString() ?? VPNStage.disconnected.toString()),
              Text(status?.toJson().toString() ?? ""),
              TextButton(
                child: const Text("Start"),
                onPressed: () {
                  initPlatformState();
                },
              ),
              TextButton(
                child: const Text("STOP"),
                onPressed: () {
                  engine.disconnect();
                },
              ),
              if (Platform.isAndroid)
                TextButton(
                  child: Text(_granted ? "Granted" : "Request Permission"),
                  onPressed: () {
                    engine.requestPermissionAndroid().then((value) {
                      setState(() {
                        _granted = value;
                      });
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

const String defaultVpnUsername = "vendor_scm";
const String defaultVpnPassword = "vendorw1k4@2020";

String config = "103.25.196.250:4433";
