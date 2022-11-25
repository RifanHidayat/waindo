import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/kontrol_controller.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';

class DetailKontrol extends StatefulWidget {
  String emId;
  DetailKontrol({Key? key, required this.emId}) : super(key: key);
  @override
  _DetailKontrolState createState() => _DetailKontrolState();
}

class _DetailKontrolState extends State<DetailKontrol> {
  var controller = Get.put(KontrolController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Constanst.colorPrimary,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Tracking",
            colorTitle: Colors.white,
            iconShow: false,
            icon: 2,
            onTap: () {
              Get.back();
            },
          )),
      body: WillPopScope(
        onWillPop: () async {
          Get.back();
          return true;
        },
        child: SafeArea(
          child: Obx(
            () => Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    IntrinsicHeight(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Iconsax.arrow_left),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 14),
                          child: Text(
                            "${controller.userTerpilih.value[0]['full_name'] ?? ''}  (${Constanst.convertDate('${controller.initialDate.value}')})",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )),
                    SizedBox(
                      height: 16,
                    ),
                    Flexible(
                      flex: 3,
                      child: controller.statusLoadingSubmitLaporan.value
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Constanst.colorPrimary,
                              ),
                            )
                          : controller.kontrolHistory.value.isEmpty
                              ? Center(
                                  child: Text("${controller.loading.value}"))
                              : listHistoryControl(),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget listHistoryControl() {
    return ListView.builder(
        physics: controller.kontrolHistory.value.length <= 15
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.kontrolHistory.value.length,
        itemBuilder: (context, index) {
          var time = controller.kontrolHistory.value[index]['time'];
          var alamat = controller.kontrolHistory.value[index]['address'];
          return InkWell(
            onTap: () {
              // Get.to(DetailKontrol(
              //   emId: emId,
              // ));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/dot.png',
                      width: 25,
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, top: 3),
                      child: Text(
                        "$time",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Constanst.colorText3),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "$alamat",
                  style: TextStyle(fontSize: 12, color: Constanst.colorText2),
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
              ],
            ),
          );
        });
  }
}
