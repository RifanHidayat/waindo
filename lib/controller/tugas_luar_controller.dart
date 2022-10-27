import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class TugasLuarController extends GetxController {
  var nomorAjuan = TextEditingController().obs;
  var tanggalLembur = TextEditingController().obs;
  var dariJam = TextEditingController().obs;
  var sampaiJam = TextEditingController().obs;
  var catatan = TextEditingController().obs;
  var cari = TextEditingController().obs;
  var dariTanggal = TextEditingController().obs;
  var sampaiTanggal = TextEditingController().obs;

  var tanggalSelectedEdit = <DateTime>[].obs;

  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);
  Rx<List<String>> allTipeFormTugasLuar = Rx<List<String>>([]);

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var selectedDropdownDelegasi = "".obs;
  var idpengajuanTugasLuar = "".obs;
  var emDelegation = "".obs;
  var valuePolaPersetujuan = "".obs;
  var idEditFormTugasLuar = "".obs;
  var selectedDropdownFormTugasLuarTipe = "".obs;
  var stringSelectedTanggal = "".obs;
  var loadingString = "Sedang Memuat...".obs;

  var statusForm = false.obs;
  var directStatus = false.obs;
  var showButtonlaporan = false.obs;
  var statusCari = false.obs;
  var viewTugasLuar = true.obs;
  var screenTanggalSelected = true.obs;

  var selectedType = 0.obs;
  var durasiIzin = 0.obs;

  var listTugasLuar = [].obs;
  var listTugasLuarAll = [].obs;
  var tampungTugasLuar = [].obs;
  var tampungDinasLuar = [].obs;
  var allEmployee = [].obs;
  var dataTypeAjuan = [].obs;
  var departementAkses = [].obs;
  var tanggalSelected = [].obs;

  Rx<DateTime> initialDate = DateTime.now().obs;

  var dataTypePengajuan = ["Tugas Luar", "Dinas Luar"];

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
    super.onReady();
    getTimeNow();
    getLoadsysData();
    loadTipePengajuan();
    loadDataTugasLuar();
    loadDataDinasLuar();
    loadAllEmployeeDelegasi();
    getDepartemen(1, "");
  }

  void removeAll() {
    tanggalLembur.value.text = "";
    dariJam.value.text = "";
    sampaiJam.value.text = "";
    catatan.value.text = "";
  }

  void getDepartemen(status, tanggal) {
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
              showButtonlaporan.value = true;
            }
          }
        }
      }
    });
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

  void loadTipePengajuan() {
    for (var element in dataTypePengajuan) {
      allTipeFormTugasLuar.value.add("$element");
    }
    var listFirst = allTipeFormTugasLuar.value.first;
    selectedDropdownFormTugasLuarTipe.value = listFirst;
  }

  void gantiTypeAjuan(value) {
    if (value == "Tugas Luar") {
      viewTugasLuar.value = true;
    } else if (value == "Dinas Luar") {
      viewTugasLuar.value = false;
    }
    selectedDropdownFormTugasLuarTipe.value = value;
    this.viewTugasLuar.refresh();
    this.selectedDropdownFormTugasLuarTipe.refresh();
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
      'status': '2'
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
              listTugasLuarAll.value.add(element);
              tampungTugasLuar.value.add(element);
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

  void loadDataDinasLuar() {
    tampungDinasLuar.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "emp_leave_load_dinasluar");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          loadingString.value = "Tidak ada pengajuan";
          this.loadingString.refresh();
        } else {
          tampungDinasLuar.value = valueBody['data'];
          this.tampungDinasLuar.refresh();
        }
      }
    });
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
          if (idpengajuanTugasLuar.value == "") {
            var listFirst = valueBody['data'].first;
            var fullName = listFirst['full_name'] ?? "";
            String namaUserPertama = "$fullName";
            selectedDropdownDelegasi.value = namaUserPertama;
          } else {
            for (var element in allEmployee) {
              if (element['em_id'] == emDelegation.value) {
                selectedDropdownDelegasi.value = element['full_name'];
              }
            }
          }
          this.allEmployee.refresh();
          this.allEmployeeDelegasi.refresh();
          this.selectedDropdownDelegasi.refresh();
        }
      }
    });
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
    listTugasLuarAll.value.forEach((element) {
      if (name == "Semua") {
        dataFilter.add(element);
      } else {
        if (element['status'] == filter) {
          dataFilter.add(element);
        }
      }
    });
    listTugasLuar.value = dataFilter;
    this.listTugasLuar.refresh();
    if (dataFilter.isEmpty) {
      loadingString.value = "Tidak ada Pengajuan";
    } else {
      loadingString.value = "Sedang memuat...";
    }
  }

  void validasiKirimPengajuan() {
    if (selectedDropdownFormTugasLuarTipe == "Tugas Luar") {
      if (tanggalLembur.value.text == "" ||
          dariJam.value.text == "" ||
          sampaiJam.value.text == "" ||
          catatan.value.text == "") {
        print(initialDate.value);
        UtilsAlert.showToast("Lengkapi form *");
      } else {
        if (statusForm.value == false) {
          UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
          checkNomorAjuan();
        } else {
          UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
          kirimPengajuan(nomorAjuan.value.text);
        }
      }
    } else if (selectedDropdownFormTugasLuarTipe == "Dinas Luar") {
      if (tanggalSelected.value.length == 0) {
        UtilsAlert.showToast("Pilih tanggal terlebih dahulu");
      } else if (catatan.value.text == "") {
        UtilsAlert.showToast("Isi catatan terlebih dahulu");
      } else {
        if (statusForm.value == false) {
          UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
          checkNomorAjuanDinasLuar(statusForm.value);
        } else {
          // UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
          // kirimPengajuan(nomorAjuan.value.text);
        }
      }
    }
  }

  void changeTypeSelected(index) {
    if (index == 0) {
      listTugasLuar.value = tampungTugasLuar.value;
      listTugasLuarAll.value = tampungTugasLuar.value;
    } else if (index == 1) {
      var listFilter = [];
      for (var element in tampungDinasLuar.value) {
        var data = {
          'nomor_ajuan': element['nomor_ajuan'],
          'dari_jam': element['start_date'],
          'sampai_jam': element['end_date'],
          'atten_date': element['atten_date'],
          'status': element['leave_status'],
          'alasan_reject': element['alasan_reject'],
          'approve_date': element['apply_date'],
          'uraian': element['reason'],
          'approve_by': element['apply_by'],
        };
        listFilter.add(data);
      }
      listTugasLuar.value = listFilter;
      listTugasLuarAll.value = listFilter;
    }
    selectedType.value = index;
    this.selectedType.refresh(); 
    this.listTugasLuar.refresh();
    this.listTugasLuarAll.refresh();
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

  void checkNomorAjuanDinasLuar(value) {
    urutkanTanggalSelected(value);
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
      'pola': 'DL'
    };
    var connect = Api.connectionApi("post", body, "emp_leave_lastrow");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          if (valueBody['data'].isEmpty) {
            var now = DateTime.now();
            var convertBulan = now.month <= 9 ? "0${now.month}" : now.month;
            var finalNomor = "DL${now.year}${convertBulan}0001";
            kirimPengajuanDinasLuar(value, finalNomor);
          } else {
            var getNomorAjuanTerakhir = valueBody['data'][0]['nomor_ajuan'];
            var keyNomor = getNomorAjuanTerakhir.replaceAll("DL", '');
            var hasilTambah = int.parse(keyNomor) + 1;
            var finalNomor = "DL$hasilTambah";
            kirimPengajuanDinasLuar(value, finalNomor);
          }
        } else {
          UtilsAlert.showToast(
              "Data periode $finalTanggalPengajuan belum tersedia, harap hubungi HRD");
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

  void cariData(value) {
    var textCari = value.toLowerCase();
    var filter = listTugasLuarAll.where((ajuan) {
      var getAjuan = ajuan['nomor_ajuan'].toLowerCase();
      return getAjuan.contains(textCari);
    }).toList();
    listTugasLuar.value = filter;
    statusCari.value = true;
    this.listTugasLuar.refresh();
    this.statusCari.refresh();

    if (listTugasLuar.value.isEmpty) {
      loadingString.value = "Tidak ada pengajuan";
    } else {
      loadingString.value = "Memuat data...";
    }
    this.loadingString.refresh();
  }

  void kirimPengajuan(getNomorAjuanTerakhir) {
    var listTanggal = tanggalLembur.value.text.split(',');
    var getTanggal = listTanggal[1].replaceAll(' ', '');
    var tanggalLemburEditData = Constanst.convertDateSimpan(getTanggal);
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    var getFullName = dataUser[0].full_name;
    var validasiDelegasiSelected = validasiSelectedDelegasi();
    var polaFormat = DateFormat('yyyy-MM-dd');
    var tanggalPengajuanInsert = polaFormat.format(initialDate.value);
    var finalTanggalPengajuan = statusForm.value == false
        ? tanggalPengajuanInsert
        : tanggalLemburEditData;
    var hasilDurasi = hitungDurasi();
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
            kirimNotifikasiToDelegasi(
                getFullName, finalTanggalPengajuan, validasiDelegasiSelected);
            kirimNotifikasiToReportTo(
                getFullName, finalTanggalPengajuan, getEmid, "Tugas Luar");
            Navigator.pop(Get.context!);
            var pesan1 = "Pengajuan Tugas Luar berhasil di buat";
            var pesan2 =
                "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
            var pesan3 = "konfirmasi via WhatsApp";
            var dataPengajuan = {
              'nameType': 'TUGAS LUAR',
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

          var pesan1 = "Pengajuan Tugas Luar berhasil di edit";
          var pesan2 =
              "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
          var pesan3 = "konfirmasi via WhatsApp";
          var dataPengajuan = {
            'nameType': 'TUGAS LUAR',
            'nomor_ajuan': '${getNomorAjuanTerakhir}',
          };
          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
          ));
        }
      });
    }
  }

  void kirimPengajuanDinasLuar(status, getNomorAjuanTerakhir) async {
    var dataUser = AppData.informasiUser;
    var getEmid = "${dataUser![0].em_id}";
    var getFullName = "${dataUser[0].full_name}";
    var validasiDelegasiSelected = validasiSelectedDelegasi();

    // var convertTanggalBikinPengajuan = status == false
    //     ? Constanst.convertDateSimpan("${initialDate.value}")
    //     : tanggalBikinPengajuan.value;

    var polaFormat = DateFormat('yyyy-MM-dd');
    var tanggalPengajuanInsert = polaFormat.format(initialDate.value);

    var convertTanggalBikinPengajuan = tanggalPengajuanInsert;

    Map<String, dynamic> body = {
      'em_id': '$getEmid',
      'typeid': 0,
      'nomor_ajuan': getNomorAjuanTerakhir,
      'leave_type': 'Full Day',
      'start_date': dariTanggal.value.text,
      'end_date': sampaiTanggal.value.text,
      'leave_duration': durasiIzin.value,
      'date_selected': stringSelectedTanggal.value,
      'time_plan': "00:00:00",
      'apply_date': '',
      'reason': catatan.value.text,
      'leave_status': 'Pending',
      'atten_date': convertTanggalBikinPengajuan,
      'em_delegation': validasiDelegasiSelected,
      'leave_files': "",
      'ajuan': "4",
    };
    if (status == false) {
      body['created_by'] = getEmid;
      body['menu_name'] = "Dinas Luar";
      body['activity_name'] =
          "Membuat Pengajuan Dinas Luar. alasan = ${catatan.value.text}";
      var connect = Api.connectionApi("post", body, "kirimPengajuanTMK");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            kirimNotifikasiToDelegasi(getFullName, convertTanggalBikinPengajuan,
                validasiDelegasiSelected);
            kirimNotifikasiToReportTo(getFullName, convertTanggalBikinPengajuan,
                getEmid, "Dinas Luar");
            Navigator.pop(Get.context!);

            var pesan1 = "Pengajuan Dinas Luar berhasil di buat";
            var pesan2 =
                "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
            var pesan3 = "konfirmasi via WhatsApp";
            var dataPengajuan = {
              'nameType': 'Dinas Luar',
              'nomor_ajuan': '${getNomorAjuanTerakhir}',
            };

            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
            ));
          } else {
            if (valueBody['message'] == "ulang") {
              checkNomorAjuanDinasLuar(status);
            } else {
              Navigator.pop(Get.context!);
              UtilsAlert.showToast(
                  "Data periode $convertTanggalBikinPengajuan belum tersedia, harap hubungi HRD");
            }
          }
        }
      });
    } else {
      // body['val'] = 'id';
      // body['cari'] = idEditFormTidakMasukKerja.value;
      // body['created_by'] = getEmid;
      // body['menu_name'] = "Tidak Hadir";
      // body['activity_name'] =
      //     "Edit form pengajuan Tidak Hadir. Tanggal pengajuan = ${dariTanggal.value.text} sd ${sampaiTanggal.value.text} Alasan Pengajuan = ${alasan.value.text}";
      // var connect = Api.connectionApi("post", body, "edit-emp_leave");
      // connect.then((dynamic res) {
      //   if (res.statusCode == 200) {
      //     Navigator.pop(Get.context!);

      //     var pesan1 =
      //         "Pengajuan ${selectedDropdownFormTidakMasukKerjaTipe.value} berhasil di edit";
      //     var pesan2 =
      //         "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
      //     var pesan3 = "konfirmasi via WhatsApp";
      //     var dataPengajuan = {
      //       'nameType': '${selectedDropdownFormTidakMasukKerjaTipe.value}',
      //       'nomor_ajuan': '${getNomorAjuanTerakhir}',
      //     };

      //     Get.offAll(BerhasilPengajuan(
      //       dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
      //     ));
      //   }
      // });
    }
  }

  void kirimNotifikasiToDelegasi(
      getFullName, convertTanggalBikinPengajuan, validasiDelegasiSelected) {
    var dt = DateTime.now();
    var jamSekarang = DateFormat('HH:mm:ss').format(dt);
    Map<String, dynamic> body = {
      'em_id': validasiDelegasiSelected,
      'title': 'Delegasi Pengajuan Tugas Luar',
      'deskripsi':
          'Anda mendapatkan delegasi pekerjaan dari $getFullName untuk pengajuan Tugas Luar',
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
      getFullName, convertTanggalBikinPengajuan, getEmid, type) {
    var dt = DateTime.now();
    var jamSekarang = DateFormat('HH:mm:ss').format(dt);
    Map<String, dynamic> body = {
      'emId_pengaju': getEmid,
      'title': 'Pengajuan Tidak Hadir',
      'deskripsi': 'Anda mendapatkan pengajuan $type dari $getFullName',
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

  String validasiSelectedDelegasi() {
    var result = [];
    for (var element in allEmployee.value) {
      var fullName = element['full_name'] ?? "";
      var namaElement = "$fullName";
      if (namaElement == selectedDropdownDelegasi.value) {
        result.add(element);
      }
    }
    return "${result[0]['em_id']}";
  }

  String hitungDurasi() {
    var format = DateFormat("HH:mm");
    var dari = format.parse("${dariJam.value.text}");
    var sampai = format.parse("${sampaiJam.value.text}");
    var hasil1 = "${sampai.difference(dari)}";
    var hasilAkhir = hasil1.replaceAll(':00.000000', '');
    return "$hasilAkhir";
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
                                  "Batalkan Pengajuan Tugas Luar",
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
