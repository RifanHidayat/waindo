import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/laporan_tidakHadir_controller.dart';
import 'package:siscom_operasional/controller/tidak_masuk_kerja_controller.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_absen_karyawan.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class LaporanDetailTidakHadir extends StatefulWidget {
  String emId, bulan, tahun, full_name, title;
  LaporanDetailTidakHadir(
      {Key? key,
      required this.emId,
      required this.bulan,
      required this.tahun,
      required this.title,
      required this.full_name})
      : super(key: key);
  @override
  _LaporanDetailTidakHadirState createState() =>
      _LaporanDetailTidakHadirState();
}

class _LaporanDetailTidakHadirState extends State<LaporanDetailTidakHadir> {
  var controller = Get.put(LaporanTidakHadirController());

  @override
  void initState() {
    controller.loadDataTidakHadirEmployee(
        widget.emId, widget.bulan, widget.tahun, widget.title);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constanst.coloBackgroundScreen,
        appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 3,
            flexibleSpace: AppbarMenu1(
              title: widget.title == "tidak_hadir"
                  ? "Detail Laporan Tidak Hadir"
                  : widget.title == "cuti"
                      ? "Detail Laporan Cuti"
                      : widget.title == "lembur"
                          ? "Detail Laporan Lembur"
                          : widget.title == "tugas_luar"
                              ? "Detail Laporan Tugas Luar"
                              : "",
              colorTitle: Colors.black,
              icon: 1,
              rightIcon: Icon(Iconsax.document_download),
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
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.title == "tidak_hadir"
                                ? Text(
                                    "Riwayat Tidak Hadir",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Constanst.colorText2),
                                  )
                                : widget.title == "cuti"
                                    ? Text(
                                        "Riwayat Cuti",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Constanst.colorText2),
                                      )
                                    : widget.title == "lembur"
                                        ? Text(
                                            "Riwayat Lembur",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Constanst.colorText2),
                                          )
                                        : widget.title == "tugas_luar"
                                            ? Text(
                                                "Riwayat Tugas Luar",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Constanst.colorText2),
                                              )
                                            : SizedBox(),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "${widget.full_name} - ${Constanst.convertDateBulanDanTahun('${widget.bulan}-${widget.tahun}')}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Constanst.colorText3),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Divider(
                              height: 5,
                              color: Constanst.colorText2,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            listStatusAjuan(),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Flexible(
                          child: controller
                                  .listDetailLaporanEmployee.value.isEmpty
                              ? Center(
                                  child:
                                      Text("${controller.loadingString.value}"))
                              : listAjuanTidakMasukEmployee())
                    ],
                  ),
                ),
              ),
            )));
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
              onTap: () => controller.changeTypeAjuanLaporan(
                  controller.dataTypeAjuan.value[index]['nama'], widget.title),
              child: Container(
                padding: EdgeInsets.only(left: 5, right: 5),
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

  Widget listAjuanTidakMasukEmployee() {
    return Obx(
      () => ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: controller.listDetailLaporanEmployee.value.length,
          itemBuilder: (context, index) {
            return widget.title == "tidak_hadir" || widget.title == "cuti"
                ? viewTidakHadir(
                    controller.listDetailLaporanEmployee.value[index])
                : viewLemburTugasLuar(
                    controller.listDetailLaporanEmployee.value[index]);
          }),
    );
  }

  Widget viewTidakHadir(index) {
    var nomorAjuan = index['nomor_ajuan'] ?? "";
    var tanggalMasukAjuan = index['atten_date'] ?? "";
    var namaTypeAjuan = index['name'] ?? "";
    var alasanReject = index['alasan_reject'] ?? "";
    var typeAjuan = index['leave_status'] ?? "";
    var approve_by = index['apply_by'] ?? "";
    return InkWell(
      onTap: () => controller.showDetailRiwayat(index),
      child: Column(
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
                  color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.4),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 8),
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
                    "NO.$nomorAjuan",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontSize: 14,
                        color: Constanst.colorText1,
                        fontWeight: FontWeight.bold),
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                alasanReject,
                                style: TextStyle(
                                    fontSize: 14, color: Constanst.colorText2),
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
                                          padding:
                                              EdgeInsets.only(left: 5, top: 3),
                                          child:
                                              Text("Approved by $approve_by"),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(left: 5, top: 3),
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
                          ],
                        )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget viewLemburTugasLuar(index) {
    var nomorAjuan = index['nomor_ajuan'];
    var dariJam = index['dari_jam'];
    var sampaiJam = index['sampai_jam'];
    var tanggalPengajuan = index['atten_date'];
    var status = index['status'];
    var alasanReject = index['alasan_reject'];
    var approveDate = index['approve_date'];
    var uraian = index['uraian'];
    var approve = index['approve_by'];
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
                color: Color.fromARGB(255, 190, 190, 190).withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(1, 1), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 10),
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
                          Constanst.convertDate('$tanggalPengajuan'),
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
                          color: status == 'Approve'
                              ? Constanst.colorBGApprove
                              : status == 'Rejected'
                                  ? Constanst.colorBGRejected
                                  : status == 'Pending'
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
                              status == 'Approve'
                                  ? Icon(
                                      Iconsax.tick_square,
                                      color: Constanst.color5,
                                      size: 14,
                                    )
                                  : status == 'Rejected'
                                      ? Icon(
                                          Iconsax.close_square,
                                          color: Constanst.color4,
                                          size: 14,
                                        )
                                      : status == 'Pending'
                                          ? Icon(
                                              Iconsax.timer,
                                              color: Constanst.color3,
                                              size: 14,
                                            )
                                          : SizedBox(),
                              Padding(
                                padding: const EdgeInsets.only(left: 3),
                                child: Text(
                                  '$status',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: status == 'Approve'
                                          ? Colors.green
                                          : status == 'Rejected'
                                              ? Colors.red
                                              : status == 'Pending'
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
                  height: 5,
                ),
                Text(
                  "NO.$nomorAjuan",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontSize: 14,
                      color: Constanst.colorText1,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${dariJam} sd ${sampaiJam}',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14, color: Constanst.colorText2),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '$uraian',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14, color: Constanst.colorText2),
                ),
                SizedBox(
                  height: 5,
                ),
                Divider(
                  height: 5,
                  color: Constanst.colorText2,
                ),
                SizedBox(
                  height: 5,
                ),
                status == "Rejected"
                    ? SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Alasan Reject",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              alasanReject,
                              style: TextStyle(
                                  fontSize: 14, color: Constanst.colorText2),
                            )
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: status == "Approve"
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Iconsax.tick_circle,
                                        color: Colors.green,
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 5, top: 3),
                                        child: Text("Approved by $approve"),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 5, top: 3),
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
                        ],
                      )
              ],
            ),
          ),
        )
      ],
    );
  }
}
