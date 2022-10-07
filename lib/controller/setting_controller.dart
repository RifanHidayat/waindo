import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/model/user_model.dart';
import 'package:siscom_operasional/screen/akun/edit_personal_data.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/login.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class SettingController extends GetxController {
  var fotoUser = File("").obs;

  Rx<List<String>> jenisKelaminDropdown = Rx<List<String>>([]);
  Rx<List<String>> golonganDarahDropdown = Rx<List<String>>([]);

  var nomorIdentitas = TextEditingController().obs;
  var fullName = TextEditingController().obs;
  var namaBelakang = TextEditingController().obs;
  var tanggalLahir = TextEditingController().obs;
  var email = TextEditingController().obs;
  var telepon = TextEditingController().obs;
  var cari = TextEditingController().obs;

  var passwordLama = TextEditingController().obs;
  var passwordBaru = TextEditingController().obs;

  var jenisKelamin = "".obs;
  var golonganDarah = "".obs;
  var base64fotoUser = "".obs;

  var showpasswordLama = false.obs;
  var showpasswordBaru = false.obs;
  var refreshPageStatus = false.obs;

  var listPusatBantuan = [].obs;

  var dataJenisKelamin = ["PRIA", "WANITA"];
  var dataGolonganDarah = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'OB+'];

  @override
  void onReady() async {
    toRouteSimpanData();
    getPusatBantuan();
    super.onReady();
  }

  logout() {
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
            content: "Yakin Keluar Akun",
            positiveBtnText: "Keluar",
            negativeBtnText: "Kembali",
            style: 1,
            buttonStatus: 1,
            positiveBtnPressed: () {
              aksiEditLastLogin();
            },
          ),
        );
      },
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return null!;
      },
    );
  }

  void aksiEditLastLogin() {
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'last_login': '0000-00-00 00:00:00',
      'em_id': getEmid
    };
    var connect = Api.connectionApi("post", body, "edit_last_login");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        print(valueBody['data']);
        AppData.informasiUser = null;
        Get.offAll(Login());
      }
    });
  }

  void toRouteSimpanData() {
    jenisKelaminDropdown.value.clear();
    golonganDarahDropdown.value.clear();
    for (var element in dataJenisKelamin) {
      jenisKelaminDropdown.value.add(element);
    }
    this.jenisKelaminDropdown.refresh();
    for (var element in dataGolonganDarah) {
      golonganDarahDropdown.value.add(element);
    }
    this.golonganDarahDropdown.refresh();
    var date =
        Constanst.convertDate1("${AppData.informasiUser![0].em_birthday}");
    nomorIdentitas.value.text = "${AppData.informasiUser![0].em_id}";
    fullName.value.text = "${AppData.informasiUser![0].full_name}";
    tanggalLahir.value.text = "$date";
    email.value.text = "${AppData.informasiUser![0].em_email}";
    telepon.value.text = "${AppData.informasiUser![0].em_phone}";

    jenisKelamin.value = "${AppData.informasiUser![0].em_gender}";
    golonganDarah.value = "${AppData.informasiUser![0].em_blood_group}";
  }

  void editDataPersonalInfo() {
    var convertTanggalSimpan =
        Constanst.convertDateSimpan(tanggalLahir.value.text);
    UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
    Map<String, dynamic> body = {
      'val': 'em_code',
      'cari': nomorIdentitas.value.text,
      'full_name': fullName.value.text,
      'em_birthday': convertTanggalSimpan,
      'em_email': email.value.text,
      'em_phone': telepon.value.text,
      'em_gender': jenisKelamin.value,
      'em_blood_group': golonganDarah.value
    };
    var connect = Api.connectionApi("post", body, "edit-employee");
    connect.then((dynamic res) async {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        List<UserModel> getData = <UserModel>[];
        var data = UserModel(
            em_id: "${AppData.informasiUser![0].em_id}",
            full_name: fullName.value.text,
            em_email: email.value.text,
            em_phone: telepon.value.text,
            em_birthday: convertTanggalSimpan,
            em_gender: jenisKelamin.value,
            em_blood_group: golonganDarah.value,
            emp_jobTitle: "${AppData.informasiUser![0].emp_jobTitle}",
            emp_departmen: "${AppData.informasiUser![0].emp_departmen}",
            emp_att_working: AppData.informasiUser![0].emp_att_working);
        getData.add(data);
        AppData.informasiUser = getData;
        Navigator.pop(Get.context!);
        UtilsAlert.berhasilSimpanData(Get.context!, "Data Berhasil diubah");
        await Future.delayed(const Duration(seconds: 3));
        Navigator.pop(Get.context!);
        Get.offAll(InitScreen());
      }
    });
  }

  void ubahPassword() {
    if (passwordLama.value.text == "" || passwordBaru.value.text == "") {
      UtilsAlert.showToast("Lengkapi form");
    } else {
      var dataUser = AppData.informasiUser;
      var getEmid = dataUser![0].em_id;
      UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
      Map<String, dynamic> body = {
        'em_id': getEmid,
        'password_lama': passwordLama.value.text,
        'password_baru': passwordBaru.value.text
      };
      var connect = Api.connectionApi("post", body, "validasiGantiPassword");
      connect.then((dynamic res) async {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == false) {
            Navigator.pop(Get.context!);
            UtilsAlert.showToast(valueBody['message']);
          } else {
            Navigator.pop(Get.context!);
            UtilsAlert.berhasilSimpanData(Get.context!, "Data Berhasil diubah");
            await Future.delayed(const Duration(seconds: 2));
            Navigator.pop(Get.context!);
            Get.offAll(InitScreen());
          }
        }
      });
    }
  }

  void getPusatBantuan() {
    listPusatBantuan.value.clear();
    var connect = Api.connectionApi("get", {}, "faq");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          for (var element in valueBody['data']) {
            var data = {
              'idx': element['idx'],
              'question': element['question'],
              'answered': element['answered'],
              'status': false
            };
            listPusatBantuan.value.add(data);
          }
          this.listPusatBantuan.refresh();
        }
      }
    });
  }

  void changeStatusPusatBantuan(id) {
    listPusatBantuan.value.forEach((element) {
      if (element['idx'] == id) {
        if (element['status'] == false) {
          element['status'] = true;
        } else {
          element['status'] = false;
        }
      } else {
        element['status'] = false;
      }
    });
    this.listPusatBantuan.refresh();
  }

  // void validasigantiFoto() {
  //   showDialog(
  //     context: Get.context!,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(15.0))),
  //           content: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Center(
  //                   child: Text(
  //                     "Ubah Foto",
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: [
  //                     Expanded(
  //                         child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: TextButtonWidget2(
  //                           title: "Camera",
  //                           onTap: () {
  //                             Navigator.pop(Get.context!);
  //                             ubahFotoCamera();
  //                           },
  //                           colorButton: Constanst.colorPrimary,
  //                           colortext: Constanst.colorWhite,
  //                           border: BorderRadius.circular(5.0),
  //                           icon: Icon(
  //                             Iconsax.camera,
  //                             size: 18,
  //                             color: Constanst.colorWhite,
  //                           )),
  //                     )),
  //                     Expanded(
  //                         child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: TextButtonWidget2(
  //                           title: "Galery",
  //                           onTap: () {
  //                             Navigator.pop(Get.context!);
  //                             ubahFotoGalery();
  //                           },
  //                           colorButton: Constanst.colorPrimary,
  //                           colortext: Constanst.colorWhite,
  //                           border: BorderRadius.circular(5.0),
  //                           icon: Icon(
  //                             Iconsax.gallery_edit,
  //                             size: 18,
  //                             color: Constanst.colorWhite,
  //                           )),
  //                     ))
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //               ]));
  //     },
  //   );
  // }

  void validasigantiFoto() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 90,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8, top: 5),
                              child: Text(
                                "Ubah Foto Profile",
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
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(Get.context!);
                        ubahFotoCamera();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.camera,
                            color: Constanst.colorPrimary,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18, top: 3),
                            child: Text(
                              "Buka Kamera",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Constanst.colorText3),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(Get.context!);
                        ubahFotoGalery();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.gallery_add,
                            color: Constanst.colorPrimary,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18, top: 3),
                            child: Text(
                              "Pilih dari Galeri",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Constanst.colorText3),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            )
          ],
        );
      },
    );
  }

  void ubahFotoCamera() async {
    fotoUser.value = File("");
    base64fotoUser.value = "";
    final getFoto = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 100,
        maxHeight: 350,
        maxWidth: 350);
    if (getFoto == null) {
      UtilsAlert.showToast("Gagal mengambil gambar");
    } else {
      fotoUser.value = File(getFoto.path);
      var bytes = File(getFoto.path).readAsBytesSync();
      base64fotoUser.value = base64Encode(bytes);
      aksiGantiFoto();
    }
  }

  void ubahFotoGalery() async {
    fotoUser.value = File("");
    base64fotoUser.value = "";
    this.fotoUser.refresh();
    this.base64fotoUser.refresh();
    final getFoto = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxHeight: 350,
        maxWidth: 350);
    if (getFoto == null) {
      UtilsAlert.showToast("Gagal mengambil gambar");
    } else {
      fotoUser.value = File(getFoto.path);
      var bytes = File(getFoto.path).readAsBytesSync();
      base64fotoUser.value = base64Encode(bytes);
      aksiGantiFoto();
    }
  }

  void aksiGantiFoto() {
    UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan");
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'created_by': getEmid,
      'base64_foto_profile': base64fotoUser.value,
      'menu_name': "Setting Profile",
      'activity_name': "Mengganti foto profile",
    };
    var connect = Api.connectionApi("post", body, "edit_foto_user");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var getImage = valueBody['nama_file'];
        List<UserModel> getData = <UserModel>[];
        var data = UserModel(
          em_id: "${dataUser[0].em_id}",
          des_id: dataUser[0].des_id,
          dep_id: dataUser[0].dep_id,
          full_name: "${dataUser[0].full_name}",
          em_email: "${dataUser[0].em_email}",
          em_phone: "${dataUser[0].em_phone}",
          em_birthday: "${dataUser[0].em_birthday}",
          em_gender: "${dataUser[0].em_gender}",
          em_image: "$getImage",
          em_joining_date: "${dataUser[0].em_joining_date}",
          em_status: "${dataUser[0].em_status}",
          em_blood_group: "${dataUser[0].em_blood_group}",
          emp_jobTitle: "${dataUser[0].emp_jobTitle}",
          emp_departmen: "${dataUser[0].emp_departmen}",
          emp_att_working: dataUser[0].emp_att_working,
        );
        getData.add(data);
        AppData.informasiUser = getData;
        Navigator.pop(Get.context!);
        Get.offAll(InitScreen());
        UtilsAlert.showToast("Foto profile berhasil diubah");
      }
    });
  }
}
