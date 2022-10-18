// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class AbsenMasukKeluar extends StatelessWidget {
  final controller = Get.put(AbsenController());
  final controllerDashboard = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Foto Absen",
            icon: 1,
            colorTitle: Colors.black,
            onTap: () {
              controller.removeAll();
              controllerDashboard.onInit();
              Get.offAll(InitScreen());
            },
          )),
      body: WillPopScope(
        onWillPop: () async {
          controller.removeAll();
          controllerDashboard.onInit();
          Get.offAll(InitScreen());
          return true;
        },
        child: Obx(
          () => SafeArea(
            child: controller.imageStatus.value == false
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/vector_camera.png"),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Aktifkan kamera untuk absen"),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40, right: 40),
                          child: TextButtonWidget(
                            title: "Foto",
                            onTap: () {
                              controller.ulangiFoto();
                            },
                            colorButton: Constanst.colorButton1,
                            colortext: Constanst.colorWhite,
                            border: BorderRadius.circular(15.0),
                          ),
                        )
                      ],
                    ),
                  )
                : screenAbsenMasuk(),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10.0),
        child: Obx(
          () => SizedBox(
            width: MediaQuery.of(Get.context!).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                controller.latUser.value == 0.0 ||
                        controller.langUser.value == 0.0 ||
                        controller.alamatUserFoto.value == ""
                    ? SizedBox()
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: BorderSide(
                                            color: Constanst.colorPrimary)))),
                            onPressed: () => controller.ulangiFoto(),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.refresh,
                                    color: Constanst.colorPrimary,
                                    size: 18,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      'Ulangi Foto',
                                      style: TextStyle(
                                          color: Constanst.colorPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Constanst.colorPrimary),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(color: Colors.white)))),
                      onPressed: () => controller.kirimDataAbsensi(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: Text('OK, Absen sekarang'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget screenAbsenMasuk() {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 135, 135, 135).withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      controller.imageStatus.value == false
                          ? SizedBox()
                          : Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 20),
                              child: Image.file(
                                controller.fotoUser.value,
                              ),
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      controller.latUser.value == 0.0 ||
                              controller.langUser.value == 0.0 ||
                              controller.alamatUserFoto.value == ""
                          ? SizedBox(
                              height: 50,
                              child: Center(
                                child: SizedBox(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3),
                                    width: 35,
                                    height: 35),
                              ),
                            )
                          : Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                            alignment: Alignment.topCenter,
                                            child: Icon(
                                              Iconsax.clock,
                                              size: 24,
                                              color: Constanst.colorPrimary,
                                            )),
                                      ),
                                      Expanded(
                                        flex: 90,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 8, top: 3),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      controller
                                                          .timeString.value,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Expanded(
                                                    child: controller.typeAbsen
                                                                .value ==
                                                            1
                                                        ? Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      156,
                                                                      223,
                                                                      253,
                                                                      223),
                                                              borderRadius:
                                                                  Constanst
                                                                      .borderStyle1,
                                                            ),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 8),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 10,
                                                                      right:
                                                                          10),
                                                              child: Text(
                                                                controller
                                                                    .titleAbsen
                                                                    .value,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Constanst
                                                                    .colorGreenBold,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      156,
                                                                      241,
                                                                      171,
                                                                      171),
                                                              borderRadius:
                                                                  Constanst
                                                                      .borderStyle1,
                                                            ),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 8),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 10,
                                                                      right:
                                                                          10),
                                                              child: Text(
                                                                controller
                                                                    .titleAbsen
                                                                    .value,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Constanst
                                                                    .colorRedBold,
                                                              ),
                                                            ),
                                                          ))
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                            alignment: Alignment.topCenter,
                                            child: Icon(
                                              Iconsax.calendar_2,
                                              size: 24,
                                              color: Constanst.colorPrimary,
                                            )
                                            // Image.asset(
                                            //     "assets/ic_calender.png"),
                                            ),
                                      ),
                                      Expanded(
                                        flex: 90,
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(left: 8, top: 3),
                                          child: Text(controller.dateNow.value,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                            alignment: Alignment.topCenter,
                                            child: Icon(
                                              Iconsax.location_tick,
                                              size: 24,
                                              color: Constanst.colorPrimary,
                                            )
                                            // Image.asset(
                                            //     "assets/ic_location.png"),
                                            ),
                                      ),
                                      Expanded(
                                          flex: 90,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 3),
                                            child: Text("Lokasi Absen",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 10, child: SizedBox()),
                                      Expanded(
                                        flex: 90,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    Constanst.borderStyle2,
                                                border: Border.all(
                                                    color:
                                                        Constanst.colorText1)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  top: 8,
                                                  bottom: 8),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  isDense: true,
                                                  items: controller
                                                      .placeCoordinateDropdown
                                                      .value
                                                      .map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value: controller
                                                      .selectedType.value,
                                                  onChanged: (selectedValue) {
                                                    controller.selectedType
                                                        .value = selectedValue!;
                                                  },
                                                  isExpanded: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                            alignment: Alignment.topCenter,
                                            child: Icon(
                                              Iconsax.map_1,
                                              size: 24,
                                              color: Constanst.colorPrimary,
                                            )
                                            // Image.asset("assets/ic_map.png"),
                                            ),
                                      ),
                                      Expanded(
                                        flex: 80,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 8, top: 3),
                                            child: Text(
                                              "Lokasi kamu saat ini",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: InkWell(
                                            onTap: () {
                                              controller.detailAlamat.value =
                                                  !controller
                                                      .detailAlamat.value;
                                            },
                                            child:
                                                !controller.detailAlamat.value
                                                    ? Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        size: 16,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .arrow_drop_down_outlined,
                                                        size: 20,
                                                      ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  !controller.detailAlamat.value
                                      ? SizedBox()
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                flex: 10, child: SizedBox()),
                                            Expanded(
                                              flex: 90,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  controller
                                                      .alamatUserFoto.value,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Constanst.colorText2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                            alignment: Alignment.topCenter,
                                            child: Icon(
                                              Iconsax.note_1,
                                              size: 24,
                                              color: Constanst.colorPrimary,
                                            )
                                            // Image.asset("assets/ic_note.png"),
                                            ),
                                      ),
                                      Expanded(
                                        flex: 90,
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(left: 8, top: 3),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Tambahkan catatan",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        Constanst.borderStyle2,
                                                    border: Border.all(
                                                        width: 1.0,
                                                        color: Color.fromARGB(
                                                            255,
                                                            211,
                                                            205,
                                                            205))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8),
                                                  child: TextField(
                                                    cursorColor: Colors.black,
                                                    controller: controller
                                                        .deskripsiAbsen,
                                                    maxLines: null,
                                                    maxLength: 225,
                                                    decoration: new InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            "Tambahkan Catatan"),
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        height: 2.0,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          )),
    );
  }
}
