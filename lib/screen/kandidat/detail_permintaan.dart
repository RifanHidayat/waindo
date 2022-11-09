// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/kandidat_controller.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';

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
                  "Kandidat",
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
        itemCount: 2,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.all(0),
              child: index == 0
                  ? screenDetail()
                  : index == 1
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
          var testingDate =
              controller.listKandidatProses.value[index]['testing_date'];
          var interviewDate =
              controller.listKandidatProses.value[index]['interview_date'];
          var urlPendukung = controller.listKandidatProses.value[index]['url'];
          var statusRemaks =
              controller.listKandidatProses.value[index]['status_remaks'];

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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 70,
                        child: screenInfo(
                            namaKandidat,
                            fileKandidat,
                            statusKandidat,
                            testingDate,
                            interviewDate,
                            statusAkhirKandidat,
                            statusRemaks,
                            urlPendukung),
                      ),
                      statusKandidat == "Accepted"
                          ? Expanded(
                              flex: 30,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  margin: EdgeInsets.only(left: 25),
                                  decoration: BoxDecoration(
                                    color: statusAkhirKandidat == 1
                                        ? Constanst.colorBGApprove
                                        : Constanst.colorBGRejected,
                                    borderRadius: Constanst.borderStyle5,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Center(
                                        child: statusAkhirKandidat == 1
                                            ? Icon(
                                                Iconsax.tick_circle,
                                                color: Colors.green,
                                              )
                                            : Icon(
                                                Iconsax.close_circle,
                                                color: Colors.red,
                                              )),
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              flex: 30,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller.updateStatusKandidat(id,
                                            namaKandidat, statusKandidat, true);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                Constanst.borderStyle5,
                                            border: Border.all(
                                                color: Colors.green)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: Text(
                                              "Terima",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.green),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.updateStatusKandidat(
                                            id,
                                            namaKandidat,
                                            statusKandidat,
                                            false);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                Constanst.borderStyle5,
                                            border:
                                                Border.all(color: Colors.red)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: Text(
                                              "Tolak",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  Widget screenInfo(namaKandidat, fileKandidat, statusKandidat, testingDate,
      interviewDate, statusAkhirKandidat, statusRemaks, urlPendukung) {
    var tanggalInterview = statusKandidat == "Testing"
        ? testingDate
        : statusKandidat == "Interview"
            ? interviewDate
            : "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$namaKandidat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(
          height: 8,
        ),
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
        SizedBox(
          height: 8,
        ),
        statusKandidat == "Accepted"
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statusAkhirKandidat == 2
                      ? Container(
                          decoration: BoxDecoration(
                              color: statusRemaks == "Open"
                                  ? Colors.grey
                                  : statusRemaks == "Testing"
                                      ? Colors.blue
                                      : statusRemaks == "Interview"
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
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : statusRemaks == "Testing"
                                      ? Text(
                                          "Test",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : statusRemaks == "Interview"
                                          ? Text(
                                              "Interview",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          : SizedBox(),
                            ),
                          ),
                        )
                      : SizedBox(),
                  Container(
                    margin: EdgeInsets.only(left: 6, top: 2),
                    decoration: BoxDecoration(
                        color: statusAkhirKandidat == 1
                            ? Colors.green
                            : statusAkhirKandidat == 2
                                ? Colors.red
                                : Colors.grey,
                        borderRadius: Constanst.borderStyle1),
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.tick_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: statusAkhirKandidat == 1
                                ? Text(
                                    "Di terima",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                : Text(
                                    "Di tolak",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: statusKandidat == "Open"
                            ? Colors.grey
                            : statusKandidat == "Testing"
                                ? Colors.blue
                                : statusKandidat == "Interview"
                                    ? Color(0xffF2AA0D)
                                    : Colors.grey,
                        borderRadius: Constanst.borderStyle1),
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                      child: Center(
                        child: statusKandidat == "Open"
                            ? Text(
                                "Sortir",
                                style: TextStyle(color: Colors.white),
                              )
                            : statusKandidat == "Testing"
                                ? Text(
                                    "Test",
                                    style: TextStyle(color: Colors.white),
                                  )
                                : statusKandidat == "Interview"
                                    ? Text(
                                        "Interview",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : SizedBox(),
                      ),
                    ),
                  ),
                  statusKandidat == "Open"
                      ? SizedBox()
                      : Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: tanggalInterview == "" ||
                                    tanggalInterview == null
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      "${Constanst.convertDate('$tanggalInterview')}",
                                      // "$tanggalInterview",
                                      style: TextStyle(
                                          color: Constanst.colorText2,
                                          fontSize: 12),
                                    ),
                                  ),
                          ),
                        ),
                ],
              ),
        statusKandidat == "Open" || statusKandidat == "Accepted"
            ? SizedBox()
            : SizedBox(
                height: 8,
              ),
        statusKandidat == "Open" || statusKandidat == "Accepted"
            ? SizedBox()
            : urlPendukung == "null" ||
                    urlPendukung == null ||
                    urlPendukung == ""
                ? SizedBox()
                : InkWell(
                    onTap: () => controller.viewUrlPendukung(urlPendukung),
                    child: Text(
                      "$urlPendukung",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
      ],
    );
  }
}
