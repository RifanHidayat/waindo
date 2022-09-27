import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class Pesan extends StatelessWidget {
  final controller = Get.put(PesanController());
  bool status;
  Pesan(this.status);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: status == true
              ? AppbarMenu1(
                  title: "Pesan",
                  colorTitle: Colors.white,
                  colorIcon: Colors.white,
                  iconShow: true,
                  icon: 1,
                  onTap: () {
                    Get.offAll(InitScreen());
                  },
                )
              : AppbarMenu1(
                  title: "Pesan",
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
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  lineTitle(),
                  SizedBox(
                    height: 8,
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: pageViewPesan(),
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
              controller.selectedView.value = 0;
              controller.menuController.jumpToPage(0);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: controller.selectedView.value == 0
                        ? Constanst.colorPrimary
                        : Constanst.color6,
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    "Notifikasi",
                    style: TextStyle(
                        color: controller.selectedView.value == 0
                            ? Constanst.colorPrimary
                            : Constanst.colorText2,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              controller.selectedView.value = 1;
              controller.menuController.jumpToPage(1);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: controller.selectedView.value == 1
                        ? Constanst.colorPrimary
                        : Constanst.color6,
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    "Persetujuan",
                    style: TextStyle(
                        color: controller.selectedView.value == 1
                            ? Constanst.colorPrimary
                            : Constanst.colorText2,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              controller.selectedView.value = 2;
              controller.menuController.jumpToPage(2);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: controller.selectedView.value == 2
                        ? Constanst.colorPrimary
                        : Constanst.color6,
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    "Riwayat",
                    style: TextStyle(
                        color: controller.selectedView.value == 2
                            ? Constanst.colorPrimary
                            : Constanst.colorText2,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget pageViewPesan() {
    return PageView.builder(
        physics: BouncingScrollPhysics(),
        controller: controller.menuController,
        onPageChanged: (index) {
          controller.selectedView.value = index;
        },
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.all(0),
              child: index == 0
                  ? screenNotifikasi()
                  : index == 1
                      ? screenPersetujuan()
                      : index == 2
                          ? screenRiwayat()
                          : SizedBox());
        });
  }

  Widget screenNotifikasi() {
    return controller.listNotifikasi.value.isEmpty
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/amico.png",
                  height: 250,
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Kamu belum memiliki Notifikasi")
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              controller.jumlahNotifikasiBelumDibaca.value == 0
                  ? SizedBox()
                  : Obx(
                      () => Container(
                          decoration: BoxDecoration(
                            color: Constanst.colorButton2,
                            borderRadius: Constanst.borderStyle3,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${controller.jumlahNotifikasiBelumDibaca.value} notifikasi belum terbaca",
                          )),
                    ),
              Flexible(
                flex: 3,
                child: ListView.builder(
                    itemCount: controller.listNotifikasi.value.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var tanggalNotif =
                          controller.listNotifikasi.value[index]['tanggal'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(tanggalNotif),
                          SizedBox(
                            height: 10,
                          ),
                          Obx(
                            () => Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: ListView.builder(
                                  itemCount: controller.listNotifikasi
                                      .value[index]['notifikasi'].length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, idx) {
                                    var idNotif = controller.listNotifikasi
                                        .value[index]['notifikasi'][idx]['id'];
                                    var titleNotif =
                                        controller.listNotifikasi.value[index]
                                            ['notifikasi'][idx]['title'];
                                    var deskripsiNotif =
                                        controller.listNotifikasi.value[index]
                                            ['notifikasi'][idx]['deskripsi'];
                                    var urlRoute = controller.listNotifikasi
                                        .value[index]['notifikasi'][idx]['url'];
                                    var jam = controller.listNotifikasi
                                        .value[index]['notifikasi'][idx]['jam'];
                                    var statusNotif =
                                        controller.listNotifikasi.value[index]
                                            ['notifikasi'][idx]['status'];
                                    var view =
                                        controller.listNotifikasi.value[index]
                                            ['notifikasi'][idx]['view'];
                                    return Column(
                                      children: [
                                        SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: view == 0
                                                ? Constanst.colorButton2
                                                : Colors.transparent,
                                            borderRadius:
                                                Constanst.borderStyle1,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if (view == 0) {
                                                controller
                                                    .aksilihatNotif(idNotif);
                                              } else {
                                                controller
                                                    .redirectToPage(urlRoute);
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Expanded(
                                                        flex: 10,
                                                        child: Center(
                                                          child:
                                                              statusNotif == 1
                                                                  ? Icon(
                                                                      Iconsax
                                                                          .tick_circle,
                                                                      color: Colors
                                                                          .green,
                                                                    )
                                                                  : Icon(
                                                                      Iconsax
                                                                          .close_circle,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                        )),
                                                    Expanded(
                                                      flex: 90,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 5),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  flex: 75,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                    child: Text(
                                                                      titleNotif,
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 25,
                                                                  child: Text(
                                                                    "$jam WIB",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              deskripsiNotif,
                                                              style: TextStyle(
                                                                  color: Constanst
                                                                      .colorText2),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Divider(
                                          height: 5,
                                          color: Constanst.colorText2,
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      );
                    }),
              ),
            ],
          );
  }

  Widget screenPersetujuan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 8,
        ),
        Obx(
          () => Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: controller.statusScreenInfoApproval.value == false
                ? Center(
                    child: Text(controller.stringLoading.value),
                  )
                : ListView.builder(
                    itemCount: controller.dataScreenPersetujuan.value.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var title = controller.dataScreenPersetujuan.value[index]
                          ['title'];
                      var jumlah = controller.dataScreenPersetujuan.value[index]
                          ['jumlah_approve'];
                      return InkWell(
                        highlightColor: Colors.white,
                        onTap: () => controller.routeApproval(
                            controller.dataScreenPersetujuan.value[index]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: title == 'Cuti'
                                      ? Icon(
                                          Iconsax.calendar_remove,
                                          color: Constanst.colorPrimary,
                                        )
                                      : title == 'Lembur'
                                          ? Icon(
                                              Iconsax.clock,
                                              color: Constanst.colorPrimary,
                                            )
                                          : title == 'Tidak Hadir'
                                              ? Icon(
                                                  Iconsax.clipboard_close,
                                                  color: Constanst.colorPrimary,
                                                )
                                              : title == 'Tugas Luar'
                                                  ? Icon(
                                                      Iconsax.send_2,
                                                      color: Constanst
                                                          .colorPrimary,
                                                    )
                                                  : SizedBox(),
                                ),
                                Expanded(
                                  flex: 60,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(top: 3, left: 8),
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Constanst.colorText3),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Constanst.colorBGRejected,
                                      borderRadius: Constanst.borderStyle1,
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: Center(
                                        child: Text(
                                          jumlah,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Constanst.colorText2,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 5,
                              color: Constanst.colorText2,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      );
                    }),
          ),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget screenRiwayat() {
    return controller.riwayatPersetujuan.value.isEmpty
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/amico.png",
                  height: 250,
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Kamu tidak memiliki Riwayat Persetujuan")
              ],
            ),
          )
        : Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 85,
                      child: controller.statusFilteriwayat.value == false
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      "Filter ${controller.stringFilterSelected.value}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Constanst.colorText1),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      controller.clearFilter();
                                    },
                                    child: Padding(
                                        padding:
                                            EdgeInsets.only(top: 6, left: 8),
                                        child: Icon(Iconsax.close_circle,
                                            color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    Expanded(
                      flex: 15,
                      child: Container(
                          alignment: Alignment.centerRight,
                          child: PopupMenuButton(
                            padding: EdgeInsets.all(0.0),
                            icon: Icon(
                              Iconsax.filter,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: "1",
                                  onTap: () => controller.filterApproveHistory(
                                      'Pengajuan Tidak Hadir'),
                                  child: Text("Pengajuan Tidak Hadir")),
                              PopupMenuItem(
                                  value: "2",
                                  onTap: () => controller
                                      .filterApproveHistory('Pengajuan Cuti'),
                                  child: Text("Pengajuan Cuti")),
                              PopupMenuItem(
                                  value: "3",
                                  onTap: () => controller
                                      .filterApproveHistory('Pengajuan Lembur'),
                                  child: Text("Pengajuan Lembur")),
                              PopupMenuItem(
                                  value: "4",
                                  onTap: () => controller.filterApproveHistory(
                                      'Pengajuan Tugas Luar'),
                                  child: Text("Pengajuan Tugas Luar"))
                            ],
                          )),
                    )
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Obx(
                  () => Flexible(
                      flex: 3,
                      child: controller.riwayatPersetujuan.value.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : controller.statusFilteriwayat.value == false
                              ? listFilterRiwayatNonAktif()
                              : listFilterRiwayatAktif()),
                ),
              ],
            ),
          );
  }

  Widget listFilterRiwayatAktif() {
    return ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: controller.riwayatPersetujuan.value.length,
        itemBuilder: (context, ixx) {
          var idx = controller.riwayatPersetujuan.value[ixx]['id'];
          var status = controller.riwayatPersetujuan.value[ixx]['status'];
          var namaPengaju =
              controller.riwayatPersetujuan.value[ixx]['nama_pengaju'];
          var typeAjuan = controller.riwayatPersetujuan.value[ixx]['type'];
          var tanggalPengajuan =
              controller.riwayatPersetujuan.value[ixx]['waktu_pengajuan'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: Constanst.borderStyle2,
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
                                namaPengaju,
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
                        height: 10,
                      ),
                      Text(
                        typeAjuan,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${Constanst.convertDate1("$tanggalPengajuan")}",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          controller.filterDetailRiwayatApproval(
                              idx, typeAjuan);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Constanst.colorPrimary,
                              borderRadius: Constanst.borderStyle3),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Center(
                              child: Text(
                                "Lihat Detail",
                                style: TextStyle(color: Colors.white),
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
          );
        });
  }

  Widget listFilterRiwayatNonAktif() {
    return ListView.builder(
        itemCount: controller.riwayatPersetujuan.value.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          var tanggalNotif =
              controller.riwayatPersetujuan.value[index]['waktu_pengajuan'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "${Constanst.convertDate1("$tanggalNotif")}",
                style: TextStyle(
                    color: Constanst.colorText1,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Obx(
                () => Padding(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller
                            .riwayatPersetujuan.value[index]['turunan'].length,
                        itemBuilder: (context, ixx) {
                          var idx = controller.riwayatPersetujuan.value[index]
                              ['turunan'][ixx]['id'];
                          var status = controller.riwayatPersetujuan
                              .value[index]['turunan'][ixx]['status'];
                          var namaPengaju = controller.riwayatPersetujuan
                              .value[index]['turunan'][ixx]['nama_pengaju'];
                          var typeAjuan = controller.riwayatPersetujuan
                              .value[index]['turunan'][ixx]['type'];
                          var tanggalPengajuan = controller.riwayatPersetujuan
                              .value[index]['turunan'][ixx]['waktu_pengajuan'];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 16,
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
                                      offset: Offset(
                                          1, 1), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 8, bottom: 8, right: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 70,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(
                                                namaPengaju,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
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
                                                        ? Constanst
                                                            .colorBGRejected
                                                        : status == 'Pending'
                                                            ? Constanst
                                                                .colorBGPending
                                                            : Colors.grey,
                                                borderRadius:
                                                    Constanst.borderStyle1,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 3,
                                                    right: 3,
                                                    top: 5,
                                                    bottom: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    status == 'Approve'
                                                        ? Icon(
                                                            Iconsax.tick_square,
                                                            color: Constanst
                                                                .color5,
                                                            size: 14,
                                                          )
                                                        : status == 'Rejected'
                                                            ? Icon(
                                                                Iconsax
                                                                    .close_square,
                                                                color: Constanst
                                                                    .color4,
                                                                size: 14,
                                                              )
                                                            : status ==
                                                                    'Pending'
                                                                ? Icon(
                                                                    Iconsax
                                                                        .timer,
                                                                    color: Constanst
                                                                        .color3,
                                                                    size: 14,
                                                                  )
                                                                : SizedBox(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 3),
                                                      child: Text(
                                                        '$status',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: status ==
                                                                    'Approve'
                                                                ? Colors.green
                                                                : status ==
                                                                        'Rejected'
                                                                    ? Colors.red
                                                                    : status ==
                                                                            'Pending'
                                                                        ? Constanst
                                                                            .color3
                                                                        : Colors
                                                                            .black),
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
                                        typeAjuan,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller
                                              .filterDetailRiwayatApproval(
                                                  idx, typeAjuan);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Constanst.colorPrimary,
                                              borderRadius:
                                                  Constanst.borderStyle3),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Center(
                                              child: Text(
                                                "Lihat Detail",
                                                style: TextStyle(
                                                    color: Colors.white),
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
                          );
                        })),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          );
        });
  }
}
