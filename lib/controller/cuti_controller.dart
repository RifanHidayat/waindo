import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class CutiController extends GetxController {
  var dariTanggal = TextEditingController().obs;
  var sampaiTanggal = TextEditingController().obs;
  var alasan = TextEditingController().obs;
  var cari = TextEditingController().obs;

  var filePengajuan = File("").obs;

  var allTipe = [].obs;
  var allEmployee = [].obs;
  var dataTypeAjuan = [].obs;
  var AlllistHistoryAjuan = [].obs;
  var listHistoryAjuan = [].obs;

  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);
  Rx<List<String>> allTipeFormCutiDropdown = Rx<List<String>>([]);

  var jumlahCuti = 12.obs;
  var cutiTerpakai = 4.obs;
  var persenCuti = 0.0.obs;

  var namaFileUpload = "".obs;
  var selectedTypeCuti = "".obs;
  var selectedDelegasi = "".obs;
  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var idEditFormCuti = "".obs;

  var statusForm = false.obs;

  var dataTypeAjuanDummy = ["Semua", "Approve", "Rejected", "Pending"];

  @override
  void onReady() async {
    getTimeNow();
    hitungCuti();
    loadCutiUser();
    getTypeAjuan();
    loadAllEmployeeDelegasi();
    loadDataTypeCuti();
    loadDataAjuanCuti();
    print("jalankan cuti controller");
    super.onReady();
  }

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";

    var dateString = "${dt.year}-${dt.month}-${dt.day}";
    var afterConvert = Constanst.convertDate1(dateString);
    if (idEditFormCuti.value == "") {
      dariTanggal.value.text = "$afterConvert";
      sampaiTanggal.value.text = "$afterConvert";
    }
  }

  void getTypeAjuan() {
    dataTypeAjuan.value.clear();
    for (var element in dataTypeAjuanDummy) {
      var data = {'nama': element, 'status': false};
      dataTypeAjuan.value.add(data);
    }
    dataTypeAjuan.value
        .firstWhere((element) => element['nama'] == 'Semua')['status'] = true;
    this.dataTypeAjuan.refresh();
  }

  void loadDataTypeCuti() {
    allTipeFormCutiDropdown.value.clear();
    allTipe.value.clear();
    Map<String, dynamic> body = {'val': 'status', 'cari': '1'};
    var connect = Api.connectionApi("post", body, "whereOnce-leave_types");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        if (data.length < 2) {
          allTipeFormCutiDropdown.value.add(data[0]['name']);
          selectedTypeCuti.value = data[0]['name'];
          var insert = {
            'type_id': data[0]['type_id'],
            'name': data[0]['name'],
            'status': data[0]['status'],
            'active': false,
          };
          allTipe.value.add(insert);
        } else {
          for (var element in data) {
            allTipeFormCutiDropdown.value.add(element['name']);
            var data = {
              'type_id': element['element'],
              'name': element['name'],
              'status': element['status'],
              'active': false,
            };
            allTipe.value.add(data);
            selectedTypeCuti.value = element['name'];
          }
        }
        var getFirst = allTipe.value.first;
        allTipe.value.firstWhere((element) =>
            element['type_id'] == getFirst['type_id'])['active'] = true;
        this.allTipe.refresh();
        this.selectedTypeCuti.refresh();
        this.allTipeFormCutiDropdown.refresh();
      }
    });
  }

  void loadDataAjuanCuti() {
    AlllistHistoryAjuan.value.clear();
    listHistoryAjuan.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_code;
    Map<String, dynamic> body = {
      'em_code': getEmCode,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
      'type': '2',
    };
    var connect = Api.connectionApi("post", body, "history-emp_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        AlllistHistoryAjuan.value = valueBody['data'];
        for (var element in valueBody['data']) {
          if (element['name'] == "Cuti Tahunan") {
            listHistoryAjuan.value.add(element);
          }
        }
        this.listHistoryAjuan.refresh();
        this.AlllistHistoryAjuan.refresh();
      }
    });
  }

  void changeTypeAjuan(name) {
    for (var element in dataTypeAjuan.value) {
      if (element['nama'] == name) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    }
    if (name == "Semua") {
      listHistoryAjuan.value.clear();
      AlllistHistoryAjuan.value.forEach((element) {
        if (element['name'] == "Cuti Tahunan") {
          listHistoryAjuan.value.add(element);
        }
      });
    } else {
      listHistoryAjuan.value.clear();
      for (var element in AlllistHistoryAjuan.value) {
        if (element['leave_status'] == name) {
          if (element['name'] == "Cuti Tahunan") {
            listHistoryAjuan.value.add(element);
          }
        }
      }
    }
    this.dataTypeAjuan.refresh();
    this.listHistoryAjuan.refresh();
  }

  void loadAllEmployeeDelegasi() {
    allEmployeeDelegasi.value.clear();
    allEmployee.value.clear();
    var dataUser = AppData.informasiUser;
    var getDepId = dataUser![0].dep_id;
    Map<String, dynamic> body = {'val': 'dep_id', 'cari': getDepId};
    var connect = Api.connectionApi("post", body, "whereOnce-employee");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var data = valueBody['data'];
          var listFirst = valueBody['data'].first;
          var namaDepan = listFirst['first_name'] ?? "";
          var namaBelakang = listFirst['last_name'] ?? "";
          String namaUserPertama = "$namaDepan $namaBelakang";
          selectedDelegasi.value = namaUserPertama;
          for (var element in data) {
            var namaDepan = element['first_name'] ?? "";
            var namaBelakang = element['last_name'] ?? "";
            String namaUser = "$namaDepan $namaBelakang";
            allEmployeeDelegasi.value.add(namaUser);
            allEmployee.value.add(element);
          }
          this.allEmployee.refresh();
          this.allEmployeeDelegasi.refresh();
          this.selectedDelegasi.refresh();
        }
      }
    });
  }

  void loadCutiUser() {
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_code;
    Map<String, dynamic> body = {
      'val': 'emp_id',
      'cari': getEmCode,
    };
    var connect = Api.connectionApi("post", body, "whereOnce-assign_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        print("cuti user ${valueBody['data']}");
      }
    });
  }

  void hitungCuti() {
    var hitung1 = (cutiTerpakai.value / jumlahCuti.value) * 100;
    var convert1 = hitung1.toInt();
    var convertedValue = double.parse("${convert1}") / 100;
    persenCuti.value = convertedValue;
    this.persenCuti.refresh();
  }

  void takeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.size > 5000000) {
        UtilsAlert.showToast("Maaf file terlalu besar...Max 5MB");
      } else {
        namaFileUpload.value = "${file.name}";
        filePengajuan.value = await saveFilePermanently(file);
      }
    } else {
      UtilsAlert.showToast("Gagal mengambil file");
    }
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appStorage.path}/${file.name}');
    return File(file.path!).copy(newFile.path);
  }

  void validasiKirimPengajuan() async {
    if (selectedTypeCuti == "" ||
        dariTanggal.value.text == "" ||
        sampaiTanggal.value.text == "" ||
        alasan.value.text == "") {
      UtilsAlert.showToast("Form * harus di isi");
    } else {
      if (namaFileUpload.value != "") {
        UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan File");
        var connectUpload = await Api.connectionApiUploadFile(
            "upload_form_cuti", filePengajuan.value);
        var valueBody = jsonDecode(connectUpload);
        if (valueBody['status'] == true) {
          UtilsAlert.showToast("Berhasil upload file");
          Navigator.pop(Get.context!);
          kirimFormAjuanCuti();
        } else {
          UtilsAlert.showToast("Gagal kirim file");
        }
      } else {
        kirimFormAjuanCuti();
      }
    }
  }

  void kirimFormAjuanCuti() async {
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_code;
    var getEmpid = dataUser[0].emp_id;
    var validasiTipeSelected = validasiSelectedType();
    var validasiDelegasiSelected = validasiSelectedDelegasi();
    var hitungIzin = validasiHitungIzin();
    var convertDariTanggal =
        Constanst.convertDateSimpan(dariTanggal.value.text);
    var convertSampaiTanggal =
        Constanst.convertDateSimpan(sampaiTanggal.value.text);
    var dt = DateTime.now();
    var dateString = "${dt.year}-${dt.month}-${dt.day}";
    var afterConvert = Constanst.convertDate1(dateString);
    var convertTanggalBikinPengajuan =
        Constanst.convertDateSimpan(afterConvert);
    UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan Data");
    Map<String, dynamic> body = {
      'em_id': '$getEmCode',
      'typeid': validasiTipeSelected,
      'leave_type': 'Full Day',
      'start_date': convertDariTanggal,
      'end_date': convertSampaiTanggal,
      'leave_duration': hitungIzin,
      'apply_date': '',
      'reason': alasan.value.text,
      'leave_status': 'Pending',
      'atten_date': convertTanggalBikinPengajuan,
      'em_delegation': validasiDelegasiSelected,
      'leave_files': namaFileUpload.value,
      'ajuan': '2',
      'created_by': getEmpid,
      'menu_name': 'Cuti'
    };
    if (statusForm.value == false) {
      body['activity_name'] =
          "Membuat Pengajuan Cuti. alasan = ${alasan.value.text}";
      var connect = Api.connectionApi("post", body, "insert-emp_leave");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          Navigator.pop(Get.context!);
          var pesan =
              "Pengajuan Form ${selectedTypeCuti.value} berhasil dibuat. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah dibuat";
          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan],
          ));
        }
      });
    } else {
      body['val'] = "id";
      body['cari'] = idEditFormCuti.value;
      body['activity_name'] =
          "Edit Pengajuan Cuti. Tanggal Pengajuan = $convertTanggalBikinPengajuan";
      var connect = Api.connectionApi("post", body, "edit-emp_leave");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          Navigator.pop(Get.context!);
          var pesan =
              "Pengajuan Form Cuti berhasil diedit. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah diedit";
          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan],
          ));
        }
      });
    }
  }

  String validasiSelectedType() {
    var result = [];
    for (var element in allTipe.value) {
      if (element['name'] == selectedTypeCuti.value) {
        result.add(element);
      }
    }
    return "${result[0]['type_id']}";
  }

  String validasiSelectedDelegasi() {
    var result = [];
    for (var element in allEmployee.value) {
      var namaDepan = element['first_name'] ?? "";
      var namaBelakang = element['last_name'] ?? "";
      var namaElement = "$namaDepan $namaBelakang";
      if (namaElement == selectedDelegasi.value) {
        result.add(element);
      }
    }
    return "${result[0]['em_code']}";
  }

  String validasiHitungIzin() {
    var getDari = Constanst.convertOnlyDate(dariTanggal.value.text);
    var getSampai = Constanst.convertOnlyDate(sampaiTanggal.value.text);
    var hitung = (int.parse(getSampai) - int.parse(getDari)) + 1;
    return "$hitung";
  }

  void batalkanPengajuanCuti(index) {
    showGeneralDialog(
      barrierDismissible: false,
      context: Get.context!,
      barrierColor: Colors.black54, // space around dialog
      transitionDuration: Duration(milliseconds: 200),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
              parent: a1,
              curve: Curves.elasticOut,
              reverseCurve: Curves.easeOutCubic),
          child: CustomDialog(
            // our custom dialog
            title: "Peringatan",
            content: "Yakin Batalkan Pengajuan ?",
            positiveBtnText: "Batalkan",
            negativeBtnText: "Kembali",
            style: 1,
            buttonStatus: 1,
            positiveBtnPressed: () {
              batalkanPengajuan(index);
            },
          ),
        );
      },
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return null!;
      },
    );
  }

  void batalkanPengajuan(index) {
    UtilsAlert.loadingSimpanData(Get.context!, "Batalkan Pengajuan");
    var dataUser = AppData.informasiUser;
    var getEmpId = dataUser![0].emp_id;
    Map<String, dynamic> body = {
      'menu_name': 'Cuti',
      'activity_name':
          'Membatalkan form pengajuan Cuti. Tanggal = ${index["start_date"]} sd Tanggal = ${index["end_date"]} Durasi Cuti = ${index["leave_duration"]} Alasan = ${index["reason"]}',
      'created_by': '$getEmpId',
      'val': 'id',
      'cari': '${index["id"]}',
    };
    var connect = Api.connectionApi("post", body, "delete-emp_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        Navigator.pop(Get.context!);
        Navigator.pop(Get.context!);
        UtilsAlert.showToast("Berhasil batalkan pengajuan");
        onReady();
      }
    });
  }

}
