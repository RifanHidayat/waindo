import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/screen/absen/history_absen.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_absen_karyawan.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:bottom_picker/bottom_picker.dart';

class LaporanAbsen extends StatefulWidget {
  var dataForm;
  LaporanAbsen({Key? key, this.dataForm}) : super(key: key);
  @override
  _LaporanAbsenState createState() => _LaporanAbsenState();
}

class _LaporanAbsenState extends State<LaporanAbsen> {
  var controller = Get.put(AbsenController());

  @override
  void initState() {
    controller.onReady();
    controller.getPlaceCoordinate();
    super.initState();
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
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 3,
            flexibleSpace: AppbarMenu1(
              title: "Laporan Absensi",
              colorTitle: Colors.black,
              icon: 1,
              rightIcon: Icon(Iconsax.document_download),
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
                          : pencarianData(),
                      SizedBox(
                        height: 8,
                      ),
                      cariData(),
                      SizedBox(
                        height: 8,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 75,
                              child: Container(
                                margin: EdgeInsets.only(top: 6),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    controller.selectedViewFilterAbsen.value ==
                                            0
                                        ? Text(
                                            "${controller.namaDepartemenTerpilih.value}  (${Constanst.convertDateBulanDanTahun('${controller.bulanDanTahunNow}')})",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          )
                                        : Text(
                                            "${controller.namaDepartemenTerpilih.value}  (${Constanst.convertDate('${DateFormat('yyyy-MM-dd').format(controller.pilihTanggalTelatAbsen.value)}')})",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                    Text(
                                      "${controller.listLaporanFilter.value.length} Data",
                                      style: TextStyle(
                                          color: Constanst.colorText2,
                                          fontSize: 12),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 25,
                                child: InkWell(
                                  onTap: () {
                                    controller.pageViewFilterAbsen =
                                        PageController(
                                            initialPage: controller
                                                .selectedViewFilterAbsen.value);
                                    controller.widgetButtomSheetFilterData();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: Constanst.borderStyle5,
                                        border: Border.all(
                                            color: Constanst.colorText2)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          left: 6.0,
                                          right: 6.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("Filter"),
                                          Padding(
                                            padding: EdgeInsets.only(left: 6),
                                            child: Icon(Iconsax.setting_4),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
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
                              : controller.listLaporanFilter.value.isEmpty
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 50,
            child: InkWell(
              onTap: () {
                controller.showDataDepartemenAkses('semua');
              },
              child: Container(
                height: 42,
                width: MediaQuery.of(Get.context!).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: Constanst.borderStyle5,
                    border: Border.all(color: Constanst.colorText2)),
                child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(controller.departemen.value.text),
                    )),
              ),
            )),
        Expanded(
          flex: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: InkWell(
              onTap: () {
                controller.showDataLokasiKoordinate();
              },
              child: Container(
                height: 42,
                width: MediaQuery.of(Get.context!).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: Constanst.borderStyle5,
                    border: Border.all(color: Constanst.colorText2)),
                child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 80,
                              child: Obx(
                                () => Text(
                                    controller.filterLokasiKoordinate.value),
                              )),
                          controller.filterLokasiKoordinate.value == "Lokasi"
                              ? SizedBox()
                              : Expanded(
                                  flex: 20,
                                  child: InkWell(
                                    onTap: () {
                                      controller.refreshFilterKoordinate();
                                    },
                                    child: Icon(
                                      Iconsax.close_circle,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget pencarianData() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: Constanst.borderStyle5,
          border: Border.all(color: Constanst.colorText2)),
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
                            border: InputBorder.none,
                            hintText: "Cari Nama Karyawan"),
                        style: TextStyle(
                            fontSize: 14.0, height: 1.0, color: Colors.black),
                        onChanged: (value) {
                          controller.pencarianNamaKaryawan(value);
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
                                controller.listLaporanFilter.value =
                                    controller.allListLaporanFilter.value;
                                this.controller.listLaporanFilter.refresh();
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
    );
  }

  Widget listAbsensiKaryawan() {
    return ListView.builder(
        physics: controller.listLaporanFilter.value.length <= 15
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.listLaporanFilter.value.length,
        itemBuilder: (context, index) {
          var fullName =
              controller.listLaporanFilter.value[index]['full_name'] ?? "";
          var namaKaryawan = "$fullName";
          var jobTitle = controller.listLaporanFilter.value[index]['job_title'];
          var emId = controller.listLaporanFilter.value[index]['em_id'];
          var attenDate =
              controller.listLaporanFilter.value[index]['atten_date'];
          var signinTime =
              controller.listLaporanFilter.value[index]['signin_time'];
          var signoutTime =
              controller.listLaporanFilter.value[index]['signout_time'];
          return InkWell(
            onTap: () {
              Get.to(LaporanAbsenKaryawan(
                em_id: emId,
                bulan: controller.bulanDanTahunNow.value,
                full_name: namaKaryawan,
              ));
            },
            child: Column(
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
                        flex: 50,
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
                      Expanded(
                        flex: 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${Constanst.convertDate("$attenDate")}",
                              style: TextStyle(fontSize: 12),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 3, right: 3),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.login_rounded,
                                        color: Constanst.color5,
                                        size: 14,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 3),
                                        child: Text(
                                          signinTime,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Constanst.color5),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                signoutTime == "00:00:00" ||
                                        signoutTime == "null"
                                    ? SizedBox()
                                    : Padding(
                                        padding:
                                            EdgeInsets.only(left: 3, right: 3),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.logout_rounded,
                                              color: Constanst.color4,
                                              size: 14,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 3),
                                              child: Text(
                                                signoutTime,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Constanst.color4),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                          ),
                        ),
                      ),
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
            ),
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
