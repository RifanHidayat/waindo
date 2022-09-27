import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siscom_operasional/controller/auth_controller.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class Register extends StatelessWidget {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/logo_login.png',
                        width: 200,
                        height: 150,
                      ),
                      Center(
                        child: Text(
                          "Registrasi",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16,),
                        ),
                      ),
                      SizedBox(
                        height: 20,
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
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            style: TextStyle(
                                fontSize: 14.0,
                                height: 2.0,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          "Username",
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
                            controller: controller.username.value,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.person),
                            ),
                            style: TextStyle(
                                fontSize: 14.0,
                                height: 2.0,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
                              obscureText: !this.controller.showpassword.value,
                              controller: controller.password.value,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(Icons.lock),
                                  // ignore: unnecessary_this
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: this.controller.showpassword.value
                                          ? Colors.blue
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
                        height: 20,
                      ),
                      TextButtonWidget(
                        title:  "Kirim",
                        onTap : () {
                          if (controller.username.value.text == "" ||
                              controller.email.value.text == "" ||
                              controller.password.value.text == "") {
                            UtilsAlert.showToast("lengkapi form di atas");
                          } else {
                            controller.registrasiAkun();
                          }
                        },
                        colorButton : Colors.blue,
                        colortext : Colors.white,
                        border : BorderRadius.circular(15.0),
                      )
                    ],
                  ),
                )),
          ],
        )));
  }
}
