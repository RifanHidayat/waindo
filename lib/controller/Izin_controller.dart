import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/api_controller.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class IzinController extends GetxController {
  var controllerApiGlobal = Get.put(ApiController());

  var nomorAjuan = TextEditingController().obs;
  var tanggalAjuan = TextEditingController().obs;
  var jamAjuan = TextEditingController().obs;
  var durasi = TextEditingController().obs;
  var catatan = TextEditingController().obs;
  var cari = TextEditingController().obs;

  Rx<List<String>> allTypeIzin = Rx<List<String>>([]);
  Rx<List<String>> allDelegasiIzin = Rx<List<String>>([]);

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var selectedDropdownDelegasi = "".obs;
  var idpengajuanIzin = "".obs;
  var emIdDelegasi = "".obs;
  var loadingString = "Sedang Memuat...".obs;

  var selectedDropdownFormIzinType = "".obs;
  var selectedDropdownFormIzinDelegasi = "".obs;

  var statusForm = false.obs;
  var directStatus = false.obs;
  var showButtonlaporan = false.obs;
  var statusCari = false.obs;

  var listRiwayatIzin = [].obs;
  var listRiwayatIzinAll = [].obs;
  var allEmployee = [].obs;
  var allTypeIzinTampung = [].obs;
  var dataTypeAjuan = [].obs;
  var departementAkses = [].obs;
  var konfirmasiAtasan = [].obs;

  Rx<DateTime> initialDate = DateTime.now().obs;

  var dataTypeAjuanDummy = ["Semua", "Approve", "Rejected", "Pending"];

  @override
  void startData() async {
    getTimeNow();
    getTypeAjuan();
    loadAllEmployeeDelegasi();
    loadTypeIzin();
    loadAllReportTo();
    // getDepartemen(1, "");
    initialDate.value = DateTime.now();
  }

  void removeAll() {
    tanggalAjuan.value.text = "";
    catatan.value.text = "";
  }

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";
    jamAjuan.value.text = DateFormat('HH:mm').format(dt);

    if (idpengajuanIzin.value == "") {
      tanggalAjuan.value.text = Constanst.convertDate("${initialDate.value}");
    }

    this.tanggalAjuan.refresh();
    this.bulanSelectedSearchHistory.refresh();
    this.tahunSelectedSearchHistory.refresh();
    this.bulanDanTahunNow.refresh();
    this.jamAjuan.refresh();
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

  void loadAllEmployeeDelegasi() {
    allDelegasiIzin.value.clear();
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
              allDelegasiIzin.value.add(namaUser);
            }
            allEmployee.value.add(element);
          }
          if (idpengajuanIzin.value == "") {
            var listFirst = valueBody['data'].first;
            var fullName = listFirst['full_name'] ?? "";
            String namaUserPertama = "$fullName";
            selectedDropdownFormIzinDelegasi.value = namaUserPertama;
          } else {
            for (var element in allEmployee) {
              if (element['em_id'] == emIdDelegasi.value) {
                selectedDropdownFormIzinDelegasi.value = element['full_name'];
              }
            }
          }
          this.allEmployee.refresh();
          this.allDelegasiIzin.refresh();
          this.selectedDropdownFormIzinDelegasi.refresh();
        }
      }
    });
  }

  void loadTypeIzin() {
    allTypeIzin.value.clear();
    Map<String, dynamic> body = {'val': 'status', 'cari': '4'};
    var connect = Api.connectionApi("post", body, "whereOnce-leave_types");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var data = valueBody['data'];
          allTypeIzinTampung.value = data;
          for (var element in data) {
            allTypeIzin.value.add(element['name']);
          }
          var listFirst = data.first;
          selectedDropdownFormIzinType.value = listFirst['name'];
          this.allTypeIzin.refresh();
          this.allTypeIzinTampung.refresh();
          this.selectedDropdownFormIzinType.refresh();
          loadDataIzin();
        }
      }
    });
  }

  void loadAllReportTo() async {
    // em id user
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {'em_id': getEmid};
    var connect = Api.connectionApi("post", body, "informasi_wa_atasan");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        konfirmasiAtasan.value = valueBody['data'];
        this.konfirmasiAtasan.refresh();
      }
    });
  }

  void loadDataIzin() {
    listRiwayatIzinAll.value.clear();
    listRiwayatIzin.value.clear();
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
          var dataFilter1 = [];
          for (var element in valueBody['data']) {
            if (element['ajuan'] == 3) {
              dataFilter1.add(element);
            }
          }
          var filterFinish = [];
          for (var element in dataFilter1) {
            var nameTypeIzin = "";
            for (var element1 in allTypeIzinTampung.value) {
              if (element['typeid'] == element1['id']) {
                nameTypeIzin = element1['name'];
              }
            }

            var dataFinal = {
              'id': element['id'],
              'em_id': element['em_id'],
              'nomor_ajuan': element['nomor_ajuan'],
              'typeid': element['typeid'],
              'nameType': nameTypeIzin,
              'dari_jam': element['dari_jam'],
              'sampai_jam': element['sampai_jam'],
              'durasi': element['durasi'],
              'tgl_ajuan': element['tgl_ajuan'],
              'atten_date': element['atten_date'],
              'status': element['status'],
              'approve_date': element['approve_date'],
              'em_delegation': element['em_delegation'],
              'uraian': element['uraian'],
              'ajuan': element['ajuan'],
            };
            filterFinish.add(dataFinal);
          }

          listRiwayatIzin.value = filterFinish;
          listRiwayatIzinAll.value = filterFinish;

          if (listRiwayatIzin.value.length == 0) {
            loadingString.value = "Tidak ada pengajuan";
          } else {
            loadingString.value = "Sedang Memuat...";
          }

          this.listRiwayatIzin.refresh();
          this.listRiwayatIzinAll.refresh();
          this.loadingString.refresh();
        }
      }
    });
  }

  void cariData(value) {
    var textCari = value.toLowerCase();
    var filter = listRiwayatIzinAll.where((ajuan) {
      var getAjuan = ajuan['nomor_ajuan'].toLowerCase();
      return getAjuan.contains(textCari);
    }).toList();
    listRiwayatIzin.value = filter;
    statusCari.value = true;
    this.listRiwayatIzin.refresh();
    this.statusCari.refresh();

    if (listRiwayatIzin.value.isEmpty) {
      loadingString.value = "Tidak ada pengajuan";
    } else {
      loadingString.value = "Memuat data...";
    }
    this.loadingString.refresh();
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
    listRiwayatIzinAll.value.forEach((element) {
      if (name == "Semua") {
        dataFilter.add(element);
      } else {
        if (element['status'] == name) {
          dataFilter.add(element);
        }
      }
    });
    listRiwayatIzin.value = dataFilter;
    this.listRiwayatIzin.refresh();
    if (dataFilter.isEmpty) {
      loadingString.value = "Tidak ada Pengajuan";
    } else {
      loadingString.value = "Sedang memuat...";
    }
  }

  void validasiKirimPengajuan() {
    if (tanggalAjuan.value.text == "" ||
        jamAjuan.value.text == "" ||
        catatan.value.text == "") {
      UtilsAlert.showToast("Lengkapi form *");
    } else {
      if (statusForm.value == false) {
        UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
        checkNomorAjuan();
      } else {
        UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
        simpanAjuanIzin(nomorAjuan.value.text);
      }
    }
  }

  void checkNomorAjuan() {
    var polaFormat = DateFormat('yyyy-MM-dd');
    var tanggalPengajuanInsert = polaFormat.format(initialDate.value);
    var finalTanggalPengajuan = tanggalPengajuanInsert;

    Map<String, dynamic> body = {
      'atten_date': finalTanggalPengajuan,
      'pola': 'IJ'
    };
    var connect = Api.connectionApi("post", body, "emp_labor_lastrow");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          var data = valueBody['data'];
          if (valueBody['data'].length == 0) {
            var now = DateTime.now();
            var convertBulan = now.month <= 9 ? "0${now.month}" : now.month;
            var finalNomor = "IJ${now.year}${convertBulan}0001";
            simpanAjuanIzin(finalNomor);
          } else {
            var getNomorAjuanTerakhir = valueBody['data'][0]['nomor_ajuan'];
            var keyNomor = getNomorAjuanTerakhir.replaceAll("IJ", '');
            var hasilTambah = int.parse(keyNomor) + 1;
            var finalNomor = "IJ$hasilTambah";
            simpanAjuanIzin(finalNomor);
          }
        } else {
          UtilsAlert.showToast(
              "Data periode $finalTanggalPengajuan belum tersedia, harap hubungi HRD");
        }
      }
    });
  }

  showDataPilihAtasan(dataEmployee) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 90,
                      child: Text(
                        "Konfirmasi via whatsapp",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Expanded(
                        flex: 10,
                        child: InkWell(
                            onTap: () => Navigator.pop(Get.context!),
                            child: Icon(Iconsax.close_circle)))
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  flex: 3,
                  child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          itemCount: konfirmasiAtasan.value.length,
                          itemBuilder: (context, index) {
                            var full_name =
                                konfirmasiAtasan.value[index]['full_name'];
                            var job_title =
                                konfirmasiAtasan.value[index]['job_title'];
                            var gambar =
                                konfirmasiAtasan.value[index]['em_image'];
                            var nohp =
                                konfirmasiAtasan.value[index]['em_mobile'];
                            return InkWell(
                              onTap: () {
                                kirimKonfirmasiWa(
                                    dataEmployee, full_name, nohp);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 15,
                                        child: gambar == ""
                                            ? Image.asset(
                                                'assets/avatar_default.png',
                                                width: 40,
                                                height: 40,
                                              )
                                            : CircleAvatar(
                                                radius: 25, // Image radius
                                                child: ClipOval(
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          Api.UrlfotoProfile +
                                                              "$gambar",
                                                      progressIndicatorBuilder:
                                                          (context, url,
                                                                  downloadProgress) =>
                                                              Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        'assets/avatar_default.png',
                                                        width: 40,
                                                        height: 40,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                      Expanded(
                                        flex: 75,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "$full_name",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                "$job_title",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Center(
                                          child: Image.asset(
                                            'assets/whatsapp.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          );
        });
  }

  void kirimKonfirmasiWa(dataEmployee, namaAtasan, nomorAtasan) async {
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    var getFullName = dataUser[0].full_name;
    var gabunganPesan =
        "Hallo pak ${namaAtasan}, saya ${getFullName} mengajukan ${dataEmployee['nameType']} dengan nomor ajuan ${dataEmployee['nomor_ajuan']}";
    var notujuan = nomorAtasan;
    var filternohp = notujuan.substring(1);
    var kodeNegara = 62;
    var gabungNohp = "$kodeNegara$filternohp";

    var whatsappURl_android =
        "whatsapp://send?phone=" + gabungNohp + "&text=" + gabunganPesan;
    var whatappURL_ios =
        "https://wa.me/$gabungNohp?text=${Uri.parse(gabunganPesan)}";

    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunch(whatappURL_ios)) {
        await launch(whatappURL_ios, forceSafariVC: false);
      } else {
        UtilsAlert.showToast("Whatsapp tidak terinstall");
      }
    } else {
      // android , web
      if (await canLaunch(whatsappURl_android)) {
        await launch(whatsappURl_android);
      } else {
        UtilsAlert.showToast("Whatsapp tidak terinstall");
      }
    }
  }

  void simpanAjuanIzin(getNomorAjuanTerakhir) {
    // em id user
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    var getFullName = dataUser[0].full_name;
    // cari delegasi
    var validasiDelegasiSelected = validasiSelectedDelegasi();
    // cari tipe terpilih
    var idTypeIzinSelected = validasiSelectedTypeIzin();
    // cari atten date
    var polaFormat = DateFormat('yyyy-MM-dd');
    var tanggalAttenDate = polaFormat.format(initialDate.value);
    // tanggal ajuan
    var listTanggal = tanggalAjuan.value.text.split(',');
    var getTanggal = listTanggal[1].replaceAll(' ', '');
    var tanggalAjuanFinal = Constanst.convertDateSimpan(getTanggal);

    Map<String, dynamic> body = {
      'em_id': getEmid,
      'nomor_ajuan': getNomorAjuanTerakhir,
      'typeid': idTypeIzinSelected,
      'dari_jam': jamAjuan.value.text,
      'sampai_jam': "",
      'durasi': "",
      'tgl_ajuan': tanggalAjuanFinal,
      'atten_date': tanggalAttenDate,
      'status': 'PENDING',
      'approve_date': '',
      'em_delegation': validasiDelegasiSelected,
      'uraian': catatan.value.text,
      'ajuan': '3',
      'created_by': getEmid,
      'menu_name': 'izin'
    };

    if (statusForm.value == false) {
      // simpan ajuan
      body['activity_name'] =
          "Membuat Pengajuan ${selectedDropdownFormIzinType.value}. alasan = ${catatan.value.text}";
      var connect = Api.connectionApi("post", body, "insert-emp_labor");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            controllerApiGlobal.kirimNotifikasiToDelegasi(
                getFullName, tanggalAttenDate, validasiDelegasiSelected);
            Navigator.pop(Get.context!);
            var pesan1 = "Pengajuan Izin berhasil dibuat";
            var pesan2 =
                "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
            var pesan3 = "konfirmasi via WhatsApp";
            Get.offAll(BerhasilPengajuan(
              dataBerhasil: [pesan1, pesan2, pesan3],
            ));
          } else {
            print("sampe sini ulang");
            if (valueBody['message'] == "ulang") {
              checkNomorAjuan();
            } else {
              Navigator.pop(Get.context!);
              UtilsAlert.showToast(
                  "Data periode $tanggalAttenDate belum tersedia, harap hubungi HRD");
            }
          }
        }
      });
    } else {
      //edit ajuan
      body['val'] = "id";
      body['cari'] = idpengajuanIzin.value;
      body['activity_name'] =
          "Edit Pengajuan ${selectedDropdownFormIzinType.value}. Tanggal Pengajuan = $tanggalAttenDate";
      var connect = Api.connectionApi("post", body, "edit-emp_labor");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          Navigator.pop(Get.context!);
          var pesan1 = "Pengajuan Izin berhasil di edit";
          var pesan2 =
              "Selanjutnya silahkan menunggu atasan kamu untuk menyetujui pengajuan yang telah dibuat atau langsung";
          var pesan3 = "konfirmasi via WhatsApp";
          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan1, pesan2, pesan3],
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
      if (namaElement == selectedDropdownFormIzinDelegasi.value) {
        result.add(element);
      }
    }
    return "${result[0]['em_id']}";
  }

  String validasiSelectedTypeIzin() {
    var result = [];
    for (var element in allTypeIzinTampung.value) {
      if (element['name'] == selectedDropdownFormIzinType.value) {
        result.add(element);
      }
    }
    return "${result[0]['id']}";
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
                                  "Batalkan Pengajuan Izin",
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
      'menu_name': 'Izin',
      'activity_name':
          'Membatalkan form pengajuan Izin. Waktu Izin = ${index["dari_jam"]} | Alasan Pengajuan = ${index["reason"]} | Tanggal Pengajuan = ${index["atten_date"]}',
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
