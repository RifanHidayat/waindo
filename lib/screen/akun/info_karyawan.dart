// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/setting_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class InfoKaryawan extends StatelessWidget {
  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Constanst.colorPrimary,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Info Karyawan",
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
                    linePencarian(),
                    SizedBox(
                      height: 16,
                    ),
                    pencarianData(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${controller.namaDepartemenTerpilih.value}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("${controller.jumlahData.value} data di tampilkan"),
                    Flexible(
                      child: controller.statusLoadingSubmitLaporan.value
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Constanst.colorPrimary,
                              ),
                            )
                          : controller.infoEmployee.value.isEmpty
                              ? Center(
                                  child: Text(controller.loading.value),
                                )
                              : infoEmployeeList(),
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
          borderRadius: Constanst.borderStyle5,
          border: Border.all(color: Constanst.colorNonAktif)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(top: 7, left: 10),
              child: Icon(Iconsax.search_normal_1),
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
                      border: InputBorder.none, hintText: "Cari nama karyawan"),
                  style: TextStyle(
                      fontSize: 14.0, height: 1.0, color: Colors.black),
                  onChanged: (value) {
                    controller.pencarianNamaKaryawan(value);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget linePencarian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: formDepartemen(),
            ),
          ],
        )
      ],
    );
  }

  Widget formDepartemen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle5,
              border: Border.all(
                  width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
          child: InkWell(
            onTap: () {
              controller.showDataDepartemenAkses('semua');
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 80,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 5, bottom: 5),
                    child: Text(
                      controller.departemen.value.text,
                      style: TextStyle(
                          fontSize: 14.0, height: 2.0, color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  flex: 20,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () async {},
                      icon: Icon(
                        Iconsax.arrow_down_14,
                        size: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget infoEmployeeList() {
    return Obx(
      () => ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: controller.infoEmployee.value.length,
          itemBuilder: (context, index) {
            var full_name = controller.infoEmployee.value[index]['full_name'];
            var image = controller.infoEmployee.value[index]['em_image'];
            var title = controller.infoEmployee.value[index]['job_title'];
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
                    borderRadius: Constanst.borderStyle2,
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
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 15,
                              child: image == ""
                                  ? Image.asset(
                                      'assets/avatar_default.png',
                                      width: 50,
                                      height: 50,
                                    )
                                  : CircleAvatar(
                                      radius: 25, // Image radius
                                      child: ClipOval(
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                Api.UrlfotoProfile + "${image}",
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Container(
                                              alignment: Alignment.center,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/avatar_default.png',
                                              width: 50,
                                              height: 50,
                                            ),
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            Expanded(
                              flex: 85,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      "$full_name",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      "$title",
                                      style: TextStyle(
                                          color: Constanst.colorText2),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(
                          height: 5,
                          color: Constanst.colorText2,
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
