// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/setting_controller.dart';
import 'package:siscom_operasional/screen/akun/edit_password.dart';
import 'package:siscom_operasional/screen/akun/face_recognigration.dart';
import 'package:siscom_operasional/screen/akun/info_karyawan.dart';
import 'package:siscom_operasional/screen/akun/personal_info.dart';
import 'package:siscom_operasional/screen/akun/pusat_bantuan.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final controller = Get.put(SettingController());
  final controllerDashboard = Get.put(DashboardController());

  Future<void> refreshData() async {
    controller.refreshPageStatus.value = true;
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      var dashboardController = Get.find<DashboardController>();
      dashboardController.updateInformasiUser();
      controller.onReady();
      controller.refreshPageStatus.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Stack(
            children: [
              Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        alignment: Alignment.topCenter,
                        image: AssetImage('assets/bg_dashboard.png'),
                        fit: BoxFit.cover)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex:
                          controllerDashboard.tinggiHp.value > 740.0 ? 20 : 25,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Obx(() => firstLine()),
                        ],
                      ),
                    ),
                    Expanded(
                      flex:
                          controllerDashboard.tinggiHp.value > 740.0 ? 80 : 75,
                      child: SizedBox(
                        child: RefreshIndicator(
                          onRefresh: refreshData,
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Perusahaan",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Constanst.colorText1),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, right: 5, top: 15),
                                  child: lineInfoPengguna(),
                                ),
                                Text(
                                  "Pengaturan",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Constanst.colorText1),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, right: 5, top: 15),
                                  child: lineKeamananAkun(),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, right: 5, top: 0),
                                  child: faceRegistration(),
                                ),
                                Text(
                                  "Lainnya",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Constanst.colorText1),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, right: 5, top: 15),
                                  child: lineLainnya(),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      overlayColor: MaterialStateProperty.all<
                                              Color>(
                                          Color.fromARGB(255, 255, 200, 196)),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(color: Colors.red),
                                        ),
                                      )),
                                  onPressed: () {
                                    controller.logout();
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Keluar",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Icon(
                                          Iconsax.logout,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text(
                                    "© Copyright 2022 PT. Shan Informasi Sistem",
                                    style: TextStyle(
                                        color: Constanst.colorText1,
                                        fontSize: 10),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget firstLine() {
    return controller.refreshPageStatus.value
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UtilsAlert.shimmerInfoPersonal(Get.context!),
              SizedBox(
                height: 50,
              )
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 20,
                child: controllerDashboard.user.value[0]['em_image'] == null ||
                        controllerDashboard.user.value[0]['em_image'] == ""
                    ? Image.asset(
                        'assets/avatar_default.png',
                      )
                    : CircleAvatar(
                        radius: 35, // Image radius
                        child: ClipOval(
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: Api.UrlfotoProfile +
                                  "${controllerDashboard.user.value[0]['em_image']}",
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Container(
                                alignment: Alignment.center,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                width: MediaQuery.of(context).size.width,
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress),
                              ),
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                            ),
                          ),
                        ),
                      ),
              ),
              Expanded(
                  flex: 80,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${controllerDashboard.user.value[0]['full_name']}",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                "${controllerDashboard.user.value[0]['emp_jobTitle']}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Constanst.colorButton2,
                                    borderRadius: Constanst.borderStyle1),
                                child: Center(
                                  child: Text(
                                    "${controllerDashboard.user.value[0]['em_status']}",
                                    style:
                                        TextStyle(color: Constanst.colorText3),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${controllerDashboard.user.value[0]['em_id']}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ))
            ],
          );
  }

  Widget lineInfoPengguna() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Get.to(InfoKaryawan()),
          highlightColor: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.people,
                        color: Constanst.colorPrimary,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Info Karyawan",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      )
                    ],
                  )),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 10,
          color: Constanst.colorNonAktif,
        ),
        SizedBox(
          height: 15,
        ),
        InkWell(
          onTap: () => Get.to(PersonalInfo()),
          highlightColor: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.personalcard,
                        color: Constanst.colorPrimary,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Personal Info",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      )
                    ],
                  )),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 10,
          color: Constanst.colorNonAktif,
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget lineKeamananAkun() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Get.to(EditPassword()),
          highlightColor: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.unlock,
                        color: Constanst.colorPrimary,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Ubah Kata Sandi",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      )
                    ],
                  )),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 10,
          color: Constanst.colorNonAktif,
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget faceRegistration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Get.to(FaceRecognition()),
          highlightColor: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/face-recognition-hitam.png",
                        width: 24,
                        height: 24,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Data Pengenalan Wajah",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              GetStorage().read('face_recog') == false
                                  ? Text(
                                      "Belum Registrasi",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.red),
                                    )
                                  : Text(
                                      "Sudah Registrasi",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.blue),
                                    ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 10,
          color: Constanst.colorNonAktif,
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget lineLainnya() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Get.to(PusatBantuan()),
          highlightColor: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        color: Constanst.colorPrimary,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Pusat Bantuan",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      )
                    ],
                  )),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 10,
          color: Constanst.colorNonAktif,
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
