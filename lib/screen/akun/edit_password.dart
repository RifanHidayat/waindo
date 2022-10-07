// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/setting_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class EditPassword extends StatelessWidget {
  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Constanst.colorPrimary,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Edit Password",
            colorTitle: Colors.white,
            colorIcon: Colors.white,
            icon: 1,
            onTap: () {
              Get.back();
            },
          )),
      body: WillPopScope(
          onWillPop: () async {
            Get.back();
            return true;
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Text("Password Lama"),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          border: Border.all(
                              width: 0.5,
                              color: Color.fromARGB(255, 211, 205, 205))),
                      child: Obx(
                        () => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            obscureText:
                                !this.controller.showpasswordLama.value,
                            controller: controller.passwordLama.value,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: const Icon(Iconsax.lock),
                                // ignore: unnecessary_this
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Iconsax.eye,
                                    color:
                                        this.controller.showpasswordLama.value
                                            ? Constanst.colorPrimary
                                            : Colors.grey,
                                  ),
                                  onPressed: () {
                                    this.controller.showpasswordLama.value =
                                        !this.controller.showpasswordLama.value;
                                  },
                                )),
                            style: TextStyle(
                                fontSize: 14.0,
                                height: 2.0,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Password Baru"),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          border: Border.all(
                              width: 0.5,
                              color: Color.fromARGB(255, 211, 205, 205))),
                      child: Obx(
                        () => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            obscureText:
                                !this.controller.showpasswordBaru.value,
                            controller: controller.passwordBaru.value,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: const Icon(Iconsax.lock),
                                // ignore: unnecessary_this
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Iconsax.eye,
                                    color:
                                        this.controller.showpasswordBaru.value
                                            ? Constanst.colorPrimary
                                            : Colors.grey,
                                  ),
                                  onPressed: () {
                                    this.controller.showpasswordBaru.value =
                                        !this.controller.showpasswordBaru.value;
                                  },
                                )),
                            style: TextStyle(
                                fontSize: 14.0,
                                height: 2.0,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextButtonWidget(
                      title: "Simpan",
                      onTap: () {
                        showGeneralDialog(
                          barrierDismissible: false,
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
                                // our custom dialog
                                title: "Peringatan",
                                content: "Yakin ganti password ?",
                                positiveBtnText: "Simpan",
                                negativeBtnText: "Kembali",
                                style: 1,
                                buttonStatus: 1,
                                positiveBtnPressed: () {
                                  controller.ubahPassword();
                                },
                              ),
                            );
                          },
                          pageBuilder: (BuildContext context,
                              Animation animation,
                              Animation secondaryAnimation) {
                            return null!;
                          },
                        );
                      },
                      colorButton: Constanst.colorPrimary,
                      colortext: Constanst.colorWhite,
                      border: BorderRadius.circular(8.0),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
