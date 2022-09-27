import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:siscom_operasional/model/absen_model.dart';
import 'package:siscom_operasional/screen/absen/berhasil_absen.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:google_maps_utils/google_maps_utils.dart';
import 'package:trust_location/trust_location.dart';

class AbsenController extends GetxController {
  TextEditingController deskripsiAbsen = TextEditingController();
  var tanggalLaporan = TextEditingController().obs;
  var departemen = TextEditingController().obs;

  var fotoUser = File("").obs;

  var settingAppInfo = AppData.infoSettingApp.obs;

  Rx<List<String>> placeCoordinateDropdown = Rx<List<String>>([]);
  var selectedType = "".obs;

  var historyAbsen = <AbsenModel>[].obs;
  var placeCoordinate = [].obs;
  var departementAkses = [].obs;
  var listLaporanFilter = [].obs;
  var allListLaporanFilter = [].obs;
  var absenSelected;

  var loading = "Memuat data...".obs;
  var base64fotoUser = "".obs;
  var timeString = "".obs;
  var dateNow = "".obs;
  var alamatUserFoto = "".obs;
  var titleAbsen = "".obs;
  var tanggalUserFoto = "".obs;
  var stringImageSelected = "".obs;
  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var namaDepartemenTerpilih = "".obs;
  var idDepartemenTerpilih = "".obs;

  var latUser = 0.0.obs;
  var langUser = 0.0.obs;

  var typeAbsen = 0.obs;

  var imageStatus = false.obs;
  var detailAlamat = false.obs;
  var mockLocation = false.obs;
  var showButtonlaporan = false.obs;
  var statusLoadingSubmitLaporan = false.obs;

  var absenStatus = AppData.statusAbsen.obs;

  @override
  void onReady() async {
    getTimeNow();
    loadHistoryAbsenUser();
    getDepartemen();
    super.onReady();
  }

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";
    var convert = Constanst.convertDate1("${dt.year}-${dt.month}-${dt.day}");
    tanggalLaporan.value.text = convert;
  }

  void getDepartemen() {
    var connect = Api.connectionApi("get", {}, "all_department");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var dataDepartemen = valueBody['data'];
          var dataUser = AppData.informasiUser;
          var hakAkses = dataUser![0].em_hak_akses;
          print('hak akses $hakAkses');
          if (hakAkses == '1') {
            var data = {'id': 0, 'dep_name': 'Semua', 'parent_id': ''};
            departementAkses.add(data);
          }
          if (hakAkses != "") {
            var convert = hakAkses!.split(',');
            for (var element in dataDepartemen) {
              if (hakAkses == '1') {
                departementAkses.add(element);
              }
              for (var element1 in convert) {
                if ("${element['id']}" == element1) {
                  print('sampe sini');
                  departementAkses.add(element);
                }
              }
            }
          }
        }
        this.departementAkses.refresh();
        if (departementAkses.value.isNotEmpty) {
          idDepartemenTerpilih.value = "${departementAkses[0]['id']}";
          namaDepartemenTerpilih.value = departementAkses[0]['dep_name'];
          departemen.value.text = departementAkses[0]['dep_name'];
          showButtonlaporan.value = true;
          aksiCariLaporan();
        }
      }
    });
  }

  void getPlaceCoordinate() {
    var connect = Api.connectionApi("get", {}, "places_coordinate");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          selectedType.value = valueBody['data'][0]['place'];
          placeCoordinate.value = valueBody['data'];
          for (var element in valueBody['data']) {
            placeCoordinateDropdown.value.add(element['place']);
          }
          this.placeCoordinate.refresh();
        }
      }
    });
  }

  void removeAll() {
    fotoUser.value = File("");

    base64fotoUser.value = "";
    timeString.value = "";
    dateNow.value = "";
    alamatUserFoto.value = "";
    alamatUserFoto.value = "";

    latUser.value = 0.0;
    langUser.value = 0.0;

    imageStatus.value = false;

    deskripsiAbsen.clear();
    historyAbsen.value.clear();
  }

  void absenSelfie() async {
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
      timeString.value = formatDateTime(DateTime.now());
      dateNow.value = dateNoww(DateTime.now());
      imageStatus.value = true;
      tanggalUserFoto.value = dateNoww2(DateTime.now());
      this.imageStatus.refresh();
      this.timeString.refresh();
      this.dateNow.refresh();
      this.base64fotoUser.refresh();
      this.fotoUser.refresh();
      getPosisition();
    }
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

  String dateNoww2(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  void getPosisition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      print(place);
      latUser.value = position.latitude;
      langUser.value = position.longitude;
      alamatUserFoto.value =
          "${placemarks[0].street} ${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}";
      this.latUser.refresh();
      this.langUser.refresh();
      this.alamatUserFoto.refresh();
    } on Exception catch (e) {
      print(e);
    }
  }

  void ulangiFoto() {
    imageStatus.value = false;
    fotoUser.value = File("");
    base64fotoUser.value = "";
    alamatUserFoto.value = "";
    absenSelfie();
  }

  void kirimDataAbsensi() async {
    if (base64fotoUser.value == "") {
      UtilsAlert.showToast("Silahkan Absen");
    } else {
      TrustLocation.start(1);
      getCheckMock();
      if (!mockLocation.value) {
        var statusPosisi = await validasiRadius();
        if (statusPosisi == true) {
          var latLangAbsen = "${latUser.value},${langUser.value}";
          var dataUser = AppData.informasiUser;
          var getEmpId = dataUser![0].emp_id;
          var getSettingAppSaveImageAbsen =
              settingAppInfo.value![0].saveimage_attend;
          var validasiGambar =
              getSettingAppSaveImageAbsen == "NO" ? "" : base64fotoUser.value;
          if (typeAbsen.value == 1) {
            absenStatus.value = true;
            AppData.statusAbsen = true;
            AppData.dateLastAbsen = tanggalUserFoto.value;
          } else {
            absenStatus.value = false;
            AppData.statusAbsen = false;
            AppData.dateLastAbsen = tanggalUserFoto.value;
          }
          Map<String, dynamic> body = {
            'emp_id': getEmpId,
            'tanggal_absen': tanggalUserFoto.value,
            'waktu': timeString.value,
            'gambar': validasiGambar,
            'lokasi': alamatUserFoto.value,
            'latLang': latLangAbsen,
            'catatan': deskripsiAbsen.value.text,
            'typeAbsen': typeAbsen.value,
            'place': selectedType.value,
            'kategori': "1"
          };

          var connect = Api.connectionApi("post", body, "kirimAbsen");
          connect.then((dynamic res) {
            if (res.statusCode == 200) {
              var valueBody = jsonDecode(res.body);
              print(res.body);
              Navigator.pop(Get.context!);
              Get.offAll(BerhasilAbsensi(
                dataBerhasil: [
                  titleAbsen.value,
                  timeString.value,
                  typeAbsen.value
                ],
              ));
            }
          });
        }
      } else {
        UtilsAlert.showToast("Periksa GPS anda");
      }
    }
  }

  void getCheckMock() async {
    try {
      TrustLocation.onChange.listen((values) => getValMock(values));
    } on PlatformException catch (e) {
      print('PlatformException $e');
    }
  }

  void getValMock(values) {
    String _latitude = values.latitude;
    String _longitude = values.longitude;
    bool _isMockLocation = values.isMockLocation;
    TrustLocation.stop();
    mockLocation.value = _isMockLocation;
    this.mockLocation.refresh();
  }

  Future<bool> validasiRadius() async {
    UtilsAlert.showLoadingIndicator(Get.context!);
    var from = Point(latUser.value, langUser.value);
    // var from = Point(-6.1716917, 106.7305503);
    var getPlaceTerpilih = placeCoordinate.value
        .firstWhere((element) => element['place'] == selectedType.value);
    var stringLatLang = "${getPlaceTerpilih['place_longlat']}";
    var defaultRadius = "${getPlaceTerpilih['place_radius']}";
    if (stringLatLang == "" ||
        stringLatLang == null ||
        stringLatLang == "null") {
      return true;
    } else {
      var listLatLang = (stringLatLang.split(','));
      var latDefault = listLatLang[0];
      var langDefault = listLatLang[1];
      var to = Point(double.parse(latDefault), double.parse(langDefault));
      double distance = SphericalUtils.computeDistanceBetween(from, to);
      print('Distance: $distance meters');
      var filter = double.parse((distance).toStringAsFixed(0));
      if (filter <= double.parse(defaultRadius)) {
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
  }

  void loadHistoryAbsenUser() {
    historyAbsen.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmpId = dataUser![0].emp_id;
    Map<String, dynamic> body = {
      'emp_id': getEmpId,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "history-attendance");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        loading.value =
            data.length == 0 ? "Data tidak ditemukan" : "Memuat data...";
        for (var el in data) {
          historyAbsen.value.add(AbsenModel(
              id: el['id'] ?? "",
              emp_id: el['emp_id'] ?? "",
              atten_date: el['atten_date'] ?? "",
              signin_time: el['signin_time'] ?? "",
              signout_time: el['signout_time'] ?? "",
              working_hour: el['working_hour'] ?? "",
              place: el['place'] ?? "",
              absence: el['absence'] ?? "",
              overtime: el['overtime'] ?? "",
              earnleave: el['earnleave'] ?? "",
              status: el['status'] ?? "",
              signin_longlat: el['signin_longlat'] ?? "",
              signout_longlat: el['signout_longlat'] ?? "",
              att_type: el['att_type'] ?? "",
              signin_pict: el['signin_pict'] ?? "",
              signout_pict: el['signout_pict'] ?? "",
              signin_note: el['signin_note'] ?? "",
              signout_note: el['signout_note'] ?? "",
              signin_addr: el['signin_addr'] ?? "",
              signout_addr: el['signout_addr'] ?? "",
              atttype: el['atttype'] ?? 0));
        }
      }
      this.historyAbsen.refresh();
    });
  }

  void historySelected(id_absen, status) {
    if (status == 'history') {
      var getSelected =
          historyAbsen.value.firstWhere((element) => element.id == id_absen);
      print(getSelected);
      Get.to(DetailAbsen(
        absenSelected: [getSelected],
        status: false,
      ));
    } else if (status == 'laporan') {
      var getSelected = listLaporanFilter.value
          .firstWhere((element) => element['id'] == id_absen);
      if (getSelected['signin_longlat'] == null ||
          getSelected['signin_longlat'] == "") {
        UtilsAlert.showToast("Terjadi kesalahan terhadap data absen ini");
      } else {
        Get.to(DetailAbsen(
          absenSelected: [getSelected],
          status: true,
        ));
      }
    }
  }

  showDetailImage() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 15),
                  Image.network(
                    Api.UrlfotoAbsen + stringImageSelected.value,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 15)
                ]));
      },
    );
  }

  showDataDepartemenAkses() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: Container(
              height: 300.0,
              width: 300.0,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: departementAkses.value.length,
                  itemBuilder: (context, index) {
                    var id = departementAkses.value[index]['id'];
                    var dep_name = departementAkses.value[index]['dep_name'];
                    return InkWell(
                      onTap: () {
                        idDepartemenTerpilih.value = "$id";
                        namaDepartemenTerpilih.value = dep_name;
                        departemen.value.text =
                            departementAkses.value[index]['dep_name'];
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Constanst.colorButton2,
                              borderRadius:
                                  Constanst.styleBoxDecoration1.borderRadius),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Center(
                              child: Text(
                                dep_name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ));
      },
    );
  }

  void carilaporanAbsenkaryawan() {
    if (tanggalLaporan.value.text == "" || departemen.value.text == "") {
      UtilsAlert.showToast("Lengkapi form");
    } else {
      aksiCariLaporan();
    }
  }

  void aksiCariLaporan() async {
    statusLoadingSubmitLaporan.value = true;
    listLaporanFilter.value.clear();
    await Future.delayed(const Duration(seconds: 1));
    var tanggalConvert = Constanst.convertDateSimpan(tanggalLaporan.value.text);
    Map<String, dynamic> body = {
      'tanggal': tanggalConvert,
      'status': idDepartemenTerpilih.value
    };
    var connect = Api.connectionApi("post", body, "load_laporan_absensi");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        loading.value =
            data.length == 0 ? "Data tidak tersedia" : "Memuat data...";
        listLaporanFilter.value = data;
        allListLaporanFilter.value = data;
      }
    });
    this.listLaporanFilter.refresh();
    this.allListLaporanFilter.refresh();
    statusLoadingSubmitLaporan.value = false;
    this.statusLoadingSubmitLaporan.refresh();
  }

  void filterData(id) {
    if (id == '1') {
      var tampung = [];
      for (var element in allListLaporanFilter.value) {
        var listJamMasuk = (element['signin_time']!.split(':'));
        var perhitunganJamMasuk1 =
            830 - int.parse("${listJamMasuk[0]}${listJamMasuk[1]}");
        print(perhitunganJamMasuk1);
        if (perhitunganJamMasuk1 <= 0) {
          tampung.add(element);
        }
      }
      loading.value =
          tampung.length == 0 ? "Data tidak tersedia" : "Memuat data...";
      listLaporanFilter.value = tampung;
      this.listLaporanFilter.refresh();
    } else if (id == '2') {
      var tampung = [];
      for (var element in allListLaporanFilter.value) {
        if (element['signout_time'] != '00:00:00') {
          var listJamKeluar = (element['signout_time']!.split(':'));
          var perhitunganJamKeluar =
              1830 - int.parse("${listJamKeluar[0]}${listJamKeluar[1]}");
          print(perhitunganJamKeluar);
          if (perhitunganJamKeluar <= 0) {
            tampung.add(element);
          }
        }
      }
      loading.value =
          tampung.length == 0 ? "Data tidak tersedia" : "Memuat data...";
      listLaporanFilter.value = tampung;
      this.listLaporanFilter.refresh();
    } else if (id == '3') {
      var tampung = [];
      for (var element in allListLaporanFilter.value) {
        if (element['signout_time'] == '00:00:00') {
          tampung.add(element);
        }
      }
      loading.value =
          tampung.length == 0 ? "Data tidak tersedia" : "Memuat data...";
      listLaporanFilter.value = tampung;
      this.listLaporanFilter.refresh();
    }
  }
}
