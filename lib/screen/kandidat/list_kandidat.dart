// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/kandidat_controller.dart';

import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/kandidat/detail_permintaan.dart';
import 'package:siscom_operasional/screen/kandidat/form_kandidat.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class Kandidat extends StatefulWidget {
  @override
  _KandidatState createState() => _KandidatState();
}

class _KandidatState extends State<Kandidat> {
  final controller = Get.put(KandidatController());

  @override
  void initState() {
    controller.startData();
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
              title: "Permintaan Kandidat",
              colorTitle: Constanst.colorText3,
              colorIcon: Constanst.colorText3,
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
          child: Obx(
            () => Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  pencarianData(),
                  SizedBox(
                    height: 16,
                  ),
                  typeStatus(),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Riwayat Permintaan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Flexible(
                      child: RefreshIndicator(
                    color: Constanst.colorPrimary,
                    onRefresh: refreshData,
                    child: controller.listPermintaanKandidat.value.isEmpty
                        ? Center(
                            child: Text(controller.loadingString.value),
                          )
                        : riwayatPermintaanKandidat(),
                  ))
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
            child: TextButtonWidget2(
                title: "Buat Permintaan Kandidat",
                onTap: () => Get.to(FormKandidat(
                      dataForm: [[], false],
                    )),
                colorButton: Constanst.colorPrimary,
                colortext: Constanst.colorWhite,
                border: BorderRadius.circular(20.0),
                icon: Icon(
                  Iconsax.add,
                  color: Constanst.colorWhite,
                ))));
  }

  Widget pencarianData() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 60,
          child: Container(
            margin: EdgeInsets.only(right: 3.0),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 80,
                            child: TextField(
                              controller: controller.cari.value,
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: "Cari"),
                              style: TextStyle(
                                  fontSize: 14.0,
                                  height: 1.0,
                                  color: Colors.black),
                              onChanged: (value) {
                                controller.cariData(value);
                              },
                            ),
                          ),
                          !controller.statusCari.value
                              ? SizedBox()
                              : Expanded(
                                  flex: 20,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: IconButton(
                                      icon: Icon(
                                        Iconsax.close_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        controller.statusCari.value = false;
                                        controller.cari.value.text = "";
                                        controller.startData();
                                      },
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
            flex: 40,
            child: InkWell(
              onTap: () {
                DatePicker.showPicker(
                  Get.context!,
                  pickerModel: CustomMonthPicker(
                    minTime: DateTime(2020, 1, 1),
                    maxTime: DateTime(2050, 1, 1),
                    currentTime: DateTime.now(),
                  ),
                  onConfirm: (time) {
                    if (time != null) {
                      print("$time");
                      var filter = DateFormat('yyyy-MM').format(time);
                      var array = filter.split('-');
                      var bulan = array[1];
                      var tahun = array[0];
                      controller.bulanSelectedSearchHistory.value = bulan;
                      controller.tahunSelectedSearchHistory.value = tahun;
                      controller.bulanDanTahunNow.value = "$bulan-$tahun";
                      this.controller.bulanSelectedSearchHistory.refresh();
                      this.controller.tahunSelectedSearchHistory.refresh();
                      this.controller.bulanDanTahunNow.refresh();
                      controller.loadPermintaanKandidat();
                    }
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: Constanst.borderStyle5,
                    border: Border.all(color: Constanst.colorNonAktif)),
                child: Padding(
                  padding: EdgeInsets.all(9.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 18,
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            "${Constanst.convertDateBulanDanTahun(controller.bulanDanTahunNow.value)}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget typeStatus() {
    return SizedBox(
      height: 30,
      child: ListView.builder(
          itemCount: controller.listTypeStatus.value.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var id = controller.listTypeStatus[index]['id'];
            var namaType = controller.listTypeStatus[index]['name'];
            var status = controller.listTypeStatus[index]['status'];
            return InkWell(
              highlightColor: Constanst.colorPrimary,
              onTap: () => controller.changeTypeStatus(id, namaType),
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                  color: status == true
                      ? Constanst.colorPrimary
                      : Constanst.colorNonAktif,
                  borderRadius: Constanst.borderStyle1,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          '$namaType',
                          style: TextStyle(
                              fontSize: 12,
                              color: status == true
                                  ? Colors.white
                                  : Constanst.colorText2,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget riwayatPermintaanKandidat() {
    return ListView.builder(
        physics: controller.listPermintaanKandidat.value.length <= 10
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.listPermintaanKandidat.value.length,
        itemBuilder: (context, index) {
          var id = controller.listPermintaanKandidat.value[index]['id'];
          var nomorAjuan =
              controller.listPermintaanKandidat.value[index]['nomor_ajuan'];
          var tanggalAjuan =
              controller.listPermintaanKandidat.value[index]['tgl_ajuan'];
          var posisi =
              controller.listPermintaanKandidat.value[index]['position'];
          var status = controller.listPermintaanKandidat.value[index]
              ['status_transaksi'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "${Constanst.convertDate('$tanggalAjuan')}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  controller.getDetail(id);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 6, right: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: Constanst.borderStyle1,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Color.fromARGB(255, 190, 190, 190).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$posisi",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                "$nomorAjuan",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Constanst.colorText2),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 30,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 80,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: status == 1
                                          ? Colors.blue
                                          : Colors.grey,
                                      borderRadius: Constanst.borderStyle1,
                                    ),
                                    child: Center(
                                      child: status == 1
                                          ? Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(
                                                "Aktif",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(
                                                "Tidak Aktif",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 20,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Constanst.colorText2,
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              )
            ],
          );
        });
  }
}
