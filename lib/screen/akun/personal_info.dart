import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:siscom_operasional/controller/setting_controller.dart';
import 'package:siscom_operasional/screen/akun/edit_personal_data.dart';
import 'package:siscom_operasional/screen/akun/setting.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class PersonalInfo extends StatelessWidget {
  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Personal Info",
            icon: 1,
            colorTitle: Colors.black,
            onTap: () {
              Get.back();
            },
          )),
      body: WillPopScope(
        onWillPop: () async {
          Get.back();
          return true;
        },
        child: SizedBox(
          width: MediaQuery.of(Get.context!).size.width,
          child: Obx(
            () => Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Stack(
                      children: [
                        Center(
                          child: controller.user.value![0].em_image == null ||
                                  controller.user.value![0].em_image == ""
                              ? Image.asset(
                                  'assets/avatar_default.png',
                                )
                              : CircleAvatar(
                                  radius: 60, // Image radius
                                  child: ClipOval(
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: Api.UrlfotoProfile +
                                            "${controller.user.value![0].em_image}",
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                Container(
                                          alignment: Alignment.center,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                        ),
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 150,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 110),
                            child: InkWell(
                                onTap: () {
                                  controller.validasigantiFoto();
                                },
                                child: Icon(
                                  Iconsax.camera,
                                  size: 25,
                                )),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Iconsax.personalcard),
                          ),
                        ),
                        Expanded(
                          flex: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Nomor Identitas",
                                style: TextStyle(color: Constanst.colorText1),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${controller.user.value?[0].em_id}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Iconsax.user),
                          ),
                        ),
                        Expanded(
                          flex: 88,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nama Lengkap",
                                      style: TextStyle(
                                          color: Constanst.colorText1),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${controller.user.value?[0].full_name}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Iconsax.calendar_circle),
                          ),
                        ),
                        Expanded(
                          flex: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Tanggal Lahir",
                                style: TextStyle(color: Constanst.colorText1),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${Constanst.convertDate("${controller.user.value?[0].em_birthday}")}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Iconsax.sms),
                          ),
                        ),
                        Expanded(
                          flex: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Email",
                                style: TextStyle(color: Constanst.colorText1),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${controller.user.value?[0].em_email}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Iconsax.call),
                          ),
                        ),
                        Expanded(
                          flex: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Telepon",
                                style: TextStyle(color: Constanst.colorText1),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${controller.user.value?[0].em_phone}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Iconsax.man),
                          ),
                        ),
                        Expanded(
                          flex: 88,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 45,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Jenis Kelamin",
                                      style: TextStyle(
                                          color: Constanst.colorText1),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${controller.user.value?[0].em_gender}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  color: Color(0xffE9EDF5),
                                ),
                              ),
                              Expanded(
                                flex: 54,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Golongan Darah",
                                        style: TextStyle(
                                            color: Constanst.colorText1),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "${controller.user.value?[0].em_blood_group}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Iconsax.calendar_circle),
                          ),
                        ),
                        Expanded(
                          flex: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Tanggal Bergabung",
                                style: TextStyle(color: Constanst.colorText1),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${Constanst.convertDate("${controller.user.value?[0].em_joining_date}")}",
                                // "${controller.user.value?[0].em_joining_date}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Iconsax.status),
                          ),
                        ),
                        Expanded(
                          flex: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Status",
                                style: TextStyle(color: Constanst.colorText1),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${controller.user.value?[0].em_status}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: Padding(
      //     padding: EdgeInsets.all(16.0),
      //     child: TextButtonWidget2(
      //         title: "Ubah Data",
      //         onTap: () {
      //           Get.offAll(EditPersonalInfo());
      //         },
      //         colorButton: Colors.blue,
      //         colortext: Constanst.colorWhite,
      //         border: BorderRadius.circular(10.0),
      //         icon: Icon(
      //           Iconsax.edit_2,
      //           color: Constanst.colorWhite,
      //           size: 18,
      //         ))),
    );
  }
}
