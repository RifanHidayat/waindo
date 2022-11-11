// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/kandidat_controller.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/dashed_rect.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class DetailPermintaan extends StatelessWidget {
  final controller = Get.put(KandidatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Detail Permintaan",
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
          child: SafeArea(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  lineTitle(),
                  SizedBox(
                    height: 20,
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: pageViewDetail(),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget lineTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              controller.selectedInformasiView.value = 0;
              controller.DetailController.jumpToPage(0);
              this.controller.selectedInformasiView.refresh();
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: controller.selectedInformasiView.value == 0
                        ? Constanst.colorPrimary
                        : Constanst.color6,
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Detail",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: controller.selectedInformasiView.value == 0
                          ? Constanst.colorPrimary
                          : Constanst.colorText2,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              controller.selectedInformasiView.value = 1;
              controller.DetailController.jumpToPage(1);
              this.controller.selectedInformasiView.refresh();
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: controller.selectedInformasiView.value == 1
                        ? Constanst.colorPrimary
                        : Constanst.color6,
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Upload",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: controller.selectedInformasiView.value == 1
                          ? Constanst.colorPrimary
                          : Constanst.colorText2,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              controller.selectedInformasiView.value = 2;
              controller.DetailController.jumpToPage(2);
              this.controller.selectedInformasiView.refresh();
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: controller.selectedInformasiView.value == 2
                        ? Constanst.colorPrimary
                        : Constanst.color6,
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Kandidat",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: controller.selectedInformasiView.value == 2
                          ? Constanst.colorPrimary
                          : Constanst.colorText2,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget pageViewDetail() {
    return PageView.builder(
        physics: BouncingScrollPhysics(),
        controller: controller.DetailController,
        onPageChanged: (index) {
          controller.selectedInformasiView.value = index;
          this.controller.selectedInformasiView.refresh();
        },
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.all(0),
              child: index == 0
                  ? screenDetail()
                  : index == 1
                      ? screenUpload()
                      : index == 2
                          ? screenKandidat()
                          : SizedBox());
        });
  }

  Widget screenDetail() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "${controller.detailPermintaan[0]['position']}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            "Spesifikasi",
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            height: 5,
          ),
          Html(
            data: controller.detailPermintaan[0]['requirements'],
            style: {
              "body": Style(
                fontSize: FontSize(12),
                color: Constanst.colorText2,
              ),
            },
          ),
          SizedBox(
            height: 8,
          ),
          Divider(
            height: 5,
            color: Constanst.colorNonAktif,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Keterangan",
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "${controller.detailPermintaan[0]['remark']}",
            style: TextStyle(color: Constanst.colorText2),
          ),
          SizedBox(
            height: 8,
          ),
          Divider(
            height: 5,
            color: Constanst.colorNonAktif,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Tujuan permintaan",
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "${controller.detailPermintaan[0]['purpose']}",
            style: TextStyle(color: Constanst.colorText2),
          ),
          SizedBox(
            height: 8,
          ),
          Divider(
            height: 5,
            color: Constanst.colorNonAktif,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Dibutuhkan",
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "${controller.detailPermintaan[0]['emp_needs']} Orang",
            style: TextStyle(color: Constanst.colorText2),
          ),
          SizedBox(
            height: 8,
          ),
          Divider(
            height: 5,
            color: Constanst.colorNonAktif,
          ),
          SizedBox(
            height: 8,
          ),
          controller.detailPermintaan[0]['nama_file'] == ""
              ? SizedBox()
              : fileWidget()
        ],
      ),
    );
  }

  Widget fileWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "File",
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () => controller.viewLampiranPermintaan(
              controller.detailPermintaan[0]['nama_file']),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Iconsax.export_2,
                size: 18,
                color: Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  "${controller.detailPermintaan[0]['nama_file']}",
                  style: TextStyle(
                    color: Colors.blue,
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
          height: 5,
          color: Constanst.colorNonAktif,
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget screenUpload() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          namaKandidat(),
          SizedBox(
            height: 16,
          ),
          formUnggahFile(),
          SizedBox(
            height: 16,
          ),
          keterangan(),
          SizedBox(
            height: 16,
          ),
          TextButtonWidget(
            title: "Upload kandidat baru",
            onTap: () {
              if (controller.nama_calon_kandidat.value.text == "" ||
                  controller.namaFileUpload.value == "") {
                UtilsAlert.showToast("Lengkapi nama dan file di atas");
              } else {
                controller.validasiSebelumAksi(
                    "Upload Kandidat",
                    "Yakin upload informasi kandidat ini ?",
                    "",
                    "upload_kandidat",
                    false,
                    "");
              }
            },
            colorButton: Constanst.colorPrimary,
            colortext: Constanst.colorWhite,
            border: BorderRadius.circular(20.0),
          ),
          SizedBox(
            height: 18,
          ),
          Divider(
            height: 5,
            color: Constanst.colorText2,
          ),
          SizedBox(
            height: 18,
          ),
          Text(
            "Seluruh Kandidat",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Constanst.colorPrimary),
          ),
          SizedBox(
            height: 8,
          ),
          Flexible(
              child: controller.listKandidatProsesAll.value.isEmpty
                  ? Center(
                      child: Text("Belum ada kandidat"),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: controller.listKandidatProsesAll.value.length,
                      itemBuilder: (context, index) {
                        var namaKandidat = controller.listKandidatProsesAll
                            .value[index]['candidate_name'];
                        var statusKandidat = controller
                            .listKandidatProsesAll.value[index]['status'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "$namaKandidat",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Constanst.colorPrimary,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "$statusKandidat",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Constanst.colorText2,
                                          fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Divider(
                              height: 5,
                              color: Constanst.colorText2,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        );
                      }))
        ],
      ),
    );
  }

  Widget namaKandidat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nama Kandidat *",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle1,
              border: Border.all(
                  width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.nama_calon_kandidat.value,
              cursorColor: Colors.black,
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

  Widget formUnggahFile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Unggah File *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 16,
        ),
        DashedRect(
          gap: 8,
          strokeWidth: 2,
          color: Constanst.colorNonAktif,
          child: Container(
            decoration: BoxDecoration(borderRadius: Constanst.borderStyle5),
            height: 60,
            width: MediaQuery.of(Get.context!).size.width,
            child: controller.namaFileUpload.value == ""
                ? InkWell(
                    onTap: () {
                      controller.takeFile();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.add_square,
                          size: 20,
                          color: Constanst.colorNonAktif,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text(
                            "Unggah file disini (Max 5MB)",
                            style: TextStyle(color: Constanst.colorNonAktif),
                          ),
                        )
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () {
                      controller.takeFile();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 90,
                          child: Text(
                            "${controller.namaFileUpload.value}",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: IconButton(
                            icon: Icon(
                              Iconsax.close_circle,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              controller.namaFileUpload.value = "";
                              controller.filePengajuan.value = File("");
                              controller.uploadFile.value = false;
                              this.controller.namaFileUpload.refresh();
                              this.controller.filePengajuan.refresh();
                              this.controller.uploadFile.refresh();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget keterangan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Keterangan",
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
              controller: controller.keterangan.value,
              maxLines: null,
              maxLength: 225,
              decoration:
                  new InputDecoration(border: InputBorder.none, hintText: ""),
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

  Widget screenKandidat() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          lineProses(),
          SizedBox(
            height: 16,
          ),
          Flexible(
            flex: 3,
            child: Obx(() => controller.listKandidatProses.value.isEmpty
                ? Center(
                    child: Text("${controller.loadingString.value}"),
                  )
                : controller.loadingUpdateData.value == true
                    ? Center(
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : riwayatKandidat()),
          )
        ],
      ),
    );
  }

  Widget lineProses() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: controller.listProsesKandidat.value.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var id = controller.listProsesKandidat.value[index]['id'];
            var name = controller.listProsesKandidat.value[index]['name'];
            var status = controller.listProsesKandidat.value[index]['status'];

            return InkWell(
                onTap: () {
                  controller.changeProsesRekrut(name);
                },
                child: SizedBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            color: status == false
                                ? Color(0xffD5DBE5)
                                : Constanst.colorPrimary,
                            borderRadius: BorderRadius.circular(100)),
                        child: Center(
                            child: Text(
                          "$id",
                          style: TextStyle(
                              color:
                                  status == false ? Colors.grey : Colors.white),
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 8.0, top: 3),
                        child: Text(
                          "$name",
                          style: TextStyle(
                            color: status == false
                                ? Constanst.colorText2
                                : Constanst.colorPrimary,
                          ),
                        ),
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(left: 5.0, top: 3, right: 20.0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: status == false
                                ? Constanst.colorText2
                                : Constanst.colorPrimary,
                            size: 16,
                          ))
                    ],
                  ),
                ));
          }),
    );
  }

  Widget riwayatKandidat() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: controller.listKandidatProses.value.length,
        itemBuilder: (context, index) {
          var id = controller.listKandidatProses.value[index]['id'];
          var namaKandidat =
              controller.listKandidatProses.value[index]['candidate_name'];
          var fileKandidat =
              controller.listKandidatProses.value[index]['nama_file'];
          var statusKandidat =
              controller.listKandidatProses.value[index]['status'];
          var statusAkhirKandidat =
              controller.listKandidatProses.value[index]['status_akhir'];
          var urlPendukung = controller.listKandidatProses.value[index]['url'];
          var statusRemaks =
              controller.listKandidatProses.value[index]['status_remaks'];
          var alasanTerima =
              controller.listKandidatProses.value[index]['alasan_terima'];
          var alasanTolak =
              controller.listKandidatProses.value[index]['alasan_tolak'];
          // tanggal
          var tampungDateInterview1 =
              controller.listKandidatProses.value[index]['interview1_date'];
          var tampungDateInterview2 =
              controller.listKandidatProses.value[index]['interview2_date'];

          // convert
          var interview1Date;
          if (tampungDateInterview1 == "" ||
              tampungDateInterview1 == null ||
              tampungDateInterview1 == '0000-00-00') {
          } else {
            var convert = tampungDateInterview1.split(',');
            interview1Date = convert.last;
          }
          var interview2Date;
          if (tampungDateInterview2 == "" ||
              tampungDateInterview2 == null ||
              tampungDateInterview2 == '0000-00-00') {
          } else {
            var convert = tampungDateInterview2.split(',');
            interview2Date = convert.last;
          }

          // validasi screen tanggal
          var viewTanggal;
          if (statusKandidat == 'Schedule1' || statusKandidat == 'Interview1') {
            if (interview1Date == '0000-00-00' ||
                interview1Date == null ||
                interview1Date == "") {
              viewTanggal = false;
            } else {
              viewTanggal = true;
            }
          } else if (statusKandidat == 'Schedule2' ||
              statusKandidat == 'Interview2') {
            if (interview2Date == '0000-00-00' ||
                interview2Date == null ||
                interview2Date == "") {
              viewTanggal = false;
            } else {
              viewTanggal = true;
            }
          } else if (statusKandidat == 'Open') {
            viewTanggal = true;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 70,
                            child: Text(
                              "$namaKandidat",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 30,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                statusKandidat == "Accepted"
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: statusAkhirKandidat == 1
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                                Constanst.borderStyle1),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              bottom: 5,
                                              left: 8,
                                              right: 8),
                                          child: Center(
                                              child: statusAkhirKandidat == 1
                                                  ? Text(
                                                      "Di terima",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10),
                                                    )
                                                  : Text(
                                                      "Di tolak",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10),
                                                    )),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: statusKandidat == "Open"
                                                ? Colors.grey
                                                : statusKandidat == "Schedule1"
                                                    ? Colors.blue
                                                    : statusKandidat ==
                                                            "Schedule2"
                                                        ? Colors.blue
                                                        : statusKandidat ==
                                                                "Interview1"
                                                            ? Color(0xffF2AA0D)
                                                            : statusKandidat ==
                                                                    "Interview2"
                                                                ? Color(
                                                                    0xffF2AA0D)
                                                                : Colors.grey,
                                            borderRadius:
                                                Constanst.borderStyle1),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              bottom: 5,
                                              left: 8,
                                              right: 8),
                                          child: Center(
                                            child: statusKandidat == "Open"
                                                ? Text(
                                                    "Sortir",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  )
                                                : statusKandidat == "Schedule1"
                                                    ? Text(
                                                        "Schedule 1",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10),
                                                      )
                                                    : statusKandidat ==
                                                            "Interview1"
                                                        ? Text(
                                                            "Interview 1",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10),
                                                          )
                                                        : statusKandidat ==
                                                                "Schedule2"
                                                            ? Text(
                                                                "Schedule 2",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10),
                                                              )
                                                            : statusKandidat ==
                                                                    "Interview2"
                                                                ? Text(
                                                                    "Interview 2",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10),
                                                                  )
                                                                : SizedBox(),
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  height: 6,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 60,
                            child: screenInfo(
                                namaKandidat,
                                fileKandidat,
                                statusKandidat,
                                statusAkhirKandidat,
                                viewTanggal,
                                interview1Date,
                                interview2Date,
                                statusRemaks,
                                urlPendukung),
                          ),
                          Expanded(
                            flex: 40,
                            child: screenInfo2(
                              statusKandidat,
                              statusAkhirKandidat,
                              statusRemaks,
                              viewTanggal,
                              interview1Date,
                              interview2Date,
                            ),
                          ),
                        ],
                      ),

                      statusKandidat == "Schedule1" ||
                              statusKandidat == "Interview1" ||
                              statusKandidat == "Schedule2" ||
                              statusKandidat == "Interview2" ||
                              statusKandidat == "Accepted"
                          ? SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  statusKandidat == "Accepted" &&
                                          statusAkhirKandidat == 1
                                      ? Text(
                                          "$alasanTerima",
                                          style: TextStyle(
                                              color: Constanst.colorText2,
                                              fontSize: 12),
                                        )
                                      : statusKandidat == "Accepted" &&
                                              statusAkhirKandidat == 2
                                          ? Text(
                                              "$alasanTolak",
                                              style: TextStyle(
                                                  color: Constanst.colorText2,
                                                  fontSize: 12),
                                            )
                                          : statusAkhirKandidat == 0
                                              ? Text(
                                                  "$alasanTerima",
                                                  style: TextStyle(
                                                      color:
                                                          Constanst.colorText2,
                                                      fontSize: 12),
                                                )
                                              : Text(
                                                  "$alasanTolak",
                                                  style: TextStyle(
                                                      color:
                                                          Constanst.colorText2,
                                                      fontSize: 12),
                                                ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),

                      statusKandidat == "Accepted"
                          ? SizedBox()
                          : Divider(
                              height: 5,
                              color: Constanst.colorText2,
                            ),
                      SizedBox(
                        height: 8,
                      ),
                      // BUTTON AKSI
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          statusKandidat == "Schedule1" ||
                                  statusKandidat == "Interview1" ||
                                  statusKandidat == "Schedule2" ||
                                  statusKandidat == "Interview2"
                              ? Expanded(
                                  flex: 20,
                                  child: InkWell(
                                    onTap: () {
                                      if (statusKandidat == "Schedule1" ||
                                          statusKandidat == "Schedule2") {
                                        if (statusKandidat == "Schedule1") {
                                          if (interview1Date == null ||
                                              interview1Date == "" ||
                                              interview1Date == "0000-00-00") {
                                            controller.pilihTanggalSchedule1
                                                .value = DateTime.now();
                                          } else {
                                            controller.pilihTanggalSchedule1
                                                    .value =
                                                DateTime.parse(
                                                    '$interview1Date');
                                          }
                                        } else {
                                          if (interview2Date == null ||
                                              interview2Date == "" ||
                                              interview2Date == "0000-00-00") {
                                            controller.pilihTanggalSchedule2
                                                .value = DateTime.now();
                                          } else {
                                            controller.pilihTanggalSchedule2
                                                    .value =
                                                DateTime.parse(
                                                    '$interview2Date');
                                          }
                                        }
                                        controller.urlFormSchedule.value.text =
                                            urlPendukung;
                                        var typeSchedule =
                                            statusKandidat == "Schedule1"
                                                ? false
                                                : true;
                                        controller.showBottomFormSchedule(
                                            typeSchedule, id);
                                      } else if (statusKandidat ==
                                              "Interview1" ||
                                          statusKandidat == "Interview2") {
                                        var typeInterview =
                                            statusKandidat == "Interview1"
                                                ? false
                                                : true;
                                        controller.showBottomFormInterview(
                                            typeInterview, id);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 3.0),
                                      decoration: BoxDecoration(
                                          borderRadius: Constanst.borderStyle5,
                                          border: Border.all(
                                              color: Constanst.colorPrimary)),
                                      child: Center(
                                        child: Icon(
                                          Iconsax.more,
                                          size: 23,
                                          color: Constanst.colorPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          statusKandidat == "Accepted"
                              ? SizedBox()
                              : Expanded(
                                  flex: statusKandidat == "Schedule1" ||
                                          statusKandidat == "Interview1" ||
                                          statusKandidat == "Schedule2" ||
                                          statusKandidat == "Interview2"
                                      ? 40
                                      : 50,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 3.0, left: 3.0),
                                    child: InkWell(
                                      onTap: () {
                                        if (viewTanggal == false) {
                                          UtilsAlert.showToast(
                                              'Harap isi tanggal interview dan link terlebih dahulu');
                                        } else {
                                          controller.showBottomAlasan(false, id,
                                              namaKandidat, statusKandidat);
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                Constanst.borderStyle5,
                                            border: Border.all(
                                                color: viewTanggal == false
                                                    ? Colors.grey
                                                    : Colors.red)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: Text(
                                              "Tolak",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                  color: viewTanggal == false
                                                      ? Colors.grey
                                                      : Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          statusKandidat == "Accepted"
                              ? SizedBox()
                              : Expanded(
                                  flex: statusKandidat == "Schedule1" ||
                                          statusKandidat == "Interview1" ||
                                          statusKandidat == "Schedule2" ||
                                          statusKandidat == "Interview2"
                                      ? 40
                                      : 50,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 3.0),
                                    child: InkWell(
                                      onTap: () {
                                        if (viewTanggal == false) {
                                          UtilsAlert.showToast(
                                              'Harap isi tanggal interview dan link terlebih dahulu');
                                        } else {
                                          controller.showBottomAlasan(true, id,
                                              namaKandidat, statusKandidat);
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                Constanst.borderStyle5,
                                            border: Border.all(
                                                color: viewTanggal == false
                                                    ? Colors.grey
                                                    : Colors.green)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: Text(
                                              "Tahap selanjutnya",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                  color: viewTanggal == false
                                                      ? Colors.grey
                                                      : Colors.green),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      )
                    ],
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

  Widget screenInfo(
      namaKandidat,
      fileKandidat,
      statusKandidat,
      statusAkhirKandidat,
      viewTanggal,
      interview1Date,
      interview2Date,
      statusRemaks,
      urlPendukung) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => controller.viewLampiranKandidat(fileKandidat),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Iconsax.export_2,
                size: 18,
                color: Colors.blue,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6),
                  child: Text(
                    "$fileKandidat",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        urlPendukung == "" ||
                urlPendukung == null ||
                statusKandidat == "Accepted"
            ? SizedBox(
                height: 8,
              )
            : SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    InkWell(
                      onTap: () => controller.viewUrlPendukung(urlPendukung),
                      child: Text(
                        "$urlPendukung",
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget screenInfo2(statusKandidat, statusAkhirKandidat, statusRemaks,
      viewTanggal, interview1Date, interview2Date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        viewTanggal == false
            ? SizedBox()
            : statusKandidat == 'Schedule1' || statusKandidat == 'Interview1'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${Constanst.convertDate("$interview1Date")}',
                        style: TextStyle(
                            fontSize: 12, color: Constanst.colorPrimary),
                      ),
                      SizedBox(
                        height: 8,
                      )
                    ],
                  )
                : statusKandidat == 'Schedule2' ||
                        statusKandidat == 'Interview2'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${Constanst.convertDate("$interview2Date")}',
                            style: TextStyle(
                                fontSize: 12, color: Constanst.colorPrimary),
                          ),
                          SizedBox(
                            height: 8,
                          )
                        ],
                      )
                    : SizedBox(),
        statusKandidat == "Accepted" && statusAkhirKandidat == 2
            ? SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                          color: statusRemaks == "Open"
                              ? Colors.grey
                              : statusRemaks == "Schedule1"
                                  ? Colors.blue
                                  : statusRemaks == "Schedule2"
                                      ? Colors.blue
                                      : statusRemaks == "Interview1"
                                          ? Color(0xffF2AA0D)
                                          : statusRemaks == "Interview2"
                                              ? Color(0xffF2AA0D)
                                              : Colors.grey,
                          borderRadius: Constanst.borderStyle1),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 5, bottom: 5, left: 8, right: 8),
                        child: Center(
                          child: statusRemaks == "Open"
                              ? Text(
                                  "Sortir",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                )
                              : statusRemaks == "Schedule1"
                                  ? Text(
                                      "Schedule 1",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    )
                                  : statusRemaks == "Interview1"
                                      ? Text(
                                          "Interview 1",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        )
                                      : statusRemaks == "Schedule2"
                                          ? Text(
                                              "Schedule 2",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            )
                                          : statusRemaks == "Interview2"
                                              ? Text(
                                                  "Interview 2",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                )
                                              : SizedBox(),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
