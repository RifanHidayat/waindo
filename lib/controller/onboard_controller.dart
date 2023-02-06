import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/login.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class OnboardController extends GetxController {
  var deviceStatus = false.obs;

  final AbsenController abseController = Get.put(AbsenController());

  var loading = false.obs;

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() async {
    getSizeDevice();
    super.onInit();
    iniFaceRecog();
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
    loading.value = true;
    var dataInformasiUser = AppData.informasiUser;

    if (dataInformasiUser != null) {
      validasiUser();
    } else {
      loading.value = false;
      Get.offAll(Login());
    }
  }

  void validasiUser() {
    print("validasion masuk");
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

  void checkAbsenUser(convert, getEmid) async {
    Map<String, dynamic> body = {'atten_date': convert, 'em_id': getEmid};
    print(body);

    var connect = Api.connectionApi("post", body, "view_last_absen_user");
    var value = await connect;
    var valueBody = jsonDecode(value.body);

    List data = valueBody['data'];

    print('data response $valueBody');
    if (data.isEmpty) {
      loading.value = false;
      AppData.statusAbsen = false;
      Get.offAll(InitScreen());
      // Future.delayed(Duration.zero, () {});
    } else {
      var tanggalTerakhirAbsen = data[0]['atten_date'];
      if (tanggalTerakhirAbsen == convert) {
        loading.value = false;
        // print("siggin time ${data[0]['sign_time']}");
        AppData.statusAbsen =
            data[0]['signout_time'] == "00:00:00" ? true : false;

        Get.offAll(InitScreen());
      } else {
        loading.value = false;
        AppData.statusAbsen = false;

        Get.offAll(InitScreen());
      }
    }

    // conne.then((dynamic res) {
    //   if (res.statusCode == 200) {
    //     var valueBody = jsonDecode(res.body);

    //     print("value body ${valueBody}");

    //   }
    // });
  }

  void iniFaceRecog() async {
    final box = GetStorage();
    if (box.read('face_recog') == false) {
    } else {
      abseController.widgetButtomSheetFaceRegistrattion();
    }
  }
}
