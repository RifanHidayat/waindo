import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/cuti_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
import 'package:siscom_operasional/screen/absen/form/form_tidakMasukKerja.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_semua_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_pengajuan_cuti.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class RiwayatCuti extends StatefulWidget {
  @override
  _RiwayatCutiState createState() => _RiwayatCutiState();
}

class _RiwayatCutiState extends State<RiwayatCuti> {
  final controller = Get.put(CutiController());
  var controllerGlobal = Get.put(GlobalController());

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    controller.loadDataAjuanCuti();
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
            title: "Cuti",
            icon: 1,
            colorTitle: Colors.black,
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
                  child: Text("Memuat Data..."),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      controller.bulanDanTahunNow.value == ""
                          ? SizedBox()
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 60,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: pencarianData(),
                                  ),
                                ),
                                Expanded(
                                  flex: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: pickDate(),
                                  ),
                                )
                              ],
                            ),
                      SizedBox(
                        height: 16,
                      ),
                      listStatusAjuan(),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Riwayat Pengajuan Cuti",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Flexible(
                        child: RefreshIndicator(
                            color: Constanst.colorPrimary,
                            onRefresh: refreshData,
                            child: controller.listHistoryAjuan.value.isEmpty
                                ? Center(
                                    child: Obx(() =>
                                        Text(controller.stringLoading.value)),
                                  )
                                : listAjuanCuti()),
                      )
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(
        () => controller.showButtonlaporan.value == false
            ? SizedBox()
            : SpeedDial(
                icon: Iconsax.more,
                activeIcon: Icons.close,
                backgroundColor: Constanst.colorPrimary,
                spacing: 3,
                childPadding: const EdgeInsets.all(5),
                spaceBetweenChildren: 4,
                elevation: 8.0,
                animationCurve: Curves.elasticInOut,
                animationDuration: const Duration(milliseconds: 200),
                children: [
                  SpeedDialChild(
                      child: Icon(Iconsax.minus_cirlce),
                      backgroundColor: Color(0xff2F80ED),
                      foregroundColor: Colors.white,
                      label: 'Laporan Cuti',
                      onTap: () {
                        Get.to(LaporanTidakMasuk(
                          title: 'cuti',
                        ));
                      }),
                  SpeedDialChild(
                      child: Icon(Iconsax.add_square),
                      backgroundColor: Color(0xff14B156),
                      foregroundColor: Colors.white,
                      label: 'Buat Pengajuan Cuti',
                      onTap: () {
                        Get.to(FormPengajuanCuti(
                          dataForm: [[], false],
                        ));
                      }),
                ],
              ),
      ),
      bottomNavigationBar: Obx(
        () => Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
            child: controller.showButtonlaporan.value == true
                ? SizedBox()
                : TextButtonWidget2(
                    title: "Buat Pengajuan Cuti",
                    onTap: () {
                      Get.to(FormPengajuanCuti(
                        dataForm: [[], false],
                      ));
                    },
                    colorButton: Constanst.colorPrimary,
                    colortext: Constanst.colorWhite,
                    border: BorderRadius.circular(20.0),
                    icon: Icon(
                      Iconsax.add,
                      color: Constanst.colorWhite,
                    ))),
      ),
    );
  }

  Widget pickDate() {
    return Container(
      height: 42,
      decoration: Constanst.styleBoxDecoration1,
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
                controller.loadDataAjuanCuti();
                this.controller.bulanSelectedSearchHistory.refresh();
                this.controller.tahunSelectedSearchHistory.refresh();
                this.controller.bulanDanTahunNow.refresh();
              }
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 20,
                child: Icon(Iconsax.calendar_2),
              ),
              Expanded(
                flex: 70,
                child: Padding(
                    padding: const EdgeInsets.only(left: 6, top: 3),
                    child: Text(
                        "${controller.bulanSelectedSearchHistory.value}-${controller.tahunSelectedSearchHistory.value}")),
              ),
              Expanded(
                flex: 10,
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
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
              highlightColor: Constanst.colorPrimary,
              onTap: () => controller.changeTypeAjuan(
                  controller.dataTypeAjuan.value[index]['nama']),
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
                      namaType == "Approve"
                          ? Icon(
                              Iconsax.tick_square,
                              size: 14,
                              color: status == true
                                  ? Colors.white
                                  : Constanst.colorText2,
                            )
                          : namaType == "Approve 1"
                              ? Icon(
                                  Iconsax.tick_square,
                                  size: 14,
                                  color: status == true
                                      ? Colors.white
                                      : Constanst.colorText2,
                                )
                              : namaType == "Approve 2"
                                  ? Icon(
                                      Iconsax.tick_square,
                                      size: 14,
                                      color: status == true
                                          ? Colors.white
                                          : Constanst.colorText2,
                                    )
                                  : namaType == "Rejected"
                                      ? Icon(
                                          Iconsax.close_square,
                                          size: 14,
                                          color: status == true
                                              ? Colors.white
                                              : Constanst.colorText2,
                                        )
                                      : namaType == "Pending"
                                          ? Icon(
                                              Iconsax.timer,
                                              size: 14,
                                              color: status == true
                                                  ? Colors.white
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 85,
                      child: TextField(
                        controller: controller.cari.value,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: "Cari"),
                        style: TextStyle(
                            fontSize: 14.0, height: 1.0, color: Colors.black),
                        onSubmitted: (value) {
                          controller.cariData(value);
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
                                controller.loadDataAjuanCuti();
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

  Widget listAjuanCuti() {
    return ListView.builder(
        physics: controller.listHistoryAjuan.value.length <= 8
            ? AlwaysScrollableScrollPhysics()
            : BouncingScrollPhysics(),
        itemCount: controller.listHistoryAjuan.value.length,
        itemBuilder: (context, index) {
          var nomorAjuan =
              controller.listHistoryAjuan.value[index]['nomor_ajuan'];
          var tanggalMasukAjuan =
              controller.listHistoryAjuan.value[index]['atten_date'];
          var namaTypeAjuan = controller.listHistoryAjuan.value[index]['name'];
          var alasanReject =
              controller.listHistoryAjuan.value[index]['alasan_reject'];
          var typeAjuan;
          if (controller.valuePolaPersetujuan.value == "1") {
            typeAjuan =
                controller.listHistoryAjuan.value[index]['leave_status'];
          } else {
            typeAjuan = controller.listHistoryAjuan.value[index]
                        ['leave_status'] ==
                    "Approve"
                ? "Approve 1"
                : controller.listHistoryAjuan.value[index]['leave_status'] ==
                        "Approve2"
                    ? "Approve 2"
                    : controller.listHistoryAjuan.value[index]['leave_status'];
          }
          var apply_by;
          if (controller.listHistoryAjuan.value[index]['apply2_by'] == "" ||
              controller.listHistoryAjuan.value[index]['apply2_by'] == "null" ||
              controller.listHistoryAjuan.value[index]['apply2_by'] == null) {
            apply_by = controller.listHistoryAjuan.value[index]['apply_by'];
          } else {
            apply_by = controller.listHistoryAjuan.value[index]['apply2_by'];
          }
          return InkWell(
            onTap: () => controller
                .showDetailRiwayat(controller.listHistoryAjuan.value[index]),
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
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: Constanst.borderStyle1,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Color.fromARGB(255, 190, 190, 190).withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 60,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  "$namaTypeAjuan",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 40,
                              child: Container(
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: typeAjuan == 'Approve'
                                      ? Constanst.colorBGApprove
                                      : typeAjuan == 'Approve 1'
                                          ? Constanst.colorBGApprove
                                          : typeAjuan == 'Approve 2'
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
                                          : typeAjuan == 'Approve 1'
                                              ? Icon(
                                                  Iconsax.tick_square,
                                                  color: Constanst.color5,
                                                  size: 14,
                                                )
                                              : typeAjuan == 'Approve 2'
                                                  ? Icon(
                                                      Iconsax.tick_square,
                                                      color: Constanst.color5,
                                                      size: 14,
                                                    )
                                                  : typeAjuan == 'Rejected'
                                                      ? Icon(
                                                          Iconsax.close_square,
                                                          color:
                                                              Constanst.color4,
                                                          size: 14,
                                                        )
                                                      : typeAjuan == 'Pending'
                                                          ? Icon(
                                                              Iconsax.timer,
                                                              color: Constanst
                                                                  .color3,
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
                                                  : typeAjuan == 'Approve 1'
                                                      ? Colors.green
                                                      : typeAjuan == 'Approve 2'
                                                          ? Colors.green
                                                          : typeAjuan ==
                                                                  'Rejected'
                                                              ? Colors.red
                                                              : typeAjuan ==
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
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Iconsax.close_circle,
                                          color: Colors.red,
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(left: 5, top: 3),
                                          child: Text("Rejected by $apply_by"),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(left: 5, top: 3),
                                          child: Text(""),
                                        )
                                      ],
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
                                    child: typeAjuan == "Approve" ||
                                            typeAjuan == "Approve 1" ||
                                            typeAjuan == "Approve 2"
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
                                                    "Approved by $apply_by"),
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
                                                    color:
                                                        Constanst.colorText2),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/whatsapp.png',
                                                    width: 25,
                                                    height: 25,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 3),
                                                      child: InkWell(
                                                          onTap: () {
                                                            var dataEmployee = {
                                                              'nameType':
                                                                  '$namaTypeAjuan',
                                                              'nomor_ajuan':
                                                                  '$nomorAjuan',
                                                            };
                                                            controllerGlobal
                                                                .showDataPilihAtasan(
                                                                    dataEmployee);
                                                          },
                                                          child: Text(
                                                            "Konfirmasi via WA",
                                                            style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                  ),
                                  typeAjuan == "Approve" ||
                                          typeAjuan == "Approve 1" ||
                                          typeAjuan == "Approve 2"
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
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: InkWell(
                                                onTap: () {
                                                  controller
                                                      .showModalBatalPengajuan(
                                                          controller
                                                              .listHistoryAjuan
                                                              .value[index]);
                                                },
                                                child: Text(
                                                  "Batalkan",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            )),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        Constanst.borderStyle1,
                                                    border: Border.all(
                                                        color: Constanst
                                                            .colorPrimary)),
                                                child: InkWell(
                                                  onTap: () {
                                                    Get.offAll(
                                                        FormPengajuanCuti(
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
                                                        color: Constanst
                                                            .colorPrimary),
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
            ),
          );
        });
  }
}
