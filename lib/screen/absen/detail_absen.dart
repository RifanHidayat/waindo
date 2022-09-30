import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/model/absen_model.dart';
import 'package:siscom_operasional/screen/absen/history_absen.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class DetailAbsen extends StatelessWidget {
  List<dynamic>? absenSelected;
  bool? status;
  DetailAbsen({
    Key? key,
    this.absenSelected,
    this.status,
  }) : super(key: key);
  final controller = Get.put(AbsenController());
  @override
  Widget build(BuildContext context) {
    var tanggal = status == false
        ? absenSelected![0].atten_date ?? ""
        : absenSelected![0]['atten_date'] ?? "";
    var longlatKeluar = status == false
        ? absenSelected![0].signout_longlat ?? ""
        : absenSelected![0]['signout_longlat'] ?? "";
    var getFullName =
        status == false ? "" : absenSelected![0]['full_name'] ?? "";
    var namaKaryawan = status == false ? "" : "$getFullName";

    return Scaffold(
        backgroundColor: Constanst.coloBackgroundScreen,
        appBar: AppBar(
            backgroundColor: Constanst.coloBackgroundScreen,
            automaticallyImplyLeading: false,
            elevation: 2,
            flexibleSpace: AppbarMenu1(
              title: "Detail Absen",
              icon: 1,
              colorTitle: Colors.black,
              onTap: () {
                Get.back();
              },
            )),
        body: WillPopScope(
          onWillPop: () async {
            Get.back();
            return true;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  status == true
                      ? Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Constanst.colorButton2,
                            borderRadius: Constanst.borderStyle3,
                          ),
                          child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                            namaKaryawan,
                            style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Constanst.colorText1),
                          ),
                              )),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    Constanst.convertDate("$tanggal"),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  descMasuk(),
                  SizedBox(
                    height: 20,
                  ),
                  longlatKeluar == "" ? SizedBox() : descKeluar(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget descMasuk() {
    var jamMasuk = status == false
        ? absenSelected![0].signin_time ?? ""
        : absenSelected![0]['signin_time'] ?? "";
    var gambarMasuk = status == false
        ? absenSelected![0].signin_pict ?? ""
        : absenSelected![0]['signin_pict'] ?? "";
    var alamatMasuk = status == false
        ? absenSelected![0].signin_addr ?? ""
        : absenSelected![0]['signin_addr'] ?? "";
    var catatanMasuk = status == false
        ? absenSelected![0].signin_note ?? ""
        : absenSelected![0]['signin_note'] ?? "";
    return Container(
      decoration: Constanst.styleBoxDecoration1,
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.login,
                        color: Colors.green,
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          jamMasuk ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  decoration: Constanst.styleBoxDecoration2(
                      Color.fromARGB(156, 223, 253, 223)),
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "Absen Masuk",
                      textAlign: TextAlign.center,
                      style: Constanst.colorGreenBold,
                    ),
                  ),
                ))
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.only(left: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  gambarMasuk == ''
                      ? SizedBox()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 10,
                                child: Image.asset("assets/ic_galery.png")),
                            Expanded(
                              flex: 90,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Text(gambarMasuk ?? ''),
                              ),
                            )
                          ],
                        ),
                  gambarMasuk == ''
                      ? SizedBox()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 10, child: SizedBox()),
                            Expanded(
                              flex: 90,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.stringImageSelected.value = "";
                                      controller.stringImageSelected.value =
                                          gambarMasuk ?? '';
                                      controller.showDetailImage();
                                    },
                                    child: Text(
                                      "Lihat Foto",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8, top: 3),
                                    child:
                                        Image.asset("assets/ic_lihat_foto.png"),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 10,
                          child: Image.asset("assets/ic_location_black.png")),
                      Expanded(
                        flex: 90,
                        child: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(
                              alamatMasuk ?? '',
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 10,
                          child: Image.asset("assets/ic_note_black.png")),
                      Expanded(
                        flex: 90,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(catatanMasuk ?? ''),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget descKeluar() {
    var jamKeluar = status == false
        ? absenSelected![0].signout_time
        : absenSelected![0]['signout_time'];
    var gambarKeluar = status == false
        ? absenSelected![0].signout_pict
        : absenSelected![0]['signout_pict'];
    var alamatKeluar = status == false
        ? absenSelected![0].signout_addr
        : absenSelected![0]['signout_addr'];
    var catatanKeluar = status == false
        ? absenSelected![0].signout_note
        : absenSelected![0]['signout_note'];
    return Container(
      decoration: Constanst.styleBoxDecoration1,
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.logout,
                        color: Colors.red,
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          jamKeluar ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  decoration: Constanst.styleBoxDecoration2(
                      Color.fromARGB(156, 241, 171, 171)),
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "Absen Keluar",
                      textAlign: TextAlign.center,
                      style: Constanst.colorRedBold,
                    ),
                  ),
                ))
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.only(left: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  gambarKeluar == ''
                      ? SizedBox()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 10,
                                child: Image.asset("assets/ic_galery.png")),
                            Expanded(
                              flex: 90,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Text(gambarKeluar ?? ''),
                              ),
                            )
                          ],
                        ),
                  gambarKeluar == ''
                      ? SizedBox()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 10, child: SizedBox()),
                            Expanded(
                              flex: 90,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.stringImageSelected.value = "";
                                      controller.stringImageSelected.value =
                                          gambarKeluar ?? '';
                                      controller.showDetailImage();
                                    },
                                    child: Text(
                                      "Lihat Foto",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8, top: 3),
                                    child:
                                        Image.asset("assets/ic_lihat_foto.png"),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 10,
                          child: Image.asset("assets/ic_location_black.png")),
                      Expanded(
                        flex: 90,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(alamatKeluar ?? ''),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 10,
                          child: Image.asset("assets/ic_note_black.png")),
                      Expanded(
                        flex: 90,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(catatanKeluar ?? ''),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
