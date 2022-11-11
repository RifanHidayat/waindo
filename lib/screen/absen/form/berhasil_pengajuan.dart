// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/constans.dart';

class BerhasilPengajuan extends StatefulWidget {
  List dataBerhasil;
  BerhasilPengajuan({Key? key, required this.dataBerhasil}) : super(key: key);
  @override
  _BerhasilPengajuanState createState() => _BerhasilPengajuanState();
}

class _BerhasilPengajuanState extends State<BerhasilPengajuan> {
  var controllerGlobal = Get.put(GlobalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 240, 248),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SafeArea(
            child: Column(
          children: [
            Expanded(flex: 30, child: SizedBox()),
            Expanded(
                flex: 70,
                child: Column(
                  children: [
                    Image.asset(
                      "assets/berhasil_pengajuan.png",
                      width: 150,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("${widget.dataBerhasil[0]}",
                        textAlign: TextAlign.center,
                        style: Constanst.boldType1),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Text("${widget.dataBerhasil[1]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constanst.colorText2, fontSize: 14)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Text("${widget.dataBerhasil[2]}",
                          textAlign: TextAlign.center,
                          style: Constanst.boldType2),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ))
          ],
        )),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(Get.context!).size.width,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 8, right: 8),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Constanst.colorPrimary),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.white)))),
                onPressed: () {
                  Get.offAll(InitScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Text('Kembali ke beranda'),
                ),
              ),
            ),
          ),
          widget.dataBerhasil[3] == false
              ? SizedBox()
              : SizedBox(
                  width: MediaQuery.of(Get.context!).size.width,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 6.0, left: 8, right: 8),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(
                                          color: Constanst.colorPrimary)))),
                      onPressed: () {
                        controllerGlobal
                            .showDataPilihAtasan(widget.dataBerhasil[3]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: Text(
                          'Konfirmasi via WA',
                          style: TextStyle(color: Constanst.colorPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
