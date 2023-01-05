import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/constans.dart';

class BerhasilRegistration extends StatelessWidget {
  const BerhasilRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/sukses-icon.png',
                  width: 100,
                  height: 100,
                ),
                Text(
                  'Berhasil Ditambahkan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'sekarang Kamu bisa melakukan absen masuk dan keluar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
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
                onPressed: () async {
                  // controller.removeAll();
                  // controllerDashboard.onInit();
                  Get.offAll(InitScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text('Selesai'),
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
