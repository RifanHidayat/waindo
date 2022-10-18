import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siscom_operasional/controller/auth_controller.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/kontrol_controller.dart';
import 'package:siscom_operasional/screen/kontrol/detail_kontrol.dart';
import 'package:siscom_operasional/screen/register.dart';
import 'package:siscom_operasional/services/local_notification_service.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class KontrolList extends StatefulWidget {
  var dataForm;
  KontrolList({Key? key, this.dataForm}) : super(key: key);
  @override
  _KontrolListState createState() => _KontrolListState();
}

class _KontrolListState extends State<KontrolList> {
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
            title: "Kontrol",
            colorTitle: Colors.white,
            iconShow: false,
            icon: 2,
            onTap: () {},
          )),
      body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: SafeArea(
            child: Obx(
              () => Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: !controller.showViewKontrol.value
                    ? Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/noakses.png",
                              height: 250,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Kamu tidak punya akses ke menu ini.")
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          linePencarian(),
                          SizedBox(
                            height: 8,
                          ),
                          pencarianData(),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            controller.departemen.value.text,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${controller.jumlahData.value} Karyawan",
                            style: TextStyle(
                                fontSize: 12, color: Constanst.colorText2),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          // ElevatedButton(
                          //   onPressed: () async {
                          //     _stopForegroundTask();
                          //     Location location = new Location();
                          //     location.enableBackgroundMode(enable: false);
                          //   },
                          //   child: const Text('berhenti'),
                          // ),
                          Flexible(
                            flex: 3,
                            child: controller.statusLoadingSubmitLaporan.value
                                ? Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Constanst.colorPrimary,
                                    ),
                                  )
                                : controller.employeeKontrol.value.isEmpty
                                    ? Center(
                                        child: Text(controller.loading.value))
                                    : listEmployeeControl(),
                          )
                        ],
                      ),
              ),
            ),
          )),
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
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: formHariDanTanggal(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: formDepartemen(),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget formHariDanTanggal() {
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 80,
                child: InkWell(
                  onTap: () async {
                    var dateSelect = await showDatePicker(
                      context: Get.context!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: controller.initialDate.value,
                    );
                    if (dateSelect == null) {
                      UtilsAlert.showToast("Tanggal tidak terpilih");
                    } else {
                      controller.initialDate.value = dateSelect;
                      controller.tanggalPilihKontrol.value.text =
                          Constanst.convertDate("$dateSelect");
                      this.controller.tanggalPilihKontrol.refresh();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 3, bottom: 5),
                    child: Text(
                      controller.tanggalPilihKontrol.value.text,
                      style: TextStyle(
                          fontSize: 14.0, height: 2.0, color: Colors.black),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 20,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 80,
                child: InkWell(
                  onTap: () async {
                    controller.showDataDepartemenAkses('semua');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 3, bottom: 5),
                    child: Text(
                      controller.departemen.value.text,
                      style: TextStyle(
                          fontSize: 14.0, height: 2.0, color: Colors.black),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 20,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () async {
                      controller.showDataDepartemenAkses('semua');
                    },
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
      ],
    );
  }

  Widget pencarianData() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: Constanst.borderStyle5,
          border: Border.all(color: Color.fromARGB(255, 211, 205, 205))),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 85,
                      child: TextField(
                        controller: controller.cari.value,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Cari Nama Karyawan"),
                        style: TextStyle(
                            fontSize: 14.0, height: 1.0, color: Colors.black),
                        onChanged: (value) {
                          // controller.pencarianNamaKaryawan(value);
                        },
                      ),
                    ),
                    !controller.statusCari.value
                        ? SizedBox()
                        : Expanded(
                            flex: 15,
                            child: IconButton(
                              icon: Icon(
                                Iconsax.close_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                controller.statusCari.value = false;
                                controller.cari.value.text = "";

                                controller.getDepartemen(1, "");
                              },
                            ),
                          )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget listEmployeeControl() {
    return ListView.builder(
        physics: controller.employeeKontrol.value.length <= 15
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.employeeKontrol.value.length,
        itemBuilder: (context, index) {
          var fullName =
              controller.employeeKontrol.value[index]['full_name'] ?? "";
          var namaKaryawan = "$fullName";
          var jobTitle = controller.employeeKontrol.value[index]['job_title'];
          var emId = controller.employeeKontrol.value[index]['em_id'];
          return InkWell(
            onTap: () {
              UtilsAlert.loadingSimpanData(context, "Sedang Memuat");
              controller.getEmployeeTerpilih(emId);
              controller.getHistoryControl(emId);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaKaryawan,
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              jobTitle,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
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
