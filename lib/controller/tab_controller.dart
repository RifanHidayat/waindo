import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:siscom_operasional/controller/aktifitas_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/controller/setting_controller.dart';
import 'package:siscom_operasional/model/user_model.dart';
import 'package:siscom_operasional/screen/aktifitas/aktifitas.dart';
import 'package:siscom_operasional/screen/akun/setting.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/pesan/pesan.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class TabbController extends GetxController {
  var currentPage = 0.obs;
  Rx<PersistentTabController> tabPersistantController =
      PersistentTabController().obs;
  DateTime? _currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      UtilsAlert.showToast("Tekan sekali lagi untuk keluar");
      return Future.value(false);
    }
    return Future.value(true);
  }

  void onClickItem(s) async {
    print(s);
    if (s == 0) {
      // try {
        // var dashboardController = Get.find<DashboardController>();
        // // dashboardController.onClose();
        // dashboardController.onInit();
      // } catch (e) {}
    } else if (s == 1) {
      // try {
      //   // var aktifitasController = Get.find<AktifitasController>();
      //   // aktifitasController.onInit();
      // } catch (e) {}
    } else if (s == 2) {
      // try {
      //   // var pesanController = Get.find<PesanController>();
      //   // pesanController.onInit();
      // } catch (e) {}
    } else if (s == 3) {
      // try {
      //   // var settingController = Get.find<SettingController>();
      //   // settingController.onInit();
      // } catch (e) {}
    }
  }
}
