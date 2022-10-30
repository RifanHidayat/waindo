import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_tidakMasukKerja.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class TidakMasukKerjaController extends GetxController {
  var cari = TextEditingController().obs;
  var nomorAjuan = TextEditingController().obs;
  var dariTanggal = TextEditingController().obs;
  var sampaiTanggal = TextEditingController().obs;
  var jamAjuan = TextEditingController().obs;
  var alasan = TextEditingController().obs;
  var departemen = TextEditingController().obs;

  var filePengajuan = File("").obs;

  var dataTypeAjuan = [].obs;
  var AlllistHistoryAjuan = [].obs;
  var allNameLaporanTidakhadir = [].obs;
  var allNameLaporanTidakhadirCopy = [].obs;

  var listHistoryAjuan = [].obs;
  var allTipe = [].obs;
  var allEmployee = [].obs;
  var tanggalSelected = [].obs;
  var departementAkses = [].obs;
  var konfirmasiAtasan = [].obs;
  var tanggalSelectedEdit = <DateTime>[].obs;

  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);
  Rx<List<String>> allTipeFormTidakMasukKerja = Rx<List<String>>([]);

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var namaFileUpload = "".obs;
  var tanggalBikinPengajuan = "".obs;
  var idEditFormTidakMasukKerja = "".obs;
  var emDelegationEdit = "".obs;
  var idDepartemenTerpilih = "".obs;
  var namaDepartemenTerpilih = "".obs;
  var loadingString = "Memuat Data...".obs;

  var stringSelectedTanggal = "".obs;
  var valuePolaPersetujuan = "".obs;

  var selectedTypeAjuan = "Semua".obs;

  var selectedDropdownFormTidakMasukKerjaTipe = "".obs;
  var selectedDropdownFormTidakMasukKerjaDelegasi = "".obs;

  var selectedType = 0.obs;
  var durasiIzin = 0.obs;
  var jumlahData = 0.obs;

  var screenTanggalSelected = true.obs;
  var uploadFile = false.obs;
  var statusCari = false.obs;
  var showTipe = false.obs;
  var showButtonlaporan = false.obs;
  var statusLoadingSubmitLaporan = false.obs;
  var viewFormWaktu = false.obs;

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
    getLoadsysData();
    loadAllEmployeeDelegasi();
    loadTypeSakit();
    loadDataAjuanIzin();
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
    var outputFormat1 = DateFormat('MM');
    var outputFormat2 = DateFormat('yyyy');
    bulanSelectedSearchHistory.value = outputFormat1.format(dt);
    tahunSelectedSearchHistory.value = outputFormat2.format(dt);
    bulanDanTahunNow.value =
        "${bulanSelectedSearchHistory.value}-${tahunSelectedSearchHistory.value}";

    var dateString = "${dt.year}-${dt.month}-${dt.day}";
    var afterConvert = Constanst.convertDate1(dateString);
    if (idEditFormTidakMasukKerja.value == "") {
      dariTanggal.value.text = "$afterConvert";
      sampaiTanggal.value.text = "$afterConvert";
      tanggalBikinPengajuan.value = "$afterConvert";
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

  void loadDataAjuanIzin() {
    AlllistHistoryAjuan.value.clear();
    listHistoryAjuan.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "emp_leave_load_izin");
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
            if (element['category'] == 'FULLDAY') {
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

  void cariData(value) {
    var text = value.toLowerCase();
    var data = [];
    for (var element in AlllistHistoryAjuan) {
      var nomorAjuan = element['nomor_ajuan'].toLowerCase();
      if (nomorAjuan == text) {
        data.add(element);
      }
    }
    if (data.isEmpty) {
      loadingString.value = "Tidak ada pengajuan";
    } else {
      loadingString.value = "Memuat data...";
    }
    listHistoryAjuan.value = data;
    statusCari.value = true;
    this.listHistoryAjuan.refresh();
    this.loadingString.refresh();
    this.statusCari.refresh();
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
          if (idEditFormTidakMasukKerja == "") {
            var listFirst = valueBody['data'].first;
            var fullName = listFirst['full_name'] ?? "";
            String namaUserPertama = "$fullName";
            selectedDropdownFormTidakMasukKerjaDelegasi.value = namaUserPertama;
          } else {
            var getFirst = allEmployee.value.firstWhere(
                (element) => element['em_id'] == emDelegationEdit.value);
            selectedDropdownFormTidakMasukKerjaDelegasi.value =
                getFirst['full_name'];
          }
          this.allEmployee.refresh();
          this.allEmployeeDelegasi.refresh();
          this.selectedDropdownFormTidakMasukKerjaDelegasi.refresh();
        }
      }
    });
  }

  void loadTypeSakit() {
    allTipe.value.clear();
    Map<String, dynamic> body = {'val': 'status', 'cari': '2'};
    var connect = Api.connectionApi("post", body, "whereOnce-leave_types");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        for (var element in data) {
          allTipeFormTidakMasukKerja.value
              .add("${element['name']} - ${element['category']}");
          var data = {
            'type_id': element['id'],
            'name': element['name'],
            'status': element['status'],
            'category': element['category'],
            'ajuan': 2,
            'active': false,
          };
          allTipe.value.add(data);
        }
        if (idEditFormTidakMasukKerja == "") {
          var listFirst = allTipeFormTidakMasukKerja.value.first;
          selectedDropdownFormTidakMasukKerjaTipe.value = listFirst;
        }
        loadTypeIzin();
      }
    });
  }

  void loadTypeIzin() {
    Map<String, dynamic> body = {'val': 'status', 'cari': '3'};
    var connect = Api.connectionApi("post", body, "whereOnce-leave_types");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        for (var element in data) {
          allTipeFormTidakMasukKerja.value
              .add("${element['name']} - ${element['category']}");
          var data = {
            'type_id': element['id'],
            'name': element['name'],
            'status': element['status'],
            'category': element['category'],
            'ajuan': 3,
            'active': false,
          };
          allTipe.value.add(data);
        }
        showTipe.value = true;
        this.showTipe.refresh();
        this.allTipe.refresh();
        this.allTipeFormTidakMasukKerja.refresh();
      }
    });
  }

  void gantiTypeAjuan(value) {
    var listData = value.split('-');
    var kategori = listData[1].replaceAll(' ', '');
    selectedDropdownFormTidakMasukKerjaTipe.value = value;
    if (kategori == "FULLDAY") {
      viewFormWaktu.value = false;
    } else if (kategori == "HALFDAY") {
      viewFormWaktu.value = true;
    }
    this.viewFormWaktu.refresh();
    this.selectedDropdownFormTidakMasukKerjaTipe.refresh();
  }

  void changeTypeSelected(index) {
    print(index);
    listHistoryAjuan.value.clear();
    if (index == 0) {
      AlllistHistoryAjuan.value.forEach((element) {
        if (element['category'] == "FULLDAY") {
          listHistoryAjuan.value.add(element);
        }
      });
    } else {
      AlllistHistoryAjuan.value.forEach((element) {
        if (element['category'] == "HALFDAY") {
          listHistoryAjuan.value.add(element);
        }
      });
    }
    if (idEditFormTidakMasukKerja.value == "") {
      this.allTipe.refresh();
      this.allTipeFormTidakMasukKerja.refresh();
      var listFirst = allTipeFormTidakMasukKerja.value.first;
      selectedDropdownFormTidakMasukKerjaTipe.value = listFirst;
      this.selectedDropdownFormTidakMasukKerjaTipe.refresh();
    }
    loadingString.value = listHistoryAjuan.value.length == 0
        ? "Tidak ada pengajuan"
        : "Memuat data...";
    selectedType.value = index;
    this.loadingString.refresh();
    this.listHistoryAjuan.refresh();
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

  void validasiTypeWhenEdit(value) {
    var selected = [];
    for (var element in allTipe.value) {
      if (element['name'] == value) {
        selected.add(element);
      }
    }
    print('yang select $selected');
    selectedDropdownFormTidakMasukKerjaTipe.value =
        "${selected[0]['name']} - ${selected[0]['category']}";
    this.selectedDropdownFormTidakMasukKerjaTipe.refresh();
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
    if (name == "Semua") {
      var type = selectedType.value == 0 ? "FULLDAY" : "HALFDAY";
      listHistoryAjuan.value.clear();
      for (var element in AlllistHistoryAjuan) {
        if (element['category'] == type) {
          listHistoryAjuan.value.add(element);
        }
      }
      this.listHistoryAjuan.refresh();
      this.selectedType.refresh();
    } else {
      var type = selectedType.value == 0 ? "FULLDAY" : "HALFDAY";
      listHistoryAjuan.value.clear();
      for (var element in AlllistHistoryAjuan.value) {
        if (element['leave_status'] == filter) {
          if (element['category'] == type) {
            listHistoryAjuan.value.add(element);
          }
        }
      }
      this.listHistoryAjuan.refresh();
      this.selectedType.refresh();
    }
    loadingString.value = listHistoryAjuan.value.length != 0
        ? "Memuat data..."
        : "Tidak ada pengajuan";
    this.loadingString.refresh();
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
    if (alasan.value.text == "") {
      UtilsAlert.showToast("Form * harus di isi");
    } else {
      if (uploadFile.value == true) {
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
          UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan Data");
          checkNomorAjuan(status);
        } else {
          UtilsAlert.loadingSimpanData(Get.context!, "Proses edit data");
          urutkanTanggalSelected(status);
          kirimFormAjuanTidakMasukKerja(status, nomorAjuan.value.text);
        }
      }
    }
  }

  void checkNomorAjuan(status) {
    urutkanTanggalSelected(status);
    var convertTanggalBikinPengajuan = status == false
        ? Constanst.convertDateSimpan(tanggalBikinPengajuan.value)
        : tanggalBikinPengajuan.value;

    var pola = selectedDropdownFormTidakMasukKerjaTipe.value ==
            allTipe.value[0]['name']
        ? "SD"
        : "ST";

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

  void urutkanTanggalSelected(status) {
    var hasilConvert = [];
    var tampungStringTanggal = "";
    if (status == true) {
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

  void kirimFormAjuanTidakMasukKerja(status, getNomorAjuanTerakhir) async {
    var dataUser = AppData.informasiUser;
    var getEmid = "${dataUser![0].em_id}";
    var getFullName = "${dataUser[0].full_name}";
    var validasiTipeSelected = validasiSelectedType();
    var getAjuanType = validasiTypeAjuan();
    var validasiDelegasiSelected = validasiSelectedDelegasi();
    var timeValue =
        viewFormWaktu.value == false ? "00:00:00" : "${jamAjuan.value.text}:00";

    var convertTanggalBikinPengajuan = status == false
        ? Constanst.convertDateSimpan(tanggalBikinPengajuan.value)
        : tanggalBikinPengajuan.value;

    Map<String, dynamic> body = {
      'em_id': '$getEmid',
      'typeid': validasiTipeSelected,
      'nomor_ajuan': getNomorAjuanTerakhir,
      'leave_type': 'Full Day',
      'start_date': dariTanggal.value.text,
      'end_date': sampaiTanggal.value.text,
      'leave_duration': durasiIzin.value,
      'date_selected': stringSelectedTanggal.value,
      'time_plan': timeValue,
      'apply_date': '',
      'reason': alasan.value.text,
      'leave_status': 'Pending',
      'atten_date': convertTanggalBikinPengajuan,
      'em_delegation': validasiDelegasiSelected,
      'leave_files': namaFileUpload.value,
      'ajuan': getAjuanType,
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
            var stringTanggal =
                "${dariTanggal.value.text} sd ${sampaiTanggal.value.text}";
            kirimNotifikasiToDelegasi(getFullName, convertTanggalBikinPengajuan,
                validasiDelegasiSelected, stringTanggal);
            kirimNotifikasiToReportTo(getFullName, convertTanggalBikinPengajuan,
                getEmid, stringTanggal);
            Navigator.pop(Get.context!);

            var pesan1 =
                "Pengajuan ${selectedDropdownFormTidakMasukKerjaTipe.value} berhasil di buat";
            var pesan2 =
                "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
            var pesan3 = "konfirmasi via WhatsApp";
            var dataPengajuan = {
              'nameType': '${selectedDropdownFormTidakMasukKerjaTipe.value}',
              'nomor_ajuan': '${getNomorAjuanTerakhir}',
            };

            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
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

          var pesan1 =
              "Pengajuan ${selectedDropdownFormTidakMasukKerjaTipe.value} berhasil di edit";
          var pesan2 =
              "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
          var pesan3 = "konfirmasi via WhatsApp";
          var dataPengajuan = {
            'nameType': '${selectedDropdownFormTidakMasukKerjaTipe.value}',
            'nomor_ajuan': '${getNomorAjuanTerakhir}',
          };

          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
          ));
        }
      });
    }
  }

  void kirimNotifikasiToDelegasi(getFullName, convertTanggalBikinPengajuan,
      validasiDelegasiSelected, stringTanggal) {
    var dt = DateTime.now();
    var jamSekarang = DateFormat('HH:mm:ss').format(dt);
    Map<String, dynamic> body = {
      'em_id': validasiDelegasiSelected,
      'title': 'Delegasi Pengajuan Tidak Hadir',
      'deskripsi':
          'Anda mendapatkan delegasi pekerjaan dari $getFullName untuk pengajuan $selectedDropdownFormTidakMasukKerjaTipe, tanggal pengajuan $stringTanggal',
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

  void kirimNotifikasiToReportTo(
      getFullName, convertTanggalBikinPengajuan, getEmid, stringTanggal) {
    var dt = DateTime.now();
    var jamSekarang = DateFormat('HH:mm:ss').format(dt);
    Map<String, dynamic> body = {
      'emId_pengaju': getEmid,
      'title': 'Pengajuan Tidak Hadir',
      'deskripsi':
          'Anda mendapatkan pengajuan $selectedDropdownFormTidakMasukKerjaTipe dari $getFullName , tanggal pengajuan $stringTanggal',
      'url': '',
      'atten_date': convertTanggalBikinPengajuan,
      'jam': jamSekarang,
      'status': '2',
      'view': '0',
    };
    var connect = Api.connectionApi("post", body, "notifikasi_reportTo");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        UtilsAlert.showToast("Pengajuan berhasil di kirim");
      }
    });
  }

  String validasiSelectedType() {
    var result = [];
    var getDataType = selectedDropdownFormTidakMasukKerjaTipe.value.split('-');
    var kategoriTerpilih = getDataType[0].replaceAll(' ', '');
    for (var element in allTipe.value) {
      var namaType = element['name'].replaceAll(' ', '');
      if (namaType == kategoriTerpilih) {
        result.add(element);
      }
    }
    return "${result[0]['type_id']}";
  }

  int validasiTypeAjuan() {
    var result = [];
    var getDataType = selectedDropdownFormTidakMasukKerjaTipe.value.split('-');
    var kategoriTerpilih = getDataType[0].replaceAll(' ', '');
    for (var element in allTipe.value) {
      var namaType = element['name'].replaceAll(' ', '');
      if (namaType == kategoriTerpilih) {
        result.add(element);
      }
    }
    return result[0]['ajuan'];
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
    return "${result[0]['em_id']}";
  }

  String validasiHitungIzin() {
    var getDari = Constanst.convertOnlyDate(dariTanggal.value.text);
    var getSampai = Constanst.convertOnlyDate(sampaiTanggal.value.text);
    var hitung = (int.parse(getSampai) - int.parse(getDari)) + 1;
    return "$hitung";
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Batalkan Pengajuan",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      index['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Constanst.colorText2),
                                    )
                                  ],
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

  void batalkanPengajuan(index) {
    UtilsAlert.loadingSimpanData(Get.context!, "Batalkan Pengajuan");
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'menu_name': 'Izin',
      'activity_name':
          'Membatalkan form pengajuan Izin. Tanggal pengajuan = ${index["start_date"]} sd ${index["end_date"]} Alasan Pengajuan = ${index["reason"]}',
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

  void pencarianNamaKaryawan(value) {
    var textCari = value.toLowerCase();
    var filter = allNameLaporanTidakhadirCopy.where((laporan) {
      var namaEmployee = laporan['full_name'].toLowerCase();
      return namaEmployee.contains(textCari);
    }).toList();
    allNameLaporanTidakhadir.value = filter;
    statusCari.value = true;
    this.allNameLaporanTidakhadir.refresh();
    this.statusCari.refresh();
  }

  void showDetailRiwayat(detailData) {
    var nomorAjuan = detailData['nomor_ajuan'];
    var tanggalMasukAjuan = detailData['atten_date'];
    var namaTypeAjuan = detailData['name'];
    var tanggalAjuanDari = detailData['start_date'];
    var tanggalAjuanSampai = detailData['end_date'];
    var alasan = detailData['reason'];
    var durasi = detailData['leave_duration'];
    // var typeAjuan = detailData['leave_status'];
    var typeAjuan;
    if (valuePolaPersetujuan.value == "1") {
      typeAjuan = detailData['leave_status'];
    } else {
      typeAjuan = detailData['leave_status'] == "Approve"
          ? "Approve 1"
          : detailData['leave_status'] == "Approve2"
              ? "Approve 2"
              : detailData['leave_status'];
    }
    var jamAjuan = detailData['time_plan'];
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
                                : typeAjuan == 'Approve 1'
                                    ? Constanst.colorBGApprove
                                    : typeAjuan == 'Approve 2'
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
                                    : typeAjuan == 'Approve 1'
                                        ? Icon(
                                            Iconsax.tick_square,
                                            color: Constanst.color5,
                                            size: 14,
                                          )
                                        : typeAjuan == 'Approve 2'
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
                                            : typeAjuan == 'Approve 1'
                                                ? Colors.green
                                                : typeAjuan == 'Approve 2'
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
                    child: Text("Nomor Ajuan"),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(":"),
                  ),
                  Expanded(
                    flex: 68,
                    child: Text("$nomorAjuan"),
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
                    child: Text("Tanggal izin"),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(":"),
                  ),
                  Expanded(
                    flex: 68,
                    child: Text(
                        "${Constanst.convertDate("$tanggalAjuanDari")}  SD  ${Constanst.convertDate("$tanggalAjuanSampai")}"),
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
                    child: Text("Durasi Izin"),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(":"),
                  ),
                  Expanded(
                    flex: 68,
                    child: Text("$durasi Hari"),
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
                    child: Text("Alasan"),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(":"),
                  ),
                  Expanded(
                    flex: 68,
                    child: Text("$alasan"),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              jamAjuan == "" ||
                      jamAjuan == "NULL" ||
                      jamAjuan == null ||
                      jamAjuan == "00:00:00"
                  ? SizedBox()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 30,
                          child: Text("Jam"),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(":"),
                        ),
                        Expanded(
                          flex: 68,
                          child: Text("$jamAjuan"),
                        )
                      ],
                    ),
              jamAjuan == "" ||
                      jamAjuan == "NULL" ||
                      jamAjuan == null ||
                      jamAjuan == "00:00:00"
                  ? SizedBox()
                  : SizedBox(
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
    _launchURL() async => await canLaunch(Api.UrlfileTidakhadir + value)
        ? await launch(Api.UrlfileTidakhadir + value)
        : throw UtilsAlert.showToast('Tidak dapat membuka');
    _launchURL();
  }
}
