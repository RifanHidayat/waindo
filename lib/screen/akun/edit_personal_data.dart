import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/setting_controller.dart';
import 'package:siscom_operasional/screen/akun/personal_info.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class EditPersonalInfo extends StatelessWidget {
  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Constanst.coloBackgroundScreen,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Edit Personal Info",
            icon: 1,
            colorTitle: Colors.black,
            onTap: () {
              Get.offAll(PersonalInfo());
            },
          )),
      body: WillPopScope(
        onWillPop: () async {
          Get.offAll(PersonalInfo());
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
                      height: 30,
                    ),
                    Center(
                      child: Image.asset(
                        'assets/avatar_default.png',
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Expanded(
                    //       flex: 12,
                    //       child: Padding(
                    //         padding: const EdgeInsets.only(top: 16),
                    //         child: Icon(Iconsax.personalcard),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       flex: 88,
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         mainAxisAlignment: MainAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             "Nomor Identitas",
                    //             style: TextStyle(color: Constanst.colorText1),
                    //           ),
                    //           TextField(
                    //             controller: controller.nomorIdentitas.value,
                    //             decoration: InputDecoration(
                    //               border: InputBorder.none,
                    //             ),
                    //             style: TextStyle(
                    //                 fontSize: 14.0,
                    //                 height: 1.0,
                    //                 color: Colors.black),
                    //           ),
                    //         ],
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 10),
                    //   child: Divider(
                    //     height: 5,
                    //     color: Constanst.colorNonAktif,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
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
                                flex: 45,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nama Depan",
                                      style: TextStyle(
                                          color: Constanst.colorText1),
                                    ),
                                    TextField(
                                      controller: controller.fullName.value,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          height: 1.0,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  color: Color(0xffF8FAFF),
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
                                        "Nama Belakang",
                                        style: TextStyle(
                                            color: Constanst.colorText1),
                                      ),
                                      TextField(
                                        controller:
                                            controller.namaBelakang.value,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            height: 1.0,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
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
                              // controller.tanggalLahir.value == "${controller.user.value?[0].em_birthday}" ? Text("${controller.user.value?[0].em_birthday}") :
                              DateTimeField(
                                format: DateFormat('dd-MM-yyyy'),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                controller: controller.tanggalLahir.value,
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1800),
                                    lastDate: DateTime(2200),
                                    initialDate: currentValue ?? DateTime.now(),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      ],
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
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Expanded(
                    //       flex: 12,
                    //       child: Padding(
                    //         padding: const EdgeInsets.only(top: 16),
                    //         child: Icon(Iconsax.sms),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       flex: 88,
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         mainAxisAlignment: MainAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             "Email",
                    //             style: TextStyle(color: Constanst.colorText1),
                    //           ),
                    //           TextField(
                    //             controller: controller.email.value,
                    //             decoration: InputDecoration(
                    //               border: InputBorder.none,
                    //             ),
                    //             style: TextStyle(
                    //                 fontSize: 14.0,
                    //                 height: 1.0,
                    //                 color: Colors.black),
                    //           ),
                    //         ],
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 10),
                    //   child: Divider(
                    //     height: 5,
                    //     color: Constanst.colorNonAktif,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
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
                              TextField(
                                controller: controller.telepon.value,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    height: 1.0,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      ],
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
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isDense: true,
                                        items: controller
                                            .jenisKelaminDropdown.value
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          );
                                        }).toList(),
                                        value: controller.jenisKelamin.value,
                                        onChanged: (selectedValue) {
                                          controller.jenisKelamin.value =
                                              selectedValue!;
                                        },
                                        isExpanded: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  color: Color(0xffF8FAFF),
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
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isDense: true,
                                          items: controller
                                              .golonganDarahDropdown.value
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                          value: controller.golonganDarah.value,
                                          onChanged: (selectedValue) {
                                            controller.golonganDarah.value =
                                                selectedValue!;
                                          },
                                          isExpanded: true,
                                        ),
                                      ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Constanst.colorPrimary),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.white)))),
          onPressed: () {
            controller.editDataPersonalInfo();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 14),
            child: Text('Simpan Data'),
          ),
        ),
      ),
    );
  }
}
