// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class Informasi extends StatelessWidget {
  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Constanst.colorPrimary,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Informasi",
            colorTitle: Colors.white,
            colorIcon: Colors.white,
            icon: 1,
            onTap: () {
              Get.offAll(InitScreen());
            },
          )),
      body: WillPopScope(
          onWillPop: () async {
            Get.offAll(InitScreen());
            return true;
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Flexible(
                    flex: 3,
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount:
                            controller.informasiDashboard.value.length > 4
                                ? 4
                                : controller.informasiDashboard.value.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(left: 8, right: 8, top: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 70,
                                      child: Text(
                                        controller.informasiDashboard
                                            .value[index]['title'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 30,
                                      child: Text(
                                        Constanst.convertDate(controller
                                            .informasiDashboard
                                            .value[index]['date']),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(controller.informasiDashboard.value[index]
                                    ['desc']),
                                SizedBox(
                                  height: 8,
                                ),
                                Divider(
                                  height: 5,
                                  color: Constanst.colorNonAktif,
                                ),
                                SizedBox(
                                  height: 8,
                                )
                              ],
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
