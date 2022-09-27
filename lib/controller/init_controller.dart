import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/model/setting_app_model.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/login.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/onboard.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class InitController extends GetxController {
  void loadDashboard() async {
    getSettingApp();
  }

  void getSettingApp() {
    AppData.infoSettingApp = [];
    Map<String, dynamic> body = {'val': 'id', 'cari': '1'};
    var connect = Api.connectionApi("post", body, "whereOnce-settings");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          print(valueBody['data']);
          List<SettingAppModel> getData = AppData.infoSettingApp ?? [];
          for (var element in valueBody['data']) {
            var data = SettingAppModel(
              id: element['id'],
              sitelogo: element['sitelogo'],
              sitetitle: element['sitetitle'],
              description: element['description'],
              copyright: element['copyright'],
              contact: element['contact'],
              currency: element['currency'],
              symbol: element['symbol'],
              system_email: element['system_email'],
              address: element['address'],
              address2: element['address2'],
              longlat_comp: element['longlat_comp'],
              radius: element['radius'],
              saveimage_attend: element['saveimage_attend'],
            );
            getData.add(data);
          }
          AppData.infoSettingApp = getData;
          validasiLastAbsensi();
        }
      }
    });
  }

  void validasiLastAbsensi() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAll(Onboard());
  }
}
