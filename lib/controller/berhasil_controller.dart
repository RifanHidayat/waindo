import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';

class BerhasilController extends GetxController {
  Future<bool> getPosisition(getEmid, jam, tanggal, lat, long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      var alamatUser =
          "${placemarks[0].street} ${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}";

      Future<bool> prosesKirim =
          kirimDataKontrol(lat, long, alamatUser, jam, tanggal, getEmid);
      bool hasilProses = await prosesKirim;
      if (hasilProses)
        return true;
      else
        return false;
    } on Exception catch (e) {
      print("error ${e}");
      return false;
    }
  }

  Future<bool> kirimDataKontrol(
      latUser, langUser, alamatUser, jam, tanggal, getEmid) async {
    var latLangUserKontrol = "$latUser,$langUser";
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'atten_date': tanggal,
      'jam': jam,
      'latLangKontrol': latLangUserKontrol,
      'alamat': alamatUser,
    };

    var connect =
        Api.connectionApi("post", body, "insert_emp_control_employee");
    print("connect ${connect}");
    var getValue = await connect;

    var valueBody = jsonDecode(getValue.body);
    print("value body ${valueBody}");
    if (valueBody['status'] == true) {
      return true;
    }
    return false;
    // connect.then((dynamic res) {
    //   var valueBody = jsonDecode(res.body);

    //   print(valueBody);
    // });
  }

  Future<String> checkUserKontrol() {
    Map<String, dynamic> body = {
      'val': 'em_id',
      'cari': AppData.informasiUser![0].em_id,
    };
    var connect = Api.connectionApi("post", body, "whereOnce-employee");
    var kontrolString = connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      var emKontrol = "${valueBody['data'][0]['em_control']}";
      return "$emKontrol";
    });
    return kontrolString;
  }
}
