import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/model/user_model.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class AuthController extends GetxController {
  var username = TextEditingController().obs;
  var password = TextEditingController().obs;
  var email = TextEditingController().obs;
  var showpassword = false.obs;

  @override
  void onReady() {
    email.value.text = AppData.emailUser;
    password.value.text = AppData.passwordUser;
    super.onReady();
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

  Future<void> loginUser() async {
    final box = GetStorage();
    var fcm_registration_token = await FirebaseMessaging.instance.getToken();
    print("token ${fcm_registration_token}");

    UtilsAlert.showLoadingIndicator(Get.context!);
    Map<String, dynamic> body = {
      'email': email.value.text,
      'password': password.value.text,
      'token_notif': fcm_registration_token.toString()
    };
    var connect = Api.connectionApi("post", body, "validasiLogin");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      if (valueBody['status'] == false) {
        UtilsAlert.showToast(valueBody['message']);
        Navigator.pop(Get.context!);
      } else {
        List<UserModel> getData = AppData.informasiUser ?? [];
        var lastLoginUser = "";
        var getEmId = "";
        var getAktif = "";
        for (var element in valueBody['data']) {
          var data = UserModel(
              em_id: element['em_id'] ?? "",
              des_id: element['des_id'] ?? 0,
              dep_id: element['dep_id'] ?? 0,
              dep_group: element['dep_group'] ?? 0,
              full_name: element['full_name'] ?? "",
              em_email: element['em_email'] ?? "",
              em_phone: element['em_phone'] ?? "",
              em_birthday: element['em_birthday'] ?? "1999-09-09",
              em_gender: element['em_gender'] ?? "",
              em_image: element['em_image'] ?? "",
              em_joining_date: element['em_joining_date'] ?? "1999-09-09",
              em_status: element['em_status'] ?? "",
              em_blood_group: element['em_blood_group'] ?? "",
              posisi: element['posisi'] ?? "",
              emp_jobTitle: element['emp_jobTitle'] ?? "",
              emp_departmen: element['emp_departmen'] ?? "",
              em_control: element['em_control'] ?? 0,
              em_control_acess: element['em_control_access'] ?? 0,
              emp_att_working: element['emp_att_working'] ?? 0,
              em_hak_akses: element['em_hak_akses'] ?? "",
              face_recog: element['face_recog']);

          if (element['face_recog'] == "" || element['face_recog'] == null) {
            box.write("face_recog", false);
          } else {
            box.write("face_recog", true);
          }
          getData.add(data);
          lastLoginUser = "${element['last_login']}";
          getEmId = "${element['em_id']}";
          getAktif = "${element['status_aktif']}";
          print(element.toString());
        }
        print(lastLoginUser);
        if (getAktif == "ACTIVE") {
          if (lastLoginUser == "" ||
              lastLoginUser == "null" ||
              lastLoginUser == null ||
              lastLoginUser == "0000-00-00 00:00:00") {
            print("sampe sini");
            fillLastLoginUser(getEmId, getData);
          } else {
            var filterLastLogin = Constanst.convertDate1("$lastLoginUser");
            var dateNow = DateTime.now();
            var convert = DateFormat('dd-MM-yyyy').format(dateNow);
            if (convert != filterLastLogin) {
              print("sampe sini 2");
              fillLastLoginUser(getEmId, getData);
            } else {
              UtilsAlert.showToast("Anda telah masuk di perangkat lain");
              Navigator.pop(Get.context!);
            }
          }
        } else {
          UtilsAlert.showToast("Maaf status anda sudah tidak aktif");
          Navigator.pop(Get.context!);
        }
      }
    });
  }

  void fillLastLoginUser(getEmId, getData) {
    var now = DateTime.now();
    var jam = "${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}";
    Map<String, dynamic> body = {'last_login': jam, 'em_id': getEmId};
    var connect = Api.connectionApi("post", body, "edit_last_login");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        print(valueBody['data']);
        if (valueBody['status'] == true) {
          var dateNow = DateTime.now();
          var convert = DateFormat('yyyy-MM-dd').format(dateNow);
          AppData.emailUser = email.value.text;
          AppData.passwordUser = password.value.text;
          AppData.informasiUser = getData;
          checkAbsenUser(convert, getEmId);
        }
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
        if (data.isEmpty) {
          AppData.statusAbsen = false;
          Get.offAll(InitScreen());
        } else {
          var tanggalTerakhirAbsen = data[0]['atten_date'];
          if (tanggalTerakhirAbsen == convert) {
            AppData.statusAbsen =
                data[0]['signout_time'] == "00:00:00" ? true : false;
            Get.offAll(InitScreen());
          } else {
            AppData.statusAbsen = false;
            Get.offAll(InitScreen());
          }
        }
      }
    });
  }

  // Future<bool>? verifyPassword() async {
  //   final box = GetStorage();

  //   UtilsAlert.showLoadingIndicator(Get.context!);
  //   Map<String, dynamic> body = {
  //     'email': email.value.text,
  //     'password': password.value.text,
  //   };
  //   var connect = Api.connectionApi("post", body, "validasiLogin");
  //   connect.then((dynamic res) {
  //     var valueBody = jsonDecode(res.body);
  //     if (valueBody['status'] == false) {
  //       UtilsAlert.showToast(valueBody['message']);
  //       Navigator.pop(Get.context!);
  //       return false;
  //     } else {
  //       return true;
  //     }
  //   });
  //   return false;
  // }
}
