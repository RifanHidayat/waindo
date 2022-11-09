// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/Izin_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/lembur_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/controller/ruang_diskusi_controller.dart';
import 'package:siscom_operasional/screen/absen/form/form_izin.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_tidakMasuk.dart';
import 'package:siscom_operasional/screen/diskusi/buat_project.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class RuangDiskusi extends StatefulWidget {
  @override
  _RuangDiskusiState createState() => _RuangDiskusiState();
}

class _RuangDiskusiState extends State<RuangDiskusi> {
  final controller = Get.put(RuangDiskusiController());

  @override
  void initState() {
    controller.startData();
    super.initState();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    controller.startData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Ruang Diskusi",
            colorTitle: Constanst.colorText3,
            colorIcon: Constanst.colorText3,
            icon: 1,
            onTap: () {
              Get.offAll(InitScreen());
            },
          )),
      body: WillPopScope(
        onWillPop: () async {
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
                lineTitle(),
                SizedBox(
                  height: 8,
                ),
                pencarianData(),
                // Flexible(
                //     child: RefreshIndicator(
                //   color: Constanst.colorPrimary,
                //   onRefresh: refreshData,
                //   child: controller.listRiwayatIzin.value.isEmpty
                //       ? Center(
                //           child: Text(controller.loadingString.value),
                //         )
                //       : riwayatLembur(),
                // ))
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        icon: Iconsax.add,
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
              child: Icon(Iconsax.task_square),
              backgroundColor: Color(0xff2F80ED),
              foregroundColor: Colors.white,
              label: 'Buat Tugas',
              onTap: () {
                // Get.to(LaporanTidakMasuk(
                //   title: 'izin',
                // ));
              }),
          SpeedDialChild(
              child: Icon(Iconsax.clipboard_tick),
              backgroundColor: Color(0xff2F80ED),
              foregroundColor: Colors.white,
              label: 'Buat Project',
              onTap: () {
                Get.to(BuatProject());
              }),
        ],
      ),
    );
  }

  Widget lineTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              controller.changeType(0);
            },
            child: Container(
              margin: EdgeInsets.only(left: 3.0, right: 3.0),
              decoration: BoxDecoration(
                color: controller.selectType.value == 0
                    ? Constanst.colorPrimary
                    : Colors.transparent,
                borderRadius: Constanst.borderStyle1,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "Project",
                    style: TextStyle(
                        fontSize: 14,
                        color: controller.selectType.value == 0
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              controller.changeType(1);
            },
            child: Container(
              margin: EdgeInsets.only(left: 3.0, right: 3.0),
              decoration: BoxDecoration(
                color: controller.selectType.value == 1
                    ? Constanst.colorPrimary
                    : Colors.transparent,
                borderRadius: Constanst.borderStyle1,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "Tugas",
                    style: TextStyle(
                        fontSize: 14,
                        color: controller.selectType.value == 1
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget pencarianData() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 70,
          child: Container(
            margin: EdgeInsets.only(right: 3.0),
            decoration: BoxDecoration(
                borderRadius: Constanst.borderStyle5,
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 85,
                            child: TextField(
                              controller: controller.cari.value,
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: "Cari"),
                              style: TextStyle(
                                  fontSize: 14.0,
                                  height: 1.0,
                                  color: Colors.black),
                              onChanged: (value) {
                                controller.cariData(value);
                              },
                            ),
                          ),
                          !controller.statusCari.value
                              ? SizedBox()
                              : Expanded(
                                  flex: 15,
                                  child: IconButton(
                                    icon: Icon(
                                      Iconsax.close_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      controller.statusCari.value = false;
                                      controller.cari.value.text = "";
                                      controller.startData();
                                    },
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 30,
          child: Container(
            height: 40,
            margin: EdgeInsets.only(left: 3.0),
            decoration: BoxDecoration(
                borderRadius: Constanst.borderStyle5,
                border: Border.all(color: Constanst.colorNonAktif)),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Iconsax.sort),
                  )),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text("Urutkan"),
                  ))
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
