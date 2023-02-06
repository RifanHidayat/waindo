import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/model/absen_model.dart';
import 'package:siscom_operasional/screen/absen/history_absen.dart';
import 'package:siscom_operasional/screen/absen/photo_absent.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class DetailAbsen extends StatelessWidget {
  List<dynamic>? absenSelected;
  bool? status;
  String? fullName;
  DetailAbsen({
    Key? key,
    this.absenSelected,
    this.status,
    this.fullName,
  }) : super(key: key);
  final controller = Get.put(AbsenController());
  @override
  Widget build(BuildContext context) {
    var tanggal = status == false
        ? absenSelected![0].atten_date ?? ""
        : absenSelected![0]['atten_date'] ?? "";
    var longlatMasuk = status == false
        ? absenSelected![0].signin_longlat ?? ""
        : absenSelected![0]['signin_longlat'] ?? "";
    var longlatKeluar = status == false
        ? absenSelected![0].signout_longlat ?? ""
        : absenSelected![0]['signout_longlat'] ?? "";
    var getFullName =
        status == false ? "" : absenSelected![0]['full_name'] ?? "";
    var namaKaryawan = fullName != "" ? fullName : "$getFullName";

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
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "$namaKaryawan",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Constanst.colorPrimary),
                          ),
                        ))
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
                  longlatMasuk == "" ? SizedBox() : descMasuk(),
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

  // Widget descMasuk() {
  //   var jamMasuk = status == false
  //       ? absenSelected![0].signin_time ?? ""
  //       : absenSelected![0]['signin_time'] ?? "";
  //   var gambarMasuk = status == false
  //       ? absenSelected![0].signin_pict ?? ""
  //       : absenSelected![0]['signin_pict'] ?? "";
  //   var alamatMasuk = status == false
  //       ? absenSelected![0].signin_addr ?? ""
  //       : absenSelected![0]['signin_addr'] ?? "";
  //   var catatanMasuk = status == false
  //       ? absenSelected![0].signin_note ?? ""
  //       : absenSelected![0]['signin_note'] ?? "";
  //   var placeIn = status == false
  //       ? absenSelected![0].place_in ?? ""
  //       : absenSelected![0]['place_in'] ?? "";
  //   return Container(
  //     decoration: Constanst.styleBoxDecoration1,
  //     child: Padding(
  //       padding: EdgeInsets.only(left: 10, right: 10),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           SizedBox(
  //             height: 10,
  //           ),
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Expanded(
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Icon(
  //                       Iconsax.login,
  //                       color: Colors.green,
  //                       size: 24,
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.only(left: 8),
  //                       child: Text(
  //                         jamMasuk ?? '',
  //                         style: TextStyle(fontSize: 16),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                   child: Container(
  //                 decoration: Constanst.styleBoxDecoration2(
  //                     Color.fromARGB(156, 223, 253, 223)),
  //                 margin: EdgeInsets.only(left: 10, right: 10),
  //                 child: Padding(
  //                   padding: EdgeInsets.only(left: 10, right: 10),
  //                   child: Text(
  //                     "Absen Masuk",
  //                     textAlign: TextAlign.center,
  //                     style: Constanst.colorGreenBold,
  //                   ),
  //                 ),
  //               ))
  //             ],
  //           ),
  //           SizedBox(
  //             height: 16,
  //           ),
  //           Padding(
  //             padding: EdgeInsets.only(left: 18),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 gambarMasuk == ''
  //                     ? SizedBox()
  //                     : Row(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Expanded(
  //                               flex: 10,
  //                               child: Icon(
  //                                 Iconsax.gallery,
  //                                 size: 24,
  //                                 color: Constanst.colorPrimary,
  //                               )
  //                               // Image.asset("assets/ic_galery.png")
  //                               ),
  //                           Expanded(
  //                             flex: 90,
  //                             child: Padding(
  //                               padding: const EdgeInsets.only(top: 2, left: 3),
  //                               child: Text(gambarMasuk ?? ''),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                 gambarMasuk == ''
  //                     ? SizedBox()
  //                     : Row(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Expanded(flex: 10, child: SizedBox()),
  //                           Expanded(
  //                             flex: 90,
  //                             child: Padding(
  //                               padding: const EdgeInsets.only(top: 3, left: 3),
  //                               child: Row(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   InkWell(
  //                                     onTap: () {
  //                                       controller.stringImageSelected.value =
  //                                           "";
  //                                       controller.stringImageSelected.value =
  //                                           gambarMasuk ?? '';
  //                                       controller.showDetailImage();
  //                                     },
  //                                     child: Text(
  //                                       "Lihat Foto",
  //                                       style: TextStyle(
  //                                         color: Constanst.colorPrimary,
  //                                         decoration: TextDecoration.underline,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Padding(
  //                                       padding:
  //                                           EdgeInsets.only(left: 8, top: 3),
  //                                       child: Icon(
  //                                         Iconsax.export_3,
  //                                         size: 16,
  //                                         color: Constanst.color1,
  //                                       )
  //                                       // Image.asset("assets/ic_lihat_foto.png"),
  //                                       )
  //                                 ],
  //                               ),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Expanded(
  //                         flex: 10,
  //                         child: Icon(
  //                           Iconsax.location_tick,
  //                           size: 24,
  //                           color: Constanst.colorPrimary,
  //                         )
  //                         // Image.asset("assets/ic_location_black.png")
  //                         ),
  //                     Expanded(
  //                       flex: 90,
  //                       child: Padding(
  //                           padding: const EdgeInsets.only(top: 3, left: 3),
  //                           child: Text(
  //                             "${alamatMasuk ?? ''}  (${placeIn ?? ''})",
  //                           )),
  //                     )
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Expanded(
  //                         flex: 10,
  //                         child: Icon(
  //                           Iconsax.note_text,
  //                           size: 24,
  //                           color: Constanst.colorPrimary,
  //                         )
  //                         // Image.asset("assets/ic_note_black.png")
  //                         ),
  //                     Expanded(
  //                       flex: 90,
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(top: 3, left: 3),
  //                         child: Text(catatanMasuk ?? ''),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           SizedBox(
  //             height: 18,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
    var placeIn = status == false
        ? absenSelected![0].place_in ?? ""
        : absenSelected![0]['place_in'] ?? "";
    // var alamat = (alamatMasuk + placeIn).toString().substring(0, 50) + "...";
    return Container(
      decoration: Constanst.styleBoxDecoration1,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gambarMasuk != ''
                ? Expanded(
                    flex: 30,
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          Get.to(PhotoAbsen(
                            image: Api.UrlfotoAbsen + gambarMasuk,
                            type: "masuk",
                            time: jamMasuk,
                            alamat: alamatMasuk + placeIn,
                            note: catatanMasuk,
                          ));
                        },
                        child: gambarMasuk != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: SizedBox(
                                    width:
                                        MediaQuery.of(Get.context!).size.width /
                                            3,
                                    child: Image.network(
                                      Api.UrlfotoAbsen + gambarMasuk,
                                      errorBuilder:
                                          (context, exception, stackTrace) {
                                        return ClipRRect(
                                          child: SizedBox(
                                              child: Image.asset(
                                            'assets/Foto.png',
                                            fit: BoxFit.fill,
                                          )),
                                        );
                                      },
                                      fit: BoxFit.fill,
                                    )),
                              )
                            : ClipRRect(
                                child: SizedBox(
                                    width:
                                        MediaQuery.of(Get.context!).size.width /
                                            3,
                                    child: Image.asset(
                                      'assets/Foto.png',
                                    )),
                              ),
                      ),
                    ),
                  )
                : Expanded(
                    flex: 00,
                    child: Container(),
                  ),
            Expanded(
              flex: 70,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                  style: TextStyle(fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          Container(
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
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.location_tick,
                            size: 24,
                            color: Constanst.colorPrimary,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 3, left: 3),
                                  child: Text(
                                    "Lokasi",
                                  )),
                              Container(
                                width: gambarMasuk != ''
                                    ? MediaQuery.of(Get.context!).size.width / 2
                                    : MediaQuery.of(Get.context!).size.width -
                                        80,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.only(top: 3, left: 3),
                                    child: Text(
                                      "$alamatMasuk ( $placeIn )",
                                      style: TextStyle(fontSize: 10),
                                    )),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.note_text,
                            size: 24,
                            color: Constanst.colorPrimary,
                          ),
                          Container(
                            width: gambarMasuk != ''
                                ? MediaQuery.of(Get.context!).size.width / 2
                                : MediaQuery.of(Get.context!).size.width - 80,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3, left: 3),
                              child: Text(catatanMasuk ?? '-'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
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
    var placeOut = status == false
        ? absenSelected![0].place_out ?? ""
        : absenSelected![0]['place_out'] ?? "";
    // var alamat = (alamatKeluar + placeOut).toString().substring(0, 50) + "...";
    return Container(
      decoration: Constanst.styleBoxDecoration1,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gambarKeluar != ''
                ? Expanded(
                    flex: 30,
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          Get.to(PhotoAbsen(
                            image: Api.UrlfotoAbsen + gambarKeluar,
                            type: "keluar",
                            time: jamKeluar,
                            alamat: alamatKeluar + placeOut,
                            note: catatanKeluar,
                          ));
                        },
                        child: gambarKeluar != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: SizedBox(
                                    // width: MediaQuery.of(Get.context!).size.width / 3,
                                    child: Image.network(
                                  Api.UrlfotoAbsen + gambarKeluar,
                                  errorBuilder:
                                      (context, exception, stackTrace) {
                                    return ClipRRect(
                                      child: SizedBox(
                                          child: Image.asset(
                                        'assets/Foto.png',
                                        fit: BoxFit.fitHeight,
                                      )),
                                    );
                                  },
                                  fit: BoxFit.fitHeight,
                                )),
                              )
                            : ClipRRect(
                                child: SizedBox(
                                    // width: MediaQuery.of(Get.context!).size.width / 3,
                                    child: Image.asset(
                                  'assets/Foto.png',
                                )),
                              ),
                      ),
                    ),
                  )
                : Expanded(flex: 0, child: Container()),
            Expanded(
              flex: 70,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                  style: TextStyle(fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          Container(
                            decoration: Constanst.styleBoxDecoration2(
                                Color.fromARGB(156, 223, 253, 223)),
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                "Absen Keluar",
                                textAlign: TextAlign.center,
                                style: Constanst.colorRedBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.location_tick,
                            size: 24,
                            color: Constanst.colorPrimary,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 3, left: 3),
                                  child: Text(
                                    "Lokasi",
                                  )),
                              SizedBox(
                                width: gambarKeluar != ''
                                    ? MediaQuery.of(Get.context!).size.width / 2
                                    : MediaQuery.of(Get.context!).size.width -
                                        80,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.only(top: 3, left: 3),
                                    child: Text(
                                      "$alamatKeluar ( $placeOut )",
                                      style: TextStyle(fontSize: 10),
                                    )),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.note_text,
                            size: 24,
                            color: Constanst.colorPrimary,
                          ),
                          Container(
                            width: gambarKeluar != ''
                                ? MediaQuery.of(Get.context!).size.width / 2
                                : MediaQuery.of(Get.context!).size.width - 80,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3, left: 3),
                              child: Text(catatanKeluar ?? '-'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
    // return Container(
    //   decoration: Constanst.styleBoxDecoration1,
    //   child: Padding(
    //     padding: EdgeInsets.only(left: 10, right: 10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         SizedBox(
    //           height: 10,
    //         ),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Expanded(
    //               child: Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Icon(
    //                     Iconsax.logout,
    //                     color: Colors.red,
    //                     size: 24,
    //                   ),
    //                   Padding(
    //                     padding: EdgeInsets.only(left: 8),
    //                     child: Text(
    //                       jamKeluar ?? '',
    //                       style: TextStyle(fontSize: 16),
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //             Expanded(
    //                 child: Container(
    //               decoration: Constanst.styleBoxDecoration2(
    //                   Color.fromARGB(156, 241, 171, 171)),
    //               margin: EdgeInsets.only(left: 10, right: 10),
    //               child: Padding(
    //                 padding: EdgeInsets.only(left: 10, right: 10),
    //                 child: Text(
    //                   "Absen Keluar",
    //                   textAlign: TextAlign.center,
    //                   style: Constanst.colorRedBold,
    //                 ),
    //               ),
    //             ))
    //           ],
    //         ),
    //         SizedBox(
    //           height: 16,
    //         ),
    //         Padding(
    //           padding: EdgeInsets.only(left: 18),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               gambarKeluar == ''
    //                   ? SizedBox()
    //                   : Row(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Expanded(
    //                             flex: 10,
    //                             child: Icon(
    //                               Iconsax.gallery,
    //                               size: 24,
    //                               color: Constanst.colorPrimary,
    //                             )
    //                             // Image.asset("assets/ic_galery.png")
    //                             ),
    //                         Expanded(
    //                           flex: 90,
    //                           child: Padding(
    //                             padding: const EdgeInsets.only(top: 3, left: 3),
    //                             child: Text(gambarKeluar ?? ''),
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //               gambarKeluar == ''
    //                   ? SizedBox()
    //                   : Row(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Expanded(flex: 10, child: SizedBox()),
    //                         Expanded(
    //                           flex: 90,
    //                           child: Padding(
    //                             padding: const EdgeInsets.only(top: 3, left: 3),
    //                             child: Row(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 InkWell(
    //                                   onTap: () {
    //                                     controller.stringImageSelected.value =
    //                                         "";
    //                                     controller.stringImageSelected.value =
    //                                         gambarKeluar ?? '';
    //                                     controller.showDetailImage();
    //                                   },
    //                                   child: Text(
    //                                     "Lihat Foto",
    //                                     style: TextStyle(
    //                                       color: Constanst.colorPrimary,
    //                                       decoration: TextDecoration.underline,
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 Padding(
    //                                     padding:
    //                                         EdgeInsets.only(left: 8, top: 3),
    //                                     child: Icon(
    //                                       Iconsax.export_3,
    //                                       size: 16,
    //                                       color: Constanst.color1,
    //                                     )
    //                                     // Image.asset("assets/ic_lihat_foto.png"),
    //                                     )
    //                               ],
    //                             ),
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //               SizedBox(
    //                 height: 10,
    //               ),
    //               Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Expanded(
    //                       flex: 10,
    //                       child: Icon(
    //                         Iconsax.location_tick,
    //                         size: 24,
    //                         color: Constanst.colorPrimary,
    //                       )
    //                       // Image.asset("assets/ic_location_black.png")
    //                       ),
    //                   Expanded(
    //                     flex: 90,
    //                     child: Padding(
    //                       padding: const EdgeInsets.only(top: 3, left: 3),
    //                       child: Text(
    //                           "${alamatKeluar ?? ''}  (${placeOut ?? ''})"),
    //                     ),
    //                   )
    //                 ],
    //               ),
    //               SizedBox(
    //                 height: 10,
    //               ),
    //               Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Expanded(
    //                       flex: 10,
    //                       child: Icon(
    //                         Iconsax.note_text,
    //                         size: 24,
    //                         color: Constanst.colorPrimary,
    //                       )
    //                       // Image.asset("assets/ic_note_black.png")
    //                       ),
    //                   Expanded(
    //                     flex: 90,
    //                     child: Padding(
    //                       padding: const EdgeInsets.only(top: 3, left: 3),
    //                       child: Text(catatanKeluar ?? ''),
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //         SizedBox(
    //           height: 18,
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
