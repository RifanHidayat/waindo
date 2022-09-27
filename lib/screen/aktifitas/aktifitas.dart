// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:siscom_operasional/controller/aktifitas_controller.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class Aktifitas extends StatelessWidget {
  final controller = Get.put(AktifitasController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Aktifitas",
            colorTitle: Colors.white,
            icon: 2,
            onTap: () {
              controller.cari.value.text = "";
              controller.cariDataAktifitas();
            },
          )),
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
                                                      flex: 40,
                                                      child: Text(
                                                        namaMenu,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                  Expanded(
                                                      flex: 60,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 2),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              Constanst
                                                                  .convertDate2(
                                                                      createdDate),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Constanst
                                                                      .colorText2,
                                                                  fontSize: 12),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5),
                                                              child: Text(jam,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Constanst
                                                                          .colorText2,
                                                                      fontSize:
                                                                          12)),
                                                            )
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Text(namaAktifitas),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Divider(
                                                height: 5,
                                                color: Constanst.colorText2,
                                              ),
                                              SizedBox(
                                                height: 10,
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
                                                  flex: 40,
                                                  child: Text(
                                                    namaMenu,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 60,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          Constanst
                                                              .convertDate2(
                                                                  createdDate),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Constanst
                                                                  .colorText2,
                                                              fontSize: 12),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: Text(jam,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Constanst
                                                                      .colorText2,
                                                                  fontSize:
                                                                      12)),
                                                        )
                                                      ],
                                                    ),
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Text(namaAktifitas),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Divider(
                                            height: 5,
                                            color: Constanst.colorText2,
                                          ),
                                          SizedBox(
                                            height: 10,
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
}
