// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/setting_controller.dart';
import 'package:siscom_operasional/screen/akun/face_recognition_foto.dart';
import 'package:siscom_operasional/screen/akun/face_registration_verify_password.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class FaceRecognition extends StatelessWidget {
  final controller = Get.put(SettingController());

  final list = [
    {
      "icon": "0",
      "title": "Proses absensi yang lebih cepat",
      "subtitle":
          "Proses absensi dilakukan dengan lebih cepat sehingga dapat menghemat waktu."
    },
    {
      "icon": "1",
      "title": "Mencegah penyalahgunaan absensi",
      "subtitle":
          "Memastikan bahwa hanya orang yang terdaftar yang dapat melakukan absensi."
    },
    {
      "icon": "2",
      "title": "Hemat ruang penyimpanan",
      "subtitle":
          "Fitur ini melakukan scan untuk mengenali data wajah tersimpan, dan tidak ada  gambar yang disimpan dalam memori internal."
    },
  ];
  final AbsenController absenController = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constanst.coloBackgroundScreen,
        appBar: AppBar(
            backgroundColor: Constanst.colorWhite,
            automaticallyImplyLeading: false,
            elevation: 2,
            flexibleSpace: AppbarMenu1(
              title: "Data Wajah",
              colorTitle: Colors.black,
              colorIcon: Colors.black,
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
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(Get.context!).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(width: 1, color: HexColor('#D5DBE5'))),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        GetStorage().read('face_recog') == false
                            ? Container(
                                width: MediaQuery.of(context).size.width - 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1, color: HexColor('#868FA0'))),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    bottom: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/face-recognition-hitam.png",
                                        width: 40,
                                        height: 40,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Belum Registrasi",
                                        style: TextStyle(
                                            color: HexColor('#868FA0')),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width - 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1,
                                        color: Constanst.colorPrimary)),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    bottom: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/face-recognition-biru.png",
                                        width: 40,
                                        height: 40,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Sudah di registrasi",
                                            style: TextStyle(
                                                color: Constanst.colorBlack),
                                          ),
                                          // SizedBox(
                                          //   width: 5,
                                          // ),
                                          // Icon(
                                          //   Iconsax.tick_circle,
                                          //   color: HexColor(
                                          //     '#2F80ED',
                                          //   ),
                                          //   size: 20,
                                          // )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.to(FaceRecognitionPhotoPage());
                                        },
                                        child: Text(
                                          "Lihat Foto",
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Constanst.colorPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        GetStorage().read('face_recog') == false
                            ? InkWell(
                                onTap: () {
                                  absenController
                                      .widgetButtomSheetFaceRegistrattion();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Constanst.colorPrimary,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            width: 1,
                                          )),
                                      padding: EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width -
                                          90,
                                      child: Center(
                                        child: Text(
                                          "Registrasi Sekarang",
                                          style: TextStyle(
                                              color: Constanst.colorWhite),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  Get.to(FaceRegistrationVerifyPassword());
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 1,
                                              color: HexColor('FF463D'))),
                                      padding: EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width -
                                          90,
                                      child: Center(
                                        child: Text(
                                          "Hapus dan registrasi ulang data wajah",
                                          style: TextStyle(
                                              color: HexColor('FF463D')),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text("Untuk apa fitur ini?",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(width: 1, color: HexColor('#D5DBE5'))),
                    child: Column(
                      children: List.generate(list.length, (index) {
                        var data = list[index];
                        return Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 10,
                                child: Icon(data['icon'] == "0"
                                    ? Iconsax.flash
                                    : data['icon'] == "1"
                                        ? Iconsax.security_user
                                        : data['icon'] == "2"
                                            ? Iconsax.gallery_remove
                                            : Iconsax.security_user),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 70,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'].toString(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      data['subtitle'].toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: HexColor('#E9F5FE'),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1,
                          color: HexColor('#2F80ED'),
                        )),
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Icon(
                            Icons.info_outline,
                            color: HexColor('#2F80ED'),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          flex: 60,
                          child: Text(
                            "Data wajah ini akan digunakan setiap kali Kamu melakukan Absen Masuk dan Keluar.",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12, color: HexColor('#868FA0')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
