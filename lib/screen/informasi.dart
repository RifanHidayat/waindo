// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class Informasi extends StatelessWidget {
  final controller = Get.put(DashboardController());
  var controllerGlobal = Get.put(GlobalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Constanst.colorPrimary,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Informasi",
            colorTitle: Colors.white,
            colorIcon: Colors.white,
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
                    lineTitle(),
                    SizedBox(
                      height: 20,
                    ),
                    Flexible(
                      flex: 3,
                      child: pageViewPesan(),
                    )
                  ],
                ),
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
                "Informasi",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: controller.selectedInformasiView.value == 0
                        ? Constanst.colorPrimary
                        : Constanst.colorText2,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
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
                "Ulang Tahun",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: controller.selectedInformasiView.value == 1
                        ? Constanst.colorPrimary
                        : Constanst.colorText2,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
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
                "Tidak Hadir",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: controller.selectedInformasiView.value == 2
                        ? Constanst.colorPrimary
                        : Constanst.colorText2,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget pageViewPesan() {
    return PageView.builder(
        physics: BouncingScrollPhysics(),
        controller: controller.informasiController,
        onPageChanged: (index) {
          controller.selectedInformasiView.value = index;
          this.controller.selectedInformasiView.refresh();
        },
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.all(0),
              child: index == 0
                  ? screenInformasi()
                  : index == 1
                      ? screenUltah()
                      : index == 2
                          ? screenTidakHadir()
                          : SizedBox());
        });
  }

  Widget screenInformasi() {
    return ListView.builder(
        itemCount: controller.informasiDashboard.value.length,
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          var title = controller.informasiDashboard.value[index]['title'];
          var desc = controller.informasiDashboard.value[index]['description'];
          var create = controller.informasiDashboard.value[index]['created_on'];
          return Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 50,
                      child: Text(
                        "$title",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Constanst.colorText3),
                      ),
                    ),
                    Expanded(
                      flex: 50,
                      child: Text(
                        Constanst.convertDate("$create"),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Constanst.colorText2),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Html(
                  data: desc,
                  style: {
                    "body": Style(
                      fontSize: FontSize(14),
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
                )
              ],
            ),
          );
        });
  }

  Widget screenUltah() {
    return controller.employeeUltah.value.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "Tidak ada karyawan yang berulang tahun pada hari ini",
                textAlign: TextAlign.center,
              ),
            ),
          )
        : ListView.builder(
            itemCount: controller.employeeUltah.value.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              var fullname = controller.employeeUltah.value[index]['full_name'];
              var jobtitle = controller.employeeUltah.value[index]['job_title'];
              var tanggalLahir =
                  controller.employeeUltah.value[index]['em_birthday'];
              var nowa = controller.employeeUltah.value[index]['em_mobile'];
              var image = controller.employeeUltah.value[index]['em_image'];
              var listTanggalLahir = tanggalLahir.split('-');

              return Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 15,
                            child: image == ""
                                ? Image.asset(
                                    'assets/avatar_default.png',
                                    width: 50,
                                    height: 50,
                                  )
                                : Center(
                                    child: CircleAvatar(
                                      radius: 25, // Image radius
                                      child: ClipOval(
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                Api.UrlfotoProfile + "${image}",
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Container(
                                              alignment: Alignment.center,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/avatar_default.png',
                                              width: 50,
                                              height: 50,
                                            ),
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Expanded(
                            flex: 85,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 60,
                                        child: Text(
                                          "$fullname",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 40,
                                        child: Text(
                                          "${Constanst.convertDateBulanDanHari('${listTanggalLahir[1]}-${listTanggalLahir[2]}')}",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 60,
                                        child: Text(
                                          "$jobtitle",
                                          style: TextStyle(
                                              color: Constanst.colorText2),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 40,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Image.asset(
                                                'assets/whatsapp.png',
                                                width: 18,
                                                height: 18,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6),
                                                child: InkWell(
                                                    onTap: () {
                                                      var message =
                                                          "Selamat Ulang Tahun $fullname, ";
                                                      var nomorUltah = "$nowa";
                                                      controllerGlobal
                                                          .kirimUcapanWa(
                                                              message,
                                                              nomorUltah);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 3),
                                                      child: Text(
                                                        "Beri ucapan",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                ],
                              ),
                            ),
                          )
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
                    )
                  ],
                ),
              );
            });
  }

  Widget screenTidakHadir() {
    return controller.employeeTidakHadir.value.isEmpty
        ? Center(
            child: Text(
              "Semua karyawan hadir pada hari ini",
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            itemCount: controller.employeeTidakHadir.value.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              var fullname =
                  controller.employeeTidakHadir.value[index]['full_name'];
              var jobtitle =
                  controller.employeeTidakHadir.value[index]['job_title'];
              return Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "$fullname",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "$jobtitle",
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
                    )
                  ],
                ),
              );
            });
  }
}
