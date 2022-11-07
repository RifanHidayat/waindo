import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class AktifitasController extends GetxController {
  var cari = TextEditingController().obs;

  RefreshController refreshController = RefreshController(initialRefresh: true);
  ScrollController controllerScroll = ScrollController();

  var listAktifitas = [].obs;
  var infoAktifitas = [].obs;

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var stringPersenAbsenTepatWaktu = "".obs;
  var stringBulan = "".obs;

  var statusPencarian = false.obs;
  var statusFormPencarian = false.obs;
  var visibleWidget = false.obs;

  var indexList = 0.0.obs;
  var persenAbsenTelat = 0.0.obs;

  var limit = 10.obs;
  var jumlahTepatWaktu = 0.obs;
  var firstDayMonth = 0.obs;
  var lastDayMonth = 0.obs;

  List dummyInfo = [
    {
      'id': '1',
      'nama': 'Masuk Kerja',
    },
    {
      'id': '2',
      'nama': 'Izin',
    },
    {
      'id': '3',
      'nama': 'Sakit',
    },
    {
      'id': '4',
      'nama': 'Cuti',
    },
    {
      'id': '5',
      'nama': 'Lembur',
    },
    {
      'id': '6',
      'nama': 'WFH',
    },
  ];

  @override
  void onReady() async {
    getTimeNow();
    loadAktifitas();
    getInformasiAktivitas();
    controllerScroll.addListener(listenScrolling);
    super.onReady();
  }

  void listenScrolling() {
    if (listAktifitas.length >= 10) {
      double indexScroll = controllerScroll.offset;
      if (indexScroll > 0.0) {
        indexList.value = indexScroll;
        visibleWidget.value = true;
        this.visibleWidget.refresh();
        this.indexList.refresh();
      } else {
        if (indexList.value > indexScroll) {
          indexList.value = indexScroll;
          visibleWidget.value = false;
          this.visibleWidget.refresh();
          this.indexList.refresh();
        }
      }
    }
  }

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";

    stringBulan.value = "${DateFormat('MMMM').format(dt)}";

    this.stringBulan.refresh();
    this.bulanSelectedSearchHistory.refresh();
    this.tahunSelectedSearchHistory.refresh();
    this.bulanDanTahunNow.refresh();
  }

  void loadAktifitas() {
    var dataUser = AppData.informasiUser;
    var getEmpid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmpid,
      'offset': listAktifitas.value.length,
      'limit': limit.value,
    };
    var connect = Api.connectionApi("post", body, "load_aktifitas");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      for (var element in valueBody['data']) {
        var getList = element['createdDate'].split('T');
        var tanggal = getList[0];
        var jam = getList[1].replaceAll('.000Z', '');
        var data = {
          'idx': element['idx'],
          'menu_name': element['menu_name'],
          'activity_name': element['activity_name'],
          'createdDate': tanggal,
          'jam': jam,
        };
        listAktifitas.value.add(data);
      }
      this.listAktifitas.refresh();
    });
  }

  void getInformasiAktivitas() {
    infoAktifitas.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmId = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmId,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, 'info_aktifitas_employee');
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);

        var finalFilterMasukKerja;

        if (valueBody['status'] == true) {
          var tampungMasukKerja = valueBody['data_masuk_kerja'];
          var seen = Set<String>();
          List filter = tampungMasukKerja
              .where((tanggal) => seen.add(tanggal['atten_date']))
              .toList();
          finalFilterMasukKerja = filter;
        }

        var dataMasukKerja =
            valueBody['status'] == false ? 0 : finalFilterMasukKerja.length;

        var dataIzin = valueBody['status'] == false
            ? 0
            : valueBody['data_izin'][0]['jumlah_izin'];
        var dataSakit = valueBody['status'] == false
            ? 0
            : valueBody['data_sakit'][0]['jumlah_sakit'];
        var dataCuti = valueBody['status'] == false
            ? 0
            : valueBody['data_cuti'][0]['jumlah_cuti'];
        var dataLembur = valueBody['status'] == false
            ? 0
            : valueBody['data_lembur'][0]['jumlah_lembur'];
        var dataMasukWfh = valueBody['status'] == false
            ? 0
            : valueBody['data_masukwfh'][0]['jumlah_masuk_wfh'];
        List dataAbsenTepatWaktu = valueBody['status'] == false
            ? []
            : valueBody['data_absentepatwaktu'];

        if (dataAbsenTepatWaktu.isNotEmpty) {
          var tampungTepatWaktu = [];
          for (var element in dataAbsenTepatWaktu) {
            var listJamMasuk = (element['signin_time'].split(':'));
            var perhitunganJamMasuk1 =
                830 - int.parse("${listJamMasuk[0]}${listJamMasuk[1]}");
            if (perhitunganJamMasuk1 < 0) {
              print('telat');
            } else {
              tampungTepatWaktu.add(element);
            }
          }
          jumlahTepatWaktu.value = tampungTepatWaktu.length;
        } else {
          jumlahTepatWaktu.value = 0;
        }

        for (var element in dummyInfo) {
          if (element['id'] == '1') {
            var data = {
              'id': '1',
              'nama': 'Masuk Kerja',
              'jumlah': dataMasukKerja,
            };
            infoAktifitas.value.add(data);
          } else if (element['id'] == '2') {
            var data = {
              'id': '2',
              'nama': 'Izin',
              'jumlah': dataIzin,
            };
            infoAktifitas.value.add(data);
          } else if (element['id'] == '3') {
            var data = {
              'id': '3',
              'nama': 'Sakit',
              'jumlah': dataSakit,
            };
            infoAktifitas.value.add(data);
          } else if (element['id'] == '4') {
            var data = {
              'id': '4',
              'nama': 'Cuti',
              'jumlah': dataCuti,
            };
            infoAktifitas.value.add(data);
          } else if (element['id'] == '5') {
            var data = {
              'id': '5',
              'nama': 'Lembur',
              'jumlah': dataLembur,
            };
            infoAktifitas.value.add(data);
          } else if (element['id'] == '6') {
            var data = {
              'id': '6',
              'nama': 'WFH',
              'jumlah': dataMasukWfh,
            };
            infoAktifitas.value.add(data);
          }
        }
        this.jumlahTepatWaktu.refresh();
        this.infoAktifitas.refresh();
        hitungTepatWaktu(20, jumlahTepatWaktu.value);
      }
    });
  }

  void hitungTepatWaktu(totalDay, terpakai) {
    print('terpaakai $terpakai');
    var hitung1 = (terpakai / totalDay) * 100;
    var convert1 = hitung1;
    var convertedValue = double.parse("${convert1}") / 100;
    print('persen double $convertedValue');
    var fltr1 = '$convertedValue'.split('.');
    var fltr2;
    if (fltr1[1].length != 1) {
      fltr2 = '${fltr1[1]} %';
    } else {
      fltr2 = '${fltr1[1]}0 %';
    }
    stringPersenAbsenTepatWaktu.value = "$fltr2";
    persenAbsenTelat.value = convertedValue;
    DateTime now = DateTime.now();
    int firstday = DateTime(now.year, now.month + 1).day;
    int lastday = DateTime(now.year, now.month + 1, 0).day;
    firstDayMonth.value = firstday;
    lastDayMonth.value = lastday;

    this.firstDayMonth.refresh();
    this.lastDayMonth.refresh();
    this.persenAbsenTelat.refresh();
    this.stringPersenAbsenTepatWaktu.refresh();
  }

  void showInputCari() {
    statusFormPencarian.value = !statusFormPencarian.value;
  }

  void pencarianDataAktifitas() {
    listAktifitas.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmpid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmpid,
      'cari': cari.value.text,
    };
    var connect = Api.connectionApi("post", body, "pencarian_aktifitas");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      for (var element in valueBody['data']) {
        var getList = element['createdDate'].split('T');
        var tanggal = getList[0];
        var jam = getList[1].replaceAll('.000Z', '');
        var data = {
          'idx': element['idx'],
          'menu_name': element['menu_name'],
          'activity_name': element['activity_name'],
          'createdDate': tanggal,
          'jam': jam,
        };
        listAktifitas.value.add(data);
      }
      cari.value.text = "";
      statusPencarian.value = true;
      statusFormPencarian.value = false;
      this.statusFormPencarian.refresh();
      this.statusPencarian.refresh();
      this.listAktifitas.refresh();
      Navigator.pop(Get.context!);
    });
  }

  void cariDataAktifitas() {
    showDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Cari Data Aktifitas"),
                SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: Constanst.borderStyle2,
                      border: Border.all(color: Constanst.colorNonAktif)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 15,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7, left: 10),
                          child: Icon(Iconsax.search_normal_1),
                        ),
                      ),
                      Expanded(
                        flex: 85,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: cari.value,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Cari judul aktifitas"),
                              style: TextStyle(
                                  fontSize: 14.0,
                                  height: 1.0,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: TextButtonWidget(
                    iconShow: false,
                    title: 'Cari',
                    colorButton: Constanst.colorPrimary,
                    colortext: Colors.white,
                    border: BorderRadius.circular(15.0),
                    onTap: () {
                      if (cari.value.text == "") {
                        UtilsAlert.showToast("Isi form cari terlebih dahulu");
                      } else {
                        UtilsAlert.loadingSimpanData(
                            Get.context!, "Mencari Data...");
                        pencarianDataAktifitas();
                      }
                    },
                  ),
                )
              ]),
        );
      },
    );
  }
}
