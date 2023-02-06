import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_absen.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_absen_telat.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_belum_absen.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class HistoryAbsen extends StatefulWidget {
  var dataForm;
  HistoryAbsen({Key? key, this.dataForm}) : super(key: key);
  @override
  _HistoryAbsenState createState() => _HistoryAbsenState();
}

class _HistoryAbsenState extends State<HistoryAbsen> {
  var controller = Get.put(AbsenController());

  @override
  void initState() {
    super.initState();
    controller.loadHistoryAbsenUser();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    controller.onReady();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constanst.coloBackgroundScreen,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Constanst.coloBackgroundScreen,
            elevation: 2,
            flexibleSpace: AppbarMenu1(
              title: "History Absen",
              icon: 1,
              colorTitle: Colors.black,
              onTap: () {
                controller.removeAll();
                Get.offAll(InitScreen());
              },
            )),
        body: WillPopScope(
          onWillPop: () async {
            controller.removeAll();
            Get.offAll(InitScreen());
            return true;
          },
          child: Obx(
            () => Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  controller.bulanDanTahunNow.value == ""
                      ? SizedBox()
                      : pickDate(),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 85,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Riwayat Absensi",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Constanst.sizeTitle),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Flexible(
                      child: RefreshIndicator(
                    onRefresh: refreshData,
                    child: controller.historyAbsen.value.isEmpty
                        ? Center(
                            child: Text(controller.loading.value),
                          )
                        : listAbsen(),
                  ))
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Obx(
          () => controller.showButtonlaporan.value == false
              ? SizedBox()
              : SpeedDial(
                  icon: Iconsax.more,
                  activeIcon: Icons.close,
                  backgroundColor: Constanst.colorPrimary,
                  spacing: 3,
                  childPadding: const EdgeInsets.all(5),
                  spaceBetweenChildren: 4,
                  elevation: 8.0,
                  animationCurve: Curves.elasticInOut,
                  animationDuration: const Duration(milliseconds: 200),
                  children: [
                    SpeedDialChild(
                        child: Icon(Iconsax.document_text),
                        backgroundColor: Color(0xff2F80ED),
                        foregroundColor: Colors.white,
                        label: 'Laporan Absensi',
                        onTap: () {
                          Get.to(LaporanAbsen(
                            dataForm: "",
                          ));
                        }),
                    SpeedDialChild(
                        child: Icon(Iconsax.minus_cirlce),
                        backgroundColor: Color(0xffFF463D),
                        foregroundColor: Colors.white,
                        label: 'Absen Terlambat',
                        onTap: () {
                          Get.to(LaporanAbsenTelat(
                            dataForm: "",
                          ));
                        }),
                    SpeedDialChild(
                        child: Icon(Iconsax.watch),
                        backgroundColor: Color(0xffF2AA0D),
                        foregroundColor: Colors.white,
                        label: 'Belum Absen',
                        onTap: () {
                          Get.to(LaporanBelumAbsen(
                            dataForm: "",
                          ));
                        }),
                  ],
                ),
        ));
  }

  Widget pickDate() {
    return InkWell(
      onTap: () async {
        print("kesini");
        DatePicker.showPicker(
          context,
          pickerModel: CustomMonthPicker(
            minTime: DateTime(2020, 1, 1),
            maxTime: DateTime(2050, 1, 1),
            currentTime: DateTime.now(),
          ),
          onConfirm: (time) {
            if (time != null) {
              print("$time");
              var filter = DateFormat('yyyy-MM').format(time);
              var array = filter.split('-');
              var bulan = array[1];
              var tahun = array[0];
              controller.bulanSelectedSearchHistory.value = bulan;
              controller.tahunSelectedSearchHistory.value = tahun;
              controller.bulanDanTahunNow.value = "$bulan-$tahun";
              this.controller.bulanSelectedSearchHistory.refresh();
              this.controller.tahunSelectedSearchHistory.refresh();
              this.controller.bulanDanTahunNow.refresh();
              controller.loadHistoryAbsenUser();
            }
          },
        );
      },
      child: Container(
        decoration: Constanst.styleBoxDecoration1,
        child: Padding(
          padding: EdgeInsets.only(top: 15, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Iconsax.calendar_2),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "${Constanst.convertDateBulanDanTahun(controller.bulanDanTahunNow.value)}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 24,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget listAbsen() {
    return ListView.builder(
        physics: controller.historyAbsenShow.value.length <= 10
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.historyAbsenShow.value.length,
        itemBuilder: (context, index) {
          var jamMasuk =
              controller.historyAbsenShow.value[index]['signin_time'] ?? '';
          var jamKeluar =
              controller.historyAbsenShow.value[index]['signout_time'] ?? '';
          var placeIn =
              controller.historyAbsenShow.value[index]['place_in'] ?? '';
          var placeOut =
              controller.historyAbsenShow.value[index]['place_out'] ?? '';
          var note =
              controller.historyAbsenShow.value[index]['signin_note'] ?? '';
          var signInLongLat =
              controller.historyAbsenShow.value[index]['signin_longlat'] ?? '';
          var signOutLongLat =
              controller.historyAbsenShow.value[index]['signout_longlat'] ?? '';
          var reqType =
              controller.historyAbsenShow.value[index]['reg_type'] ?? '';

          var statusView;
          var listJamMasuk;
          var listJamKeluar;
          var perhitunganJamMasuk1;
          var perhitunganJamMasuk2;
          var getColorMasuk;
          var getColorKeluar;

          if (placeIn != "") {
            statusView = placeIn == "pengajuan" &&
                    placeOut == "pengajuan" &&
                    signInLongLat == "pengajuan" &&
                    signOutLongLat == "pengajuan"
                ? true
                : false;
          }
          if (controller.historyAbsenShow.value[index]['view_turunan'] ==
              false) {
            listJamMasuk = (jamMasuk!.split(':'));
            listJamKeluar = (jamKeluar!.split(':'));
            perhitunganJamMasuk1 =
                830 - int.parse("${listJamMasuk[0]}${listJamMasuk[1]}");
            perhitunganJamMasuk2 =
                1800 - int.parse("${listJamKeluar[0]}${listJamKeluar[1]}");

            if (perhitunganJamMasuk1 < 0) {
              getColorMasuk = Colors.red;
            } else {
              getColorMasuk = Colors.black;
            }

            if (perhitunganJamMasuk2 == 0) {
              getColorKeluar = Colors.black;
            } else if (perhitunganJamMasuk2 > 0) {
              getColorKeluar = Colors.red;
            } else if (perhitunganJamMasuk2 < 0) {
              getColorKeluar = Constanst.colorPrimary;
            }
          } else {}

          return InkWell(
              onTap: () {
                controller.showTurunan(
                    controller.historyAbsenShow.value[index]['atten_date']);
                if (controller.historyAbsenShow.value[index]['view_turunan'] ==
                    false) {
                  controller.historySelected(
                      controller.historyAbsen.value[index].id, 'history');
                }
              },
              child: controller.historyAbsenShow.value[index]['view_turunan'] ==
                      true
                  ? tampilan1(controller.historyAbsenShow.value[index])
                  : tampilan2(controller.historyAbsenShow.value[index]));
        });
  }

  Widget tampilan1(index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 90,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${Constanst.convertDate('${index['atten_date']}')}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(
                        "Type : ${index['reg_type'] == 0 ? "Face Recognition" : "Photo"}",
                        style: TextStyle(
                          fontSize: 9,
                        )),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: index['status_view'] == false
                      ? Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        )
                      : Icon(
                          Iconsax.arrow_down,
                          size: 14,
                        ),
                ))
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Divider(
          height: 3,
          color: Colors.grey,
        ),
        index['status_view'] == false
            ? SizedBox()
            : listTurunanHistoryAbsen(index['turunan']),
      ],
    );
  }

  Widget tampilan2(index) {
    var jamMasuk = index['signin_time'] ?? '';
    var jamKeluar = index['signout_time'] ?? '';
    var placeIn = index['place_in'] ?? '';
    var placeOut = index['place_out'] ?? '';
    var note = index['signin_note'] ?? '';
    var signInLongLat = index['signin_longlat'] ?? '';
    var signOutLongLat = index['signout_longlat'] ?? '';
    var regType = index['regtype'] ?? 0;
    var statusView;
    if (placeIn != "") {
      statusView =
          placeIn == "pengajuan" && placeOut == "pengajuan" ? true : false;
    }
    var listJamMasuk = (jamMasuk!.split(':'));
    var listJamKeluar = (jamKeluar!.split(':'));
    var perhitunganJamMasuk1 =
        830 - int.parse("${listJamMasuk[0]}${listJamMasuk[1]}");
    var perhitunganJamMasuk2 =
        1800 - int.parse("${listJamKeluar[0]}${listJamKeluar[1]}");
    var getColorMasuk;
    var getColorKeluar;

    if (perhitunganJamMasuk1 < 0) {
      getColorMasuk = Colors.red;
    } else {
      getColorMasuk = Colors.black;
    }

    if (perhitunganJamMasuk2 == 0) {
      getColorKeluar = Colors.black;
    } else if (perhitunganJamMasuk2 > 0) {
      getColorKeluar = Colors.red;
    } else if (perhitunganJamMasuk2 < 0) {
      getColorKeluar = Constanst.colorPrimary;
    }
    return InkWell(
      onTap: () {
        if (statusView == false) {
          controller.historySelected(index['id'], 'history');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
          ),
          statusView == false
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "${Constanst.convertDate('${index['atten_date']}')}",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                              "Type : ${regType == 0 ? "Face Recognition" : "Photo"}",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: getColorMasuk,
                            size: 14,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              "${jamMasuk}",
                              style:
                                  TextStyle(color: getColorMasuk, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: getColorKeluar,
                            size: 14,
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: signInLongLat == ""
                                  ? Text("")
                                  : Text(
                                      "${jamKeluar}",
                                      style: TextStyle(
                                          color: getColorKeluar, fontSize: 14),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 50,
                            child: Text(
                                "${Constanst.convertDate('${index['atten_date']}')}",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 50,
                            child: Text(
                              "${note}".toLowerCase(),
                              style: TextStyle(color: Constanst.colorText3),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
          SizedBox(
            height: 16,
          ),
          Divider(
            height: 3,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget listTurunanHistoryAbsen(indexData) {
    return ListView.builder(
        itemCount: indexData.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          var jamMasuk = indexData[index]['signin_time'] ?? '';
          var jamKeluar = indexData[index]['signout_time'] ?? '';
          var placeIn = indexData[index]['place_in'] ?? '';
          var placeOut = indexData[index]['place_out'] ?? '';
          var note = indexData[index]['signin_note'] ?? '';
          var signInLongLat = indexData[index]['signin_longlat'] ?? '';
          var signOutLongLat = indexData[index]['signout_longlat'] ?? '';
          var statusView;
          if (placeIn != "") {
            statusView = placeIn == "pengajuan" && placeOut == "pengajuan"
                ? true
                : false;
          }
          var listJamMasuk = (jamMasuk!.split(':'));
          var listJamKeluar = (jamKeluar!.split(':'));
          var perhitunganJamMasuk1 =
              830 - int.parse("${listJamMasuk[0]}${listJamMasuk[1]}");
          var perhitunganJamMasuk2 =
              1800 - int.parse("${listJamKeluar[0]}${listJamKeluar[1]}");
          var getColorMasuk;
          var getColorKeluar;

          if (perhitunganJamMasuk1 < 0) {
            getColorMasuk = Colors.red;
          } else {
            getColorMasuk = Colors.black;
          }

          if (perhitunganJamMasuk2 == 0) {
            getColorKeluar = Colors.black;
          } else if (perhitunganJamMasuk2 > 0) {
            getColorKeluar = Colors.red;
          } else if (perhitunganJamMasuk2 < 0) {
            getColorKeluar = Constanst.colorPrimary;
          }
          return InkWell(
            onTap: () {
              if (statusView == false) {
                controller.historySelected(indexData[index]['id'], 'history');
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                ),
                statusView == false
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  color: getColorMasuk,
                                  size: 14,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    "${jamMasuk}",
                                    style: TextStyle(
                                        color: getColorMasuk, fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: getColorKeluar,
                                  size: 14,
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: signInLongLat == ""
                                        ? Text("")
                                        : Text(
                                            "${jamKeluar}",
                                            style: TextStyle(
                                                color: getColorKeluar,
                                                fontSize: 14),
                                          ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 10,
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${note}".toLowerCase(),
                                  style: TextStyle(color: Constanst.colorText3),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
              ],
            ),
          );
        });
  }
}
