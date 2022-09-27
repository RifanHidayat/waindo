import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/tidak_masuk_kerja_controller.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
import 'package:siscom_operasional/screen/absen/form/form_tidakMasukKerja.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class TidakMasukKerja extends StatelessWidget {
  var controller = Get.put(TidakMasukKerjaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Tidak Hadir",
            icon: 1,
            colorTitle: Constanst.colorText3,
            colorIcon: Constanst.colorText3,
            onTap: () {
              controller.onClose();
              Get.offAll(InitScreen());
            },
          )),
      body: WillPopScope(
        onWillPop: () async {
          controller.onClose();
          Get.offAll(InitScreen());
          return true;
        },
        child: Obx(
          () => controller.bulanDanTahunNow.value == ''
              ? Center(
                  child: Text(controller.loadingString.value),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 12,
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 16,
                                ),
                                pickDate(),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              listTypeTidakMasuk(),
                              Divider(
                                height: 5,
                                color: Constanst.colorText2,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              listStatusAjuan(),
                              SizedBox(
                                height: 16,
                              ),
                              pencarianData(),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                "Riwayat Pengajuan Tidak Hadir",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Flexible(
                                  child: controller
                                          .listHistoryAjuan.value.isEmpty
                                      ? Center(
                                          child: Text("Tidak ada pengajuan"),
                                        )
                                      : listAjuanIzinTidakMasukKerja()),
                            ],
                          ))
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
          child: TextButtonWidget2(
              title: "Buat Pengajuan Tidak Hadir",
              onTap: () {
                Get.offAll(FormTidakMasukKerja(
                  dataForm: [[], false],
                ));
              },
              colorButton: Colors.blue,
              colortext: Constanst.colorWhite,
              border: BorderRadius.circular(20.0),
              icon: Icon(
                Iconsax.add,
                color: Constanst.colorWhite,
              ))),
    );
  }

  Widget pickDate() {
    return Container(
      decoration: Constanst.styleBoxDecoration1,
      child: InkWell(
        onTap: () {
          showMonthPicker(
            context: Get.context!,
            firstDate: DateTime(DateTime.now().year - 1, 5),
            lastDate: DateTime(DateTime.now().year + 1, 9),
            initialDate: DateTime.now(),
            locale: Locale("en"),
          ).then((date) {
            if (date != null) {
              print(date);
              var outputFormat1 = DateFormat('MM');
              var outputFormat2 = DateFormat('yyyy');
              var bulan = outputFormat1.format(date);
              var tahun = outputFormat2.format(date);
              controller.bulanSelectedSearchHistory.value = bulan;
              controller.tahunSelectedSearchHistory.value = tahun;
              controller.bulanDanTahunNow.value = "$bulan-$tahun";
              controller.loadDataAjuanTidakMasukKerja();
              this.controller.bulanSelectedSearchHistory.refresh();
              this.controller.tahunSelectedSearchHistory.refresh();
              this.controller.bulanDanTahunNow.refresh();
            }
          });
        },
        child: Padding(
          padding: EdgeInsets.only(top: 15, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Iconsax.calendar_2),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "${Constanst.convertDateBulanDanTahun(controller.bulanDanTahunNow.value)}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 24,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget listTypeTidakMasuk() {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width,
      height: 50,
      child: Center(
        child: ListView.builder(
            itemCount: controller.allTipe.value.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => controller.changeTypeSelected(
                    controller.allTipe.value[index]['type_id']),
                child: SizedBox(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 50, right: 50),
                      child: Text(
                        controller.allTipe.value[index]['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              controller.allTipe.value[index]['active'] == true
                                  ? Constanst.colorPrimary
                                  : Constanst.colorText2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget listStatusAjuan() {
    return SizedBox(
      height: 30,
      child: ListView.builder(
          itemCount: controller.dataTypeAjuan.value.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var namaType = controller.dataTypeAjuan[index]['nama'];
            var status = controller.dataTypeAjuan[index]['status'];
            return InkWell(
              highlightColor: Constanst.colorButton2,
              onTap: () => controller.changeTypeAjuan(
                  controller.dataTypeAjuan.value[index]['nama']),
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                  color: status == true
                      ? Constanst.colorButton2
                      : Constanst.colorNonAktif,
                  borderRadius: Constanst.borderStyle1,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      namaType == "Approve"
                          ? Icon(
                              Iconsax.tick_square,
                              size: 14,
                              color: status == true
                                  ? Constanst.colorPrimary
                                  : Constanst.colorText2,
                            )
                          : namaType == "Rejected"
                              ? Icon(
                                  Iconsax.close_square,
                                  size: 14,
                                  color: status == true
                                      ? Constanst.colorPrimary
                                      : Constanst.colorText2,
                                )
                              : namaType == "Pending"
                                  ? Icon(
                                      Iconsax.timer,
                                      size: 14,
                                      color: status == true
                                          ? Constanst.colorPrimary
                                          : Constanst.colorText2,
                                    )
                                  : SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: Text(
                          namaType,
                          style: TextStyle(
                              fontSize: 12,
                              color: status == true
                                  ? Constanst.colorPrimary
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

  Widget pencarianData() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: Constanst.borderStyle2,
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

  Widget listAjuanIzinTidakMasukKerja() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: controller.listHistoryAjuan.value.length,
        itemBuilder: (context, index) {
          var tanggalMasukAjuan =
              controller.listHistoryAjuan.value[index]['atten_date'];
          var namaTypeAjuan = controller.listHistoryAjuan.value[index]['name'];
          var tanggalAjuanDari =
              controller.listHistoryAjuan.value[index]['start_date'];
          var tanggalAjuanSampai =
              controller.listHistoryAjuan.value[index]['end_date'];
          var alasan = controller.listHistoryAjuan.value[index]['reason'];
          var alasanReject =
              controller.listHistoryAjuan.value[index]['alasan_reject'];
          var typeAjuan =
              controller.listHistoryAjuan.value[index]['leave_status'];
          var approve_by = controller.listHistoryAjuan.value[index]['apply_by'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text("${Constanst.convertDate("$tanggalMasukAjuan")}"),
              SizedBox(
                height: 8,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: Constanst.borderStyle1,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 170, 170, 170).withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, top: 8, bottom: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 70,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                namaTypeAjuan,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 30,
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: typeAjuan == 'Approve'
                                    ? Constanst.colorBGApprove
                                    : typeAjuan == 'Rejected'
                                        ? Constanst.colorBGRejected
                                        : typeAjuan == 'Pending'
                                            ? Constanst.colorBGPending
                                            : Colors.grey,
                                borderRadius: Constanst.borderStyle1,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 3, right: 3, top: 5, bottom: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    typeAjuan == 'Approve'
                                        ? Icon(
                                            Iconsax.tick_square,
                                            color: Constanst.color5,
                                            size: 14,
                                          )
                                        : typeAjuan == 'Rejected'
                                            ? Icon(
                                                Iconsax.close_square,
                                                color: Constanst.color4,
                                                size: 14,
                                              )
                                            : typeAjuan == 'Pending'
                                                ? Icon(
                                                    Iconsax.timer,
                                                    color: Constanst.color3,
                                                    size: 14,
                                                  )
                                                : SizedBox(),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: Text(
                                        '$typeAjuan',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: typeAjuan == 'Approve'
                                                ? Colors.green
                                                : typeAjuan == 'Rejected'
                                                    ? Colors.red
                                                    : typeAjuan == 'Pending'
                                                        ? Constanst.color3
                                                        : Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          "${Constanst.convertDate("$tanggalAjuanDari")}  --  ${Constanst.convertDate("$tanggalAjuanSampai")}"),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        alasan,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontSize: 12, color: Constanst.colorText2),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(height: 5, color: Constanst.colorText2),
                      SizedBox(
                        height: 5,
                      ),
                      typeAjuan == 'Rejected'
                          ? SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Alasan Reject",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    alasanReject,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Constanst.colorText2),
                                  )
                                ],
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: typeAjuan == "Approve"
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Iconsax.tick_circle,
                                              color: Colors.green,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 5, top: 3),
                                              child: Text(
                                                  "Approved by $approve_by"),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 5, top: 3),
                                              child: Text(""),
                                            )
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pending Approval",
                                              style: TextStyle(
                                                  color: Constanst.colorText2),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text("")
                                          ],
                                        ),
                                ),
                                typeAjuan == "Approve"
                                    ? SizedBox()
                                    : Expanded(
                                        child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    Constanst.borderStyle1,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  controller
                                                      .batalkanPengajuanTidakMasuk(
                                                          controller
                                                              .listHistoryAjuan
                                                              .value[index]);
                                                },
                                                child: Text(
                                                  "Batalkan",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )),
                                          Expanded(
                                              child: Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    Constanst.borderStyle1,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  Get.offAll(
                                                      FormTidakMasukKerja(
                                                    dataForm: [
                                                      controller
                                                          .listHistoryAjuan
                                                          .value[index],
                                                      true
                                                    ],
                                                  ));
                                                },
                                                child: Text(
                                                  "Edit",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )),
                                        ],
                                      )),
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
