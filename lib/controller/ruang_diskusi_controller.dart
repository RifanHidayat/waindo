import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/api_controller.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class RuangDiskusiController extends GetxController {
  var controllerApiGlobal = Get.put(ApiController());

  var cari = TextEditingController().obs;
  var judulProject = TextEditingController().obs;
  var deskripsiProject = TextEditingController().obs;
  var dariTanggal = TextEditingController().obs;
  var sampaiTanggal = TextEditingController().obs;

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;

  var selectType = 0.obs;

  var statusCari = false.obs;

  var listRiwayatIzin = [].obs;
  var listRiwayatIzinAll = [].obs;

  Rx<DateTime> initialDate = DateTime.now().obs;

  var dataTypeAjuanDummy = ["Semua", "Approve", "Rejected", "Pending"];

  @override
  void startData() async {
    getTimeNow();
    initialDate.value = DateTime.now();
  }

  void removeAll() {}

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";

    this.bulanSelectedSearchHistory.refresh();
    this.tahunSelectedSearchHistory.refresh();
    this.bulanDanTahunNow.refresh();
  }

  void cariData(value) {}

  void changeType(value) {
    selectType.value = value;
    this.selectType.refresh();
  }
}
