import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class LemburController extends GetxController {
  var nomorAjuan = TextEditingController().obs;
  var tanggalLembur = TextEditingController().obs;
  var dariJam = TextEditingController().obs;
  var sampaiJam = TextEditingController().obs;
  var durasi = TextEditingController().obs;
  var catatan = TextEditingController().obs;

  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var selectedDropdownDelegasi = "".obs;
  var idpengajuanLembur = "".obs;
  var emIdDelegasi = "".obs;
  var loadingString = "Sedang Memuat...".obs;

  var statusForm = false.obs;
  var directStatus = false.obs;

  var listLembur = [].obs;
  var listLemburAll = [].obs;
  var allEmployee = [].obs;
  var dataTypeAjuan = [].obs;

  Rx<DateTime> initialDate = DateTime.now().obs;

  var dataTypeAjuanDummy = ["Semua", "Approve", "Rejected", "Pending"];

  @override
  void onReady() async {
    super.onReady();
    getTimeNow();
    getTypeAjuan();
    loadDataLembur();
    loadAllEmployeeDelegasi();
  }

  void removeAll() {
    tanggalLembur.value.text = "";
    dariJam.value.text = "";
    sampaiJam.value.text = "";
    catatan.value.text = "";
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

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";

    if (idpengajuanLembur.value == "") {
      tanggalLembur.value.text = Constanst.convertDate("${initialDate.value}");
    }

    this.tanggalLembur.refresh();
    this.bulanSelectedSearchHistory.refresh();
    this.tahunSelectedSearchHistory.refresh();
    this.bulanDanTahunNow.refresh();
  }

  void loadDataLembur() {
    listLemburAll.value.clear();
    listLembur.value.clear();
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
            if (element['ajuan'] == 1) {
              listLembur.value.add(element);
              listLemburAll.value.add(element);
            }
          }
          if (listLembur.value.length == 0) {
            loadingString.value = "Tidak ada pengajuan";
          } else {
            loadingString.value = "Sedang Memuat...";
          }

          this.listLembur.refresh();
          this.listLemburAll.refresh();
          this.loadingString.refresh();
        }
      }
    });
  }

  void loadAllEmployeeDelegasi() {
    allEmployeeDelegasi.value.clear();
    allEmployee.value.clear();
    var dataUser = AppData.informasiUser;
    var getDepGroup = dataUser![0].dep_group;
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
            allEmployeeDelegasi.value.add(namaUser);
            allEmployee.value.add(element);
          }
          if (idpengajuanLembur.value == "") {
            var listFirst = valueBody['data'].first;
            var fullName = listFirst['full_name'] ?? "";
            String namaUserPertama = "$fullName";
            selectedDropdownDelegasi.value = namaUserPertama;
          } else {
            for (var element in allEmployee) {
              if (element['em_id'] == emIdDelegasi.value) {
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

  void validasiKirimPengajuan() {
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
      'pola': 'LB'
    };
    var connect = Api.connectionApi("post", body, "emp_labor_lastrow");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          var data = valueBody['data'];
          print(data);
          if (valueBody['data'].length == 0) {
            var now = DateTime.now();
            var convertBulan = now.month <= 9 ? "0${now.month}" : now.month;
            var finalNomor = "LB${now.year}${convertBulan}0001";
            kirimPengajuan(finalNomor);
          } else {
            var getNomorAjuanTerakhir = valueBody['data'][0]['nomor_ajuan'];
            var keyNomor = getNomorAjuanTerakhir.replaceAll("LB", '');
            var hasilTambah = int.parse(keyNomor) + 1;
            var finalNomor = "LB$hasilTambah";
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
      'ajuan': '1',
      'created_by': getEmid,
      'menu_name': 'Lembur'
    };
    if (statusForm.value == false) {
      print("sampe sini input");
      body['activity_name'] =
          "Membuat Pengajuan Lembur. alasan = ${catatan.value.text}";
      var connect = Api.connectionApi("post", body, "insert-emp_labor");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            kirimNotifikasiToDelegasi(
                getFullName, finalTanggalPengajuan, validasiDelegasiSelected);
            Navigator.pop(Get.context!);
            var pesan =
                "Pengajuan Form lembur berhasil dibuat. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah dibuat";
            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan],
            ));
          } else {
            print("sampe sini ulang");
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
      body['cari'] = idpengajuanLembur.value;
      body['activity_name'] =
          "Edit Pengajuan Lembur. Tanggal Pengajuan = $finalTanggalPengajuan";
      var connect = Api.connectionApi("post", body, "edit-emp_labor");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          Navigator.pop(Get.context!);
          var pesan =
              "Pengajuan Form lembur berhasil diedit. Selanjutnya silakan menunggu Atasan kamu untuk menyetujui pengajuan yang telah diedit";
          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan],
          ));
        }
      });
    }
  }

  void changeTypeAjuan(name) {
    print(name);
    for (var element in dataTypeAjuan.value) {
      if (element['nama'] == name) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    }
    this.dataTypeAjuan.refresh();
    var dataFilter = [];
    listLemburAll.value.forEach((element) {
      if (name == "Semua") {
        dataFilter.add(element);
      } else {
        if (element['status'] == name) {
          dataFilter.add(element);
        }
      }
    });
    listLembur.value = dataFilter;
    this.listLembur.refresh();
    if (dataFilter.isEmpty) {
      loadingString.value = "Tidak ada Pengajuan";
    } else {
      loadingString.value = "Sedang memuat...";
    }
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
                                  "Batalkan Pengajuan Lembur",
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
