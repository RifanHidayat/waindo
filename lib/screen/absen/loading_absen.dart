import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/scanner_widget.dart';
import 'package:siscom_operasional/screen/absen/absen_masuk_keluar.dart';
import 'package:siscom_operasional/screen/absen/absen_verify_password.dart';
import 'package:siscom_operasional/screen/absen/facee_id_detection.dart';
import 'package:siscom_operasional/utils/constans.dart';

class LoadingAbsen extends StatefulWidget {
  final file, status, statusAbsen;
  LoadingAbsen({super.key, this.file, this.status, this.statusAbsen});

  @override
  State<LoadingAbsen> createState() => _LoadingAbsenState();
}

class _LoadingAbsenState extends State<LoadingAbsen>
    with SingleTickerProviderStateMixin {
  final abseController = Get.put(AbsenController());

  AnimationController? _animationController;
  bool _animationStopped = false;
  String scanText = "Scan";
  bool scanning = false;

  @override
  void initState() {
    _animationController = new AnimationController(
        duration: new Duration(seconds: 1), vsync: this);

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animateScanAnimation(true);
      } else if (status == AnimationStatus.dismissed) {
        animateScanAnimation(false);
      }
    });
    if (!scanning) {
      animateScanAnimation(false);
      setState(() {
        _animationStopped = false;
        scanning = true;
        scanText = "Stop";
      });
    } else {
      setState(() {
        _animationStopped = true;
        scanning = false;
        scanText = "Scan";
      });
    }
    // TODO: implement initState
    super.initState();
    abseController.absenSuccess.value = "";
    if (widget.status == "registration") {
      Get.back();
      abseController.facedDetection(
          status: "registration",
          absenStatus:
              widget.statusAbsen == 'masuk' ? "Absen Masuk" : "Absen Keluar",
          img: widget.file,
          type: "1");
    } else {
      abseController.facedDetection(
          status: "detection",
          absenStatus:
              widget.statusAbsen == 'masuk' ? "Absen Masuk" : "Absen Keluar",
          img: widget.file,
          type: "1");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.colorBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Constanst.colorBlack,
        title: Text(""),
        leading: InkWell(
          child: Icon(Icons.arrow_back),
          onTap: () => Get.back(),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Obx(() {
              return abseController.absenSuccess.value == ""
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Sedang Memindai wajah \n tunggu sebentar",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Constanst.colorWhite,
                        ),
                      ),
                    )
                  : abseController.absenSuccess.value == "1"
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.tick_circle,
                                  color: HexColor('#2F80ED')),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Berhasil memindai Wajah",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: HexColor('#2F80ED'),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.info_circle,
                                  color: HexColor('#FF463D')),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Gagal memindai wajah",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: HexColor('#FF463D'),
                                ),
                              ),
                            ],
                          ),
                        );
            }),
            Positioned(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 400,
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(56),
                  //   image: DecorationImage(
                  //     image: AssetImage('assets/face_id.png'),
                  //     fit: BoxFit.fill,
                  //   ),
                  // ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(56),
                    image: DecorationImage(
                      image: FileImage(File(widget.file)),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Container(
                    height: 400,
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(56),
                    //   image: DecorationImage(
                    //     image: FileImage(File(widget.file)),
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(56),
                      image: DecorationImage(
                        image: AssetImage('assets/face_id.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(child: Obx(() {
                          return abseController.absenSuccess.value == ""
                              ? Container(
                                  width: 275,
                                )
                              : abseController.absenSuccess.value == "1"
                                  ? succesAbsen()
                                  : failedAbsen();
                        })),
                        Obx(() {
                          return abseController.absenSuccess == ""
                              ? ImageScannerAnimation(
                                  _animationStopped,
                                  334,
                                  animation: _animationController!,
                                )
                              : Container(
                                  width: 275,
                                );
                        })
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 20,
                child: Align(
                    alignment: Alignment.center,
                    child: Obx(() {
                      return abseController.absenSuccess.value == ""
                          ? Container()
                          : abseController.absenSuccess.value == "1"
                              ? InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      Get.context!,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AbsenMasukKeluar(
                                                status: widget.statusAbsen ==
                                                        'masuk'
                                                    ? "Absen Masuk"
                                                    : "Absen Keluar",
                                              )),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            width: 1,
                                            color: Constanst.colorWhite)),
                                    child: Center(
                                      child: Text(
                                        "Lanjutkan",
                                        style: TextStyle(
                                            color: Constanst.colorWhite,
                                            fontSize: 14.0),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width - 40,
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          width: 1,
                                          color: Constanst.colorWhite)),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        if (abseController.gagalAbsen.value >=
                                            3) {
                                          Get.off(AbsenVrifyPassword(
                                            status: widget.statusAbsen,
                                            type: "",
                                          ));
                                        } else {
                                          Get.off(FaceDetectorView(
                                            status: widget.statusAbsen,
                                          ));
                                          // cont

                                        }
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Iconsax.refresh,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Coba Lagi",
                                            style: TextStyle(
                                                color: Constanst.colorWhite,
                                                fontSize: 14.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                    })))
          ],
        ),
      ),
    );
  }

  Widget succesAbsen() {
    return Container(
      width: 275,
      child: Container(
          child: Center(
            child: Container(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Constanst.colorWhite,
                child: Icon(
                  Icons.check,
                  size: 70,
                  color: HexColor('#0E3389'),
                ),
              ),
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(56),
              color: HexColor('#2F80ED').withOpacity(0.5))),
    );
  }

  Widget failedAbsen() {
    return Container(
      width: 275,
      child: Container(
          child: Center(
            child: Container(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Constanst.colorWhite,
                child: Icon(
                  Icons.close,
                  size: 70,
                  color: HexColor('#FF463D'),
                ),
              ),
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(56),
              color: HexColor('#FF463D').withOpacity(0.5))),
    );
  }

  void animateScanAnimation(bool reverse) {
    if (reverse) {
      _animationController!.reverse(from: 1.0);
    } else {
      _animationController!.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }
}
