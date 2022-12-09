// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/berhasil_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:location/location.dart';

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

class BerhasilAbsensi extends StatefulWidget {
  List? dataBerhasil;
  BerhasilAbsensi({Key? key, this.dataBerhasil}) : super(key: key);
  @override
  _BerhasilAbsensiState createState() => _BerhasilAbsensiState();
}

class _BerhasilAbsensiState extends State<BerhasilAbsensi> {
  var controller = Get.put(AbsenController());
  var controllerBerhasil = Get.put(BerhasilController());
  Timer? time;

  @override
  void initState() {
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
    super.initState();
  }

  ReceivePort? _receivePort;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

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
        //   const NotificationButton(id: 'sendButton', text: 'Send'),
        //   const NotificationButton(id: 'testButton', text: 'Test'),
        // ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: true,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // interval: 1800000,
        interval: widget.dataBerhasil![3],
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
        var now = DateTime.now();
        var getJam = DateFormat('HH:mm:ss').format(now);
        var tanggal = DateFormat('yyyy-MM-dd').format(now);
        print("$getJam");
        print("${AppData.informasiUser![0].em_id}");
        Location location = new Location();
        location.enableBackgroundMode(enable: true);
        _userLocation = await location.getLocation();
        print(
            'lat ${_userLocation!.latitude} long ${_userLocation!.longitude}');
        controllerBerhasil.getPosisition(AppData.informasiUser![0].em_id,
            getJam, tanggal, _userLocation!.latitude, _userLocation!.longitude);

        if (message is int) {
          print('eventCount: $message');
        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            Navigator.of(context).pushNamed('/resume-route');
          }
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
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

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 240, 248),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SafeArea(
            child: Column(
          children: [
            Expanded(flex: 30, child: SizedBox()),
            Expanded(
                flex: 70,
                child: Column(
                  children: [
                    Image.asset(
                      "assets/berhasil_absen.png",
                      width: 150,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Berhasil", style: Constanst.boldType1),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Kamu Berhasil melakukan"),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            widget.dataBerhasil![0],
                            style: Constanst.boldType2,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text("Pada"),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    widget.dataBerhasil![2] == 1
                        ? Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(156, 223, 253, 223),
                              borderRadius: Constanst.borderStyle1,
                            ),
                            margin: EdgeInsets.only(left: 8),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                widget.dataBerhasil![1],
                                style: Constanst.colorGreenBold,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(156, 241, 171, 171),
                              borderRadius: Constanst.borderStyle1,
                            ),
                            margin: EdgeInsets.only(left: 8),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                widget.dataBerhasil![1],
                                style: Constanst.colorRedBold,
                              ),
                            ),
                          )
                  ],
                ))
          ],
        )),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10.0),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Constanst.colorPrimary),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.white)))),
          onPressed: () async {
            print("${controller.intervalControl.value}");
            String checkUserKontrol =
                await controllerBerhasil.checkUserKontrol();
            print(checkUserKontrol);
            if (widget.dataBerhasil![2] == 1) {
              if (checkUserKontrol != '0') {
                _startForegroundTask();
                AbsenController().removeAll();
                Get.offAll(InitScreen());
              } else {
                AbsenController().removeAll();
                Get.offAll(InitScreen());
              }
            } else {
              if (checkUserKontrol != '0') {
                _stopForegroundTask();
                Location location = new Location();
                location.enableBackgroundMode(enable: false);
                AbsenController().removeAll();
                Get.offAll(InitScreen());
              } else {
                AbsenController().removeAll();
                Get.offAll(InitScreen());
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text('Kembali ke beranda'),
          ),
        ),
      ),
    );
  }
}
