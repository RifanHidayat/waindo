// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/constans.dart';

class BerhasilAbsensi extends StatelessWidget {
  final List? dataBerhasil;
  BerhasilAbsensi({Key? key, this.dataBerhasil}) : super(key: key);
  final controller = Get.put(AbsenController());
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
                      "assets/berhasil_absen.png",
                      width: 150,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Berhasil", style: Constanst.boldType1),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Kamu Berhasil melakukan"),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            dataBerhasil![0],
                            style: Constanst.boldType2,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text("Pada"),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    dataBerhasil![2] == 1
                        ? Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(156, 223, 253, 223),
                              borderRadius: Constanst.borderStyle1,
                            ),
                            margin: EdgeInsets.only(left: 8),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                dataBerhasil![1],
                                style: Constanst.colorGreenBold,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(156, 241, 171, 171),
                              borderRadius: Constanst.borderStyle1,
                            ),
                            margin: EdgeInsets.only(left: 8),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                dataBerhasil![1],
                                style: Constanst.colorRedBold,
                              ),
                            ),
                          )
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
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.white)))),
          onPressed: () {
            AbsenController().removeAll();
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
