import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';

class UtilsAlert {
  static showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        timeInSecForIosWeb: 5,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 12);
  }

  static showLoadingIndicator(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Padding(
                          child: CircularProgressIndicator(strokeWidth: 3),
                          padding: EdgeInsets.all(8)),
                      Padding(
                          child: Text(
                            'Tunggu Sebentar …',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          padding: EdgeInsets.all(8))
                    ],
                  )
                ]));
      },
    );
  }

  static informasiDashboard(BuildContext context) {
    var informasiRadius = AppData.infoSettingApp;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 90,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Constanst.colorButton2),
                              child: Center(
                                  child: Icon(
                                Iconsax.message_question,
                                size: 20,
                                color: Constanst.colorPrimary,
                              )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8, top: 5),
                              child: Text(
                                "Info",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(Get.context!);
                            },
                            child: Icon(
                              Iconsax.close_circle,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    "Jarak radius untuk melakukan absen masuk dan keluar adalah ${informasiRadius![0].radius} m",
                    style: TextStyle(color: Constanst.colorText2, fontSize: 14),
                  )
                ]));
      },
    );
  }

  static loadingSimpanData(BuildContext context, text) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 20,
                        child: Padding(
                            child: CircularProgressIndicator(strokeWidth: 3),
                            padding: EdgeInsets.all(8)),
                      ),
                      Expanded(
                        flex: 80,
                        child: Padding(
                            child: Text(
                              text,
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            padding: EdgeInsets.all(8)),
                      )
                    ],
                  )
                ]));
      },
    );
  }

  static berhasilSimpanData(BuildContext context, text) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 20,
                        child: Padding(
                            child: Icon(
                              Iconsax.tick_circle,
                              color: Constanst.colorPrimary,
                            ),
                            padding: EdgeInsets.all(8)),
                      ),
                      Expanded(
                        flex: 80,
                        child: Padding(
                            child: Text(
                              text,
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            padding: EdgeInsets.all(8)),
                      )
                    ],
                  )
                ]));
      },
    );
  }

  static shimmerInfoPersonal(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: 20,
                            width: 100,
                            child: Card(child: ListTile(title: Text('')))),
                        SizedBox(
                            height: 20,
                            width: 100,
                            child: Card(child: ListTile(title: Text('')))),
                      ],
                    ),
                  )
                ],
              )
            ],
          )),
    );
  }

  static shimmerMenuDashboard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(
                        height: 30,
                        width: 100,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(
                        height: 30,
                        width: 100,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                ],
              ),
              Row(children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 10),
                    child: SizedBox(
                        height: 50,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 10),
                    child: SizedBox(
                        height: 50,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 10),
                    child: SizedBox(
                        height: 50,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 10),
                    child: SizedBox(
                        height: 50,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                )
              ]),
              Row(children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 5, top: 5),
                    child: SizedBox(
                        height: 50,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 5, top: 5),
                    child: SizedBox(
                        height: 50,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 5, top: 5),
                    child: SizedBox(
                        height: 50,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 5, top: 5),
                    child: SizedBox(
                        height: 50,
                        child: Card(child: ListTile(title: Text('')))),
                  ),
                )
              ]),
              // SizedBox(
              //   height: 10,
              // ),
              // SizedBox(
              //   height: 100,
              //   child: Padding(
              //     padding: const EdgeInsets.only(left: 16, right: 16),
              //     child: Card(child: ListTile(title: Text(''))),
              //   ),
              // )
            ],
          )),
    );
  }

  static shimmerBannerDashboard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: SizedBox(
            height: 100,
            child: Card(child: ListTile(title: Text(''))),
          )),
    );
  }

  static koneksiBuruk() {
    showGeneralDialog(
      context: Get.context!,
      barrierColor: Colors.black54, // space around dialog
      transitionDuration: Duration(milliseconds: 200),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
            scale: CurvedAnimation(
                parent: a1,
                curve: Curves.elasticOut,
                reverseCurve: Curves.easeOutCubic),
            child: CustomDialog(
              title: "Peringatan",
              content: "Terjadi kesalahan",
              positiveBtnText: "",
              negativeBtnText: "",
              style: 1,
              buttonStatus: 1,
              positiveBtnPressed: () {
                Navigator.of(context).pop();
              },
            ));
      },
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return null!;
      },
    );
  }
}
