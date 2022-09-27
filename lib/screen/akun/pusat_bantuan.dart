// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/setting_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class PusatBantuan extends StatelessWidget {
  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation : 2,
          flexibleSpace: AppbarMenu1(
            title: "Pusat Bantuan",
            colorTitle: Colors.white,
            colorIcon: Colors.transparent,
            icon: 1,
            onTap: () {
              controller.cari.value.text = "";
              Get.back();
            },
          )),
      body: WillPopScope(
          onWillPop: () async {
            controller.cari.value.text = "";
            Get.back();
            return true;
          },
          child: SafeArea(
            child: Obx(
              () => Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    pencarianData(),
                    SizedBox(
                      height: 10,
                    ),
                    Flexible(
                      flex: 3,
                      child: pusatBantuanList(),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget pencarianData() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: Constanst.borderStyle1,
          border: Border.all(color: Constanst.colorNonAktif)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(top: 7, left: 10),
              child: Icon(Iconsax.search_normal),
            ),
          ),
          Expanded(
            flex: 85,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: controller.cari.value,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Cari"),
                  style: TextStyle(
                      fontSize: 14.0, height: 1.0, color: Colors.black),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pusatBantuanList() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: controller.listPusatBantuan.value.length,
        itemBuilder: (context, index) {
          var id = controller.listPusatBantuan.value[index]['idx'];
          var pertanyaan = controller.listPusatBantuan.value[index]['question'];
          var jawaban = controller.listPusatBantuan.value[index]['answered'];
          var status = controller.listPusatBantuan.value[index]['status'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: Constanst.borderStyle1,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 190, 190, 190).withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, top: 8, bottom: 8, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => controller.changeStatusPusatBantuan(id), 
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 90,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(
                                  pertanyaan,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 10,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: status == false
                                      ? Icon(
                                          Icons.arrow_forward_ios,
                                          size: 20,
                                        )
                                      : Icon(
                                          Iconsax.arrow_down_14,
                                          size: 24,
                                        ),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      status == false
                          ? SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  height: 5,
                                  color: Constanst.colorText2,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  jawaban,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Constanst.colorText2,
                                  ),
                                )
                              ],
                            )
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }
}
