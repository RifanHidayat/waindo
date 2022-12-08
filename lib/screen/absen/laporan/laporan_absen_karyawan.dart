import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/laporan_absen_karyawan_controller.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';

class LaporanAbsenKaryawan extends StatefulWidget {
  String? em_id, bulan, full_name;
  LaporanAbsenKaryawan({Key? key, this.em_id, this.bulan, this.full_name})
      : super(key: key);
  @override
  _LaporanAbsenKaryawanState createState() => _LaporanAbsenKaryawanState();
}

class _LaporanAbsenKaryawanState extends State<LaporanAbsenKaryawan> {
  var controller = Get.put(LaporanAbsenKaryawanController());

  @override
  void initState() {
    controller.loadData(widget.em_id, widget.bulan, widget.full_name);
    super.initState();
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
              title: "Laporan Absen Karyawan",
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 57,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Riwayat Karyawan",
                                style: TextStyle(
                                    color: Constanst.colorText2, fontSize: 12),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                "${widget.full_name}",
                                style: TextStyle(
                                    color: Constanst.colorText3,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 30,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: Constanst.borderStyle5,
                                border:
                                    Border.all(color: Constanst.colorText2)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Iconsax.calendar_1),
                                  Padding(
                                    padding: EdgeInsets.only(left: 3, top: 3),
                                    child: Text("${widget.bulan}"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 13,
                          child: Container(
                              margin: EdgeInsets.only(left: 2),
                              decoration: BoxDecoration(
                                  borderRadius: Constanst.borderStyle5,
                                  border:
                                      Border.all(color: Constanst.colorText2)),
                              child: SizedBox(
                                height: 40,
                                child: PopupMenuButton(
                                  padding: EdgeInsets.all(0.0),
                                  icon: Icon(
                                    Iconsax.setting_3,
                                  ),
                                  offset: const Offset(0, 0),
                                  elevation: 2,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                        value: "0",
                                        onTap: () => controller.filterData('0'),
                                        child: Text("Semua Riwayat")),
                                    PopupMenuItem(
                                        value: "1",
                                        onTap: () => controller.filterData('1'),
                                        child: Text("Terlambat absen masuk")),
                                    PopupMenuItem(
                                        value: "2",
                                        onTap: () => controller.filterData('2'),
                                        child: Text("Pulang lebih lama")),
                                    PopupMenuItem(
                                        value: "3",
                                        onTap: () => controller.filterData('3'),
                                        child: Text("Tidak absen keluar"))
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Flexible(
                        child: controller.prosesLoad.value
                            ? Center(
                                child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Constanst.colorPrimary,
                              ))
                            : controller.detailRiwayat.value.isEmpty
                                ? Center(child: Text(controller.loading.value))
                                : listAbsen())
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget listAbsen() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: controller.detailRiwayat.value.length,
        itemBuilder: (context, index) {
          var idAbsen = controller.detailRiwayat.value[index]['id'];
          var jamMasuk = controller.detailRiwayat.value[index]['signin_time'];
          var jamKeluar = controller.detailRiwayat.value[index]['signout_time'];
          var tanggal = controller.detailRiwayat.value[index]['atten_date'];
          var longLatAbsenKeluar =
              controller.detailRiwayat.value[index]['signout_longlat'];

          var placeIn = controller.detailRiwayat.value[index]['place_in'];
          var placeOut = controller.detailRiwayat.value[index]['place_out'];
          var note = controller.detailRiwayat.value[index]['signin_note'];
          var signInLongLat =
              controller.detailRiwayat.value[index]['signin_longlat'];
          var signOutLongLat =
              controller.detailRiwayat.value[index]['signout_longlat'];
          var statusView = placeIn == "pengajuan" &&
                  placeOut == "pengajuan" &&
                  signInLongLat == "pengajuan" &&
                  signOutLongLat == "pengajuan"
              ? true
              : false;

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
                
                print(idAbsen);
                controller.historySelected(idAbsen, "laporan");
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                statusView == false
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 40,
                            child: Text(
                              "${Constanst.convertDate(tanggal)}",
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
                                    style: TextStyle(
                                        color: getColorMasuk, fontSize: 14),
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
                                    child: longLatAbsenKeluar == ""
                                        ? Text("")
                                        : Text(
                                            jamKeluar,
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
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
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
                            flex: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "$note",
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
        });
  }
}
