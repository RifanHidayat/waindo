import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class TugasLuarController extends GetxController {
  var tanggalLembur = TextEditingController().obs;
  var dariJam = TextEditingController().obs;
  var sampaiJam = TextEditingController().obs;
  var catatan = TextEditingController().obs;

  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var selectedDropdownDelegasi = "".obs;
  var idpengajuanTugasLuar = "".obs;
  var loadingString = "Sedang Memuat...".obs;

  var statusForm = false.obs;
  var directStatus = false.obs;

  var listTugasLuar = [].obs;
  var allEmployee = [].obs;

  Rx<DateTime> initialDate = DateTime.now().obs;

  @override
  void onReady() async {
    super.onReady();
    getTimeNow();
    loadDataTugasLuar();
    loadAllEmployeeDelegasi();
  }

  void removeAll() {
    tanggalLembur.value.text = "";
    dariJam.value.text = "";
    sampaiJam.value.text = "";
    catatan.value.text = "";
  }

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";

    if (idpengajuanTugasLuar.value == "") {
      tanggalLembur.value.text = Constanst.convertDate("${initialDate.value}");
    }

    this.tanggalLembur.refresh();
    this.bulanSelectedSearchHistory.refresh();
    this.tahunSelectedSearchHistory.refresh();
    this.bulanDanTahunNow.refresh();
  }

  void loadDataTugasLuar() {
    listTugasLuar.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_code;
    Map<String, dynamic> body = {
      'emp_id': getEmCode,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "history-emp_labor");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        for (var element in valueBody['data']) {
          if (element['ajuan'] == 2) {
            listTugasLuar.value.add(element);
          }
        }
        if (listTugasLuar.value.length == 0) {
          loadingString.value = "Tidak ada pengajuan";
        } else {
          loadingString.value = "Sedang Memuat...";
        }
        
        this.listTugasLuar.refresh();
      }
    });
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
          selectedDropdownDelegasi.value = namaUserPertama;
          for (var element in data) {
            var namaDepan = element['first_name'] ?? "";
            var namaBelakang = element['last_name'] ?? "";
            String namaUser = "$namaDepan $namaBelakang";
            allEmployeeDelegasi.value.add(namaUser);
            allEmployee.value.add(element);
          }
          this.allEmployee.refresh();
          this.allEmployeeDelegasi.refresh();
          this.selectedDropdownDelegasi.refresh();
        }
      }
    });
  }

  void validasiKirimPengajuan() {
    if (tanggalLembur.value.text == "" ||
        dariJam.value.text == "" ||
        sampaiJam.value.text == "" ||
        catatan.value.text == "") {
      print(initialDate.value);
      UtilsAlert.showToast("Lengkapi form *");
    } else {
      kirimPengajuan();
    }
  }

  void kirimPengajuan() {
    var listTanggal = tanggalLembur.value.text.split(',');
    var getTanggal = listTanggal[1].replaceAll(' ', '');
    var tanggalLemburEditData = Constanst.convertDateSimpan(getTanggal);
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_code;
    var getEmpid = dataUser[0].emp_id;
    var validasiDelegasiSelected = validasiSelectedDelegasi();
    var polaFormat = DateFormat('yyyy-MM-dd');
    var tanggalPengajuanInsert = polaFormat.format(initialDate.value);
    var finalTanggalPengajuan = statusForm.value == false ? tanggalPengajuanInsert : tanggalLemburEditData;
    UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
    Map<String, dynamic> body = {
      'emp_id': getEmCode,
      'dari_jam': dariJam.value.text,
      'sampai_jam': sampaiJam.value.text,
      'atten_date': finalTanggalPengajuan,
      'status': 'PENDING',
      'approve_date': '',
      'em_delegation': validasiDelegasiSelected,
      'uraian': catatan.value.text,
      'ajuan': '2',
      'created_by': getEmpid,
      'menu_name': 'Tugas Luar'
    };
    if (statusForm.value == false) {
      body['activity_name'] =
          "Membuat Pengajuan Tugas Luar. alasan = ${catatan.value.text}";
      var connect = Api.connectionApi("post", body, "insert-emp_labor");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          Navigator.pop(Get.context!);
          var pesan =
              "Pengajuan Form Tugas Luar berhasil dibuat. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah dibuat";
          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan],
          ));
        }
      });
    } else {
      body['val'] = "id";
      body['cari'] = idpengajuanTugasLuar.value;
      body['activity_name'] =
          "Edit Pengajuan Tugas Luar. Tanggal Pengajuan = $finalTanggalPengajuan";
      var connect = Api.connectionApi("post", body, "edit-emp_labor");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          Navigator.pop(Get.context!);
          var pesan =
              "Pengajuan Form Tugas Luar berhasil diedit. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah diedit";
          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan],
          ));
        }
      });
    }
  }

  String validasiSelectedDelegasi() {
    var result = [];
    for (var element in allEmployee.value) {
      var namaDepan = element['first_name'] ?? "";
      var namaBelakang = element['last_name'] ?? "";
      var namaElement = "$namaDepan $namaBelakang";
      if (namaElement == selectedDropdownDelegasi.value) {
        result.add(element);
      }
    }
    return "${result[0]['em_code']}";
  }

  void batalkanPengajuanLembur(index) {
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
      'menu_name': 'Lembur',
      'activity_name':
          'Membatalkan form pengajuan Lembur. Waktu Lembur = ${index["dari_jam"]} sd ${index["sampai_jam"]} Alasan Pengajuan = ${index["reason"]} Tanggal Pengajuan = ${index["atten_date"]}',
      'created_by': '$getEmpId',
      'val': 'id',
      'cari': '${index["id"]}',
    };
    var connect = Api.connectionApi("post", body, "delete-emp_labor");
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
