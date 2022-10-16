// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/constans.dart';

class BerhasilPengajuan extends StatelessWidget {
  final List? dataBerhasil;
  BerhasilPengajuan({Key? key, this.dataBerhasil}) : super(key: key);
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
                    Text("Berhasil",
                        textAlign: TextAlign.center,
                        style: Constanst.boldType1),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Text("${dataBerhasil![0]}",
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10.0),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Constanst.colorPrimary),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.white)))),
          onPressed: () {
            Get.offAll(InitScreen());
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text('Kembali ke beranda'),
          ),
        ),
      ),
    );
  }
}
