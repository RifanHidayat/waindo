import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class CutiController extends GetxController {
  var nomorAjuan = TextEditingController().obs;
  var dariTanggal = TextEditingController().obs;
  var sampaiTanggal = TextEditingController().obs;
  var alasan = TextEditingController().obs;
  var cari = TextEditingController().obs;
  var departemen = TextEditingController().obs;

  var filePengajuan = File("").obs;

  var allTipe = [].obs;
  var allEmployee = [].obs;
  var dataTypeAjuan = [].obs;
  var AlllistHistoryAjuan = [].obs;
  var listHistoryAjuan = [].obs;
  var tanggalSelected = [].obs;
  var departementAkses = [].obs;
  var allNameLaporanCuti = [].obs;
  var allNameLaporanCutiCopy = [].obs;
  var tanggalSelectedEdit = <DateTime>[].obs;

  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);
  Rx<List<String>> allTipeFormCutiDropdown = Rx<List<String>>([]);

  var jumlahCuti = 0.obs;
  var typeIdEdit = 0.obs;
  var cutiTerpakai = 0.obs;
  var persenCuti = 0.0.obs;
  var durasiIzin = 0.obs;
  var jumlahData = 0.obs;

  var namaFileUpload = "".obs;
  var stringSelectedTanggal = "".obs;
  var selectedTypeCuti = "".obs;
  var selectedDelegasi = "".obs;
  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var idEditFormCuti = "".obs;
  var atten_date_edit = "".obs;
  var emDelegationEdit = "".obs;
  var idDepartemenTerpilih = "".obs;
  var namaDepartemenTerpilih = "".obs;
  var valuePolaPersetujuan = "".obs;

  var stringLoading = "Sedang memuat...".obs;

  var statusForm = false.obs;
  var statusHitungCuti = false.obs;
  var screenTanggalSelected = true.obs;
  var uploadFile = false.obs;
  var statusCari = false.obs;
  var showButtonlaporan = false.obs;
  var statusLoadingSubmitLaporan = false.obs;

  var dataTypeAjuanDummy1 = ["Semua", "Approve", "Rejected", "Pending"];
  var dataTypeAjuanDummy2 = [
    "Semua",
    "Approve 1",
    "Approve 2",
    "Rejected",
    "Pending"
  ];

  @override
  void onReady() async {
    getTimeNow();
    loadCutiUser();
    getLoadsysData();
    loadAllEmployeeDelegasi();
    loadDataTypeCuti();
    loadDataAjuanCuti();
    getDepartemen(1, "");
    super.onReady();
  }

  void getDepartemen(status, tanggal) {
    jumlahData.value = 0;
    var connect = Api.connectionApi("get", {}, "all_department");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var dataDepartemen = valueBody['data'];

          var dataUser = AppData.informasiUser;
          var hakAkses = dataUser![0].em_hak_akses;
          print(hakAkses);
          if (hakAkses != "" || hakAkses != null) {
            if (hakAkses == '0') {
              var data = {
                'id': 0,
                'name': 'SEMUA DIVISI',
                'inisial': 'AD',
                'parent_id': '',
                'aktif': '',
                'pakai': '',
                'ip': '',
                'created_by': '',
                'created_on': '',
                'modified_by': '',
                'modified_on': ''
              };
              departementAkses.add(data);
            }
            var convert = hakAkses!.split(',');
            for (var element in dataDepartemen) {
              if (hakAkses == '0') {
                departementAkses.add(element);
              }
              for (var element1 in convert) {
                if ("${element['id']}" == element1) {
                  print('sampe sini');
                  departementAkses.add(element);
                }
              }
            }
          }
          this.departementAkses.refresh();
          if (departementAkses.value.isNotEmpty) {
            if (status == 1) {
              idDepartemenTerpilih.value = "${departementAkses[0]['id']}";
              namaDepartemenTerpilih.value = departementAkses[0]['name'];
              departemen.value.text = departementAkses[0]['name'];
              showButtonlaporan.value = true;
            }
          }
        }
      }
    });
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

  void getLoadsysData() {
    var connect = Api.connectionApi("get", "", "sysdata");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        for (var element in valueBody['data']) {
          if (element['kode'] == "013") {
            valuePolaPersetujuan.value = "${element['name']}";
            this.valuePolaPersetujuan.refresh();
            getTypeAjuan();
          }
        }
      }
    });
  }

  void getTypeAjuan() {
    if (valuePolaPersetujuan.value == "1") {
      dataTypeAjuan.value.clear();
      for (var element in dataTypeAjuanDummy1) {
        var data = {'nama': element, 'status': false};
        dataTypeAjuan.value.add(data);
      }
      dataTypeAjuan.value
          .firstWhere((element) => element['nama'] == 'Semua')['status'] = true;
      this.dataTypeAjuan.refresh();
    } else {
      dataTypeAjuan.value.clear();
      for (var element in dataTypeAjuanDummy2) {
        var data = {'nama': element, 'status': false};
        dataTypeAjuan.value.add(data);
      }
      dataTypeAjuan.value
          .firstWhere((element) => element['nama'] == 'Semua')['status'] = true;
      this.dataTypeAjuan.refresh();
    }
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
        for (var element in data) {
          allTipeFormCutiDropdown.value.add(element['name']);
          var data = {
            'id': element['id'],
            'name': element['name'],
            'status': element['status'],
            'active': false,
          };
          allTipe.value.add(data);
        }
        if (statusForm.value == false) {
          var getFirst = allTipe.value.first;
          selectedTypeCuti.value = getFirst['name'];
        } else {
          var getFirst = allTipe.value
              .firstWhere((element) => element['id'] == typeIdEdit.value);
          selectedTypeCuti.value = getFirst['name'];
        }
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
      'ajuan': '1',
    };
    var connect = Api.connectionApi("post", body, "history-emp_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
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
          this.listHistoryAjuan.refresh();
          this.AlllistHistoryAjuan.refresh();
          this.stringLoading.refresh();
        }
      }
    });
  }

  void cariData(value) {
    var text = value.toLowerCase();
    var data = [];
    for (var element in AlllistHistoryAjuan.value) {
      var nomorAjuan = element['nomor_ajuan'].toLowerCase();
      if (nomorAjuan == text) {
        data.add(element);
      }
    }
    if (data.isEmpty) {
      stringLoading.value = "Tidak ada pengajuan";
    } else {
      stringLoading.value = "Memuat data...";
    }
    print(data);
    listHistoryAjuan.value = data;
    statusCari.value = true;
    this.listHistoryAjuan.refresh();
    this.stringLoading.refresh();
    this.statusCari.refresh();
  }

  void changeTypeAjuan(name) {
    var filter = name == "Approve 1"
        ? "Approve"
        : name == "Approve 2"
            ? "Approve2"
            : name == "Rejected"
                ? "Rejected"
                : name == "Pending"
                    ? "Pending"
                    : "Approve";
    for (var element in dataTypeAjuan.value) {
      if (element['nama'] == name) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    }
    this.dataTypeAjuan.refresh();
    var dataFilter = [];
    AlllistHistoryAjuan.value.forEach((element) {
      if (name == "Semua") {
        dataFilter.add(element);
      } else {
        if (element['leave_status'] == filter) {
          dataFilter.add(element);
        }
      }
    });
    listHistoryAjuan.value = dataFilter;
    this.listHistoryAjuan.refresh();
    if (dataFilter.isEmpty) {
      stringLoading.value = "Tidak ada Pengajuan";
    } else {
      stringLoading.value = "Sedang memuat...";
    }
  }

  void loadAllEmployeeDelegasi() {
    allEmployeeDelegasi.value.clear();
    allEmployee.value.clear();
    var dataUser = AppData.informasiUser;
    var getDepGroup = dataUser![0].dep_group;
    var full_name = dataUser[0].full_name;
    Map<String, dynamic> body = {'val': 'dep_group_id', 'cari': getDepGroup};
    var connect = Api.connectionApi("post", body, "whereOnce-employee");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var data = valueBody['data'];
          for (var element in data) {
            var fullName = element['full_name'] ?? "";
            String namaUser = "$fullName";
            if (namaUser != full_name) {
              allEmployeeDelegasi.value.add(namaUser);
            }
            allEmployee.value.add(element);
          }
          if (statusForm.value == false) {
            var listFirst = valueBody['data'].first;
            var fullName = listFirst['full_name'] ?? "";
            String namaUserPertama = "$fullName";
            selectedDelegasi.value = namaUserPertama;
          } else {
            var listFirst = allEmployee.value.firstWhere(
                (element) => element['em_id'] == emDelegationEdit.value);
            var fullName = listFirst['full_name'] ?? "";
            String namaUserPertama = "$fullName";
            selectedDelegasi.value = namaUserPertama;
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
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'val': 'em_id',
      'cari': getEmid,
    };
    var connect = Api.connectionApi("post", body, "whereOnce-assign_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].isNotEmpty) {
          var totalDay = valueBody['data'][0]['total_day'];
          var terpakai = valueBody['data'][0]['terpakai'];
          print("ini data cuti user ${valueBody['data']}");
          if (totalDay == 0) {
            statusHitungCuti.value = false;
            this.statusHitungCuti.refresh();
          } else {
            jumlahCuti.value = totalDay;
            cutiTerpakai.value = terpakai;
            this.jumlahCuti.refresh();
            this.cutiTerpakai.refresh();
            statusHitungCuti.value = true;
            hitungCuti(totalDay, terpakai);
            this.statusHitungCuti.refresh();
          }
        } else {
          statusHitungCuti.value = false;
          this.statusHitungCuti.refresh();
        }
      }
    });
  }

  void hitungCuti(totalDay, terpakai) {
    var hitung1 = (terpakai / totalDay) * 100;
    // var convert1 = hitung1.toInt();
    var convert1 = hitung1;
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
        uploadFile.value = true;
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
      int hitung = jumlahCuti.value - cutiTerpakai.value;
      if (hitung <= 0 || hitung == 0) {
        UtilsAlert.showToast("Cuti anda sudah habis");
      } else {
        if (uploadFile.value == true) {
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
              UtilsAlert.loadingSimpanData(
                  Get.context!, "Sedang Menyimpan Data");
              checkNomorAjuan();
            }
          } else {
            UtilsAlert.loadingSimpanData(Get.context!, "Proses edit data");
            urutkanTanggalSelected();
            kirimFormAjuanCuti(nomorAjuan.value.text);
          }
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
    if (statusForm.value == true) {
      if (tanggalSelectedEdit.value.isNotEmpty) {
        tanggalSelectedEdit.value.forEach((element) {
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
    } else {
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
  }

  void kirimFormAjuanCuti(getNomorAjuanTerakhir) async {
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    var getFullName = dataUser[0].full_name;
    var validasiTipeSelected = validasiSelectedType();
    var validasiDelegasiSelected = validasiSelectedDelegasi();
    var dt = DateTime.now();
    var dateString = "${dt.year}-${dt.month}-${dt.day}";
    var afterConvert = Constanst.convertDate1(dateString);
    var convertTanggalBikinPengajuan = statusForm.value == false
        ? Constanst.convertDateSimpan(afterConvert)
        : atten_date_edit.value;
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
      'ajuan': '1',
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
            kirimNotifikasiToDelegasi(getFullName, convertTanggalBikinPengajuan,
                validasiDelegasiSelected);
            Navigator.pop(Get.context!);

            var pesan1 = "Pengajuan ${selectedTypeCuti.value} berhasil di buat";
            var pesan2 =
                "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
            var pesan3 = "konfirmasi via WhatsApp";
            var dataPengajuan = {
              'nameType': '${selectedTypeCuti.value}',
              'nomor_ajuan': '${getNomorAjuanTerakhir}',
            };

            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
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
          Navigator.pop(Get.context!);

          var pesan1 = "Pengajuan ${selectedTypeCuti.value} berhasil di edit";
          var pesan2 =
              "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
          var pesan3 = "konfirmasi via WhatsApp";
          var dataPengajuan = {
            'nameType': '${selectedTypeCuti.value}',
            'nomor_ajuan': '${getNomorAjuanTerakhir}',
          };

          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
          ));
        }
      });
    }
  }

  void kirimNotifikasiToDelegasi(
      getFullName, convertTanggalBikinPengajuan, validasiDelegasiSelected) {
    var dt = DateTime.now();
    var jamSekarang = DateFormat('HH:mm:ss').format(dt);
    Map<String, dynamic> body = {
      'em_id': validasiDelegasiSelected,
      'title': 'Delegasi Pengajuan Cuti',
      'deskripsi':
          'Anda mendapatkan delegasi pekerjaan dari $getFullName untuk pengajuan $selectedTypeCuti',
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

  void showModalBatalPengajuan(index) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 90,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Constanst.colorBGRejected,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Iconsax.minus_cirlce,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Text(
                                  "Batalkan Pengajuan Cuti",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 10,
                          child: InkWell(
                            onTap: () => Navigator.pop(Get.context!),
                            child: Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(Iconsax.close_circle),
                            ),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Data pengajuan yang telah kamu buat akan di hapus. Yakin ingin membatalkan pengajuan?",
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Constanst.colorText2),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: TextButtonWidget(
                            title: "Ya, Batalkan",
                            onTap: () async {
                              batalkanPengajuan(index);
                            },
                            colorButton: Constanst.colorButton1,
                            colortext: Constanst.colorWhite,
                            border: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(Get.context!),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: Constanst.borderStyle2,
                                  border: Border.all(
                                      color: Constanst.colorPrimary)),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12, bottom: 12),
                                  child: Text(
                                    "Urungkan",
                                    style: TextStyle(
                                        color: Constanst.colorPrimary),
                                  ),
                                ),
                              )),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            )
          ],
        );
      },
    );
  }

  void showDetailRiwayat(detailData) {
    var nomorAjuan = detailData['nomor_ajuan'];
    var tanggalMasukAjuan = detailData['atten_date'];
    var namaTypeAjuan = detailData['name'];
    var tanggalAjuanDari = detailData['start_date'];
    var tanggalAjuanSampai = detailData['end_date'];
    var alasan = detailData['reason'];
    var durasi = detailData['leave_duration'];
    var typeAjuan = detailData['leave_status'];
    var leave_files = detailData['leave_files'];
    var listTanggalTerpilih = detailData['date_selected'].split(',');
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 16,
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$namaTypeAjuan",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                              "${Constanst.convertDate("$tanggalMasukAjuan")}"),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 40,
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: typeAjuan == 'Approve'
                                ? Constanst.colorBGApprove
                                : typeAjuan == 'Rejected'
                                    ? Constanst.colorBGRejected
                                    : typeAjuan == 'Pending'
                                        ? Constanst.colorBGPending
                                        : Colors.grey,
                            borderRadius: Constanst.borderStyle1,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 3, right: 3, top: 5, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                typeAjuan == 'Approve'
                                    ? Icon(
                                        Iconsax.tick_square,
                                        color: Constanst.color5,
                                        size: 14,
                                      )
                                    : typeAjuan == 'Rejected'
                                        ? Icon(
                                            Iconsax.close_square,
                                            color: Constanst.color4,
                                            size: 14,
                                          )
                                        : typeAjuan == 'Pending'
                                            ? Icon(
                                                Iconsax.timer,
                                                color: Constanst.color3,
                                                size: 14,
                                              )
                                            : SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Text(
                                    '$typeAjuan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: typeAjuan == 'Approve'
                                            ? Colors.green
                                            : typeAjuan == 'Rejected'
                                                ? Colors.red
                                                : typeAjuan == 'Pending'
                                                    ? Constanst.color3
                                                    : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Divider(
                height: 5,
                color: Constanst.colorText2,
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nomor Ajuan"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(":"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$nomorAjuan"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tanggal Cuti"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(":"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${Constanst.convertDate("$tanggalAjuanDari")}  SD  ${Constanst.convertDate("$tanggalAjuanSampai")}"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Durasi Cuti"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(":"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$durasi Hari"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Alasan"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(":"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$alasan"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              leave_files == "" || leave_files == "NULL" || leave_files == null
                  ? SizedBox()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 30,
                          child: Text("File Ajuan"),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(":"),
                        ),
                        Expanded(
                          flex: 68,
                          child: InkWell(
                              onTap: () {
                                viewLampiranAjuan(leave_files);
                              },
                              child: Text(
                                "$leave_files",
                                style: TextStyle(
                                  color: Constanst.colorPrimary,
                                  decoration: TextDecoration.underline,
                                ),
                              )),
                        )
                      ],
                    ),
              leave_files == "" || leave_files == "NULL" || leave_files == null
                  ? SizedBox()
                  : SizedBox(
                      height: 8,
                    ),
              Text("Tanggal Terpilih"),
              SizedBox(
                height: 8,
              ),
              ListView.builder(
                  itemCount: listTanggalTerpilih.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var nomor = index + 1;
                    var tanggalConvert =
                        Constanst.convertDate1(listTanggalTerpilih[index]);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$nomor."),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(tanggalConvert),
                        )
                      ],
                    );
                  }),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        );
      },
    );
  }

  void viewLampiranAjuan(value) {
    _launchURL() async => await canLaunch(Api.UrlfileCuti + value)
        ? await launch(Api.UrlfileCuti + value)
        : throw UtilsAlert.showToast('Tidak dapat membuka');
    _launchURL();
  }
}
