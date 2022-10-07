import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siscom_operasional/controller/auth_controller.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/screen/register.dart';
import 'package:siscom_operasional/utils/constans.dart';

class Login extends StatelessWidget {
  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Stack(
          children: [
            Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: AssetImage('assets/vector_login.png'),
                      fit: BoxFit.cover)),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Image.asset(
                          'assets/logo_login.png',
                          width: 200,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Login",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 28),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Selamat Datang di SISCOM HRIS 👋",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Ketik alamat email dan password untuk masuk",
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Email",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: controller.email.value,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: const Icon(Iconsax.sms),
                              ),
                              style: TextStyle(
                                  fontSize: 14.0,
                                  height: 2.0,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Password",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
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
                                    !this.controller.showpassword.value,
                                controller: controller.password.value,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(Iconsax.lock),
                                    // ignore: unnecessary_this
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.showpassword.value
                                            ? Iconsax.eye
                                            : Iconsax.eye_slash,
                                        color:
                                            this.controller.showpassword.value
                                                ? Constanst.colorPrimary
                                                : Colors.grey,
                                      ),
                                      onPressed: () {
                                        this.controller.showpassword.value =
                                            !this.controller.showpassword.value;
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
                          height: 5,
                        ),
                        // Container(
                        //   alignment: Alignment.centerRight,
                        //   child: Text(
                        //     "Lupa Password?",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         color: Color.fromARGB(255, 18, 134, 230)),
                        //   ),
                        // ),
                        SizedBox(
                          height: 30,
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Constanst.colorPrimary),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ))),
                          onPressed: () => controller.loginUser(),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 6, bottom: 6),
                              child: Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: Text(
                            "© Copyright 2022 PT. Shan Informasi Sistem",
                            style: TextStyle(
                                fontSize: 10, color: Constanst.color1),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width,
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Text("Belum punya akun ?"),
                        //       Padding(
                        //         padding: const EdgeInsets.only(left: 5),
                        //         child: InkWell(
                        //           onTap: () {
                        //             controller.email.value.text = "";
                        //             controller.password.value.text = "";
                        //             controller.username.value.text = "";
                        //             Get.to(Register());
                        //           },
                        //           child: Text(
                        //             "Register",
                        //             style: TextStyle(
                        //                 fontWeight: FontWeight.bold,
                        //                 color: Constanst.colorPrimary),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  ),
                )),
          ],
        )));
  }
}
