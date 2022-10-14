import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:siscom_operasional/controller/approval_controller.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class DetailApproval extends StatefulWidget {
  String? title, idxDetail, emId, delegasi;
  DetailApproval(
      {Key? key, this.title, this.idxDetail, this.emId, this.delegasi})
      : super(key: key);
  @override
  _DetailApprovalState createState() => _DetailApprovalState();
}

class _DetailApprovalState extends State<DetailApproval> {
  var controller = Get.put(ApprovalController());

  @override
  void initState() {
    controller.getDetailData(
        widget.idxDetail, widget.emId, widget.title, widget.delegasi);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
        backgroundColor: Constanst.colorPrimary,
        automaticallyImplyLeading: false,
        elevation: 2,
        flexibleSpace: AppbarMenu1(
          title: "Detail Menyetujui",
          colorTitle: Colors.white,
          colorIcon: Colors.white,
          iconShow: true,
          icon: 1,
          onTap: () {
            controller.alasanReject.value.text = "";
            Get.back();
          },
        ),
      ),
      body: WillPopScope(
          onWillPop: () async {
            controller.alasanReject.value.text = "";
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
                      height: 20,
                    ),
                    controller.jumlahCuti.value == 0
                        ? SizedBox()
                        : informasiSisaCuti(),
                    controller.jumlahCuti.value == 0
                        ? SizedBox()
                        : SizedBox(
                            height: 20,
                          ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Constanst.borderStyle2,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 170, 170, 170)
                                .withOpacity(0.4),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(1, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                controller.detailData[0]['title_ajuan'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: Text(
                                Constanst.convertDate2(
                                    "${controller.detailData[0]['waktu_pengajuan']}"),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              controller.detailData[0]['nama_pengaju'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Mengajukan ${widget.title} pada : ",
                              style: TextStyle(color: Constanst.colorText2),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 45,
                                  child: Text(
                                    controller.detailData[0]['waktu_dari'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Text("s.d",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  flex: 45,
                                  child: Text(
                                    controller.detailData[0]['waktu_sampai'],
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            controller.detailData[0]['type'] == "Lembur"
                                ? Text(
                                    "Pemberi Tugas",
                                    style:
                                        TextStyle(color: Constanst.colorText2),
                                  )
                                : Text(
                                    "Delegasi Kepada",
                                    style:
                                        TextStyle(color: Constanst.colorText2),
                                  ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${controller.fullNameDelegasi.value}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Deskripsi",
                              style: TextStyle(color: Constanst.colorText2),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              controller.detailData[0]['catatan'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            controller.detailData[0]['durasi'] == ""
                                ? SizedBox()
                                : durasiWidget(),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Tipe",
                              style: TextStyle(color: Constanst.colorText2),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              controller.detailData[0]['type'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            controller.detailData[0]['file'] == ""
                                ? SizedBox()
                                : fileWidget(),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    controller.showBottomAlasanReject();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5, right: 5),
                                    decoration: BoxDecoration(
                                        color: Constanst.color4,
                                        borderRadius: Constanst.borderStyle2),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Tolak",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    controller.validasiMenyetujui(true);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5, right: 5),
                                    decoration: BoxDecoration(
                                        color: Constanst.colorPrimary,
                                        borderRadius: Constanst.borderStyle2),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Menyetujui",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ))
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget fileWidget() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "File",
            style: TextStyle(color: Constanst.colorText2),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 60,
                child: Text(
                  controller.detailData[0]['file'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 40,
                child: InkWell(
                  onTap: () {
                    if (controller.detailData[0]['title_ajuan'] ==
                        "Pengajuan Tidak Hadir") {
                      controller.viewFile(
                          "tidak_hadir", controller.detailData[0]['file']);
                    } else {
                      controller.viewFile(
                          "cuti", controller.detailData[0]['file']);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Lihat File",
                        style: TextStyle(color: Constanst.colorPrimary),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Constanst.colorPrimary,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget durasiWidget() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "Durasi",
            style: TextStyle(color: Constanst.colorText2),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "${controller.detailData[0]['durasi']} Hari",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget informasiSisaCuti() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Constanst.styleBoxDecoration1.borderRadius),
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 90,
                      child: Text(
                        "SISA CUTI ${controller.detailData[0]['nama_pengaju']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Expanded(
                      flex: 10,
                      child: Text(
                        "${controller.cutiTerpakai.value}/${controller.jumlahCuti.value}",
                        textAlign: TextAlign.right,
                      )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(Get.context!).size.width,
                child: Center(
                  child: LinearPercentIndicator(
                    barRadius: Radius.circular(15.0),
                    lineHeight: 8.0,
                    percent: controller.persenCuti.value,
                    progressColor: Constanst.colorPrimary,
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              // Text("Cuti Khusus"),
            ],
          ),
        ),
      ),
    );
  }
}
