import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/login.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';

class OnboardController extends GetxController {
  var deviceStatus = false.obs;

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() async {
    getSizeDevice();
    super.onInit();
  }

  void getSizeDevice() {
    double width = MediaQuery.of(Get.context!).size.width;
    if (width <= 395.0 || width <= 425.0) {
      print("kesini mobile kecil");
      deviceStatus.value = false;
    } else if (width >= 425.0) {
      print("kesini mobile besar");
      deviceStatus.value = true;
    }
    print("lebar $width");
  }

  void validasiToNextRoute() async {
    var dataInformasiUser = AppData.informasiUser;
    if (dataInformasiUser != null) {
      validasiUser();
    } else {
      Get.offAll(Login());
    }
  }

  void validasiUser() {
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {'em_id': getEmid};
    var connect = Api.connectionApi("post", body, "refresh_employee");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      if (valueBody['status'] == true) {
        var dateNow = DateTime.now();
        var convert = DateFormat('yyyy-MM-dd').format(dateNow);
        checkAbsenUser(convert, getEmid);
      } else {
        AppData.informasiUser = null;
        Get.offAll(Login());
      }
    });
  }

  void checkAbsenUser(convert, getEmid) {
    Map<String, dynamic> body = {'atten_date': convert, 'em_id': getEmid};
    var connect = Api.connectionApi("post", body, "view_last_absen_user");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        print(data[0]['signout_time']);
        if (data[0]['signout_time'] == "00:00:00") {
          AppData.statusAbsen = true;
        } else {
          AppData.statusAbsen = false;
        }
        Get.offAll(InitScreen());
      }
    });
  }
}
