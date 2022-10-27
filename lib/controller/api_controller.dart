import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class ApiController extends GetxController {
  // METHOD GET

  Future<List> getDepartemen() async {
    List dataFinal = [];
    var connect = Api.connectionApi("get", "", "all_department");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        for (var element in valueBody['data']) {
          dataFinal.add(element);
        }
      }
    });

    return dataFinal;
  }

  // METHOD POST

  Future<List> employeeInfo(depId) async {
    List dataFinal = [];
    Map<String, dynamic> body = {'dep_id': depId};
    var connect = Api.connectionApi("post", body, "cari_informasi_employee");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        for (var element in valueBody['data']) {
          dataFinal.add(element);
        }
      }
    });

    return dataFinal;
  }

  void kirimNotifikasiToDelegasi(
      getFullName, convertTanggalBikinPengajuan, validasiDelegasiSelected) {
    var dt = DateTime.now();
    var jamSekarang = DateFormat('HH:mm:ss').format(dt);
    Map<String, dynamic> body = {
      'em_id': validasiDelegasiSelected,
      'title': 'Delegasi Pengajuan Lembur',
      'deskripsi':
          'Anda mendapatkan delegasi pekerjaan dari $getFullName untuk Pengajuan Lembur',
      'url': '',
      'atten_date': convertTanggalBikinPengajuan,
      'jam': jamSekarang,
      'status': '2',
      'view': '0',
    };
    var connect = Api.connectionApi("post", body, "insert-notifikasi");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        UtilsAlert.showToast("Berhasil kirim delegasi");
      }
    });
  }
}
