import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';

class PhotoAbsen extends StatelessWidget {
  var image, time, alamat, type, note;
  PhotoAbsen(
      {super.key, this.image, this.time, this.alamat, this.type, this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Constanst.coloBackgroundScreen,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Detail Absen",
            icon: 1,
            colorTitle: Colors.black,
            onTap: () {
              Get.back();
            },
          )),
      body: DraggableBottomSheet(
        minExtent: 30,
        useSafeArea: true,
        curve: Curves.easeIn,
        previewWidget: _previewWidget(),
        expandedWidget: _expandedWidget(),
        backgroundWidget: _backgroundWidget(),
        duration: const Duration(milliseconds: 10),
        maxExtent: MediaQuery.of(context).size.height * 0.5,
        barrierColor: Colors.transparent,
        onDragging: (pos) {},
      ),
    );
  }

  Widget _backgroundWidget() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Foto"),
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(Icons.close))
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: HexColor('#035446'),
              width: MediaQuery.of(Get.context!).size.width,
              height: double.maxFinite,
              child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: image != ''
                      ? Image.network(
                          image,
                          fit: BoxFit.fill,
                        )
                      : Image.asset(
                          'assets/foto.png',
                          fit: BoxFit.fill,
                        )),
            ),
          )
        ],
      ),
    );
  }

  Widget _expandedWidget() {
    return Container(
      color: HexColor('#11151E').withOpacity(0.25),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(Get.context!).size.width / 4,
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    type == 'keluar'
                        ? Icon(
                            Iconsax.logout,
                            color: Colors.red,
                            size: 24,
                          )
                        : Icon(
                            Iconsax.login,
                            color: Colors.green,
                            size: 24,
                          ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        time ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    )
                  ],
                ),
                Container(
                  decoration: Constanst.styleBoxDecoration2(Colors.white),
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      type == 'keluar' ? "Absen Keluar" : "Absen Masuk",
                      textAlign: TextAlign.center,
                      style: type == "keluar"
                          ? Constanst.colorRedBold
                          : Constanst.colorGreenBold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.location_tick,
                  size: 24,
                  color: Colors.white,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 3, left: 3),
                        child: Text(
                          "Lokasi",
                          style: TextStyle(color: Colors.white),
                        )),
                    Container(
                      width: MediaQuery.of(Get.context!).size.width - 100,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 3, left: 3),
                          child: Text(
                            "$alamat",
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          )),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.note_text,
                    size: 24,
                    color: Colors.white,
                  ),
                  Container(
                    width: MediaQuery.of(Get.context!).size.width - 100,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3, left: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Catatan",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            note ?? '-',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewWidget() {
    return Container(
      width: MediaQuery.of(Get.context!).size.width,
      height: 50,
      color: HexColor('#11151E').withOpacity(0.25),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: MediaQuery.of(Get.context!).size.width / 4,
              height: 5,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2), color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
