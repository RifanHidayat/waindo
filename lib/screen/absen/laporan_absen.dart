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
    super.initState();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    controller.carilaporanAbsenkaryawan();
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
              title: "Laporan Absensi",
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
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "List Laporan Absensi Karyawan",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      controller.namaDepartemenTerpilih.value,
                                      style: TextStyle(
                                          color: Constanst.colorText2,
                                          fontSize: 12),
                                    )
                                  ],
                                ),
                              ),
                            ),
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
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 44,
            child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: InkWell(
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
                      }
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: Constanst.borderStyle1,
                        border: Border.all(color: Constanst.colorText2)),
                    child: Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 8),
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
                                    padding: const EdgeInsets.only(left: 3),
                                    child: Text(
                                      "${Constanst.convertDateBulanDanTahun(controller.bulanDanTahunNow.value)}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
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
                  controller.carilaporanAbsenkaryawan();
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
                              "${Constanst.convertDate2("$attenDate")}",
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
