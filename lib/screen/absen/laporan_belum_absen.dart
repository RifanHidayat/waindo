import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/screen/absen/history_absen.dart';
import 'package:siscom_operasional/screen/absen/laporan_absen_karyawan.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class LaporanBelumAbsen extends StatefulWidget {
  var dataForm;
  LaporanBelumAbsen({Key? key, this.dataForm}) : super(key: key);
  @override
  _LaporanBelumAbsenState createState() => _LaporanBelumAbsenState();
}

class _LaporanBelumAbsenState extends State<LaporanBelumAbsen> {
  var controller = Get.put(AbsenController());

  @override
  void initState() {
    controller.pilihTanggalTelatAbsen.value = DateTime.now();
    controller.filterBelumAbsen();
    super.initState();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    controller.aksiEmployeeBelumAbsen(
        "${DateFormat('yyyy-MM-dd').format(controller.pilihTanggalTelatAbsen.value)}");
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
              title: "Laporan Belum Absen",
              colorTitle: Colors.black,
              icon: 1,
              onTap: () {
                Get.back();
              },
            )),
        body: WillPopScope(
            onWillPop: () async {
              Get.back();
              return true;
            },
            child: SafeArea(
              child: Obx(
                () => Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      controller.bulanDanTahunNow.value == ""
                          ? SizedBox()
                          : cariData(),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 50,
                              child: Container(
                                padding: EdgeInsets.only(top: 8),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${controller.namaDepartemenTerpilih.value}",
                                      style: TextStyle(
                                          color: Constanst.colorText3,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${DateFormat('EEEE, dd-MM-yyyy').format(controller.pilihTanggalTelatAbsen.value)}",
                                      style: TextStyle(
                                          color: Constanst.colorText2,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 50,
                              child: Container(
                                padding: EdgeInsets.only(top: 8),
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "",
                                      style: TextStyle(
                                          color: Constanst.colorText3,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${controller.jumlahData.value} Karyawan Belum Absen",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Constanst.colorText2,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Expanded(
                            //   flex: 75,
                            //   child: Container(
                            //     alignment: Alignment.centerLeft,
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         Text(
                            //           "List Laporan Karyawan Belum Absen",
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.bold,
                            //               fontSize: 14),
                            //         ),
                            //         SizedBox(
                            //           height: 5,
                            //         ),
                            //         Text(
                            //           "${controller.namaDepartemenTerpilih.value} - ${DateFormat('EEEE, dd-MM-yyyy').format(controller.pilihTanggalTelatAbsen.value)}",
                            //           style: TextStyle(
                            //               color: Constanst.colorText2,
                            //               fontSize: 12),
                            //         ),
                            //         SizedBox(
                            //           height: 5,
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // Expanded(
                            //   flex: 25,
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //         borderRadius: Constanst.borderStyle5,
                            //         color: Constanst.colorButton2),
                            //     child: Column(
                            //       mainAxisAlignment: MainAxisAlignment.end,
                            //       children: [
                            //         SizedBox(
                            //           height: 5,
                            //         ),
                            //         controller.jumlahData.value == "0" ||
                            //                 controller.jumlahData.value == ""
                            //             ? SizedBox()
                            //             : Text("${controller.jumlahData.value}",
                            //                 textAlign: TextAlign.center,
                            //                 style: TextStyle(
                            //                     color: Constanst.colorPrimary,
                            //                     fontSize: 12)),
                            //         controller.jumlahData.value == "0" ||
                            //                 controller.jumlahData.value == ""
                            //             ? SizedBox()
                            //             : Padding(
                            //                 padding: const EdgeInsets.only(
                            //                     bottom: 6),
                            //                 child: Text("Karyawan",
                            //                     textAlign: TextAlign.center,
                            //                     style: TextStyle(
                            //                         color:
                            //                             Constanst.colorPrimary,
                            //                         fontSize: 12)),
                            //               )
                            //       ],
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Flexible(
                        child: RefreshIndicator(
                          onRefresh: refreshData,
                          child: controller.statusLoadingSubmitLaporan.value
                              ? Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Constanst.colorPrimary,
                                  ),
                                )
                              : controller.listLaporanBelumAbsen.value.isEmpty
                                  ? Center(
                                      child: Text(controller.loading.value),
                                    )
                                  : listAbsensiKaryawan(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget cariData() {
    return SizedBox(
      child: Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 44,
              child: InkWell(
                onTap: () async {
                  var dateSelect = await showDatePicker(
                    context: Get.context!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: controller.pilihTanggalTelatAbsen.value,
                  );
                  if (dateSelect == null) {
                    UtilsAlert.showToast("Tanggal tidak terpilih");
                  } else {
                    print(dateSelect);
                    controller.pilihTanggalTelatAbsen.value = dateSelect;
                    this.controller.pilihTanggalTelatAbsen.refresh();
                  }
                },
                child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: Constanst.borderStyle1,
                          border: Border.all(color: Constanst.colorText2)),
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Icon(Iconsax.calendar_2),
                                  ),
                                  Flexible(
                                    child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "${DateFormat('dd-MM-yyyy').format(controller.pilihTanggalTelatAbsen.value)}",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              height: 2.0,
                                              color: Colors.black),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ),
            Expanded(
              flex: 44,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: InkWell(
                  onTap: () {
                    controller.showDataDepartemenAkses();
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(Get.context!).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Constanst.borderStyle1,
                        border: Border.all(color: Constanst.colorText2)),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(controller.departemen.value.text),
                        )),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 12,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: InkWell(
                  onTap: () {
                    controller.aksiEmployeeBelumAbsen(
                        "${DateFormat('yyyy-MM-dd').format(controller.pilihTanggalTelatAbsen.value)}");
                  },
                  child: Container(
                      width: MediaQuery.of(Get.context!).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Constanst.colorPrimary,
                        borderRadius: Constanst.borderStyle1,
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.search_normal_1,
                          color: Colors.white,
                          size: 16,
                        ),
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget listAbsensiKaryawan() {
    return ListView.builder(
        physics: controller.listLaporanBelumAbsen.value.length <= 15
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.listLaporanBelumAbsen.value.length,
        itemBuilder: (context, index) {
          var fullName =
              controller.listLaporanBelumAbsen.value[index]['full_name'] ?? "";
          var namaKaryawan = "$fullName";
          var jobTitle =
              controller.listLaporanBelumAbsen.value[index]['job_title'];
          var emId = controller.listLaporanBelumAbsen.value[index]['em_id'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaKaryawan,
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            jobTitle,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Expanded(
                    //   flex: 30,
                    //   child: Center(
                    //       child: Text(
                    //     "$jamMasuk",
                    //     style: TextStyle(color: Colors.red),
                    //   )),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Divider(
                height: 3,
                color: Colors.grey,
              ),
            ],
          );
        });
  }

  Widget textSubmit() {
    return controller.statusLoadingSubmitLaporan.value == false
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.search_normal_1,
                size: 18,
                color: Constanst.colorWhite,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Submit Data",
                  style: TextStyle(color: Constanst.colorWhite),
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Center(
                  child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      )),
                ),
              )
            ],
          );
  }
}
