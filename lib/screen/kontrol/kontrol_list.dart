import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/kontrol_controller.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() async {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;
  String getEmid = "";

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
      notificationTitle: 'MyTaskHandler',
      notificationText: 'eventCount: $_eventCount',
      // callback: updateCallback,
      // () async {
      //   // var dataUser = AppData.informasiUser;
      //   // var getEmid = dataUser![0].em_id;
      //   // var controller = Get.put(KontrolController());
      //   // controller.getPosisition(getEmid);
      //   Position position = await Geolocator.getCurrentPosition(
      //       desiredAccuracy: LocationAccuracy.high);
      //   try {
      //     List<Placemark> placemarks = await placemarkFromCoordinates(
      //         position.latitude, position.longitude);
      //     Placemark place = placemarks[0];
      //     var latUser = position.latitude;
      //     var langUser = position.longitude;
      //     var alamatUser =
      //         "${placemarks[0].street} ${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}";
      //     var now = DateTime.now();
      //     var getJam = DateFormat('HH:mm:ss').format(now);
      //     var tanggal = DateFormat('yyyy-MM-dd').format(now);
      //     print(getJam);
      //     print(tanggal);
      //     print(latUser);
      //     print(langUser);

      //   } on Exception catch (e) {}
      // }
    );
    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @pragma('vm:entry-point')
  void updateCallback() async {}

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

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const KontrolList(),
        '/resume-route': (context) => const ResumeRoutePage(),
      },
    );
  }
}

class KontrolList extends StatefulWidget {
  const KontrolList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KontrolListState();
}

class _KontrolListState extends State<KontrolList> {
  ReceivePort? _receivePort;

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        // buttons: [
        //   const NotificationButton(id: 'sendButton', text: 'Send'),
        //   const NotificationButton(id: 'testButton', text: 'Test'),
        // ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: true,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 10000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
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
        if (message is int) {
          print('eventCount: $message');

          // try {
          //   List<Placemark> placemarks = await placemarkFromCoordinates(
          //       position.latitude, position.longitude);
          //   Placemark place = placemarks[0];
          //   var latUser = position.latitude;
          //   var langUser = position.longitude;
          //   var alamatUser =
          //       "${placemarks[0].street} ${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}";
          //   var now = DateTime.now();
          //   var getJam = DateFormat('HH:mm:ss').format(now);
          //   var tanggal = DateFormat('yyyy-MM-dd').format(now);
          //   var dataUser = AppData.informasiUser;
          //   var getEmid = dataUser![0].em_id;
          //   var latLangUserKontrol = "$latUser,$langUser";
          //   Map<String, dynamic> body = {
          //     'em_id': getEmid,
          //     'atten_date': tanggal,
          //     'jam': getJam,
          //     'latLangKontrol': latLangUserKontrol,
          //     'alamat': alamatUser,
          //   };
          //   var connect =
          //       Api.connectionApi("post", body, "insert_emp_control_employee");
          //   connect.then((dynamic res) {
          //     var valueBody = jsonDecode(res.body);
          //     print(valueBody);
          //     // loadControlUser();
          //   });
          // } on Exception catch (e) {}
        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            Navigator.of(context).pushNamed('/resume-route');
          }
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        }
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        var now = DateTime.now();
        var getJam = DateFormat('HH:mm:ss').format(now);
        var tanggal = DateFormat('yyyy-MM-dd').format(now);
        print(position.latitude);
        print(position.longitude);
        print(getJam);
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

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A widget that prevents the app from closing when the foreground service is running.
    // This widget must be declared above the [Scaffold] widget.
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Foreground Task'),
          centerTitle: true,
        ),
        body: _buildContentView(),
      ),
    );
  }

  Widget _buildContentView() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        child: Text(text),
        onPressed: onPressed,
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buttonBuilder('start', onPressed: _startForegroundTask),
          buttonBuilder('stop', onPressed: _stopForegroundTask),
        ],
      ),
    );
  }
}

class ResumeRoutePage extends StatelessWidget {
  const ResumeRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Route'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.of(context).pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:ui';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:siscom_operasional/controller/auth_controller.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:siscom_operasional/controller/kontrol_controller.dart';
// import 'package:siscom_operasional/screen/register.dart';
// import 'package:siscom_operasional/services/local_notification_service.dart';
// import 'package:siscom_operasional/utils/app_data.dart';
// import 'package:siscom_operasional/utils/appbar_widget.dart';
// import 'package:siscom_operasional/utils/constans.dart';
// import 'package:siscom_operasional/utils/widget_utils.dart';

// import 'dart:isolate';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class KontrolList extends StatefulWidget {
//   var dataForm;
//   KontrolList({Key? key, this.dataForm}) : super(key: key);
//   @override
//   _KontrolListState createState() => _KontrolListState();
// }

// // class _KontrolListState extends State<KontrolList> with WidgetsBindingObserver {
// class _KontrolListState extends State<KontrolList> {
//   var controller = Get.put(KontrolController());
//   Timer? time;
//   late final LocalNotificationService service;

//   late LocationSettings locationSettings;

//   @override
//   void initState() {
//     controller.onReady();
//     // _initForegroundTask();
//     // startForegroundService();
//     // WidgetsBinding.instance.addObserver(this);
//     // time = Timer.periodic(Duration(seconds: 5), (tm) {
//     //   getPosisition();
//     // });
//     startLokasiKontrol();
//     service = LocalNotificationService();
//     service.intialize();
//     listenToNotification();
//     super.initState();
//   }

//   void listenToNotification() =>
//       service.onNotificationClick.stream.listen(onNoticationListener);

//   void onNoticationListener(String? payload) {
//     if (payload != null && payload.isNotEmpty) {
//       print('qwer $payload');
//       // controller.getPosisition();
//     }
//   }

//   void startLokasiKontrol() {
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       locationSettings = AndroidSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 100,
//           forceLocationManager: true,
//           intervalDuration: const Duration(seconds: 5),
//           //(Optional) Set foreground notification config to keep the app alive
//           //when going to the background
//           foregroundNotificationConfig: const ForegroundNotificationConfig(
//             notificationText:
//                 "Example app will continue to receive your location even when you aren't using it",
//             notificationTitle: "Running in Background",
//             enableWakeLock: true,
//             enableWifiLock: true,
//           ));
//     } else if (defaultTargetPlatform == TargetPlatform.iOS ||
//         defaultTargetPlatform == TargetPlatform.macOS) {
//       locationSettings = AppleSettings(
//         accuracy: LocationAccuracy.high,
//         activityType: ActivityType.fitness,
//         distanceFilter: 100,
//         pauseLocationUpdatesAutomatically: true,
//         // Only set to true if our app will be started up in the background.
//         showBackgroundLocationIndicator: true,
//       );
//     } else {
//       locationSettings = LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 100,
//       );
//     }
//     print("jalan terus");
//     // StreamSubscription<Position> positionStream =
//     //     Geolocator.getPositionStream(locationSettings: locationSettings)
//     //         .listen((Position? position) {
//     //   // String? posisi = '${position!.latitude.toString()}, ${position.longitude.toString()}';

//     //   return position;
//     // });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     // ForegroundService().stop();
//     // WidgetsBinding.instance.removeObserver(this);
//   }

//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   super.didChangeAppLifecycleState(state);
//   // }

//   void getPosisition() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     try {
//       List<Placemark> placemarks =
//           await placemarkFromCoordinates(position.latitude, position.longitude);
//       Placemark place = placemarks[0];
//       var latUser = position.latitude;
//       var langUser = position.longitude;
//       var alamatUser =
//           "${placemarks[0].street} ${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}";
//       controller.jumlahKontrol.value = controller.jumlahKontrol.value + 1;
//       this.controller.jumlahKontrol.refresh();
//       var now = DateTime.now();
//       var getJam = DateFormat('HH:mm').format(now);
//       var tanggal = DateFormat('yyyy-MM-dd').format(now);
//       print(latUser);
//       print(langUser);
//       var dataUser = AppData.informasiUser;
//       var getEmid = dataUser![0].em_id;
//       print("hitung kontrol ${controller.jumlahKontrol.value}");
//       controller.kirimDataKontrol(
//           latUser, langUser, alamatUser, getJam, tanggal, getEmid);
//     } on Exception catch (e) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//           backgroundColor: Constanst.colorPrimary,
//           automaticallyImplyLeading: false,
//           elevation: 2,
//           flexibleSpace: AppbarMenu1(
//             title: "Kontrol",
//             colorTitle: Colors.white,
//             iconShow: false,
//             icon: 2,
//             onTap: () {},
//           )),
//       body: WillPopScope(
//           onWillPop: () async {
//             return false;
//           },
//           child: SafeArea(
//             child: Obx(
//               () => Padding(
//                 padding: const EdgeInsets.only(left: 16, right: 16),
//                 child: !controller.showViewKontrol.value
//                     ? Center(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               "assets/noakses.png",
//                               height: 250,
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Text("Kamu tidak punya akses ke menu ini.")
//                           ],
//                         ),
//                       )
//                     : Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: 16,
//                           ),
//                           linePencarian(),
//                           SizedBox(
//                             height: 8,
//                           ),
//                           pencarianData(),
//                           SizedBox(
//                             height: 16,
//                           ),
//                           Text(
//                             controller.departemen.value.text,
//                             style: TextStyle(fontSize: 14),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           Text(
//                             "${controller.jumlahData.value} Karyawan",
//                             style: TextStyle(
//                                 fontSize: 12, color: Constanst.colorText2),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           // InkWell(
//                           //     onTap: () => controller.loadControlUser(),
//                           //     child: Text("Test kontrol"))

//                           ElevatedButton(
//                             onPressed: () async {
//                               await service.showNotification(
//                                   id: 0,
//                                   title: 'Notification Title',
//                                   body: 'Some body');
//                             },
//                             child: const Text('Show Local Notification'),
//                           ),
//                           // InkWell(
//                           //     onTap: () => ForegroundService().stop(),
//                           //     child: Text("Test kontrol"))

//                           // Flexible(
//                           //   flex: 3,
//                           //   child: Padding(
//                           //     padding: const EdgeInsets.only(left: 16, right: 16),
//                           //     child: pageViewPesan(),
//                           //   ),
//                           // )
//                         ],
//                       ),
//               ),
//             ),
//           )),
//     );
//   }

//   Widget linePencarian() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: formHariDanTanggal(),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: formDepartemen(),
//               ),
//             )
//           ],
//         )
//       ],
//     );
//   }

//   Widget formHariDanTanggal() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           height: 40,
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: Constanst.borderStyle5,
//               border: Border.all(
//                   width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 flex: 80,
//                 child: InkWell(
//                   onTap: () async {
//                     var dateSelect = await showDatePicker(
//                       context: Get.context!,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                       initialDate: controller.initialDate.value,
//                     );
//                     if (dateSelect == null) {
//                       UtilsAlert.showToast("Tanggal tidak terpilih");
//                     } else {
//                       controller.initialDate.value = dateSelect;
//                       controller.tanggalPilihKontrol.value.text =
//                           Constanst.convertDate("$dateSelect");
//                       this.controller.tanggalPilihKontrol.refresh();
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 8, top: 3, bottom: 5),
//                     child: Text(
//                       controller.tanggalPilihKontrol.value.text,
//                       style: TextStyle(
//                           fontSize: 14.0, height: 2.0, color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 flex: 20,
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: IconButton(
//                     onPressed: () async {},
//                     icon: Icon(
//                       Iconsax.arrow_down_14,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget formDepartemen() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           height: 40,
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: Constanst.borderStyle5,
//               border: Border.all(
//                   width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 flex: 80,
//                 child: InkWell(
//                   onTap: () async {
//                     controller.showDataDepartemenAkses('semua');
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 8, top: 3, bottom: 5),
//                     child: Text(
//                       controller.departemen.value.text,
//                       style: TextStyle(
//                           fontSize: 14.0, height: 2.0, color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 flex: 20,
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: IconButton(
//                     onPressed: () async {
//                       controller.showDataDepartemenAkses('semua');
//                     },
//                     icon: Icon(
//                       Iconsax.arrow_down_14,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget pencarianData() {
//     return Container(
//       decoration: BoxDecoration(
//           borderRadius: Constanst.borderStyle5,
//           border: Border.all(color: Constanst.colorText2)),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 15,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 7, left: 10),
//               child: Icon(Iconsax.search_normal_1),
//             ),
//           ),
//           Expanded(
//             flex: 85,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10),
//               child: SizedBox(
//                 height: 40,
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: 85,
//                       child: TextField(
//                         controller: controller.cari.value,
//                         decoration: InputDecoration(
//                             border: InputBorder.none,
//                             hintText: "Cari Nama Karyawan"),
//                         style: TextStyle(
//                             fontSize: 14.0, height: 1.0, color: Colors.black),
//                         onChanged: (value) {
//                           // controller.pencarianNamaKaryawan(value);
//                         },
//                       ),
//                     ),
//                     !controller.statusCari.value
//                         ? SizedBox()
//                         : Expanded(
//                             flex: 15,
//                             child: IconButton(
//                               icon: Icon(
//                                 Iconsax.close_circle,
//                                 color: Colors.red,
//                               ),
//                               onPressed: () {
//                                 controller.statusCari.value = false;
//                                 controller.cari.value.text = "";

//                                 controller.getDepartemen(1, "");
//                               },
//                             ),
//                           )
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
