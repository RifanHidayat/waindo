import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/model/user_model.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class AuthController extends GetxController {
  var username = TextEditingController().obs;
  var password = TextEditingController().obs;
  var email = TextEditingController().obs;
  var showpassword = false.obs;

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() async {
    super.onInit();
  }

  bool validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value))
      return false;
    else
      return true;
  }

  void registrasiAkun() {
    var validasiEmail = validateEmail(email.value.text);
    if (validasiEmail) {
      UtilsAlert.showLoadingIndicator(Get.context!);
      Map<String, dynamic> body = {
        'email': email.value.text,
        'username': username.value.text,
        'password': password.value.text,
      };
      var connect = Api.connectionApi("post", body, "registrasi");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            username.value.text = "";
            email.value.text = "";
            password.value.text = "";
            UtilsAlert.showToast("Berhasil registrasi akun");
            Navigator.pop(Get.context!);
            Navigator.pop(Get.context!);
          }
          print(res.body);
        }
      });
    } else {
      UtilsAlert.showToast("Email tidak valid");
    }
  }

  void loginUser() {
    UtilsAlert.showLoadingIndicator(Get.context!);
    Map<String, dynamic> body = {
      'email': email.value.text,
      'password': password.value.text
    };
    var connect = Api.connectionApi("post", body, "validasiLogin");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      if (valueBody['status'] == false) {
        UtilsAlert.showToast(valueBody['message']);
        Navigator.pop(Get.context!);
      } else {
        UtilsAlert.showToast("Selamat Datang");
        List<UserModel> getData = AppData.informasiUser ?? [];
        for (var element in valueBody['data']) {
          var data = UserModel(
            emp_id: element['em_code'] ?? "",
            em_code: element['em_id'] ?? "",
            des_id: element['des_id'] ?? 0,
            dep_id: element['dep_id'] ?? 0,
            first_name: element['first_name'] ?? "",
            last_name: element['last_name'] ?? "",
            em_email: element['em_email'] ?? "",
            em_phone: element['em_phone'] ?? "",
            em_birthday: element['em_birthday'] ?? "1999-09-09",
            em_gender: element['em_gender'] ?? "",
            em_image: element['em_image'] ?? "",
            em_joining_date: element['em_joining_date'] ?? "1999-09-09",
            em_status: element['em_status'] ?? "",
            em_blood_group: element['em_blood_group'] ?? "",
            emp_jobTitle: element['emp_jobTitle'] ?? "",
            emp_departmen: element['emp_departmen'] ?? "",
            emp_att_working: element['emp_att_working'] ?? 0,
            em_hak_akses: element['em_hak_akses'] ?? "",
          );
          getData.add(data);
        }
        username.value.text = "";
        password.value.text = "";
        AppData.informasiUser = getData;
        // Get.offAll(Dashboard());
        Get.offAll(InitScreen());
      }
    });
  }
}
