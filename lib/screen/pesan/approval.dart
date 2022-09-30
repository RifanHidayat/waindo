import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/approval_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/screen/pesan/detail_approval.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class Approval extends StatefulWidget {
  String? title, bulan, tahun;
  Approval({Key? key, this.title, this.bulan, this.tahun}) : super(key: key);
  @override
  _ApprovalState createState() => _ApprovalState();
}

class _ApprovalState extends State<Approval> {
  var controller = Get.put(ApprovalController());

  @override
  void initState() {
    controller.startLoadData(widget.title, widget.bulan, widget.tahun);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: Obx(
            () => AppbarMenu1(
              title: "Menyetujui ${controller.titleAppbar.value}",
              colorTitle: Colors.white,
              colorIcon: Colors.white,
              iconShow: true,
              icon: 1,
              onTap: () {
                var pesanController = Get.find<PesanController>();
                pesanController.loadApproveInfo();
                pesanController.loadApproveHistory();
                Get.back();
              },
            ),
          )),
      body: WillPopScope(
          onWillPop: () async {
            var pesanController = Get.find<PesanController>();
            pesanController.loadApproveInfo();
            pesanController.loadApproveHistory();
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
                      height: 10,
                    ),
                    // pencarianData(),
                    // SizedBox(
                    //   height: 16,
                    // ),
                    Flexible(
                        flex: 3,
                        child: controller.listData.value.isEmpty
                            ? Center(
                                child: Text(controller.loadingString.value),
                              )
                            : listDataApproval())
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget pencarianData() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: Constanst.borderStyle2,
          border: Border.all(color: Constanst.colorNonAktif)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(top: 7, left: 10),
              child: Icon(Iconsax.search_normal),
            ),
          ),
          Expanded(
            flex: 85,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: controller.cari.value,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Cari"),
                  style: TextStyle(
                      fontSize: 14.0, height: 1.0, color: Colors.black),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget listDataApproval() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: controller.listData.value.length,
        itemBuilder: (context, index) {
          var idx = controller.listData.value[index]['id'];
          var namaPengaju = controller.listData.value[index]['nama_pengaju'];
          var typeAjuan = controller.listData.value[index]['type'];
          var tanggalPengajuan =
              controller.listData.value[index]['waktu_pengajuan'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              Text("${Constanst.convertDate2("$tanggalPengajuan")}"),
              SizedBox(
                height: 8,
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
                                color: Constanst.colorBGPending,
                                borderRadius: Constanst.borderStyle1,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 3, right: 3, top: 5, bottom: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.timer,
                                      color: Constanst.color3,
                                      size: 14,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: Text(
                                        'Pending',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Constanst.color3),
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
                          Get.to(DetailApproval(
                            title: typeAjuan,
                            idxDetail: "$idx",
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Constanst.colorPrimary,
                              borderRadius: Constanst.borderStyle2),
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
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }
}
