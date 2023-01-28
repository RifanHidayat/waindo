// ignore_for_file: deprecated_member_use

import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/berhasil_controller.dart';
import 'package:siscom_operasional/controller/onboard_controller.dart';

import 'package:siscom_operasional/utils/app_data.dart';

import 'package:siscom_operasional/utils/constans.dart';


// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'SISCOM HRIS',
      notificationText: 'Running...',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class Onboard extends StatelessWidget {
  final controller = Get.put(OnboardController());
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ReceivePort? _receivePort;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  Future<void> setupInteractedMessage() async {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = const IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    var initSetttings = new InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(
      initSetttings,
    );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  Location location = new Location();
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          // backgroundColor: Color(0xff001767),
        ),
        // buttons: [
        //   const Notific  ationButton(id: 'sendButton', text: 'Send'),
        //   const NotificationButton(id: 'testButton', text: 'Test'),
        // ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: true,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // interval: 1800000,
        // interval: widget.dataBerhasil![3],
        interval: 10000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) async {
        var now = DateTime.now();
        var getJam = DateFormat('HH:mm:ss').format(now);
        var tanggal = DateFormat('yyyy-MM-dd').format(now);
        print("$getJam");
        print("${AppData.informasiUser![0].em_id}");

        print("location");
        location.enableBackgroundMode(enable: true);
        print("enabled  background mode");
        _userLocation = await location.getLocation();

        print(
            'lat ${_userLocation!.latitude} long ${_userLocation!.longitude}');

        Future<bool> kirimProses = controllerBerhasil.getPosisition(
            AppData.informasiUser![0].em_id,
            getJam,
            tanggal,
            _userLocation!.latitude,
            _userLocation!.longitude);

        bool hasil = await kirimProses;
        if (hasil == true) {
          if (message is int) {
            print('eventCount: $message');
          } else if (message is String) {
            if (message == 'onNotificationPressed') {
              Navigator.of(Get.context!).pushNamed('/resume-route');
            }
          } else if (message is DateTime) {
            print('timestamp: ${message.toString()}');
          }
        } else {
          print("gagal kirim");
        }
      });

      return true;
    }

    return false;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  T? _ambiguate<T>(T? value) => value;

  var controllerAbsensi = Get.put(AbsenController());
  var controllerBerhasil = Get.put(BerhasilController());

  @override
  Widget build(BuildContext context) {
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/Splash.png'),
                    fit: BoxFit.cover)),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 15,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Center(
                        child:
                            Image.asset('assets/logo_splash.png', width: 150),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: !controller.deviceStatus.value ? 58 : 63,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Image.asset(
                        'assets/img_after_splash.png',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: !controller.deviceStatus.value ? 27 : 22,
                    child: Container(
                      width: MediaQuery.of(Get.context!).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Selamat Datang",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                "di SISCOM HRIS 👋  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "SISCOM HRIS memberikan solusi untuk proses HR online di Perusahaan Anda. ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Constanst.colorText2,
                                        fontSize: 12),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "Kini, semua kebutuhan HR dapat terintegrasi dalam satu aplikasi dengan data yang akurat dan real time.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Constanst.colorText2,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
      bottomNavigationBar: Obx(
        () => Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Constanst.colorPrimary),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ))),
                onPressed: () async {
                  controller.validasiToNextRoute();

                  String checkUserKontrol =
                      await controllerBerhasil.checkUserKontrol();
                  print(checkUserKontrol);

                  if (1 == 1) {
                    if (checkUserKontrol == 0) {
                      _startForegroundTask();
                      AbsenController().removeAll();
                      // Get.offAll(InitScreen());
                    } else {
                      AbsenController().removeAll();
                      // Get.offAll(InitScreen());
                    }
                  } else {
                    if (checkUserKontrol != '0') {
                      _stopForegroundTask();
                      Location location = new Location();
                      location.enableBackgroundMode(enable: false);
                      AbsenController().removeAll();
                      // Get.offAll(InitScreen());
                    } else {
                      AbsenController().removeAll();
                      // Get.offAll(InitScreen());
                    }
                  }
                  // print("tes");
                  // try {
                  //   const NotificationDetails platformChannelSpecifics =
                  //       NotificationDetails(
                  //           iOS: IOSNotificationDetails(
                  //     presentAlert:
                  //         true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
                  //     presentBadge:
                  //         true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
                  //     presentSound:
                  //         true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
                  //     // Specifics the file path to play (only from iOS 10 onwards)
                  //     badgeNumber: 1, // The application's icon badge number

                  //     subtitle:
                  //         "ios", //Secondary description  (only from iOS 10 onwards)
                  //   ));

                  //   await flutterLocalNotificationsPlugin.show(
                  //       12345,
                  //       "A Notification From My Application",
                  //       "This notification was sent using Flutter Local Notifcations Package",
                  //       platformChannelSpecifics,
                  //       payload: 'data');
                  // } catch (e) {
                  //   print(e);
                  // }
                },
                child: !controller.loading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              "Ayo Mulai",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              )),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 16),
                            child: Text(
                              "Tunggu Sebentar...",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ))),
      ),
    );
  }
}



// ignore_for_file: deprecated_member_use
// import 'dart:isolate';

// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:siscom_operasional/controller/onboard_controller.dart';
// import 'package:siscom_operasional/utils/api.dart';
// import 'package:siscom_operasional/utils/appbar_widget.dart';
// import 'package:siscom_operasional/utils/constans.dart';
// import 'package:siscom_operasional/utils/widget_textButton.dart';
// import 'package:siscom_operasional/utils/widget_utils.dart';
// // The callback function should always be a top-level function.
// @pragma('vm:entry-point')
// void startCallback() {
//   // The setTaskHandler function must be called to handle the task in the background.
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }

// class MyTaskHandler extends TaskHandler {
//   SendPort? _sendPort;
//   int _eventCount = 0;

//   @override
//   Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
//     _sendPort = sendPort;
//     // You can use the getData function to get the stored data.
//     final customData =
//         await FlutterForegroundTask.getData<String>(key: 'customData');
//     print('customData: $customData');
//   }

//   @override
//   Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
//     FlutterForegroundTask.updateService(
//       notificationTitle: 'SISCOM HRIS',
//       notificationText: 'Running...',
//     );

//     // Send data to the main isolate.
//     sendPort?.send(_eventCount);

//     _eventCount++;
//   }

//   @override
//   Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
//     // You can use the clearAllData function to clear all the stored data.
//     await FlutterForegroundTask.clearAllData();
//   }

//   @override
//   void onButtonPressed(String id) {
//     // Called when the notification button on the Android platform is pressed.
//     print('onButtonPressed >> $id');
//   }

//   @override
//   void onNotificationPressed() {
//     // Called when the notification itself on the Android platform is pressed.
//     //
//     // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
//     // this function to be called.

//     // Note that the app will only route to "/resume-route" when it is exited so
//     // it will usually be necessary to send a message through the send port to
//     // signal it to restore state when the app is already started.
//     FlutterForegroundTask.launchApp("/resume-route");
//     _sendPort?.send('onNotificationPressed');
//   }
// }

// class Onboard extends StatefulWidget {
//   const Onboard({super.key});

//   @override
//   State<Onboard> createState() => _OnboardState();
// }

// class _OnboardState extends State<Onboard> {
//    final controller = Get.put(OnboardController());
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> setupInteractedMessage() async {
//     flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//     var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iOS = const IOSInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//     );
//     var initSetttings = new InitializationSettings(android: android, iOS: iOS);
//     flutterLocalNotificationsPlugin.initialize(
//       initSetttings,
//     );
//   }

//   void onDidReceiveLocalNotification(
//       int id, String? title, String? body, String? payload) {
//     print('id $id');
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
//             decoration: BoxDecoration(
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
//                     flex: 15,
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 25),
//                       child: Center(
//                         child:
//                             Image.asset('assets/logo_splash.png', width: 150),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: !controller.deviceStatus.value ? 58 : 63,
//                     child: Container(
//                       alignment: Alignment.center,
//                       margin: EdgeInsets.only(left: 20, right: 20),
//                       child: Image.asset(
//                         'assets/img_after_splash.png',
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: !controller.deviceStatus.value ? 27 : 22,
//                     child: Container(
//                       width: MediaQuery.of(Get.context!).size.width,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(30),
//                           topRight: Radius.circular(30),
//                         ),
//                       ),
//                       child: SingleChildScrollView(
//                         physics: BouncingScrollPhysics(),
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: 8,
//                             ),
//                             Text(
//                               "Selamat Datang",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 24),
//                             ),
//                             SizedBox(
//                               height: 8,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 20),
//                               child: Text(
//                                 "di SISCOM HRIS 👋  ",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 24),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 16,
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16, right: 16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "SISCOM HRIS memberikan solusi untuk proses HR online di Perusahaan Anda. ",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         color: Constanst.colorText2,
//                                         fontSize: 12),
//                                   ),
//                                   SizedBox(
//                                     height: 8,
//                                   ),
//                                   Text(
//                                     "Kini, semua kebutuhan HR dapat terintegrasi dalam satu aplikasi dengan data yang akurat dan real time.",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         color: Constanst.colorText2,
//                                         fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height: 16,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ))
//         ],
//       ),
//       bottomNavigationBar: Obx(
//         () => Padding(
//             padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
//             child: TextButton(
//                 style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all<Color>(
//                         Constanst.colorPrimary),
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ))),
//                 onPressed: () async {
//                   controller.validasiToNextRoute();
//                   // print("tes");
//                   // try {
//                   //   const NotificationDetails platformChannelSpecifics =
//                   //       NotificationDetails(
//                   //           iOS: IOSNotificationDetails(
//                   //     presentAlert:
//                   //         true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
//                   //     presentBadge:
//                   //         true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
//                   //     presentSound:
//                   //         true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
//                   //     // Specifics the file path to play (only from iOS 10 onwards)
//                   //     badgeNumber: 1, // The application's icon badge number

//                   //     subtitle:
//                   //         "ios", //Secondary description  (only from iOS 10 onwards)
//                   //   ));

//                   //   await flutterLocalNotificationsPlugin.show(
//                   //       12345,
//                   //       "A Notification From My Application",
//                   //       "This notification was sent using Flutter Local Notifcations Package",
//                   //       platformChannelSpecifics,
//                   //       payload: 'data');
//                   // } catch (e) {
//                   //   print(e);
//                   // }
//                 },
//                 child: !controller.loading.value
//                     ? Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8, bottom: 8),
//                             child: Text(
//                               "Ayo Mulai",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.only(left: 10),
//                             child: Icon(
//                               Icons.arrow_forward,
//                               color: Colors.white,
//                             ),
//                           )
//                         ],
//                       )
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 3,
//                                 color: Colors.white,
//                               )),
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 top: 8, bottom: 8, left: 16),
//                             child: Text(
//                               "Tunggu Sebentar...",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           )
//                         ],
//                       ))),
//       ),
//     );
//   }
 
// }