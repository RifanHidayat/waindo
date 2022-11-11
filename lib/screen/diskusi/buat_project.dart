// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:siscom_operasional/controller/ruang_diskusi_controller.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class BuatProject extends StatefulWidget {
  @override
  _BuatProjectState createState() => _BuatProjectState();
}

class _BuatProjectState extends State<BuatProject> {
  final controller = Get.put(RuangDiskusiController());

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    controller.startData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Buat Project",
            colorTitle: Constanst.colorText3,
            colorIcon: Constanst.colorText3,
            icon: 1,
            onTap: () {
              Get.back();
            },
          )),
      body: WillPopScope(
        onWillPop: () async {
          Get.back();
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              judulProject(),
              SizedBox(
                height: 16,
              ),
              deskripsiProject(),
              SizedBox(
                height: 16,
              ),
              deadlineProject(),
              SizedBox(
                height: 16,
              ),
              anggotaTeam(),
            ],
          ),
        ),
      ),
    );
  }

  Widget judulProject() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Judul Project *",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              border: Border.all(
                  width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.judulProject.value,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              style:
                  TextStyle(fontSize: 14.0, height: 2.0, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget deskripsiProject() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Deskripsi Project *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle1,
              border: Border.all(
                  width: 1.0, color: Color.fromARGB(255, 211, 205, 205))),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextField(
              cursorColor: Colors.black,
              controller: controller.deskripsiProject.value,
              maxLines: null,
              maxLength: 225,
              decoration: new InputDecoration(
                  border: InputBorder.none, hintText: "Deskripsi"),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              style:
                  TextStyle(fontSize: 12.0, height: 2.0, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget deadlineProject() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dari Tanggal *",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: 40,
                  width: MediaQuery.of(Get.context!).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: Constanst.borderStyle1,
                      border: Border.all(
                          width: 0.5,
                          color: Color.fromARGB(255, 211, 205, 205))),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, top: 5),
                            child: Text(
                              controller.dariTanggal.value.text,
                              style: TextStyle(fontSize: 16),
                            ),
                          ))),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sampai Tanggal *",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: 40,
                  width: MediaQuery.of(Get.context!).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: Constanst.borderStyle1,
                      border: Border.all(
                          width: 0.5,
                          color: Color.fromARGB(255, 211, 205, 205))),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, top: 5),
                            child: Text(
                              controller.sampaiTanggal.value.text,
                              style: TextStyle(fontSize: 16),
                            ),
                          ))),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget anggotaTeam() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Tambah Anggota Team *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
               
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Iconsax.add_circle,
                    size: 40,
                    color: Constanst.colorPrimary,
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
