import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class KlaimController extends GetxController {
  var nomorAjuan = TextEditingController().obs;
  var tanggalKlaim = TextEditingController().obs;
  var durasi = TextEditingController().obs;
  var catatan = TextEditingController().obs;
  var cari = TextEditingController().obs;
  var totalKlaim = TextEditingController().obs;

  Rx<List<String>> allTypeKlaim = Rx<List<String>>([]);
  Rx<List<String>> allEmployeeDelegasi = Rx<List<String>>([]);

  var filePengajuan = File("").obs;

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var selectedDropdownDelegasi = "".obs;
  var selectedDropdownType = "".obs;
  var idpengajuanKlaim = "".obs;
  var emIdDelegasi = "".obs;
  var valuePolaPersetujuan = "".obs;
  var tanggalTerpilih = "".obs;
  var tanggalShow = "".obs;
  var namaFileUpload = "".obs;
  var loadingString = "Sedang Memuat...".obs;

  var statusForm = false.obs;
  var directStatus = false.obs;
  var showButtonlaporan = false.obs;
  var statusCari = false.obs;
  var uploadFile = false.obs;

  var listKlaim = [].obs;
  var listKlaimAll = [].obs;
  var allEmployee = [].obs;
  var allType = [].obs;
  var dataTypeAjuan = [].obs;
  var departementAkses = [].obs;

  Rx<DateTime> initialDate = DateTime.now().obs;

  var dataTypeAjuanDummy1 = ["Semua", "Approve", "Rejected", "Pending"];
  var dataTypeAjuanDummy2 = [
    "Semua",
    "Approve 1",
    "Approve 2",
    "Rejected",
    "Pending"
  ];
  GlobalController globalCt = Get.put(GlobalController());

  @override
  void onReady() async {
    super.onReady();
    getTimeNow();
    getLoadsysData();
    getTypeKlaim();
    loadDataKlaim();
    loadAllEmployeeDelegasi();
    getDepartemen(1, "");
  }

  void removeAll() {
    tanggalKlaim.value.text = "";
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

    if (idpengajuanKlaim.value == "") {
      tanggalKlaim.value.text = "${DateFormat('yyyy-MM-dd').format(dt)}";
      tanggalShow.value = "${DateFormat('dd MMMM yyyy').format(dt)}";
      tanggalTerpilih.value = "${DateFormat('yyyy-MM-dd').format(dt)}";
    }

    this.tanggalKlaim.refresh();
    this.bulanSelectedSearchHistory.refresh();
    this.tahunSelectedSearchHistory.refresh();
    this.bulanDanTahunNow.refresh();
  }

  void getTypeKlaim() {
    allType.value.clear();
    var connect = Api.connectionApi("get", "", "cost");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        print(data);
        for (var element in data) {
          allTypeKlaim.value.add("${element['name']}");
          var data = {
            'type_id': element['id'],
            'name': element['name'],
            'active': false,
          };
          allType.value.add(data);
        }
        if (idpengajuanKlaim == "") {
          var listFirst = allTypeKlaim.value.first;
          selectedDropdownType.value = listFirst;
        }
      }
    });
  }

  void checkTypeEdit(id) {
    for (var element in allType.value) {
      if ("${element['type_id']}" == "$id") {
        selectedDropdownType.value = element['name'];
      }
    }
    this.selectedDropdownType.refresh();
  }

  String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }

  void loadDataKlaim() {
    listKlaimAll.value.clear();
    listKlaim.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "history-emp_claim");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          loadingString.value = "Tidak ada pengajuan";
          this.loadingString.refresh();
        } else {
          listKlaim.value = valueBody['data'];
          listKlaimAll.value = valueBody['data'];
          if (listKlaim.value.length == 0) {
            loadingString.value = "Tidak ada pengajuan";
          } else {
            loadingString.value = "Sedang Memuat...";
          }
          this.listKlaim.refresh();
          this.listKlaimAll.refresh();
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
            if (element['status'] == 'ACTIVE') {
              var fullName = element['full_name'] ?? "";
              String namaUser = "$fullName";
              if (namaUser != full_name) {
                allEmployeeDelegasi.value.add(namaUser);
              }
              allEmployee.value.add(element);
            }
          }
          if (idpengajuanKlaim.value == "") {
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
        this.namaFileUpload.refresh();
        this.filePengajuan.refresh();
        this.uploadFile.refresh();
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
    if (tanggalKlaim.value.text == "" ||
        catatan.value.text == "" ||
        tanggalTerpilih.value == "") {
      UtilsAlert.showToast("Lengkapi form *");
    } else {
      if (uploadFile.value == true) {
        UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan File");
        var connectUpload = await Api.connectionApiUploadFile(
            "upload_form_klaim", filePengajuan.value);
        var valueBody = jsonDecode(connectUpload);
        if (valueBody['status'] == true) {
          UtilsAlert.showToast("Berhasil upload file");
          Navigator.pop(Get.context!);
          if (statusForm.value == false) {
            UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
            checkNomorAjuan(statusForm.value);
          } else {
            UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
            kirimPengajuan(nomorAjuan.value.text);
          }
        } else {
          UtilsAlert.showToast("Gagal kirim file");
        }
      } else {
        if (statusForm.value == false) {
          UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
          checkNomorAjuan(statusForm.value);
        } else {
          UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
          kirimPengajuan(nomorAjuan.value.text);
        }
      }
    }
  }

  void checkNomorAjuan(value) {
    var finalTanggalPengajuan = tanggalKlaim.value.text;
    Map<String, dynamic> body = {
      'atten_date': finalTanggalPengajuan,
      'pola': 'KL'
    };
    var connect = Api.connectionApi("post", body, "emp_klaim_lastrow");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          var data = valueBody['data'];
          if (valueBody['data'].length == 0) {
            var now = DateTime.now();
            var convertBulan = now.month <= 9 ? "0${now.month}" : now.month;
            var finalNomor = "KL${now.year}${convertBulan}0001";
            kirimPengajuan(finalNomor);
          } else {
            var getNomorAjuanTerakhir = valueBody['data'][0]['nomor_ajuan'];
            var keyNomor = getNomorAjuanTerakhir.replaceAll("KL", '');
            var hasilTambah = int.parse(keyNomor) + 1;
            var finalNomor = "KL$hasilTambah";
            kirimPengajuan(finalNomor);
          }
        } else {
          UtilsAlert.showToast(
              "Data periode $finalTanggalPengajuan belum tersedia, harap hubungi HRD");
        }
      }
    });
  }

  void checkNomorAjuanDalamAntrian(nomorAjuanTerakhirDalamAntrian) {
    var getNomorAjuanTerakhir = nomorAjuanTerakhirDalamAntrian;
    var keyNomor = getNomorAjuanTerakhir.replaceAll("KL", '');
    var hasilTambah = int.parse(keyNomor) + 1;
    var finalNomor = "KL$hasilTambah";
    kirimPengajuan(finalNomor);
  }

  void kirimPengajuan(getNomorAjuanTerakhir) {
    // data employee
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    var getFullName = dataUser[0].full_name;
    // cari type klaim
    var idSelectedType = cariTypeSelected();
    // filter total klaim
    var cv1 = totalKlaim.value.text.replaceAll('Rp', '');
    var cv2 = cv1.replaceAll('.', '');
    int cv3 = int.parse(cv2);
    // variabel upload file
    var nameFile;
    if (idpengajuanKlaim == "") {
      nameFile = uploadFile.value == true ? namaFileUpload.value : "";
    } else {
      nameFile = namaFileUpload.value;
    }

    Map<String, dynamic> body = {
      'em_id': getEmid,
      'nomor_ajuan': getNomorAjuanTerakhir,
      'tgl_ajuan': tanggalTerpilih.value,
      'cost_id': idSelectedType,
      'description': catatan.value.text,
      'total_claim': '$cv3',
      'status': 'PENDING',
      'nama_file': nameFile,
      'created_on': "${DateTime.now()}",
      'atten_date': tanggalKlaim.value.text,
      'created_by': getEmid,
      'menu_name': 'Klaim'
    };
     var typeNotifFcm = "Pengajuan Klaim";
    if (statusForm.value == false) {
      body['activity_name'] =
          "Membuat Pengajuan Klaim. alasan = ${catatan.value.text}";
      var connect = Api.connectionApi("post", body, "insert-emp_claim");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            kirimNotifikasiToReportTo(
                getFullName, tanggalKlaim.value.text, getEmid, "Klaim");
            Navigator.pop(Get.context!);
            var pesan1 = "Pengajuan klaim berhasil dibuat";
            var pesan2 =
                "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
            var pesan3 = "konfirmasi via WhatsApp";
            var dataPengajuan = {
              'nameType': 'KLAIM',
              'nomor_ajuan': '${getNomorAjuanTerakhir}',
            };
            for (var item in globalCt.konfirmasiAtasan) {
              print(item['token_notif']);
              var pesan;
              if (item['em_gender'] == "PRIA") {
                pesan =
                    "Hallo pak ${item['full_name']}, saya ${getFullName} mengajukan Klaim dengan nomor ajuan ${getNomorAjuanTerakhir}";
              } else {
                pesan =
                    "Hallo bu ${item['full_name']}, saya ${getFullName} mengajukan Klaim dengan nomor ajuan ${getNomorAjuanTerakhir}";
              }
              if (item['token_notif'] != null) {
                globalCt.kirimNotifikasiFcm(
                    title: typeNotifFcm,
                    message: pesan,
                    tokens: item['token_notif']);
              }
            }
            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
            ));
          } else {
            if (valueBody['message'] == "ulang") {
              var nomorAjuanTerakhirDalamAntrian =
                  valueBody['data'][0]['nomor_ajuan'];
              checkNomorAjuanDalamAntrian(nomorAjuanTerakhirDalamAntrian);
            } else {
              Navigator.pop(Get.context!);
              UtilsAlert.showToast(
                  "Data periode ${tanggalKlaim.value.text} belum tersedia, harap hubungi HRD");
            }
          }
        }
      });
    } else {
      body['val'] = "id";
      body['cari'] = idpengajuanKlaim.value;
      body['activity_name'] =
          "Edit Pengajuan Klaim. Tanggal Pengajuan = ${tanggalKlaim.value.text}";
      var connect = Api.connectionApi("post", body, "edit-emp_claim");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          Navigator.pop(Get.context!);
          var pesan1 = "Pengajuan klaim berhasil di edit";
          var pesan2 =
              "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
          var pesan3 = "konfirmasi via WhatsApp";
          var dataPengajuan = {
            'nameType': 'KLAIM',
            'nomor_ajuan': '${getNomorAjuanTerakhir}',
          };
          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan1, pesan2, pesan3, dataPengajuan],
          ));
        }
      });
    }
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
    listKlaimAll.value.forEach((element) {
      if (name == "Semua") {
        dataFilter.add(element);
      } else {
        if (element['status'] == filter) {
          dataFilter.add(element);
        }
      }
    });
    listKlaim.value = dataFilter;
    this.listKlaim.refresh();
    if (dataFilter.isEmpty) {
      loadingString.value = "Tidak ada Pengajuan";
    } else {
      loadingString.value = "Sedang memuat...";
    }
  }

  void cariData(value) {
    var textCari = value.toLowerCase();
    var filter = listKlaimAll.where((ajuan) {
      var getAjuan = ajuan['nomor_ajuan'].toLowerCase();
      return getAjuan.contains(textCari);
    }).toList();
    listKlaim.value = filter;
    statusCari.value = true;
    this.listKlaim.refresh();
    this.statusCari.refresh();

    if (listKlaim.value.isEmpty) {
      loadingString.value = "Tidak ada pengajuan";
    } else {
      loadingString.value = "Memuat data...";
    }
    this.loadingString.refresh();
  }

  void kirimNotifikasiToReportTo(
      getFullName, convertTanggalBikinPengajuan, getEmid, type) {
    var dt = DateTime.now();
    var jamSekarang = DateFormat('HH:mm:ss').format(dt);
    Map<String, dynamic> body = {
      'emId_pengaju': getEmid,
      'title': 'Pengajuan Lembur',
      'deskripsi':
          'Anda mendapatkan pengajuan $type dari $getFullName, waktu pengajuan $convertTanggalBikinPengajuan',
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

  String cariTypeSelected() {
    var result = [];
    for (var element in allType.value) {
      var nameType = element['name'] ?? "";
      if (nameType == selectedDropdownType.value) {
        result.add(element);
      }
    }
    return "${result[0]['type_id']}";
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
                                  "Batalkan Pengajuan Klaim",
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
    DateTime ftr1 = DateTime.parse(index["created_on"]);
    var filterTanggal = "${DateFormat('yyyy-MM-dd').format(ftr1)}";
    Map<String, dynamic> body = {
      'menu_name': 'Klaim',
      'activity_name':
          'Membatalkan form pengajuan Klaim. Alasan Pengajuan = ${index["reason"]} Tanggal Pengajuan = $filterTanggal',
      'created_by': '$getEmid',
      'val': 'id',
      'cari': '${index["id"]}',
      'status_transaksi': 0,
      'atten_date': filterTanggal,
    };
    var connect = Api.connectionApi("post", body, "edit-emp_claim");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        Navigator.pop(Get.context!);
        Navigator.pop(Get.context!);
        UtilsAlert.showToast("Berhasil batalkan pengajuan");
        loadDataKlaim();
      }
    });
  }

  void viewLampiranAjuan(value) async {
    var urlViewGambar = Api.UrlfileKlaim + value;

    final url = Uri.parse(urlViewGambar);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      UtilsAlert.showToast('Tidak dapat membuka file');
    }
  }
}
