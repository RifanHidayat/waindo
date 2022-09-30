import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_tidakMasukKerja.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:file_picker/file_picker.dart';

class TidakMasukKerjaController extends GetxController {
  var cari = TextEditingController().obs;
  var nomorAjuan = TextEditingController().obs;
  var dariTanggal = TextEditingController().obs;
  var sampaiTanggal = TextEditingController().obs;
  var alasan = TextEditingController().obs;

  var filePengajuan = File("").obs;

  var dataTypeAjuan = [].obs;
  var AlllistHistoryAjuan = [].obs;
  var listHistoryAjuan = [].obs;
  var allTipe = [].obs;
  var allEmployee = [].obs;
  var tanggalSelected = [].obs;

  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);
  Rx<List<String>> allTipeFormTidakMasukKerja = Rx<List<String>>([]);

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var namaFileUpload = "".obs;
  var tanggalBikinPengajuan = "".obs;
  var idEditFormTidakMasukKerja = "".obs;
  var loadingString = "Memuat Data...".obs;

  var testing = "".obs;

  var selectedTypeAjuan = "Semua".obs;

  var selectedDropdownFormTidakMasukKerjaTipe = "".obs;
  var selectedDropdownFormTidakMasukKerjaDelegasi = "".obs;

  var selectedType = 0.obs;
  var durasiIzin = 0.obs;
  var screenTanggalSelected = true.obs;

  var dataTypeAjuanDummy = ["Semua", "Approve", "Rejected", "Pending"];

  @override
  void onReady() async {
    super.onReady();
    getTimeNow();
    getTypeAjuan();
    loadDataAjuanTidakMasukKerja();
    loadAllEmployeeDelegasi();
    loadDataLeaveTypeTidakMasukKerja();
  }

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";

    var dateString = "${dt.year}-${dt.month}-${dt.day}";
    var afterConvert = Constanst.convertDate1(dateString);
    if (idEditFormTidakMasukKerja.value == "") {
      dariTanggal.value.text = "$afterConvert";
      sampaiTanggal.value.text = "$afterConvert";
      tanggalBikinPengajuan.value = "$afterConvert";
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

  void loadDataAjuanTidakMasukKerja() {
    AlllistHistoryAjuan.value.clear();
    listHistoryAjuan.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
      'type': '1',
    };
    var connect = Api.connectionApi("post", body, "history-emp_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          loadingString.value = "Tidak ada pengajuan";
          this.loadingString.refresh();
        } else {
          if (valueBody['data'].length == 0) {
            loadingString.value = "Tidak ada pengajuan";
          } else {
            loadingString.value = "Sedang memuat data...";
          }
          AlllistHistoryAjuan.value = valueBody['data'];
          for (var element in valueBody['data']) {
            if (element['name'] == "Sakit") {
              listHistoryAjuan.value.add(element);
            }
          }
          this.listHistoryAjuan.refresh();
          this.AlllistHistoryAjuan.refresh();
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
          selectedDropdownFormTidakMasukKerjaDelegasi.value = namaUserPertama;
          for (var element in data) {
            var fullName = element['full_name'] ?? "";
            String namaUser = "$fullName";
            allEmployeeDelegasi.value.add(namaUser);
            allEmployee.value.add(element);
          }
          this.allEmployee.refresh();
          this.allEmployeeDelegasi.refresh();
          this.selectedDropdownFormTidakMasukKerjaDelegasi.refresh();
        }
      }
    });
  }

  void loadDataLeaveTypeTidakMasukKerja() {
    listHistoryAjuan.value.clear();
    allTipe.value.clear();
    Map<String, dynamic> body = {'val': 'status', 'cari': '2'};
    var connect = Api.connectionApi("post", body, "whereOnce-leave_types");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        if (idEditFormTidakMasukKerja.value == "") {
          var listFirst = valueBody['data'].first;
          selectedDropdownFormTidakMasukKerjaTipe.value = listFirst['name'];
        }
        for (var element in data) {
          allTipeFormTidakMasukKerja.value.add(element['name']);
          var data = {
            'type_id': element['element'],
            'name': element['name'],
            'status': element['status'],
            'active': false,
          };
          allTipe.value.add(element);
        }
        var getFirst = allTipe.value.first;
        allTipe.value.firstWhere((element) =>
            element['type_id'] == getFirst['type_id'])['active'] = true;
        selectedType.value = getFirst['type_id'];
        this.selectedType.refresh();
        this.allTipe.refresh();
        this.allTipeFormTidakMasukKerja.refresh();
        this.selectedDropdownFormTidakMasukKerjaTipe.refresh();
      }
    });
  }

  void changeTypeSelected(index) {
    print(index);
    listHistoryAjuan.value.clear();
    AlllistHistoryAjuan.value.forEach((element) {
      if (element['typeid'] == index) {
        listHistoryAjuan.value.add(element);
      }
    });
    allTipe.value.forEach((element) {
      if (element['type_id'] == index) {
        element['active'] = true;
      } else {
        element['active'] = false;
      }
    });
    selectedType.value = index;
    this.listHistoryAjuan.refresh();
    this.allTipe.refresh();
    this.selectedType.refresh();
    typeAjuanRefresh("Semua");
  }

  void typeAjuanRefresh(name) {
    for (var element in dataTypeAjuan.value) {
      if (element['nama'] == name) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    }
    this.dataTypeAjuan.refresh();
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
        if (element['typeid'] == selectedType.value) {
          listHistoryAjuan.value.add(element);
        }
      });
      this.listHistoryAjuan.refresh();
      this.selectedType.refresh();
    } else {
      listHistoryAjuan.value.clear();
      for (var element in AlllistHistoryAjuan.value) {
        if (element['leave_status'] == name) {
          if (element['typeid'] == selectedType.value) {
            listHistoryAjuan.value.add(element);
          }
        }
      }
      this.listHistoryAjuan.refresh();
      this.selectedType.refresh();
    }
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
        // print(file.name);
        // print(file.bytes);
        // print(file.size);
        // print(file.extension);
        // print(file.path);
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

  void validasiKirimPengajuan(status) async {
    if (selectedDropdownFormTidakMasukKerjaTipe == "" ||
        dariTanggal.value.text == "" ||
        sampaiTanggal.value.text == "" ||
        alasan.value.text == "") {
      UtilsAlert.showToast("Form * harus di isi");
    } else {
      if (namaFileUpload.value != "") {
        UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan File");
        var connectUpload = await Api.connectionApiUploadFile(
            "upload_form_tidakMasukKerja", filePengajuan.value);
        var valueBody = jsonDecode(connectUpload);
        if (valueBody['status'] == true) {
          UtilsAlert.showToast("Berhasil upload file");
          Navigator.pop(Get.context!);
          checkNomorAjuan(status);
        } else {
          UtilsAlert.showToast("Gagal kirim file");
        }
      } else {
        if (status == false) {
          checkNomorAjuan(status);
        } else {
          urutkanTanggalSelected();
          kirimFormAjuanTidakMasukKerja(status, nomorAjuan.value.text);
        }
      }
    }
  }

  void checkNomorAjuan(status) {
    urutkanTanggalSelected();
    var convertTanggalBikinPengajuan = status == false
        ? Constanst.convertDateSimpan(tanggalBikinPengajuan.value)
        : tanggalBikinPengajuan.value;

    var pola =
        selectedDropdownFormTidakMasukKerjaTipe.value == "Sakit" ? "SK" : "IZ";

    Map<String, dynamic> body = {
      'atten_date': convertTanggalBikinPengajuan,
      'pola': pola
    };
    var connect = Api.connectionApi("post", body, "emp_leave_lastrow");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          if (valueBody['data'].isEmpty) {
            var now = DateTime.now();
            var convertBulan = now.month <= 9 ? "0${now.month}" : now.month;
            var finalNomor = "$pola${now.year}${convertBulan}0001";
            kirimFormAjuanTidakMasukKerja(status, finalNomor);
          } else {
            var getNomorAjuanTerakhir = valueBody['data'][0]['nomor_ajuan'];
            var keyNomor = getNomorAjuanTerakhir.replaceAll("$pola", '');
            var hasilTambah = int.parse(keyNomor) + 1;
            var finalNomor = "$pola$hasilTambah";
            kirimFormAjuanTidakMasukKerja(status, finalNomor);
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
    tanggalSelected.value.forEach((element) {
      var inputFormat = DateFormat('yyyy-MM-dd');
      String formatted = inputFormat.format(element);
      hasilConvert.add(formatted);
    });
    hasilConvert.sort((a, b) {
      return DateTime.parse(a).compareTo(DateTime.parse(b));
    });
    if (hasilConvert.isNotEmpty) {
      var getFirst = hasilConvert.first;
      var getLast = hasilConvert.last;
      dariTanggal.value.text = getFirst;
      sampaiTanggal.value.text = getLast;
      durasiIzin.value = hasilConvert.length;
      this.dariTanggal.refresh();
      this.sampaiTanggal.refresh();
      this.durasiIzin.refresh();
    }
  }

  void kirimFormAjuanTidakMasukKerja(status, getNomorAjuanTerakhir) async {
    var dataUser = AppData.informasiUser;
    var getEmid = "${dataUser![0].em_id}";
    var validasiTipeSelected = validasiSelectedType();
    var validasiDelegasiSelected = validasiSelectedDelegasi();

    var convertTanggalBikinPengajuan = status == false
        ? Constanst.convertDateSimpan(tanggalBikinPengajuan.value)
        : tanggalBikinPengajuan.value;
    UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan Data");
    Map<String, dynamic> body = {
      'em_id': '$getEmid',
      'typeid': validasiTipeSelected,
      'nomor_ajuan': getNomorAjuanTerakhir,
      'leave_type': 'Full Day',
      'start_date': dariTanggal.value.text,
      'end_date': sampaiTanggal.value.text,
      'leave_duration': durasiIzin.value,
      'apply_date': '',
      'reason': alasan.value.text,
      'leave_status': 'Pending',
      'atten_date': convertTanggalBikinPengajuan,
      'em_delegation': validasiDelegasiSelected,
      'leave_files': namaFileUpload.value,
      'ajuan': '1',
    };
    if (status == false) {
      body['created_by'] = getEmid;
      body['menu_name'] = "Tidak Hadir";
      body['activity_name'] =
          "Membuat Pengajuan tidak hadir. alasan = ${alasan.value.text}";
      var connect = Api.connectionApi("post", body, "kirimPengajuanTMK");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            Navigator.pop(Get.context!);
            var pesan =
                "Pengajuan Form ${selectedDropdownFormTidakMasukKerjaTipe.value} berhasil dibuat. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah dibuat";
            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan],
            ));
          } else {
            if (valueBody['message'] == "ulang") {
              checkNomorAjuan(status);
            } else {
              Navigator.pop(Get.context!);
              UtilsAlert.showToast(
                  "Data periode $convertTanggalBikinPengajuan belum tersedia, harap hubungi HRD");
            }
          }
        }
      });
    } else {
      body['val'] = 'id';
      body['cari'] = idEditFormTidakMasukKerja.value;
      body['created_by'] = getEmid;
      body['menu_name'] = "Tidak Hadir";
      body['activity_name'] =
          "Edit form pengajuan Tidak Hadir. Tanggal pengajuan = ${dariTanggal.value.text} sd ${sampaiTanggal.value.text} Alasan Pengajuan = ${alasan.value.text}";
      var connect = Api.connectionApi("post", body, "edit-emp_leave");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          Navigator.pop(Get.context!);
          var pesan =
              "Pengajuan Form ${selectedDropdownFormTidakMasukKerjaTipe.value} berhasil diedit. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah diedit";
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
      if (element['name'] == selectedDropdownFormTidakMasukKerjaTipe.value) {
        result.add(element);
      }
    }
    return "${result[0]['type_id']}";
  }

  String validasiSelectedDelegasi() {
    var result = [];
    for (var element in allEmployee.value) {
      var fullName = element['full_name'] ?? "";
      var namaElement = "$fullName";
      if (namaElement == selectedDropdownFormTidakMasukKerjaDelegasi.value) {
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

  void batalkanPengajuanTidakMasuk(index) {
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
      'menu_name': 'Tidak Hadir',
      'activity_name':
          'Membatalkan form pengajuan Tidak Hadir. Tanggal pengajuan = ${index["start_date"]} sd ${index["end_date"]} Alasan Pengajuan = ${index["reason"]}',
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
