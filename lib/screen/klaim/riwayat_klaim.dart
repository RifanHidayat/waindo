// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/controller/lembur_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/controller/riwayat_controller.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/screen/absen/laporan/laporan_tidakMasuk.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/klaim/form_klaim.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class Klaim extends StatefulWidget {
  @override
  _KlaimState createState() => _KlaimState();
}

class _KlaimState extends State<Klaim> {
  final controller = Get.put(KlaimController());
  var controllerGlobal = Get.put(GlobalController());

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
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
            title: "Klaim",
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
                  "Riwayat Pengajuan Klaim",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Constanst.sizeTitle,
                      color: Constanst.colorText3),
                ),
                SizedBox(
                  height: 8,
                ),
                // Flexible(
                //     child: RefreshIndicator(
                //         color: Constanst.colorPrimary,
                //         onRefresh: refreshData,
                //         child: controller.listLembur.value.isEmpty
                //             ? Center(
                //                 child: Text(controller.loadingString.value),
                //               )
                //             : riwayatLembur()))
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
                  // SpeedDialChild(
                  //     child: Icon(Iconsax.minus_cirlce),
                  //     backgroundColor: Color(0xff2F80ED),
                  //     foregroundColor: Colors.white,
                  //     label: 'Laporan Klaim',
                  //     onTap: () {
                  //       Get.to(LaporanTidakMasuk(
                  //         title: 'klaim',
                  //       ));
                  //     }),
                  SpeedDialChild(
                      child: Icon(Iconsax.add_square),
                      backgroundColor: Color(0xff14B156),
                      foregroundColor: Colors.white,
                      label: 'Buat Pengajuan Klaim',
                      onTap: () {
                        Get.to(FormKlaim(
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
                    title: "Buat Pengajuan Klaim",
                    onTap: () {
                      Get.to(FormKlaim(
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
                          : namaType == "Approve 1"
                              ? Icon(
                                  Iconsax.tick_square,
                                  size: 14,
                                  color: status == true
                                      ? Constanst.colorPrimary
                                      : Constanst.colorText2,
                                )
                              : namaType == "Approve 2"
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
                        onChanged: (value) {
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
                                controller.onReady();
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

  // Widget riwayatLembur() {
  //   return ListView.builder(
  //       physics: controller.listLembur.value.length <= 8
  //           ? AlwaysScrollableScrollPhysics()
  //           : BouncingScrollPhysics(),
  //       itemCount: controller.listLembur.value.length,
  //       itemBuilder: (context, index) {
  //         var nomorAjuan = controller.listLembur.value[index]['nomor_ajuan'];
  //         var dariJam = controller.listLembur.value[index]['dari_jam'];
  //         var sampaiJam = controller.listLembur.value[index]['sampai_jam'];
  //         var tanggalPengajuan =
  //             controller.listLembur.value[index]['atten_date'];
  //         var status;
  //         if (controller.valuePolaPersetujuan.value == "1") {
  //           status = controller.listLembur.value[index]['status'];
  //         } else {
  //           status = controller.listLembur.value[index]['status'] == "Approve"
  //               ? "Approve 1"
  //               : controller.listLembur.value[index]['status'] == "Approve2"
  //                   ? "Approve 2"
  //                   : controller.listLembur.value[index]['status'];
  //         }

  //         var alasanReject =
  //             controller.listLembur.value[index]['alasan_reject'];
  //         var approveDate = controller.listLembur.value[index]['approve_date'];
  //         var uraian = controller.listLembur.value[index]['uraian'];
  //         var approve = controller.listLembur.value[index]['approve_by'];
  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             SizedBox(
  //               height: 10,
  //             ),
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: Constanst.borderStyle1,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color:
  //                         Color.fromARGB(255, 190, 190, 190).withOpacity(0.4),
  //                     spreadRadius: 1,
  //                     blurRadius: 1,
  //                     offset: Offset(1, 1), // changes position of shadow
  //                   ),
  //                 ],
  //               ),
  //               child: Padding(
  //                 padding: const EdgeInsets.only(
  //                     left: 16, top: 8, bottom: 8, right: 10),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         Expanded(
  //                           flex: 70,
  //                           child: Padding(
  //                             padding: const EdgeInsets.only(top: 5),
  //                             child: Text(
  //                               Constanst.convertDate('$tanggalPengajuan'),
  //                               style: TextStyle(
  //                                   fontWeight: FontWeight.bold, fontSize: 16),
  //                             ),
  //                           ),
  //                         ),
  //                         Expanded(
  //                           flex: 30,
  //                           child: Container(
  //                             margin: EdgeInsets.only(right: 8),
  //                             decoration: BoxDecoration(
  //                               color: status == 'Approve'
  //                                   ? Constanst.colorBGApprove
  //                                   : status == 'Approve 1'
  //                                       ? Constanst.colorBGApprove
  //                                       : status == 'Approve 2'
  //                                           ? Constanst.colorBGApprove
  //                                           : status == 'Rejected'
  //                                               ? Constanst.colorBGRejected
  //                                               : status == 'Pending'
  //                                                   ? Constanst.colorBGPending
  //                                                   : Colors.grey,
  //                               borderRadius: Constanst.borderStyle1,
  //                             ),
  //                             child: Padding(
  //                               padding: EdgeInsets.only(
  //                                   left: 3, right: 3, top: 5, bottom: 5),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   status == 'Approve'
  //                                       ? Icon(
  //                                           Iconsax.tick_square,
  //                                           color: Constanst.color5,
  //                                           size: 14,
  //                                         )
  //                                       : status == 'Approve 1'
  //                                           ? Icon(
  //                                               Iconsax.tick_square,
  //                                               color: Constanst.color5,
  //                                               size: 14,
  //                                             )
  //                                           : status == 'Approve 2'
  //                                               ? Icon(
  //                                                   Iconsax.tick_square,
  //                                                   color: Constanst.color5,
  //                                                   size: 14,
  //                                                 )
  //                                               : status == 'Rejected'
  //                                                   ? Icon(
  //                                                       Iconsax.close_square,
  //                                                       color: Constanst.color4,
  //                                                       size: 14,
  //                                                     )
  //                                                   : status == 'Pending'
  //                                                       ? Icon(
  //                                                           Iconsax.timer,
  //                                                           color: Constanst
  //                                                               .color3,
  //                                                           size: 14,
  //                                                         )
  //                                                       : SizedBox(),
  //                                   Padding(
  //                                     padding: const EdgeInsets.only(left: 3),
  //                                     child: Text(
  //                                       '$status',
  //                                       textAlign: TextAlign.center,
  //                                       style: TextStyle(
  //                                           fontWeight: FontWeight.bold,
  //                                           color: status == 'Approve'
  //                                               ? Colors.green
  //                                               : status == 'Approve 1'
  //                                                   ? Colors.green
  //                                                   : status == 'Approve 2'
  //                                                       ? Colors.green
  //                                                       : status == 'Rejected'
  //                                                           ? Colors.red
  //                                                           : status ==
  //                                                                   'Pending'
  //                                                               ? Constanst
  //                                                                   .color3
  //                                                               : Colors.black),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 5,
  //                     ),
  //                     Text(
  //                       "NO.$nomorAjuan",
  //                       textAlign: TextAlign.justify,
  //                       style: TextStyle(
  //                           fontSize: 14,
  //                           color: Constanst.colorText1,
  //                           fontWeight: FontWeight.bold),
  //                     ),
  //                     SizedBox(
  //                       height: 5,
  //                     ),
  //                     Text(
  //                       '${dariJam} sd ${sampaiJam}',
  //                       textAlign: TextAlign.justify,
  //                       style: TextStyle(
  //                           fontSize: 14, color: Constanst.colorText2),
  //                     ),
  //                     SizedBox(
  //                       height: 5,
  //                     ),
  //                     Text(
  //                       '$uraian',
  //                       textAlign: TextAlign.justify,
  //                       style: TextStyle(
  //                           fontSize: 14, color: Constanst.colorText2),
  //                     ),
  //                     SizedBox(
  //                       height: 5,
  //                     ),
  //                     Divider(
  //                       height: 5,
  //                       color: Constanst.colorText2,
  //                     ),
  //                     SizedBox(
  //                       height: 5,
  //                     ),
  //                     status == "Rejected"
  //                         ? SizedBox(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text(
  //                                   "Alasan Reject",
  //                                   style:
  //                                       TextStyle(fontWeight: FontWeight.bold),
  //                                 ),
  //                                 SizedBox(
  //                                   height: 6,
  //                                 ),
  //                                 Text(
  //                                   alasanReject,
  //                                   style: TextStyle(
  //                                       fontSize: 14,
  //                                       color: Constanst.colorText2),
  //                                 )
  //                               ],
  //                             ),
  //                           )
  //                         : Row(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             children: [
  //                               Expanded(
  //                                 child: status == "Approve" ||
  //                                         status == "Approve 1" ||
  //                                         status == "Approve 2"
  //                                     ? Row(
  //                                         crossAxisAlignment:
  //                                             CrossAxisAlignment.start,
  //                                         children: [
  //                                           Icon(
  //                                             Iconsax.tick_circle,
  //                                             color: Colors.green,
  //                                           ),
  //                                           Padding(
  //                                             padding: EdgeInsets.only(
  //                                                 left: 5, top: 3),
  //                                             child:
  //                                                 Text("Approved by $approve"),
  //                                           ),
  //                                           Padding(
  //                                             padding: EdgeInsets.only(
  //                                                 left: 5, top: 3),
  //                                             child: Text(""),
  //                                           )
  //                                         ],
  //                                       )
  //                                     : Column(
  //                                         crossAxisAlignment:
  //                                             CrossAxisAlignment.start,
  //                                         children: [
  //                                           Text(
  //                                             "Pending Approval",
  //                                             style: TextStyle(
  //                                                 color: Constanst.colorText2),
  //                                           ),
  //                                           SizedBox(
  //                                             height: 5,
  //                                           ),
  //                                           SizedBox(
  //                                             height: 5,
  //                                           ),
  //                                           Row(
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             children: [
  //                                               Image.asset(
  //                                                 'assets/whatsapp.png',
  //                                                 width: 25,
  //                                                 height: 25,
  //                                               ),
  //                                               Padding(
  //                                                 padding:
  //                                                     const EdgeInsets.only(
  //                                                         left: 6),
  //                                                 child: Padding(
  //                                                   padding:
  //                                                       const EdgeInsets.only(
  //                                                           top: 3),
  //                                                   child: InkWell(
  //                                                       onTap: () {
  //                                                         var dataEmployee = {
  //                                                           'nameType':
  //                                                               'LEMBUR',
  //                                                           'nomor_ajuan':
  //                                                               '$nomorAjuan',
  //                                                         };
  //                                                         controllerGlobal
  //                                                             .showDataPilihAtasan(
  //                                                                 dataEmployee);
  //                                                       },
  //                                                       child: Text(
  //                                                         "Konfirmasi via WA",
  //                                                         style: TextStyle(
  //                                                           decoration:
  //                                                               TextDecoration
  //                                                                   .underline,
  //                                                         ),
  //                                                       )),
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           )
  //                                         ],
  //                                       ),
  //                               ),
  //                               status == "Approve" ||
  //                                       status == "Approve 1" ||
  //                                       status == "Approve 2"
  //                                   ? SizedBox()
  //                                   : Expanded(
  //                                       child: Row(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.center,
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.center,
  //                                       children: [
  //                                         Expanded(
  //                                             child: Padding(
  //                                           padding: EdgeInsets.only(right: 10),
  //                                           child: InkWell(
  //                                             onTap: () {
  //                                               controller
  //                                                   .showModalBatalPengajuan(
  //                                                       controller.listLembur
  //                                                           .value[index]);
  //                                             },
  //                                             child: Text(
  //                                               "Batalkan",
  //                                               textAlign: TextAlign.center,
  //                                               style: TextStyle(
  //                                                   color: Colors.red),
  //                                             ),
  //                                           ),
  //                                         )),
  //                                         Expanded(
  //                                             child: Padding(
  //                                           padding: EdgeInsets.only(right: 10),
  //                                           child: Container(
  //                                             decoration: BoxDecoration(
  //                                                 borderRadius:
  //                                                     Constanst.borderStyle1,
  //                                                 border: Border.all(
  //                                                     color: Constanst
  //                                                         .colorPrimary)),
  //                                             child: InkWell(
  //                                               onTap: () {
  //                                                 Get.offAll(FormLembur(
  //                                                   dataForm: [
  //                                                     controller.listLembur
  //                                                         .value[index],
  //                                                     true
  //                                                   ],
  //                                                 ));
  //                                               },
  //                                               child: Text(
  //                                                 "Edit",
  //                                                 textAlign: TextAlign.center,
  //                                                 style: TextStyle(
  //                                                     color: Constanst
  //                                                         .colorPrimary),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         )),
  //                                       ],
  //                                     )),
  //                             ],
  //                           )
  //                   ],
  //                 ),
  //               ),
  //             )
  //           ],
  //         );
  //       });
  // }
}
