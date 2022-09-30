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
  var nomorAjuan = TextEditingController().obs;
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
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "history-emp_labor");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          loadingString.value = "Tidak ada pengajuan";
          this.loadingString.refresh();
        } else {
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
          this.loadingString.refresh();
        }
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
          var fullName = listFirst['full_name'] ?? "";
          String namaUserPertama = "$fullName";
          selectedDropdownDelegasi.value = namaUserPertama;
          for (var element in data) {
            var fullName = element['full_name'] ?? "";
            String namaUser = "$fullName";
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
      if (statusForm.value == false) {
        checkNomorAjuan();
      } else {
        kirimPengajuan(nomorAjuan.value.text);
      }
    }
  }

  void checkNomorAjuan() {
    var listTanggal = tanggalLembur.value.text.split(',');
    var getTanggal = listTanggal[1].replaceAll(' ', '');
    var tanggalLemburEditData = Constanst.convertDateSimpan(getTanggal);
    var polaFormat = DateFormat('yyyy-MM-dd');
    var tanggalPengajuanInsert = polaFormat.format(initialDate.value);
    var finalTanggalPengajuan = statusForm.value == false
        ? tanggalPengajuanInsert
        : tanggalLemburEditData;

    Map<String, dynamic> body = {
      'atten_date': finalTanggalPengajuan,
      'pola': 'TL'
    };
    var connect = Api.connectionApi("post", body, "emp_labor_lastrow");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          if (valueBody['data'].isEmpty) {
            var now = DateTime.now();
            var convertBulan = now.month <= 9 ? "0${now.month}" : now.month;
            var finalNomor = "TL${now.year}${convertBulan}0001";
            kirimPengajuan(finalNomor);
          } else {
            var getNomorAjuanTerakhir = valueBody['data'][0]['nomor_ajuan'];
            var keyNomor = getNomorAjuanTerakhir.replaceAll("TL", '');
            var hasilTambah = int.parse(keyNomor) + 1;
            var finalNomor = "TL$hasilTambah";
            kirimPengajuan(finalNomor);
          }
        } else {
          UtilsAlert.showToast(
              "Data periode $finalTanggalPengajuan belum tersedia, harap hubungi HRD");
        }
      }
    });
  }

  void kirimPengajuan(getNomorAjuanTerakhir) {
    var listTanggal = tanggalLembur.value.text.split(',');
    var getTanggal = listTanggal[1].replaceAll(' ', '');
    var tanggalLemburEditData = Constanst.convertDateSimpan(getTanggal);
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    var validasiDelegasiSelected = validasiSelectedDelegasi();
    var polaFormat = DateFormat('yyyy-MM-dd');
    var tanggalPengajuanInsert = polaFormat.format(initialDate.value);
    var finalTanggalPengajuan = statusForm.value == false
        ? tanggalPengajuanInsert
        : tanggalLemburEditData;
    var hasilDurasi = hitungDurasi();

    UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'nomor_ajuan': getNomorAjuanTerakhir,
      'dari_jam': dariJam.value.text,
      'sampai_jam': sampaiJam.value.text,
      'durasi': hasilDurasi,
      'atten_date': finalTanggalPengajuan,
      'status': 'PENDING',
      'approve_date': '',
      'em_delegation': validasiDelegasiSelected,
      'uraian': catatan.value.text,
      'ajuan': '2',
      'created_by': getEmid,
      'menu_name': 'Tugas Luar'
    };
    if (statusForm.value == false) {
      body['activity_name'] =
          "Membuat Pengajuan Tugas Luar. alasan = ${catatan.value.text}";
      var connect = Api.connectionApi("post", body, "insert-emp_labor");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            Navigator.pop(Get.context!);
            var pesan =
                "Pengajuan Form Tugas Luar berhasil dibuat. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah dibuat";
            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan],
            ));
          } else {
            if (valueBody['message'] == "ulang") {
              checkNomorAjuan();
            } else {
              Navigator.pop(Get.context!);
              UtilsAlert.showToast(
                  "Data periode $finalTanggalPengajuan belum tersedia, harap hubungi HRD");
            }
          }
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
      var fullName = element['full_name'] ?? "";
      var namaElement = "$fullName";
      if (namaElement == selectedDropdownDelegasi.value) {
        result.add(element);
      }
    }
    return "${result[0]['em_code']}";
  }

  String hitungDurasi() {
    var dariJamConvert = dariJam.value.text.replaceAll(':', '');
    var sampaiJamConvert = sampaiJam.value.text.replaceAll(':', '');
    var hitung = int.parse(sampaiJamConvert) - int.parse(dariJamConvert);
    var hitungLength = "$hitung".length;
    var getHour;
    var getMenit;
    if (hitungLength == 3) {
      getHour = "$hitung".substring(0, 1);
      getMenit = "$hitung".substring("$hitung".length - 2);
    } else {
      getHour = "$hitung".substring(0, 2);
      getMenit = "$hitung".substring("$hitung".length - 2);
    }
    var hasilAkhir = "$getHour:$getMenit";
    return "$hasilAkhir";
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
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'menu_name': 'Lembur',
      'activity_name':
          'Membatalkan form pengajuan Lembur. Waktu Lembur = ${index["dari_jam"]} sd ${index["sampai_jam"]} Alasan Pengajuan = ${index["reason"]} Tanggal Pengajuan = ${index["atten_date"]}',
      'created_by': '$getEmid',
      'val': 'id',
      'cari': '${index["id"]}',
      'atten_date': '${index["atten_date"]}',
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
