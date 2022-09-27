import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/login.dart';
import 'package:siscom_operasional/utils/app_data.dart';

class OnboardController extends GetxController {
  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() async {
    super.onInit();
  }

  void validasiToNextRoute() async {
    var dateNow = DateTime.now();
    var convert = DateFormat('yyyy-MM-dd').format(dateNow);
    if (AppData.dateLastAbsen == convert) {
    } else {
      if (AppData.statusAbsen == true) {
        print("masuk sini");
        AppData.statusAbsen = false;
        AppData.dateLastAbsen = "";
      }
    }
    var dataInformasiUser = AppData.informasiUser;
    if (dataInformasiUser != null) {
      Get.offAll(InitScreen());
    } else {
      Get.offAll(Login());
    }
  }
}
