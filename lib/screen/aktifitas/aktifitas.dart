// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:siscom_operasional/controller/aktifitas_controller.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:scroll_navigation/scroll_navigation.dart';

class Aktifitas extends StatelessWidget {
  final controller = Get.put(AktifitasController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Constanst.colorPrimary,
          elevation: 2,
          flexibleSpace: appbarSetting()),
      body: WillPopScope(
          onWillPop: () async {
            return false;
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
                    AnimatedOpacity(
                        opacity: controller.visibleWidget.value ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: controller.visibleWidget.value
                            ? SizedBox()
                            : dashboardAktifitas()),
                    !controller.visibleWidget.value
                        ? SizedBox()
                        : SizedBox(
                            height: 16,
                          ),
                    Text(
                      "Log Aktifitas",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Constanst.colorText3),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    controller.statusPencarian.value == false
                        ? SizedBox()
                        : Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 90,
                                    child: Text(
                                        "Pencarian data : #${controller.cari.value.text}")),
                                Expanded(
                                  flex: 10,
                                  child: InkWell(
                                      onTap: () {
                                        controller.statusPencarian.value =
                                            false;
                                        controller.statusFormPencarian.value =
                                            false;
                                        controller.listAktifitas.value.clear();
                                        controller.loadAktifitas();
                                      },
                                      child: Icon(
                                        Iconsax.close_circle,
                                        size: 20,
                                        color: Colors.red,
                                      )),
                                )
                              ],
                            ),
                          ),
                    Flexible(
                        flex: 3,
                        child: controller.listAktifitas.value.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/amico.png",
                                        height: 250,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Anda belum memiliki aktifitas"),
                                    ],
                                  ),
                                ),
                              )
                            : controller.statusPencarian.value == false
                                ? SmartRefresher(
                                    enablePullDown: true,
                                    enablePullUp: true,
                                    header: MaterialClassicHeader(),
                                    onRefresh: () async {
                                      await Future.delayed(
                                          Duration(milliseconds: 1000));
                                      controller.listAktifitas.value.clear();
                                      controller.loadAktifitas();
                                      controller.refreshController
                                          .refreshCompleted();
                                    },
                                    onLoading: () async {
                                      await Future.delayed(
                                          Duration(milliseconds: 1000));
                                      controller.loadAktifitas();
                                      controller.refreshController
                                          .loadComplete();
                                    },
                                    controller: controller.refreshController,
                                    child: ListView.builder(
                                        itemCount: controller
                                            .listAktifitas.value.length,
                                        controller: controller.controllerScroll,
                                        itemBuilder: (context, index) {
                                          var namaMenu = controller
                                              .listAktifitas
                                              .value[index]['menu_name'];
                                          var namaAktifitas = controller
                                              .listAktifitas
                                              .value[index]['activity_name'];
                                          var createdDate = controller
                                              .listAktifitas
                                              .value[index]['createdDate'];
                                          var jam = controller.listAktifitas
                                              .value[index]['jam'];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      flex: 10,
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Color
                                                                    .fromARGB(
                                                                        24,
                                                                        0,
                                                                        22,
                                                                        103)),
                                                        child: Center(
                                                            child: Icon(
                                                          Iconsax.document_code,
                                                          size: 18,
                                                          color: Constanst
                                                              .colorPrimary,
                                                        )),
                                                      )),
                                                  Expanded(
                                                    flex: 75,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8, top: 5),
                                                      child: Text("$namaMenu"),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 15,
                                                    child: Text(
                                                      "${Constanst.convertDate4('$createdDate')} $jam",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          color: Constanst
                                                              .colorText2,
                                                          fontSize: 10),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 10,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Container(
                                                          width: 2,
                                                          color: Color.fromARGB(
                                                              24, 0, 22, 103),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 90,
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8),
                                                          child: Text(
                                                              "$namaAktifitas")),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                          );
                                        }))
                                : ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    itemCount:
                                        controller.listAktifitas.value.length,
                                    itemBuilder: (context, index) {
                                      var namaMenu = controller.listAktifitas
                                          .value[index]['menu_name'];
                                      var namaAktifitas = controller
                                          .listAktifitas
                                          .value[index]['activity_name'];
                                      var createdDate = controller.listAktifitas
                                          .value[index]['createdDate'];
                                      var jam = controller
                                          .listAktifitas.value[index]['jam'];
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 10,
                                                  child: Container(
                                                    height: 30,
                                                    width: 30,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color.fromARGB(
                                                            24, 0, 22, 103)),
                                                    child: Center(
                                                        child: Icon(
                                                      Iconsax.document_code,
                                                      size: 18,
                                                      color: Constanst
                                                          .colorPrimary,
                                                    )),
                                                  )),
                                              Expanded(
                                                flex: 75,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, top: 5),
                                                  child: Text("$namaMenu"),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 15,
                                                child: Text(
                                                  "${Constanst.convertDate4('$createdDate')} $jam",
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      color:
                                                          Constanst.colorText2,
                                                      fontSize: 10),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 10,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      width: 3,
                                                      color: Color.fromARGB(
                                                          24, 0, 22, 103),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 90,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8),
                                                      child: Text(
                                                          "$namaAktifitas")),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      );
                                    }))
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget dashboardAktifitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 60,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Kehadiran",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Constanst.colorText3),
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
                          // controller.loadDataTugasLuar();
                        }
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: Constanst.borderStyle2,
                        border: Border.all(color: Constanst.colorText2)),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.calendar_1,
                            size: 16,
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
        ),
        SizedBox(
          height: 8,
        ),
        GridView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            itemCount: controller.infoAktifitas.value.length,
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              var id = controller.infoAktifitas.value[index]['id'];
              var title = controller.infoAktifitas.value[index]['nama'];
              var jumlah = controller.infoAktifitas.value[index]['jumlah'];
              return Card(
                elevation: 2,
                child: ClipPath(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: id == "1"
                                    ? Color(0xff2F80ED)
                                    : id == "2"
                                        ? Color(0xffF2AA0D)
                                        : id == "3"
                                            ? Color(0xffFF463D)
                                            : id == "4"
                                                ? Color(0xff14B156)
                                                : id == "5"
                                                    ? Color(0xffFF806D)
                                                    : id == "6"
                                                        ? Color(0xffACD9FD)
                                                        : Colors.white,
                                width: 8))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(jumlah),
                          SizedBox(
                            height: 5,
                          ),
                          Text(title),
                        ],
                      ),
                    ),
                  ),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              );
            }),
        SizedBox(
          height: 8,
        ),
        Container(
          decoration: BoxDecoration(
              color: Color(0xffE6FCE6),
              borderRadius: Constanst.borderStyle2,
              border: Border.all(color: Color(0xff14B156))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularPercentIndicator(
                  radius: 30.0,
                  lineWidth: 4.0,
                  percent: 0.80,
                  center: new Text("80%"),
                  progressColor: Color(0xff14B156),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Absen tepat waktu",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Dari 1 Oktober sd 30 Oktober 2022",
                        style: TextStyle(color: Constanst.colorText2),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget appbarSetting() {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 30,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    "Aktivitas",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )),
          Expanded(
              flex: 70,
              child: Container(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12, right: 8),
                    child: controller.statusFormPencarian.value
                        ? Container(
                            width: MediaQuery.of(Get.context!).size.width,
                            margin: EdgeInsets.all(0),
                            padding: EdgeInsets.all(0),
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: InkWell(
                                          onTap: () {
                                            controller.statusFormPencarian
                                                .value = false;
                                            this
                                                .controller
                                                .statusFormPencarian
                                                .refresh();
                                          },
                                          child: Icon(
                                            Iconsax.close_circle,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      )),
                                  Expanded(
                                    flex: 80,
                                    child: SizedBox(
                                      height: 30,
                                      child: TextField(
                                        controller: controller.cari.value,
                                        decoration: InputDecoration(
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            hintText: "Cari judul aktifitas"),
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            height: 1.0,
                                            color: Colors.white),
                                        onSubmitted: (value) {
                                          if (controller.cari.value.text ==
                                              "") {
                                            UtilsAlert.showToast(
                                                "Isi form cari terlebih dahulu");
                                          } else {
                                            UtilsAlert.loadingSimpanData(
                                                Get.context!,
                                                "Mencari Data...");
                                            controller.pencarianDataAktifitas();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: InkWell(
                                          onTap: () {
                                            if (controller.cari.value.text ==
                                                "") {
                                              UtilsAlert.showToast(
                                                  "Isi form cari terlebih dahulu");
                                            } else {
                                              UtilsAlert.loadingSimpanData(
                                                  Get.context!,
                                                  "Mencari Data...");
                                              controller
                                                  .pencarianDataAktifitas();
                                            }
                                          },
                                          child: Icon(
                                            Iconsax.search_normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () => controller.showInputCari(),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Icon(
                                Iconsax.search_normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ))),
        ],
      ),
    );
  }
}
