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
import 'dart:math' as math;

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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width:
                                  MediaQuery.of(Get.context!).size.width * 0.7,
                              margin: EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  controller.selectedViewFilterAbsen.value == 0
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
                                ],
                              ),
                            ),
                            Text(
                              "${controller.listLaporanFilter.value.length} Data",
                              style: TextStyle(
                                  color: Constanst.colorText2, fontSize: 12),
                            )
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
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            controller.departemen.value.text != "SEMUA DIVISI"
                ? Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () {
                        controller.selectedViewFilterAbsen.value = 0;
                        controller.refreshFilterKoordinate();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: Constanst.borderStyle5,
                            border: Border.all(color: Constanst.colorText2)),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: InkWell(
                            onTap: () {
                              controller.selectedViewFilterAbsen.value = 0;
                              controller.refreshFilterKoordinate();
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : controller.filterLokasiKoordinate.value != "Lokasi"
                    ? Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            controller.refreshFilterKoordinate();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Constanst.colorText2)),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: InkWell(
                                onTap: () {},
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : controller.selectedViewFilterAbsen.value != 0
                        ? Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                controller.refreshFilterKoordinate();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: Constanst.borderStyle5,
                                    border: Border.all(
                                        color: Constanst.colorText2)),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: InkWell(
                                    onTap: () {},
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.close,
                                          size: 15,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
            InkWell(
              onTap: () {
                
              },
              child: Container(
                child: InkWell(
                  onTap: () {
                    controller.pageViewFilterAbsen = PageController(
                        initialPage: controller.selectedViewFilterAbsen.value);
                    controller.widgetButtomSheetFilterData();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Constanst.infoLight1,
                        borderRadius: Constanst.borderStyle5,
                        border: Border.all(color: Constanst.infoLight)),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          controller.selectedViewFilterAbsen.value == 0
                              ? Text(
                                  " ${Constanst.convertDateBulanDanTahun('${controller.bulanDanTahunNow}')}",
                                  style: TextStyle(fontSize: 10),
                                )
                              : Text(
                                  " ${Constanst.convertDate('${DateFormat('yyyy-MM-dd').format(controller.pilihTanggalTelatAbsen.value)}')}",
                                  style: TextStyle(fontSize: 10),
                                ),
                          // Text("Bulan/Tanggal", style: TextStyle(fontSize: 10)),
                          Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Transform.rotate(
                              angle: -math.pi / 2,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                controller.showDataDepartemenAkses('semua');
              },
              child: Container(
                decoration: BoxDecoration(
                    color: controller.departemen.value.text == "SEMUA DIVISI"
                        ? Colors.white
                        : Constanst.infoLight1,
                    borderRadius: Constanst.borderStyle5,
                    border: Border.all(
                      color: controller.departemen.value.text == "SEMUA DIVISI"
                          ? Constanst.colorText2
                          : Constanst.infoLight,
                    )),
                // child: Text(
                //   controller.departemen.value.text,
                //   style: TextStyle(fontSize: 10),
                // ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(children: [
                    Text(
                      controller.departemen.value.text,
                      style: TextStyle(fontSize: 10),
                    ),
                    controller.departemen.value.text == "SEMUA DIVISI"
                        ? Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Transform.rotate(
                              angle: -math.pi / 2,
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 12,
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Transform.rotate(
                              angle: -math.pi / 2,
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 13,
                              ),
                            ),
                          )
                    // Padding(
                    //     padding: const EdgeInsets.only(left: 6),
                    //     child: InkWell(
                    //       onTap: () {
                    //         controller.departemen.value.text =
                    //             "SEMUA DIVISI";
                    //         // controller.showDataDepartemenAkses('semua');
                    //       },
                    //       child: Icon(
                    //         Iconsax.close_circle,
                    //         size: 20,
                    //         color: Colors.red,
                    //       ),
                    //     ),
                    //   )
                  ]),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                controller.showDataLokasiKoordinate();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: controller.filterLokasiKoordinate.value == "Lokasi"
                        ? Colors.white
                        : Constanst.infoLight1,
                    borderRadius: Constanst.borderStyle5,
                    border: Border.all(
                      color: controller.filterLokasiKoordinate.value == "Lokasi"
                          ? Constanst.colorText2
                          : Constanst.infoLight,
                    )),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(controller.filterLokasiKoordinate.value,
                            style: TextStyle(fontSize: 10)),
                      ),
                      controller.filterLokasiKoordinate.value == "Lokasi"
                          ? Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Transform.rotate(
                                angle: -math.pi / 2,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 12,
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Transform.rotate(
                                angle: -math.pi / 2,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 12,
                                ),
                              ),
                            )

                      // Padding(
                      //     padding: const EdgeInsets.only(left: 5),
                      //     child: InkWell(
                      //       onTap: () {
                      //         controller.refreshFilterKoordinate();
                      //       },
                      //       child: Icon(
                      //         Iconsax.close_circle,
                      //         size: 20,
                      //         color: Colors.red,
                      //       ),
                      //     ),
                      //   )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
    controller.listLaporanFilter.value = controller.listLaporanFilter
        .fold(Map<String, List<dynamic>>(), (Map<String, List<dynamic>> a, b) {
          a.putIfAbsent(b['em_id'], () => []).add(b);
          return a;
        })
        .values
        .where((l) => l.isNotEmpty)
        .map((l) => {
              'full_name': l.first['full_name'],
              'job_title': l.first['job_title'],
              'em_id': l.first['em_id'],
              'atten_date': l.first['atten_date'],
              'signin_time': l.first['signin_time'],
              'signout_time': l.first['signout_time'],
              'signin_note': l.first['signin_note'],
              'place_in': l.first['place_in'],
              'place_out': l.first['place_out'],
              'signin_longlat': l.first['signin_longlat'],
              'id': l.first['id_absen'],
              'signout_longlat': l.first['signout_longlat'],
              'is_open': true,
              'data': l
                  .map((e) => {
                        'full_name': e['full_name'],
                        'id': e['id_absen'],
                        'job_title': e['job_title'],
                        'em_id': e['em_id'],
                        'atten_date': e['atten_date'],
                        'signin_time': e['signin_time'],
                        'signout_time': e['signout_time'],
                        'signin_note': e['signin_note'],
                        'place_in': l.first['place_in'],
                        'place_out': l.first['place_out'],
                        'signin_longlat': l.first['signin_longlat'],
                        'signout_longlat': l.first['signout_longlat'],
                      })
                  .toList()
            })
        .toList();
    print(controller.listLaporanFilter.value);

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
          var signNote =
              controller.listLaporanFilter.value[index]['signin_note'];
          print(controller.listLaporanFilter.value[index]['data']
              .toList()
              .length
              .toString());
          return controller.listLaporanFilter.value[index]['data']
                      .toList()
                      .length <=
                  1
              ? InkWell(
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
                                    '$namaKaryawan',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '$jobTitle',
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
                                  signinTime == "00:00:00" ||
                                          signinTime == "null"
                                      ? Text(
                                          '$signNote',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 3, right: 3),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.login_rounded,
                                                    color: Constanst.color5,
                                                    size: 14,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 3),
                                                    child: Text(
                                                      '$signinTime',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Constanst.color5),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            signoutTime == "00:00:00" ||
                                                    signoutTime == "null"
                                                ? SizedBox()
                                                : Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 3, right: 3),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.logout_rounded,
                                                          color:
                                                              Constanst.color4,
                                                          size: 14,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 3),
                                                          child: Text(
                                                            '$signoutTime',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Constanst
                                                                    .color4),
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
                )
              : Column(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.listLaporanFilter.value[index]['is_open'] =
                            !controller.listLaporanFilter.value[index]
                                ['is_open'];
                        controller.listLaporanFilter.refresh();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 50,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$namaKaryawan',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '$jobTitle',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const Center(
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
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
                    ),
                    controller.listLaporanFilter.value[index]['is_open'] == true
                        ? Container(
                            padding: EdgeInsets.only(left: 20, right: 0),
                            child: Column(
                              children: List.generate(
                                  controller
                                      .listLaporanFilter.value[index]['data']
                                      .toList()
                                      .length, (index1) {
                                var idAbsen = controller.listLaporanFilter
                                    .value[index]['data'][index1]['id'];
                                var jamMasuk =
                                    controller.listLaporanFilter.value[index]
                                        ['data'][index1]['signin_time'];
                                var jamKeluar =
                                    controller.listLaporanFilter.value[index]
                                        ['data'][index1]['signout_time'];
                                var tanggal = controller.listLaporanFilter
                                    .value[index]['data'][index1]['atten_date'];
                                var longLatAbsenKeluar =
                                    controller.listLaporanFilter.value[index]
                                        ['data'][index1]['signout_longlat'];

                                var placeIn = controller.listLaporanFilter
                                    .value[index]['data'][index1]['place_in'];
                                var placeOut = controller.listLaporanFilter
                                    .value[index]['data'][index1]['place_out'];

                                var note =
                                    controller.listLaporanFilter.value[index]
                                        ['data'][index1]['signin_note'];

                                var signInLongLat =
                                    controller.listLaporanFilter.value[index]
                                        ['data'][index1]['signin_longlat'];

                                var signOutLongLat =
                                    controller.listLaporanFilter.value[index]
                                        ['data'][index1]['signout_longlat'];

                                var statusView = placeIn == "pengajuan" &&
                                        placeOut == "pengajuan" &&
                                        signInLongLat == "pengajuan" &&
                                        signOutLongLat == "pengajuan"
                                    ? true
                                    : false;

                                var listJamMasuk = (jamMasuk!.split(':'));
                                var listJamKeluar = (jamKeluar!.split(':'));
                                var perhitunganJamMasuk1 = 830 -
                                    int.parse(
                                        "${listJamMasuk[0]}${listJamMasuk[1]}");
                                var perhitunganJamMasuk2 = 1800 -
                                    int.parse(
                                        "${listJamKeluar[0]}${listJamKeluar[1]}");

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
                                    controller.loadAbsenDetail(
                                        idAbsen, attenDate, fullName);
                                    print(idAbsen);
                                    // controller.historySelected1(
                                    //     idAbsen.toString(),
                                    //     "laporan",
                                    //     index,
                                    //     index1);

                                    // if (statusView == false) {
                                    //   controller.historySelected(
                                    //       idAbsen.toString(), "laporan");
                                    // }
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      statusView == false
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 40,
                                                  child: Text(
                                                    "${Constanst.convertDate(tanggal)}",
                                                    style:
                                                        TextStyle(fontSize: 14),
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 8),
                                                        child: Text(
                                                          jamMasuk,
                                                          style: TextStyle(
                                                              color:
                                                                  getColorMasuk,
                                                              fontSize: 14),
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
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8),
                                                          child:
                                                              longLatAbsenKeluar ==
                                                                      ""
                                                                  ? Text("")
                                                                  : Text(
                                                                      jamKeluar,
                                                                      style: TextStyle(
                                                                          color:
                                                                              getColorKeluar,
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                // Expanded(
                                                //   flex: 10,
                                                //   child: Padding(
                                                //     padding:
                                                //         const EdgeInsets.only(
                                                //             top: 4),
                                                //     child: Icon(
                                                //       Icons
                                                //           .arrow_forward_ios_rounded,
                                                //       size: 14,
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            )
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 40,
                                                  child: Text(
                                                    "${Constanst.convertDate(tanggal ?? '')}",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 60,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "$note",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
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
                              }),
                            ),
                          )
                        : Container(),
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
