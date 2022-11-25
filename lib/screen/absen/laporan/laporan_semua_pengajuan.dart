import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/laporan_tidakHadir_controller.dart';
import 'package:siscom_operasional/controller/tidak_masuk_kerja_controller.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_semua_pengajuan_detail.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
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
                              : widget.title == "dinas_luar"
                                  ? "Laporan Dinas Luar"
                                  : widget.title == "klaim"
                                      ? "Laporan Klaim"
                                      : "",
              colorTitle: Colors.black,
              icon: 1,
              rightIcon: Icon(Iconsax.document_download),
              onTap: () {
                Get.back();
              },
              // onTap2: () {
              //   UtilsAlert.showToast("Comming Soon");
              // },
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
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    controller.selectedViewFilterPengajuan
                                                .value ==
                                            0
                                        ? Text(
                                            "${controller.namaDepartemenTerpilih.value}  (${Constanst.convertDateBulanDanTahun('${controller.bulanDanTahunNow}')})",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          )
                                        : Text(
                                            "${controller.namaDepartemenTerpilih.value}  (${Constanst.convertDate('${DateFormat('yyyy-MM-dd').format(controller.pilihTanggalFilterAjuan.value)}')})",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                    Text(
                                      "${controller.allNameLaporanTidakhadir.value.length} Data",
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
                                    controller.pageViewFilterWaktu =
                                        PageController(
                                            initialPage: controller
                                                .selectedViewFilterPengajuan
                                                .value);
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
                              : controller
                                      .allNameLaporanTidakhadir.value.isEmpty
                                  ? Center(
                                      child:
                                          Text(controller.loadingString.value),
                                    )
                                  : listPengajuanKaryawan(),
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
                ),
              ),
              Expanded(
                flex: 50,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: InkWell(
                    onTap: () {
                      if (controller.selectedViewFilterPengajuan.value == 1) {
                        controller.showDataStatusAjuan();
                      }
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
                            child: Text(
                                controller.filterStatusAjuanTerpilih.value),
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget listPengajuanKaryawan() {
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
          var statusAjuan;
          if (widget.title == "lembur" ||
              widget.title == "tugas_luar" ||
              widget.title == "klaim") {
            var tampung =
                controller.allNameLaporanTidakhadir.value[index]['status'];
            statusAjuan = tampung == "Approve"
                ? "Approve 1"
                : tampung == "Approve2"
                    ? "Approve 2"
                    : tampung;
          } else {
            var tampung = controller.allNameLaporanTidakhadir.value[index]
                ['leave_status'];
            statusAjuan = tampung == "Approve"
                ? "Approve 1"
                : tampung == "Approve2"
                    ? "Approve 2"
                    : tampung;
          }

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
                          child: controller.statusFilterWaktu.value == 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$jumlahPengajuan Pengajuan",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Constanst.colorText2),
                                    ),
                                    Text(
                                      "${Constanst.convertDateBulanDanTahun('${controller.bulanDanTahunNow.value}')}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Constanst.colorText2),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: EdgeInsets.only(
                                      left: 3, right: 3, top: 5, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      statusAjuan == 'Approve'
                                          ? Icon(
                                              Iconsax.tick_square,
                                              color: Constanst.color5,
                                              size: 14,
                                            )
                                          : statusAjuan == 'Approve 1'
                                              ? Icon(
                                                  Iconsax.tick_square,
                                                  color: Constanst.color5,
                                                  size: 14,
                                                )
                                              : statusAjuan == 'Approve 2'
                                                  ? Icon(
                                                      Iconsax.tick_square,
                                                      color: Constanst.color5,
                                                      size: 14,
                                                    )
                                                  : statusAjuan == 'Rejected'
                                                      ? Icon(
                                                          Iconsax.close_square,
                                                          color:
                                                              Constanst.color4,
                                                          size: 14,
                                                        )
                                                      : statusAjuan == 'Pending'
                                                          ? Icon(
                                                              Iconsax.timer,
                                                              color: Constanst
                                                                  .color3,
                                                              size: 14,
                                                            )
                                                          : SizedBox(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 3),
                                        child: Text(
                                          '$statusAjuan',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: statusAjuan == 'Approve'
                                                  ? Colors.green
                                                  : statusAjuan == 'Approve 1'
                                                      ? Colors.green
                                                      : statusAjuan ==
                                                              'Approve 2'
                                                          ? Colors.green
                                                          : statusAjuan ==
                                                                  'Rejected'
                                                              ? Colors.red
                                                              : statusAjuan ==
                                                                      'Pending'
                                                                  ? Constanst
                                                                      .color3
                                                                  : Colors
                                                                      .black),
                                        ),
                                      ),
                                    ],
                                  ),
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
