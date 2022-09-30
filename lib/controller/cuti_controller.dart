import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CutiController extends GetxController {
  var nomorAjuan = TextEditingController().obs;
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
  var tanggalSelected = [].obs;
  var seletedDateEdit = <DateTime>[].obs;

  var stringSelectedTanggal = "".obs;

  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);
  Rx<List<String>> allTipeFormCutiDropdown = Rx<List<String>>([]);

  var jumlahCuti = 0.obs;
  var cutiTerpakai = 0.obs;
  var persenCuti = 0.0.obs;
  var durasiIzin = 0.obs;

  var namaFileUpload = "".obs;
  var selectedTypeCuti = "".obs;
  var selectedDelegasi = "".obs;
  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var idEditFormCuti = "".obs;
  var atten_date_edit = "".obs;
  var stringLoading = "Sedang memuat...".obs;

  var statusForm = false.obs;
  var screenTanggalSelected = true.obs;

  var dataTypeAjuanDummy = ["Semua", "Approve", "Rejected", "Pending"];

  @override
  void onReady() async {
    getTimeNow();
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
        print(data);
        for (var element in data) {
          allTipeFormCutiDropdown.value.add(element['name']);
          var data = {
            'id': element['id'],
            'name': element['name'],
            'status': element['status'],
            'active': false,
          };
          allTipe.value.add(data);
          selectedTypeCuti.value = element['name'];
        }
        var getFirst = allTipe.value.first;
        allTipe.value.firstWhere(
            (element) => element['id'] == getFirst['id'])['active'] = true;
        this.allTipe.refresh();
        this.selectedTypeCuti.refresh();
        this.allTipeFormCutiDropdown.refresh();
      }
    });
  }

  void loadDataAjuanCuti() {
    AlllistHistoryAjuan.value.clear();
    listHistoryAjuan.value.clear();
    stringLoading.value = "Sedang memuat...";
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
      'type': '2',
    };
    var connect = Api.connectionApi("post", body, "history-emp_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          print("tidak ada data kesini");
          stringLoading.value = "Tidak ada pengajuan";
          this.stringLoading.refresh();
        } else {
          AlllistHistoryAjuan.value = valueBody['data'];
          listHistoryAjuan.value = valueBody['data'];
          if (listHistoryAjuan.value.isEmpty) {
            stringLoading.value = "Tidak ada pengajuan";
          } else {
            stringLoading.value = "Sedang memuat...";
          }
          print(listHistoryAjuan.value);
          this.listHistoryAjuan.refresh();
          this.AlllistHistoryAjuan.refresh();
          this.stringLoading.refresh();
        }
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
    if (listHistoryAjuan.value.length == 0) {
      stringLoading.value = "Tidak ada Pengajuan";
    } else {
      stringLoading.value = "Sedang memuat...";
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
          var fullName = listFirst['full_name'] ?? "";
          String namaUserPertama = "$fullName";
          selectedDelegasi.value = namaUserPertama;
          for (var element in data) {
            var fullName = element['full_name'] ?? "";
            String namaUser = "$fullName";
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
    var getEmCode = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'val': 'em_id',
      'cari': getEmCode,
    };
    var connect = Api.connectionApi("post", body, "whereOnce-assign_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var totalDay = valueBody['data'][0]['total_day'];
        var terpakai = valueBody['data'][0]['terpakai'];
        jumlahCuti.value = totalDay;
        cutiTerpakai.value = terpakai;
        this.jumlahCuti.refresh();
        this.cutiTerpakai.refresh();
        hitungCuti(totalDay, terpakai);
      }
    });
  }

  void hitungCuti(totalDay, terpakai) {
    var hitung1 = (terpakai / totalDay) * 100;
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
    if (selectedTypeCuti == "" || alasan.value.text == "") {
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
          checkNomorAjuan();
        } else {
          Navigator.pop(Get.context!);
          UtilsAlert.showToast("Gagal kirim file");
        }
      } else {
        if (statusForm.value == false) {
          if (tanggalSelected.value.isEmpty) {
            UtilsAlert.showToast("Harap isi tanggal ajuan");
          } else {
            checkNomorAjuan();
          }
        } else {
          urutkanTanggalSelected();
          kirimFormAjuanCuti(nomorAjuan.value.text);
        }
      }
    }
  }

  void checkNomorAjuan() {
    urutkanTanggalSelected();
    var dt = DateTime.now();
    var dateString = "${dt.year}-${dt.month}-${dt.day}";
    var afterConvert = Constanst.convertDate1(dateString);
    var convertTanggalBikinPengajuan = statusForm.value == false
        ? Constanst.convertDateSimpan(afterConvert)
        : atten_date_edit.value;

    Map<String, dynamic> body = {
      'atten_date': convertTanggalBikinPengajuan,
      'pola': 'CT'
    };
    var connect = Api.connectionApi("post", body, "emp_leave_lastrow");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          if (valueBody['data'].isEmpty) {
            var now = DateTime.now();
            var convertBulan = now.month <= 9 ? "0${now.month}" : now.month;
            var finalNomor = "CT${now.year}${convertBulan}0001";
            kirimFormAjuanCuti(finalNomor);
          } else {
            var getNomorAjuanTerakhir = valueBody['data'][0]['nomor_ajuan'];
            var keyNomor = getNomorAjuanTerakhir.replaceAll("CT", '');
            var hasilTambah = int.parse(keyNomor) + 1;
            var finalNomor = "CT$hasilTambah";
            kirimFormAjuanCuti(finalNomor);
          }
        } else {
          UtilsAlert.showToast(
              "Data periode $convertTanggalBikinPengajuan belum tersedia, harap hubungi HRD");
        }
      }
    });
  }

  void urutkanTanggalSelected() {
    var hasilConvert = [];
    var tampungStringTanggal = "";
    if (tanggalSelected.value.isNotEmpty) {
      tanggalSelected.value.forEach((element) {
        var inputFormat = DateFormat('yyyy-MM-dd');
        String formatted = inputFormat.format(element);
        hasilConvert.add(formatted);
      });
      hasilConvert.sort((a, b) {
        return DateTime.parse(a).compareTo(DateTime.parse(b));
      });
      var getFirst = hasilConvert.first;
      var getLast = hasilConvert.last;
      dariTanggal.value.text = getFirst;
      sampaiTanggal.value.text = getLast;
      durasiIzin.value = hasilConvert.length;
      hasilConvert.forEach((element) {
        if (tampungStringTanggal == "") {
          tampungStringTanggal = element;
        } else {
          tampungStringTanggal = "$tampungStringTanggal,$element";
        }
      });
      stringSelectedTanggal.value = tampungStringTanggal;
      this.dariTanggal.refresh();
      this.sampaiTanggal.refresh();
      this.durasiIzin.refresh();
      this.stringSelectedTanggal.refresh();
    }
  }

  void kirimFormAjuanCuti(getNomorAjuanTerakhir) async {
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    var validasiTipeSelected = validasiSelectedType();
    var validasiDelegasiSelected = validasiSelectedDelegasi();
    var dt = DateTime.now();
    var dateString = "${dt.year}-${dt.month}-${dt.day}";
    var afterConvert = Constanst.convertDate1(dateString);
    var convertTanggalBikinPengajuan = statusForm.value == false
        ? Constanst.convertDateSimpan(afterConvert)
        : atten_date_edit.value;

    UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan Data");
    Map<String, dynamic> body = {
      'em_id': '$getEmid',
      'typeid': validasiTipeSelected,
      'nomor_ajuan': getNomorAjuanTerakhir,
      'leave_type': 'Full Day',
      'start_date': dariTanggal.value.text,
      'end_date': sampaiTanggal.value.text,
      'leave_duration': durasiIzin.value,
      'date_selected': stringSelectedTanggal.value,
      'apply_date': '',
      'reason': alasan.value.text,
      'leave_status': 'Pending',
      'atten_date': convertTanggalBikinPengajuan,
      'em_delegation': validasiDelegasiSelected,
      'leave_files': namaFileUpload.value,
      'ajuan': '2',
      'created_by': getEmid,
      'menu_name': 'Cuti'
    };
    if (statusForm.value == false) {
      body['activity_name'] =
          "Membuat Pengajuan Cuti. alasan = ${alasan.value.text}";
      var connect = Api.connectionApi("post", body, "insert-emp_leave");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            Navigator.pop(Get.context!);
            var pesan =
                "Pengajuan Form ${selectedTypeCuti.value} berhasil dibuat. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah dibuat";
            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan],
            ));
          } else {
            if (valueBody['message'] == "ulang") {
              checkNomorAjuan();
            } else {
              Navigator.pop(Get.context!);
              UtilsAlert.showToast(
                  "Data periode $convertTanggalBikinPengajuan belum tersedia, harap hubungi HRD");
            }
          }
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
          var valueBody = jsonDecode(res.body);
          print(valueBody['data']);
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
    return "${result[0]['id']}";
  }

  String validasiSelectedDelegasi() {
    var result = [];
    for (var element in allEmployee.value) {
      var fullName = element['full_name'] ?? "";
      var namaElement = "$fullName";
      if (namaElement == selectedDelegasi.value) {
        result.add(element);
      }
    }
    return "${result[0]['em_id']}";
  }

  String validasiHitungIzin() {
    var getDari = dariTanggal.value.text.split('-');
    var getSampai = sampaiTanggal.value.text.split('-');
    var hitung;
    if (getDari[1] == getSampai[1]) {
      hitung = (int.parse(getSampai[0]) - int.parse(getDari[0])) + 1;
    } else {
      // get dari
      var year = int.parse(getDari[2]);
      var bulan = int.parse(getDari[1]);
      DateTime convert1 = new DateTime(year, bulan + 1, 0);
      var allDayMonthDari = "${convert1.day}";
      var proses1 = int.parse(allDayMonthDari) - int.parse(getDari[0]);
      // get sampai
      hitung = (proses1 + int.parse(getSampai[0])) + 1;
    }
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
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'menu_name': 'Cuti',
      'activity_name':
          'Membatalkan form pengajuan Cuti. Tanggal = ${index["start_date"]} sd Tanggal = ${index["end_date"]} Durasi Cuti = ${index["leave_duration"]} Alasan = ${index["reason"]}',
      'created_by': '$getEmid',
      'val': 'id',
      'cari': '${index["id"]}',
      'start_date': '${index["start_date"]}',
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
