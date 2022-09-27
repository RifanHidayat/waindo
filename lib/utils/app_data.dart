import 'dart:convert';

import 'package:siscom_operasional/model/setting_app_model.dart';
import 'package:siscom_operasional/model/user_model.dart';
import 'package:siscom_operasional/utils/local_storage.dart';

class AppData {

  // SET

  static set statusAbsen(bool value) =>
      LocalStorage.saveToDisk('statusAbsen', value);

  static set dateLastAbsen(String value) =>
      LocalStorage.saveToDisk('dateLastAbsen', value);

  static set informasiUser(List<UserModel>? value) {
    if (value != null) {
      List<String> listString = value.map((e) => e.toJson()).toList();
      LocalStorage.saveToDisk('informasiUser', listString);
    } else {
      LocalStorage.saveToDisk('informasiUser', null);
    }
  }

  static set infoSettingApp(List<SettingAppModel>? value) {
    if (value != null) {
      List<String> listString = value.map((e) => e.toJson()).toList();
      LocalStorage.saveToDisk('infoSettingApp', listString);
    } else {
      LocalStorage.saveToDisk('infoSettingApp', null);
    }
  }


  // GET

  static bool get statusAbsen {
    if (LocalStorage.getFromDisk('statusAbsen') != null) {
      return LocalStorage.getFromDisk('statusAbsen');
    }
    return false;
  }

  static String get dateLastAbsen {
    if (LocalStorage.getFromDisk('dateLastAbsen') != null) {
      return LocalStorage.getFromDisk('dateLastAbsen');
    }
    return "";
  }

  static List<UserModel>? get informasiUser {
    if (LocalStorage.getFromDisk('informasiUser') != null) {
      List<String> listData =
          LocalStorage.getFromDisk('informasiUser');
      return listData
          .map((e) => UserModel.fromMap(jsonDecode(e)))
          .toList();
    }
    return null;
  }

  static List<SettingAppModel>? get infoSettingApp {
    if (LocalStorage.getFromDisk('infoSettingApp') != null) {
      List<String> listData =
          LocalStorage.getFromDisk('infoSettingApp');
      return listData
          .map((e) => SettingAppModel.fromMap(jsonDecode(e)))
          .toList();
    }
    return null;
  }




  // CLEAR ALL DATA

  static void clearAllData() =>
      LocalStorage.removeFromDisk(null, clearAll: true);

}
