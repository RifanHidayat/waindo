import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/auth_controller.dart';
import 'package:siscom_operasional/screen/absen/absen_masuk_keluar.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class AbsenVrifyPassword extends StatefulWidget {
  const AbsenVrifyPassword({super.key, this.status, this.type});
  final status, type;

  @override
  State<AbsenVrifyPassword> createState() => _AbsenVrifyPasswordState();
}

class _AbsenVrifyPasswordState extends State<AbsenVrifyPassword> {
  final controller = Get.put(AuthController());
  final TextEditingController passwordCtr = TextEditingController();

  var absensiController = Get.put(AbsenController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Constanst.colorWhite,
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: AppbarMenu1(
            title: "",
            colorTitle: Colors.black,
            colorIcon: Colors.black,
            icon: 1,
            onTap: () {
              Get.back();
            },
          )),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  "Konfirmasi Password",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
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
                        width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
                child: Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      obscureText: !this.controller.showpassword.value,
                      controller: passwordCtr,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(Iconsax.lock),
                          // ignore: unnecessary_this
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showpassword.value
                                  ? Iconsax.eye
                                  : Iconsax.eye_slash,
                              color: this.controller.showpassword.value
                                  ? Constanst.colorPrimary
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              this.controller.showpassword.value =
                                  !this.controller.showpassword.value;
                            },
                          )),
                      style: TextStyle(
                          fontSize: 14.0, height: 2.0, color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: Container(
                  height: double.maxFinite,
                  width: MediaQuery.of(context).size.width - 40,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                            flex: 50,
                            child: InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                alignment: Alignment.center,
                                child: Text("Batal"),
                              ),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 50,
                            child: InkWell(
                              onTap: () {
                                UtilsAlert.showLoadingIndicator(context);
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  Get.back();
                                  print(controller.password.value.toString());

                                  if (passwordCtr.text.toString() ==
                                      controller.password.value.text) {
                                    absensiController.absenSelfie();
                                    // UtilsAlert.showToast(
                                    //     "Konfirmasi password berhasil");
                                    return Get.to(AbsenMasukKeluar(
                                      status: widget.status,
                                      type: widget.type,
                                    ));
                                  }
                                  return UtilsAlert.showToast(
                                      "Konfirmasi password gagal");
                                });
                              },
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Constanst.colorPrimary,
                                  border: Border.all(
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Selanjutnya",
                                  style: TextStyle(color: Constanst.colorWhite),
                                ),
                              ),
                            )),
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
