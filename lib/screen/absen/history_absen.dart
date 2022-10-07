import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:siscom_operasional/screen/absen/laporan_absen.dart';
import 'package:siscom_operasional/screen/absen/laporan_absen_telat.dart';
import 'package:siscom_operasional/screen/absen/laporan_belum_absen.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class HistoryAbsen extends StatelessWidget {
  final controller = Get.put(AbsenController());
  final controllerDashboard = Get.put(DashboardController());

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
                        backgroundColor: Color(0xff2F80ED),
                        foregroundColor: Colors.white,
                        label: 'Absen Terlambat',
                        onTap: () {
                          Get.to(LaporanAbsenTelat(
                            dataForm: "",
                          ));
                        }),
                    SpeedDialChild(
                        child: Icon(Iconsax.watch),
                        backgroundColor: Color(0xff2F80ED),
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
      onTap: () {
        showMonthPicker(
          context: Get.context!,
          firstDate: DateTime(DateTime.now().year - 1, 5),
          lastDate: DateTime(DateTime.now().year + 1, 9),
          initialDate: DateTime.now(),
          locale: Locale("en"),
        ).then((date) {
          if (date != null) {
            print(date);
            var outputFormat1 = DateFormat('MM');
            var outputFormat2 = DateFormat('yyyy');
            var bulan = outputFormat1.format(date);
            var tahun = outputFormat2.format(date);
            controller.bulanSelectedSearchHistory.value = bulan;
            controller.tahunSelectedSearchHistory.value = tahun;
            controller.bulanDanTahunNow.value = "$bulan-$tahun";
            this.controller.bulanSelectedSearchHistory.refresh();
            this.controller.tahunSelectedSearchHistory.refresh();
            this.controller.bulanDanTahunNow.refresh();
            controller.loadHistoryAbsenUser();
          }
        });
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
        physics: controller.historyAbsen.value.length <= 20
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.historyAbsen.value.length,
        itemBuilder: (context, index) {
          var jamMasuk = controller.historyAbsen.value[index].signin_time;
          var jamKeluar = controller.historyAbsen.value[index].signout_time;
          var tanggal = controller.historyAbsen.value[index].atten_date;
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
              controller.historySelected(
                  controller.historyAbsen.value[index].id, 'history');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 40,
                      child: Text(
                        "${Constanst.convertDate(tanggal ?? '')}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      flex: 25,
                      child: Row(
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: getColorMasuk,
                            size: 14,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              jamMasuk,
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
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: getColorKeluar,
                            size: 14,
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: controller.historyAbsen.value[index]
                                          .signout_longlat ==
                                      ""
                                  ? Text("")
                                  : Text(
                                      jamKeluar,
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
                ),
                SizedBox(
                  height: 15,
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
