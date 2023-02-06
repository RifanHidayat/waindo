import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/bpjs.dart';
import 'package:siscom_operasional/model/menu_dashboard_model.dart';
import 'package:google_maps_utils/google_maps_utils.dart';
import 'package:siscom_operasional/model/user_model.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/screen/absen/form/form_tidakMasukKerja.dart';
import 'package:siscom_operasional/screen/absen/form/form_tugas_luar.dart';
import 'package:siscom_operasional/screen/absen/history_absen.dart';
import 'package:siscom_operasional/screen/absen/lembur.dart';
import 'package:siscom_operasional/screen/absen/tidak_masuk_kerja.dart';
import 'package:siscom_operasional/screen/absen/tugas_luar.dart';
import 'package:siscom_operasional/screen/absen/form/form_pengajuan_cuti.dart';
import 'package:siscom_operasional/screen/absen/riwayat_cuti.dart';
import 'package:siscom_operasional/screen/absen/izin.dart';
import 'package:siscom_operasional/screen/bpjs/bpjs_kesehatan.dart';
import 'package:siscom_operasional/screen/bpjs/bpjs_ketenagakerjaan.dart';
import 'package:siscom_operasional/screen/diskusi/ruang_diskusi.dart';
import 'package:siscom_operasional/screen/kandidat/form_kandidat.dart';
import 'package:siscom_operasional/screen/kandidat/list_kandidat.dart';
import 'package:siscom_operasional/screen/klaim/form_klaim.dart';
import 'package:siscom_operasional/screen/klaim/riwayat_klaim.dart';
import 'package:siscom_operasional/screen/slip_gaji/slip_gaji.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class DashboardController extends GetxController {
  CarouselController corouselDashboard = CarouselController();
  PageController menuController = PageController(initialPage: 0);
  PageController informasiController = PageController(initialPage: 0);

  var bpjsController = Get.put(BpjsController());

  var controllerAbsensi = Get.put(AbsenController());

  var user = [].obs;
  var menuDashboard = <MenuDashboardModel>[].obs;
  var bannerDashboard = [].obs;
  var finalMenu = [].obs;
  var informasiDashboard = [].obs;
  var employeeUltah = [].obs;
  var employeeTidakHadir = [].obs;
  var menuShowInMain = [].obs;

  var timeString = "".obs;
  var dateNow = "".obs;

  var selectedPageView = 0.obs;
  var indexBanner = 0.obs;
  var heightPageView = 0.0.obs;
  var heightbanner = 0.0.obs;
  var ratioDevice = 0.0.obs;
  var tinggiHp = 0.0.obs;
  var selectedInformasiView = 0.obs;

  var deviceStatus = false.obs;
  var refreshPagesStatus = false.obs;
  var viewInformasiSisaKontrak = false.obs;

  List sortcardPengajuan = [
    {"id": 1, "nama_pengajuan": "Pengajuan Lembur"},
    {"id": 2, "nama_pengajuan": "Pengajuan Cuti"},
    {"id": 3, "nama_pengajuan": "Pengajuan Tugas Luar"},
    {"id": 4, "nama_pengajuan": "Pengajuan Izin"},
    {"id": 5, "nama_pengajuan": "Pengajuan Klaim"},
    {"id": 6, "nama_pengajuan": "Pengajuan Kandidat"},
  ];

  @override
  void onInit() async {
    getUserInfo();
    getBannerDashboard();
    getMenuDashboard();
    loadMenuShowInMain();
    getInformasiDashboard();
    getEmployeeBelumAbsen();
    timeString.value = formatDateTime(DateTime.now());
    dateNow.value = dateNoww(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    getSizeDevice();
    checkStatusPermission();
    // checkHakAkses();
    super.onInit();
  }

  void kirimNotification({
    title,
    body,
    token,
    bulan,
    tahun,
  }) async {}

  void getUserInfo() {
    var userTampung = AppData.informasiUser!
        .map((element) => {
              'em_id': element.em_id,
              'des_id': element.des_id,
              'dep_id': element.dep_id,
              'full_name': element.full_name,
              'em_email': element.em_email,
              'em_phone': element.em_phone,
              'em_birthday': element.em_birthday,
              'em_gender': element.em_gender,
              'em_image': element.em_image,
              'em_joining_date': element.em_joining_date,
              'em_status': element.em_status,
              'em_blood_group': element.em_blood_group,
              'posisi': element.posisi,
              'emp_jobTitle': element.emp_jobTitle,
              'emp_departmen': element.emp_departmen,
              'em_control': element.em_control,
              'emp_att_working': element.emp_att_working,
              'em_hak_akses': element.em_hak_akses
            })
        .toList();
    user.value = userTampung;
    this.user.refresh();
    refreshPagesStatus.value = false;
  }

  void checkHakAkses() {
    var dataUser = AppData.informasiUser;
    var hakAkses = dataUser![0].em_hak_akses;
    print("ini hak akses $hakAkses");
    if (hakAkses == "") {
      viewInformasiSisaKontrak.value = false;
    } else {
      viewInformasiSisaKontrak.value = true;
    }
    print('ini status sisa kontrak $viewInformasiSisaKontrak');
    this.viewInformasiSisaKontrak.refresh();
  }

  void checkStatusPermission() {
    var statusCamera = Permission.camera.status;
    statusCamera.then((value) {
      if (value != PermissionStatus.granted) {
        widgetButtomSheetAktifCamera('loadfirst');
      } else {
        var statusLokasi = Permission.location.status;
        statusLokasi.then((value) {
          if (value != PermissionStatus.granted) {
            widgetButtomSheetAktifCamera('loadfirst');
          }
        });
      }
    });
  }

  void updateInformasiUser() {
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {'em_id': getEmid};
    var connect = Api.connectionApi("post", body, "refresh_employee");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      if (valueBody['status'] == false) {
        UtilsAlert.showToast(valueBody['message']);
        Navigator.pop(Get.context!);
      } else {
        AppData.informasiUser = null;
        List<UserModel> getData = [];
        for (var element in valueBody['data']) {
          var data = UserModel(
            em_id: element['em_id'] ?? "",
            des_id: element['des_id'] ?? 0,
            dep_id: element['dep_id'] ?? 0,
            dep_group: element['dep_group'] ?? 0,
            full_name: element['full_name'] ?? "",
            em_email: element['em_email'] ?? "",
            em_phone: element['em_phone'] ?? "",
            em_birthday: element['em_birthday'] ?? "1999-09-09",
            em_gender: element['em_gender'] ?? "",
            em_image: element['em_image'] ?? "",
            em_joining_date: element['em_joining_date'] ?? "1999-09-09",
            em_status: element['em_status'] ?? "",
            em_blood_group: element['em_blood_group'] ?? "",
            posisi: element['posisi'] ?? "",
            emp_jobTitle: element['emp_jobTitle'] ?? "",
            emp_departmen: element['emp_departmen'] ?? "",
            em_control: element['em_control'] ?? 0,
            em_control_acess: element['em_control_access'] ?? 0,
            emp_att_working: element['emp_att_working'] ?? 0,
            em_hak_akses: element['em_hak_akses'] ?? "",
          );
          print(element['posisi']);
          getData.add(data);
        }
        AppData.informasiUser = getData;
        print("Selesai update data");
        getUserInfo();
      }
    });
  }

  void getMenuDashboard() {
    finalMenu.value.clear();
    var connect = Api.connectionApi("get", {}, "getMenu");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var temporary = valueBody['data'];
          temporary.firstWhere((element) => element['index'] == 0)['status'] =
              true;
          finalMenu.value = temporary;
          // var dataFinal = [];
          // for (var element in temporary) {
          //   var convert = [];
          //   for (var element1 in element['menu']) {
          //     convert.add(element1);
          //   }
          //   if (convert.length > 3) {
          //     var lengthMenu = convert.length;
          //     var hitung = lengthMenu - 3;
          //     int howMany = hitung;
          //     convert.length = convert.length - howMany;
          //     convert.add({'nama_menu': 'Menu Lainnya', 'gambar': 'menu_lainnya.png'});
          //     var data = {
          //       'index': element['index'],
          //       'nama_modul': element['nama_modul'],
          //       'status': element['status'],
          //       'menu': convert
          //     };
          //     dataFinal.add(data);
          //   } else {
          //     var data = {
          //       'index': element['index'],
          //       'nama_modul': element['nama_modul'],
          //       'status': element['status'],
          //       'menu': convert
          //     };
          //     dataFinal.add(data);
          //   }
          // }
          // print(dataFinal);
        }
      }
    });
  }

  void getSizeDevice() {
    double width = MediaQuery.of(Get.context!).size.width;
    double height = MediaQuery.of(Get.context!).size.height;
    tinggiHp.value = height;
    if (width <= 395.0 || width <= 425.0) {
      print("kesini mobile kecil");
      deviceStatus.value = false;
      heightbanner.value = 120.0;
      heightPageView.value = 155.0;
      ratioDevice.value = 2.0;
    } else if (width >= 425.0) {
      print("kesini mobile besar");
      heightbanner.value = 200.0;
      heightPageView.value = 180.0;
      ratioDevice.value = 3.0;
      deviceStatus.value = true;
    }
    print("lebar $width");
  }

  void loadMenuShowInMain() {
    menuShowInMain.value.clear();
    var connect = Api.connectionApi("get", {}, "menu_dashboard");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var temporary = valueBody['data'];
          temporary.firstWhere((element) => element['index'] == 0)['status'] =
              true;
          menuShowInMain.value = temporary;
        }
      }
    });
  }

  void getInformasiDashboard() {
    var connect = Api.connectionApi("get", {}, "notice");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var data = valueBody['data'];
          var filter1 = [];
          var dt = DateTime.now();
          for (var element in data) {
            DateTime dt2 = DateTime.parse("${element['end_date']}");
            if (dt2.isBefore(dt)) {
            } else {
              filter1.add(element);
            }
          }
          filter1.sort((a, b) => b['begin_date']
              .toUpperCase()
              .compareTo(a['begin_date'].toUpperCase()));
          informasiDashboard.value = filter1;
          getEmployeeUltah(dt);
        }
      }
    });
  }

  void getEmployeeUltah(dt) {
    var tanggal = "${DateFormat('yyyy-MM-dd').format(dt)}";
    Map<String, dynamic> body = {
      'dateNow': tanggal,
    };
    var connect = Api.connectionApi("post", body, "informasi_employee_ultah");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        employeeUltah.value = valueBody['data'];
        this.employeeUltah.refresh();
      }
    });
  }

  void getEmployeeBelumAbsen() {
    var dt = DateTime.now();
    var tanggal = "${DateFormat('yyyy-MM-dd').format(dt)}";
    Map<String, dynamic> body = {'atten_date': tanggal, 'status': "0"};
    var connect = Api.connectionApi("post", body, "load_laporan_belum_absen");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        List data = valueBody['data'];
        print("data pengajuan" + valueBody['data_pengajuan1'].toString());
        data.addAll(valueBody['data_pengajuan1']);
        data.addAll(valueBody['data_pengajuan2']);
        data.sort((a, b) => a['full_name']
            .toUpperCase()
            .compareTo(b['full_name'].toUpperCase()));
        employeeTidakHadir.value = data;
        this.employeeTidakHadir.refresh();
      }
    });
  }

  // void getMenuDashboard() {
  //   print("jalan 1");
  //   var connect = Api.connectionApi("get", {}, "menu_dashboard");
  //   connect.then((dynamic res) {
  //     if (res == false) {
  //       UtilsAlert.koneksiBuruk();
  //     } else {
  //       if (res.statusCode == 200) {
  //         var valueBody = jsonDecode(res.body);
  //         List<MenuDashboardModel> getData = [];
  //         for (var element in valueBody['data']) {
  //           var data = MenuDashboardModel(
  //               gambar: element['gambar'], title: element['title']);
  //           getData.add(data);
  //         }
  //         menuDashboard.value = getData;
  //         this.menuDashboard.refresh();
  //       }
  //     }
  //   });
  // }

  void getBannerDashboard() {
    bannerDashboard.value.clear();
    // var connect = Api.connectionApi("get", {}, "banner_dashboard");
    var connect = Api.connectionApi("get", {}, "banner_from_finance");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          bannerDashboard.value = valueBody['data'];
          this.bannerDashboard.refresh();
        }
      }
    });
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = formatDateTime(now);
    timeString.value = formattedDateTime;
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String dateNoww(DateTime dateTime) {
    var hari = DateFormat('EEEE').format(dateTime);
    var convertHari = Constanst.hariIndo(hari);
    var tanggal = DateFormat('dd MMMM yyyy').format(dateTime);
    return "$convertHari, $tanggal";
  }

  bool validasiAbsenMasukUser() {
    return user.value[0]['emp_att_working'] == 0 ? true : false;
  }

  Future<bool> radiusNotOpen() async {
    UtilsAlert.showLoadingIndicator(Get.context!);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var latUser = position.latitude;
    var langUser = position.longitude;
    // var latUser = -6.1716917;
    // var langUser = 106.7305503;
    var from = Point(latUser, langUser);

    var settingInformation = AppData.infoSettingApp;

    var stringLatLang = settingInformation![0].longlat_comp;

    var defaultRadius = "${settingInformation[0].radius}";

    var listLatLang = (stringLatLang!.split(','));
    var latDefault = listLatLang[0];
    var langDefault = listLatLang[1];
    var to = Point(double.parse(latDefault), double.parse(langDefault));

    double distance = SphericalUtils.computeDistanceBetween(from, to);
    print('Distance: $distance meters');
    var filter = double.parse((distance).toStringAsFixed(0));
    if (filter <= double.parse(defaultRadius)) {
      Navigator.pop(Get.context!);
      UtilsAlert.showToast("Silahkan absen");
      return true;
    } else {
      Navigator.pop(Get.context!);
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
              title: "Info",
              content:
                  "Jarak radius untuk melakukan absen adalah $defaultRadius m",
              positiveBtnText: "",
              negativeBtnText: "OK",
              style: 2,
              buttonStatus: 2,
              positiveBtnPressed: () {},
            ),
          );
        },
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return null!;
        },
      );
      return false;
    }
  }

  void changePageModul(page) {
    selectedPageView.value = page;
    for (var element in menuShowInMain.value) {
      if (element['index'] == page) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    }
    bool checkMenu = checkJumlahMenu(page);
    if (checkMenu) {
      if (deviceStatus.value == false) {
        heightPageView.value = 155.0;
      } else {
        heightPageView.value = 180.0;
      }
    } else {
      if (deviceStatus.value == false) {
        heightPageView.value = 90.0;
      } else {
        heightPageView.value = 90.0;
      }
    }
    // menuController.animateToPage(page,
    //     duration: const Duration(milliseconds: 300), curve: Curves.decelerate);
    menuController.jumpToPage(page);
    this.menuShowInMain.refresh();
    this.heightPageView.refresh();
  }

  bool checkJumlahMenu(page) {
    bool? status;
    menuShowInMain.forEach((element) {
      if (element['index'] == page) {
        var hitung = element['menu'].length;
        if (hitung > 4) {
          status = true;
        } else {
          status = false;
        }
      }
    });
    return status!;
  }

  void routePageDashboard(url) {
    print(url);
    if (url == "HistoryAbsen") {
      Get.offAll(HistoryAbsen());
    } else if (url == "TidakMasukKerja") {
      Get.offAll(TidakMasukKerja());
    } else if (url == "Lembur") {
      Get.offAll(Lembur());
    } else if (url == "FormPengajuanCuti") {
      Get.to(FormPengajuanCuti(
        dataForm: [[], false],
      ));
    } else if (url == "RiwayatCuti") {
      Get.offAll(RiwayatCuti());
    } else if (url == "Izin") {
      Get.offAll(Izin());
    } else if (url == "TugasLuar") {
      Get.offAll(TugasLuar());
    } else if (url == "Klaim") {
      Get.offAll(Klaim());
    } else if (url == "FormKlaim") {
      Get.to(FormKlaim(
        dataForm: [[], false],
      ));
    } else if (url == "Kandidat") {
      var dataUser = AppData.informasiUser;
      var getHakAkses = dataUser![0].em_hak_akses;
      if (getHakAkses == "" || getHakAkses == null || getHakAkses == "null") {
        UtilsAlert.showToast('Maaf anda tidak memiliki akses menu ini');
      } else {
        Get.offAll(Kandidat());
      }
    } else if (url == "SlipGaji") {
      Get.to(SlipGaji());
    } else if (url == "BpjsKesehatan") {
      if (bpjsController.bpjsKesehatanNumber.value == "" ||
          bpjsController.bpjsKesehatanNumber.value == null) {
        UtilsAlert.showToast(
            "Nomor BPJS anda belum tersedia,harap hubungi HRD");
      } else {
        Get.to(BpjsKesehatan());
      }
    } else if (url == "BpjsTenagaKerja") {
      if (bpjsController.BpjsKetenagakerjaanNumber.value == "" ||
          bpjsController.BpjsKetenagakerjaanNumber.value == null) {
        UtilsAlert.showToast(
            "Nomor BPJS anda belum tersedia,harap hubungi HRD");
      } else {
        Get.to(BpjsKetenagakerjaan());
      }
    } else if (url == "lainnya") {
      widgetButtomSheetMenuLebihDetail();
    } else {
      UtilsAlert.showToast("Tahap Development");
    }
  }

  void routeSortcartForm(id) {
    if (id == 1) {
      Get.to(FormLembur(
        dataForm: [[], false],
      ));
    } else if (id == 2) {
      Get.to(FormPengajuanCuti(
        dataForm: [[], false],
      ));
    } else if (id == 3) {
      Get.to(FormTugasLuar(
        dataForm: [[], false],
      ));
    } else if (id == 4) {
      Get.to(FormTidakMasukKerja(
        dataForm: [[], false],
      ));
    } else if (id == 5) {
      Get.to(FormKlaim(
        dataForm: [[], false],
      ));
    } else if (id == 6) {
      var dataUser = AppData.informasiUser;
      var getHakAkses = dataUser![0].em_hak_akses;
      if (getHakAkses == "" || getHakAkses == null || getHakAkses == "null") {
        UtilsAlert.showToast('Maaf anda tidak memiliki akses menu ini');
      } else {
        Get.to(FormKandidat(
          dataForm: [[], false],
        ));
      }
    } else {
      UtilsAlert.showToast("Tahap Development");
    }
  }

  void widgetButtomSheetAktifCamera(type) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            type == "checkTracking"
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child:
                                        Image.asset("assets/vector_camera.png"),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Image.asset("assets/vector_map.png"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        type == "checkTracking"
                            ? SizedBox(
                                child: Column(
                                  children: [
                                    Text(
                                      "Aktifkan Lokasi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Di latar belakang",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                "Aktifkan Kamera dan Lokasi",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        type == "checkTracking"
                            ? Text(
                                "SISCOM HRIS mengumpulkan data lokasi untuk mengaktifkan Absensi & Tracking bahkan jika aplikasi ditutup atau tidak digunakan.",
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                "Aplikasi ini memerlukan akses pada kamera dan lokasi pada perangkat Anda",
                                textAlign: TextAlign.center,
                              ),
                        SizedBox(
                          height: 30,
                        ),
                        TextButtonWidget(
                          title: "Lanjutkan",
                          onTap: () async {
                            if (type == "checkTracking") {
                              print('kesini');
                              Get.back();
                              controllerAbsensi.kirimDataAbsensi();
                            } else {
                              Navigator.pop(context);
                              await Permission.camera.request();
                              await Permission.location.request();
                            }
                          },
                          colorButton: Constanst.colorButton1,
                          colortext: Constanst.colorWhite,
                          border: BorderRadius.circular(15.0),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 30,
            )
          ],
        );
      },
    );
  }

  void widgetButtomSheetFormPengajuan() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 90,
                    child: Text(
                      "Buat Pengajuan",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(Get.context!);
                        },
                        child: Icon(Iconsax.close_circle)),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Divider(
                height: 5,
                color: Constanst.colorText2,
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: sortcardPengajuan.length,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      var id = sortcardPengajuan[index]['id'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: InkWell(
                          highlightColor: Colors.white,
                          onTap: () {
                            routeSortcartForm(id);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 10,
                                child: id == 1
                                    ? Icon(
                                        Iconsax.clock,
                                        color: Constanst.colorPrimary,
                                      )
                                    : id == 2
                                        ? Icon(
                                            Iconsax.calendar_remove,
                                            color: Constanst.colorPrimary,
                                          )
                                        : id == 3
                                            ? Icon(
                                                Iconsax.send_2,
                                                color: Constanst.colorPrimary,
                                              )
                                            : id == 4
                                                ? Icon(
                                                    Iconsax.clipboard_close,
                                                    color:
                                                        Constanst.colorPrimary,
                                                  )
                                                : id == 5
                                                    ? Icon(
                                                        Iconsax.receipt_2,
                                                        color: Constanst
                                                            .colorPrimary,
                                                      )
                                                    : id == 6
                                                        ? Icon(
                                                            Iconsax
                                                                .profile_2user,
                                                            color: Constanst
                                                                .colorPrimary,
                                                          )
                                                        : SizedBox(),
                              ),
                              Expanded(
                                flex: 80,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    sortcardPengajuan[index]['nama_pengajuan'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Constanst.colorText3),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 10,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Constanst.colorText2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        );
      },
    );
  }

  void widgetButtomSheetMenuLebihDetail() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            Api.UrlgambarDashboard + "lainnya.png",
                            width: 25,
                            height: 25,
                            color: Constanst.colorPrimary,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 2),
                            child: Text(
                              "Semua Menu",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(Get.context!);
                          },
                          child: Icon(Iconsax.close_circle)),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Divider(
                height: 5,
                color: Constanst.colorText2,
              ),
              SizedBox(
                height: 10,
              ),
              Flexible(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: BouncingScrollPhysics(),
                      itemCount: finalMenu.value.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              finalMenu.value[index]['nama_modul'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    itemCount:
                                        finalMenu.value[index]['menu'].length,
                                    scrollDirection: Axis.vertical,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                    ),
                                    itemBuilder: (context, idxMenu) {
                                      var gambar = finalMenu[index]['menu']
                                          [idxMenu]['gambar'];
                                      var url = finalMenu[index]['menu']
                                          [idxMenu]['url'];
                                      var namaMenu = finalMenu[index]['menu']
                                          [idxMenu]['nama_menu'];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          routePageDashboard(url);
                                        },
                                        highlightColor: Colors.white,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              gambar != ""
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                          color: Constanst
                                                              .colorButton2,
                                                          borderRadius: Constanst
                                                              .styleBoxDecoration1
                                                              .borderRadius),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 3,
                                                                right: 3,
                                                                top: 3,
                                                                bottom: 3),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              Api.UrlgambarDashboard +
                                                                  gambar,
                                                          progressIndicatorBuilder:
                                                              (context, url,
                                                                      downloadProgress) =>
                                                                  Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.5,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: CircularProgressIndicator(
                                                                value: downloadProgress
                                                                    .progress),
                                                          ),
                                                          fit: BoxFit.cover,
                                                          width: 32,
                                                          height: 32,
                                                          color: Constanst
                                                              .colorPrimary,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      color: Constanst
                                                          .colorButton2,
                                                      height: 32,
                                                      width: 32,
                                                    ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Center(
                                                child: Text(
                                                  namaMenu.length > 20
                                                      ? namaMenu.substring(
                                                              0, 20) +
                                                          '...'
                                                      : namaMenu,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Constanst.colorText3),
                                                ),
                                              ),
                                            ]),
                                      );
                                    })),
                            Divider(
                              height: 5,
                              color: Constanst.colorText2,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
