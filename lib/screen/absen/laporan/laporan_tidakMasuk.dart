import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:siscom_operasional/controller/laporan_tidakHadir_controller.dart';
import 'package:siscom_operasional/controller/tidak_masuk_kerja_controller.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_detail_tidakMasuk.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class LaporanTidakMasuk extends StatefulWidget {
  String title;
  LaporanTidakMasuk({Key? key, required this.title}) : super(key: key);
  @override
  _LaporanTidakMasukState createState() => _LaporanTidakMasukState();
}

class _LaporanTidakMasukState extends State<LaporanTidakMasuk> {
  var controller = Get.put(LaporanTidakHadirController());

  @override
  void initState() {
    controller.getDepartemen(1, "");
    controller.title.value = widget.title;
    super.initState();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    controller.getDepartemen(1, "");
    controller.title.value = widget.title;
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
              title: widget.title == "tidak_hadir"
                  ? "Laporan Tidak Hadir"
                  : widget.title == "cuti"
                      ? "Laporan Cuti"
                      : widget.title == "lembur"
                          ? "Laporan Lembur"
                          : widget.title == "tugas_luar"
                              ? "Laporan Tugas Luar"
                              : "",
              colorTitle: Colors.black,
              icon: 3,
              rightIcon: Icon(Iconsax.document_download),
              onTap: () {
                Get.back();
              },
              onTap2: () {
                UtilsAlert.showToast("Comming Soon");
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
                                    widget.title == 'tidak_hadir'
                                        ? Text(
                                            "List Laporan Tidak Hadir",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          )
                                        : widget.title == 'cuti'
                                            ? Text(
                                                "List Laporan Cuti",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              )
                                            : widget.title == 'lembur'
                                                ? Text(
                                                    "List Laporan Lembur",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14),
                                                  )
                                                : widget.title == 'tugas_luar'
                                                    ? Text(
                                                        "List Laporan Tugas Luar",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14),
                                                      )
                                                    : SizedBox(),
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
                              : controller
                                      .allNameLaporanTidakhadir.value.isEmpty
                                  ? Center(
                                      child:
                                          Text(controller.loadingString.value),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 50,
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
                            this
                                .controller
                                .bulanSelectedSearchHistory
                                .refresh();
                            this
                                .controller
                                .tahunSelectedSearchHistory
                                .refresh();
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
                flex: 50,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: InkWell(
                    onTap: () {
                      controller.showDataDepartemenAkses('semua');
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
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: pencarianData(),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget pencarianData() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: Constanst.borderStyle2,
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
                                controller.title.value = widget.title;
                                controller.getDepartemen(1, "");
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
        physics: controller.allNameLaporanTidakhadir.value.length <= 15
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.allNameLaporanTidakhadir.value.length,
        itemBuilder: (context, index) {
          var fullName = controller.allNameLaporanTidakhadir.value[index]
                  ['full_name'] ??
              "";
          var namaKaryawan = "$fullName";
          var jobTitle =
              controller.allNameLaporanTidakhadir.value[index]['job_title'];
          var emId = controller.allNameLaporanTidakhadir.value[index]['em_id'];
          var jumlahPengajuan = controller.allNameLaporanTidakhadir.value[index]
              ['jumlah_pengajuan'];

          return InkWell(
            onTap: () {
              Get.to(LaporanDetailTidakHadir(
                emId: emId,
                bulan: controller.bulanSelectedSearchHistory.value,
                tahun: controller.tahunSelectedSearchHistory.value,
                full_name: namaKaryawan,
                title: widget.title,
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
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              jobTitle,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 40,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$jumlahPengajuan Pengajuan",
                                style: TextStyle(
                                    fontSize: 12, color: Constanst.colorText2),
                              ),
                              Text(
                                "${Constanst.convertDateBulanDanTahun('${controller.bulanDanTahunNow.value}')}",
                                style: TextStyle(
                                    fontSize: 12, color: Constanst.colorText2),
                              ),
                            ],
                          ),
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
