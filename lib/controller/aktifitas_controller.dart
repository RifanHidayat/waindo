import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class AktifitasController extends GetxController {
  var cari = TextEditingController().obs;

  RefreshController refreshController = RefreshController(initialRefresh: true);

  var listAktifitas = [].obs;

  var statusPencarian = false.obs;

  var limit = 10.obs;

  @override
  void onReady() async {
    loadAktifitas();
    super.onReady();
  }

  void loadAktifitas() {
    var dataUser = AppData.informasiUser;
    var getEmpid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmpid,
      'offset': listAktifitas.value.length,
      'limit': limit.value,
    };
    var connect = Api.connectionApi("post", body, "load_aktifitas");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      for (var element in valueBody['data']) {
        var getList = element['createdDate'].split('T');
        var tanggal = getList[0];
        var jam = getList[1].replaceAll('.000Z', '');
        var data = {
          'idx': element['idx'],
          'menu_name': element['menu_name'],
          'activity_name': element['activity_name'],
          'createdDate': tanggal,
          'jam': jam,
        };
        listAktifitas.value.add(data);
      }
      this.listAktifitas.refresh();
    });
  }

  void pencarianDataAktifitas() {
    statusPencarian.value = true;
    listAktifitas.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmpid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmpid,
      'cari': cari.value.text,
    };
    var connect = Api.connectionApi("post", body, "pencarian_aktifitas");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      for (var element in valueBody['data']) {
        var getList = element['createdDate'].split('T');
        var tanggal = getList[0];
        var jam = getList[1].replaceAll('.000Z', '');
        var data = {
          'idx': element['idx'],
          'menu_name': element['menu_name'],
          'activity_name': element['activity_name'],
          'createdDate': tanggal,
          'jam': jam,
        };
        listAktifitas.value.add(data);
      }
      this.listAktifitas.refresh();
      Navigator.pop(Get.context!);
      Navigator.pop(Get.context!);
    });
  }

  void cariDataAktifitas() {
    showDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Cari Data Aktifitas"),
                SizedBox(
                  height: 16,
                ),
                Container(
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
                              controller: cari.value,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Cari judul aktifitas"),
                              style: TextStyle(
                                  fontSize: 14.0,
                                  height: 1.0,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: TextButtonWidget(
                    iconShow: false,
                    title: 'Cari',
                    colorButton: Constanst.colorPrimary,
                    colortext: Colors.white,
                    border: BorderRadius.circular(15.0),
                    onTap: () {
                      if (cari.value.text == "") {
                        UtilsAlert.showToast("Isi form cari terlebih dahulu");
                      } else {
                        UtilsAlert.loadingSimpanData(
                            Get.context!, "Mencari Data...");
                        pencarianDataAktifitas();
                      }
                    },
                  ),
                )
              ]),
        );
      },
    );
  }
}
