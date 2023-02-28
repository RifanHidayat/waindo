import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:siscom_operasional/model/absen_model.dart';
import 'package:siscom_operasional/model/shift_model.dart';
import 'package:siscom_operasional/screen/absen/berhasil_absen.dart';
import 'package:siscom_operasional/screen/absen/berhasil_registrasi.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
import 'package:siscom_operasional/screen/absen/face_id_registration.dart';
import 'package:siscom_operasional/screen/absen/loading_absen.dart';

import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:google_maps_utils/google_maps_utils.dart';
import 'package:trust_location/trust_location.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:siscom_operasional/screen/absen/absen_masuk_keluar.dart';

class AbsenController extends GetxController {
  PageController? pageViewFilterAbsen;

  TextEditingController deskripsiAbsen = TextEditingController();
  var tanggalLaporan = TextEditingController().obs;
  var departemen = TextEditingController().obs;
  var cari = TextEditingController().obs;

  var fotoUser = File("").obs;

  var settingAppInfo = AppData.infoSettingApp.obs;

  Rx<List<String>> placeCoordinateDropdown = Rx<List<String>>([]);
  var selectedType = "".obs;

  var historyAbsen = <AbsenModel>[].obs;
  var historyAbsenShow = [].obs;
  var placeCoordinate = [].obs;
  var departementAkses = [].obs;
  var listLaporanFilter = [].obs;
  var allListLaporanFilter = [].obs;
  var listLaporanBelumAbsen = [].obs;
  var allListLaporanBelumAbsen = [].obs;
  var listEmployeeTelat = [].obs;
  var alllistEmployeeTelat = [].obs;
  var sysData = [].obs;
  var isCollapse = true.obs;
  var shift = OfficeShiftModel().obs;

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
  var testingg = "".obs;
  var filterLokasiKoordinate = "Lokasi".obs;
  Rx<AbsenModel> absenModel = AbsenModel().obs;
  var jumlahData = 0.obs;
  var isTracking = 0.obs;
  var activeTracking = 0.obs;
  var selectedViewFilterAbsen = 0.obs;
  var regType = 0.obs;

  Rx<DateTime> pilihTanggalTelatAbsen = DateTime.now().obs;

  var latUser = 0.0.obs;
  var langUser = 0.0.obs;

  var typeAbsen = 0.obs;
  var intervalControl = 60000.obs;

  var imageStatus = false.obs;
  var detailAlamat = false.obs;
  var mockLocation = false.obs;
  var showButtonlaporan = false.obs;
  var statusLoadingSubmitLaporan = false.obs;
  var statusCari = false.obs;
  var filterLaporanAbsenTanggal = false.obs;

  var absenStatus = false.obs;
  var gagalAbsen = 0.obs;
  var failured = "".obs;
  RxString absenSuccess = "0".obs;

  @override
  void onReady() async {
    print("Masulk ke controller absen");
    getTimeNow();
    getLoadsysData();
    loadHistoryAbsenUser();
    getDepartemen(1, "");
    filterLokasiKoordinate.value = "Lokasi";
    selectedViewFilterAbsen.value = 0;
    pilihTanggalTelatAbsen.value = DateTime.now();
    super.onReady();
    userShift();
  }

  void getLoadsysData() {
    var connect = Api.connectionApi("get", "", "sysdata");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          statusLoadingSubmitLaporan.value = false;
          UtilsAlert.showToast(
              "Data periode $bulanSelectedSearchHistory belum tersedia, harap hubungi HRD");
        } else {
          sysData.value = valueBody['data'];
          this.sysData.refresh();
        }
      }
    });
  }

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";
    var convert = Constanst.convertDate1("${dt.year}-${dt.month}-${dt.day}");
    tanggalLaporan.value.text = convert;
    absenStatus.value = AppData.statusAbsen;
    this.absenStatus.refresh();
  }

  void getDepartemen(status, tanggal) {
    jumlahData.value = 0;
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
          print(hakAkses);
          if (hakAkses != "" || hakAkses != null) {
            if (hakAkses == '0') {
              var data = {
                'id': 0,
                'name': 'SEMUA DIVISI',
                'inisial': 'AD',
                'parent_id': '',
                'aktif': '',
                'pakai': '',
                'ip': '',
                'created_by': '',
                'created_on': '',
                'modified_by': '',
                'modified_on': ''
              };
              departementAkses.add(data);
            }
            var convert = hakAkses!.split(',');
            for (var element in dataDepartemen) {
              if (hakAkses == '0') {
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
          this.departementAkses.refresh();
          if (departementAkses.value.isNotEmpty) {
            if (status == 1) {
              idDepartemenTerpilih.value = "${departementAkses[0]['id']}";
              namaDepartemenTerpilih.value = departementAkses[0]['name'];
              departemen.value.text = departementAkses[0]['name'];
              showButtonlaporan.value = true;
              aksiCariLaporan();
            } else if (status == 2) {
              idDepartemenTerpilih.value = "${departementAkses[0]['id']}";
              namaDepartemenTerpilih.value = departementAkses[0]['name'];
              departemen.value.text = departementAkses[0]['name'];
              showButtonlaporan.value = true;
              aksiEmployeeTerlambatAbsen(tanggal);
            } else if (status == 3) {
              idDepartemenTerpilih.value = "${departementAkses[0]['id']}";
              namaDepartemenTerpilih.value = departementAkses[0]['name'];
              departemen.value.text = departementAkses[0]['name'];
              showButtonlaporan.value = true;
              aksiEmployeeBelumAbsen(tanggal);
            }
          }
        }
      }
    });
  }

  void getPlaceCoordinate() {
    placeCoordinate.clear();
    var connect = Api.connectionApi("get", {}, "places_coordinate");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          print("Place cordinate 200" + res.body.toString());
          var valueBody = jsonDecode(res.body);
          selectedType.value = valueBody['data'][0]['place'];
          for (var element in valueBody['data']) {
            placeCoordinateDropdown.value.add(element['place']);
          }
          List filter = [];
          for (var element in valueBody['data']) {
            if (element['isFilterView'] == 1) {
              filter.add(element);
            }
          }

          placeCoordinate.value = filter;
          placeCoordinate.refresh();
          placeCoordinate.refresh();
        } else {
          print("Place cordinate !=200" + res.body.toString());
          print(res.body.toString());
        }
      }
    });
  }

  void filterAbsenTelat() {
    var tanggal = DateFormat('yyyy-MM-dd').format(pilihTanggalTelatAbsen.value);
    getDepartemen(2, tanggal);
  }

  void filterBelumAbsen() {
    var tanggal = DateFormat('yyyy-MM-dd').format(pilihTanggalTelatAbsen.value);
    getDepartemen(3, tanggal);
  }

  void aksiEmployeeTerlambatAbsen(tanggal) {
    statusLoadingSubmitLaporan.value = true;
    listLaporanFilter.value.clear();
    Map<String, dynamic> body = {
      'atten_date': tanggal,
      'status': idDepartemenTerpilih.value
    };
    var connect =
        Api.connectionApi("post", body, "load_laporan_absensi_harian");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          statusLoadingSubmitLaporan.value = false;
          UtilsAlert.showToast(
              "Data periode $bulanSelectedSearchHistory belum tersedia, harap hubungi HRD");
        } else {
          var data = valueBody['data'];
          loading.value =
              data.length == 0 ? "Data tidak tersedia" : "Memuat data...";
          var seen = Set<String>();
          List filter =
              data.where((country) => seen.add(country['full_name'])).toList();
          List filterTelat = [];
          for (var element in filter) {
            var listJam = element['signin_time'].split(':');
            var getJamMenit = "${listJam[0]}${listJam[1]}";
            var jamMasukEmployee = int.parse(getJamMenit);
            var hitung = jamMasukEmployee - 840;
            if (hitung > 0) {
              filterTelat.add(element);
            }
          }
          filterTelat.sort((a, b) => a['full_name']
              .toUpperCase()
              .compareTo(b['full_name'].toUpperCase()));
          jumlahData.value = filterTelat.length;
          listEmployeeTelat.value = filterTelat;
          alllistEmployeeTelat.value = filterTelat;
          this.jumlahData.refresh();
          this.listEmployeeTelat.refresh();
          this.alllistEmployeeTelat.refresh();
          statusLoadingSubmitLaporan.value = false;
          this.statusLoadingSubmitLaporan.refresh();
          if (listEmployeeTelat.isEmpty) {
            loading.value = "Data tidak tersedia";
          } else {
            loading.value = "Memuat Data...";
          }
          this.loading.refresh();
        }
      }
    });
  }

  void aksiEmployeeBelumAbsen(tanggal) {
    statusLoadingSubmitLaporan.value = true;
    listLaporanBelumAbsen.value.clear();
    Map<String, dynamic> body = {
      // 'atten_date': '2022-12-05',
      'atten_date': tanggal,
      'status': "0"
    };
    var connect = Api.connectionApi("post", body, "load_laporan_belum_absen");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          statusLoadingSubmitLaporan.value = false;
          UtilsAlert.showToast(
              "Data periode $bulanSelectedSearchHistory belum tersedia, harap hubungi HRD");
        } else {
          List data = valueBody['data'];

          data.sort((a, b) => a['full_name']
              .toUpperCase()
              .compareTo(b['full_name'].toUpperCase()));

          jumlahData.value = valueBody['jumlah'];
          listLaporanBelumAbsen.value = data;
          allListLaporanBelumAbsen.value = data;
          this.jumlahData.refresh();
          this.listLaporanBelumAbsen.refresh();
          this.allListLaporanBelumAbsen.refresh();
          statusLoadingSubmitLaporan.value = false;
          this.statusLoadingSubmitLaporan.refresh();
          if (listLaporanBelumAbsen.isEmpty) {
            loading.value = "Data tidak tersedia";
          } else {
            loading.value = "Memuat Data...";
          }
          this.loading.refresh();
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
    //rhistoryAbsen.value.clear();
  }

  void absenSelfie() async {
    // // absenSelfie();
    timeString.value = formatDateTime(DateTime.now());
    dateNow.value = dateNoww(DateTime.now());
    tanggalUserFoto.value = dateNoww2(DateTime.now());
    imageStatus.refresh();
    timeString.refresh();
    dateNow.refresh();
    getPosisition();

    // Get.to(AbsenMasukKeluar(
    //   status: status,
    //   type: type.toString(),
    // ));
    gagalAbsen.value = 0;
    // // final getFoto = await ImagePicker().pickImage(
    // //     source: ImageSource.camera,
    // //     preferredCameraDevice: CameraDevice.front,
    // //     imageQuality: 100,
    // //     maxHeight: 350,
    // //     maxWidth: 350);
    // // if (getFoto == null) {
    // //   UtilsAlert.showToast("Gagal mengambil gambar");
    // // } else {
    // // fotoUser.value = File(getFoto.path);
    // // var bytes = File(getFoto.path).readAsBytesSync();
    // // base64fotoUser.value = base64Encode(bytes);
    // timeString.value = formatDateTime(DateTime.now());
    // dateNow.value = dateNoww(DateTime.now());
    // imageStatus.value = true;
    // tanggalUserFoto.value = dateNoww2(DateTime.now());
    // this.imageStatus.refresh();
    // this.timeString.refresh();
    // this.dateNow.refresh();
    // // this.base64fotoUser.refresh();
    // // this.fotoUser.refresh();
    // getPosisition();
    // // }
    // Get.to(AbsenMasukKeluar());
  }

  // void facedDetection({
  //   required status,
  //   absenStatus,
  //   type,
  // }) async {
  //   // if (takePicturer == "0") {
  //   //   if (status == "registration") {
  //   //     print("registration");
  //   //     saveFaceregistration(img);
  //   //   } else {
  //   //     detection(file: img, status: absenStatus, type: type);
  //   //   }
  //   // } else {
  //   //  Get.back();
  //   final getFoto = await ImagePicker().pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //   );
  //   // var bytes = File(getFoto.path).readAsBytesSync();
  //   // base64fotoUser.value = base64Encode(bytes);
  //   if (getFoto == null) {
  //     UtilsAlert.showToast("Gagal mengambil gambar");
  //   } else {
  //     print(getFoto.path);
  //     // fotoUser.value = File(getFoto.toString());
  //     if (status == "registration") {
  //       print("registration");

  //       saveFaceregistration(getFoto.path);
  //     } else {
  //       detection(file: getFoto.path, status: absenStatus, type: type);
  //     }
  //   }
  //   // }
  // }

  //  void facedDetection({
  //   required status,
  //   absenStatus,
  //   type,
  // }) async {
  //   // if (takePicturer == "0") {
  //   //   if (status == "registration") {
  //   //     print("registration");
  //   //     saveFaceregistration(img);
  //   //   } else {
  //   //     detection(file: img, status: absenStatus, type: type);
  //   //   }
  //   // } else {
  //   //  Get.back();
  //   final getFoto = await ImagePicker().pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //   );
  //   // var bytes = File(getFoto.path).readAsBytesSync();
  //   // base64fotoUser.value = base64Encode(bytes);
  //   if (getFoto == null) {
  //     UtilsAlert.showToast("Gagal mengambil gambar");
  //   } else {
  //     print(getFoto.path);
  //     // fotoUser.value = File(getFoto.toString());
  //     if (status == "registration") {
  //       print("registration");

  //       saveFaceregistration(getFoto.path);
  //     } else {
  //       detection(file: getFoto.path, status: absenStatus, type: type);
  //     }
  //   }
  //   // }
  // }

  void facedDetection({required status, absenStatus, type, img}) async {
    // if (takePicturer == "0") {
    if (status == "registration") {
      final getFoto = await ImagePicker().pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 100,
          maxHeight: 350,
          maxWidth: 350);
      if (getFoto == null) {
        UtilsAlert.showToast("Gagal mengambil gambar");
      } else {
        saveFaceregistration(getFoto.path);
      }
    } else {
      final getFoto = await ImagePicker().pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 100,
          maxHeight: 350,
          maxWidth: 350);
      if (getFoto == null) {
        UtilsAlert.showToast("Gagal mengambil gambar");
      } else {
        Navigator.push(
          Get.context!,
          MaterialPageRoute(
              builder: (context) => LoadingAbsen(
                    file: getFoto.path,
                    status: "detection",
                    statusAbsen: absenStatus,
                    // type: type.toString(),
                  )),
        );
        detection(file: getFoto.path, status: absenStatus, type: type);
      }
      // detection(file: img, status: absenStatus, type: type);
    }
  }

  void saveFaceregistration(file) async {
    UtilsAlert.showLoadingIndicator(Get.context!);
    print("register function");
    final box = GetStorage();
    File image = new File(file); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());

    try {
      var dataUser = AppData.informasiUser;
      var getEmpId = dataUser![0].em_id;
      Map<String, String> headers = {
        'Authorization': Api.basicAuth,
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      //     print(decodedImage.width);
      // print(decodedImage.height);
      Map<String, String> body = {
        'em_id': getEmpId.toString(),
        'width': decodedImage.width.toString(),
        'height': decodedImage.height.toString()
      };
      var request = http.MultipartRequest(
        "POST",
        Uri.parse(Api.basicUrl + "edit_face"),
      );

      request.fields.addAll(body);

      request.headers.addAll(headers);

      // if (fotoUser.value != null) {
      var picture = await http.MultipartFile.fromPath('file', file.toString(),
          contentType: MediaType('image', 'png'));
      request.files.add(picture);
      // }
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      final res = jsonDecode(respStr.toString());
      print(respStr.toString());

      if (res['status'] == true) {
        employeDetail();
        box.write("face_recog", true);
        gagalAbsen.value = gagalAbsen.value;

        // Get.back();
        Navigator.push(
          Get.context!,
          MaterialPageRoute(builder: (context) => BerhasilRegistration()),
        );
      } else {
        // Get.back();
        UtilsAlert.showToast(res['message']);
      }
    } on Exception catch (e) {
      print(e.toString());
      Get.back();
      UtilsAlert.showToast(e.toString());
      throw e;
    }
  }

  void detection({file, type, status}) async {
    employeDetail();
    var bytes = File(file).readAsBytesSync();
    base64fotoUser.value = base64Encode(bytes);
    Future.delayed(const Duration(milliseconds: 500), () {});
    File image = new File(file); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());

    try {
      var dataUser = AppData.informasiUser;
      var getEmpId = dataUser![0].em_id;

      Map<String, String> body = {
        'em_id': getEmpId.toString(),
        'width': decodedImage.width.toString(),
        'height': decodedImage.height.toString(),

        // 'image': file.toString()
      };
      Map<String, String> headers = {
        'Authorization': Api.basicAuth,
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      var request = http.MultipartRequest(
        "POST",
        Uri.parse(Api.basicUrl + "get_face"),
      );

      request.fields.addAll(body);
      request.headers.addAll(headers);

      // if (fotoUser.value != null) {
      var picture = await http.MultipartFile.fromPath('file', file,
          contentType: MediaType('image', 'png'));
      request.files.add(picture);
      //  }
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      final res = jsonDecode(respStr.toString());

      if (res['status'] == true) {
        absenSuccess.value = "1";

        // // absenSelfie();
        timeString.value = formatDateTime(DateTime.now());
        dateNow.value = dateNoww(DateTime.now());
        tanggalUserFoto.value = dateNoww2(DateTime.now());
        imageStatus.refresh();
        timeString.refresh();
        dateNow.refresh();
        getPosisition();

        // Get.to(AbsenMasukKeluar(
        //   status: status,
        //   type: type.toString(),
        // ));

        gagalAbsen.value = 0;

        // Navigator.push(
        //   Get.context!,
        //   MaterialPageRoute(
        //       builder: (context) => AbsenMasukKeluar(
        //             status: status,
        //             // type: type.toString(),
        //           )),
        // );

        // UtilsAlert.showToast(res['message']);
      } else {
        absenSuccess.value = "0";
        gagalAbsen.value = gagalAbsen.value + 1;

        // UtilsAlert.showToast(res['message']);
        // print("status ${titleAbsen.value}");
        // if (gagalAbsen.value >= 3) {
        //   Get.back();
        //   Get.to(AbsenVrifyPassword(
        //     status: status,
        //     type: type.toString(),
        //   ));
        // } else {
        //   Get.back();
        //   Get.back();
        //   print("titleAbsen.value");

        //   // facedDetection(
        //   //   absenStatus: status,
        //   //   status: "detection",
        //   //   type: type.toString(),
        //   // );
        //   // Get.to(FaceDetectorView(
        //   //   status: status == "masuk" ? "masuk" : "keluar",
        //   // ));
        // }
      }
    } on Exception catch (e) {
      print(e.toString());
      Get.back();
      UtilsAlert.showToast(e.toString());
      throw e;
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
    employeDetail();
    // if (base64fotoUser.value == "") {
    //   UtilsAlert.showToast("Silahkan Absen");
    // } else {
    if (Platform.isAndroid) {
      TrustLocation.start(1);
      getCheckMock();
      if (!mockLocation.value) {
        var statusPosisi = await validasiRadius();
        if (statusPosisi == true) {
          var latLangAbsen = "${latUser.value},${langUser.value}";
          var dataUser = AppData.informasiUser;
          var getEmpId = dataUser![0].em_id;
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
            'em_id': getEmpId,
            'tanggal_absen': tanggalUserFoto.value,
            'waktu': timeString.value,
            // 'gambar': validasiGambar,
            'reg_type': regType.value,
            'gambar': base64fotoUser.value,
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
              for (var element in sysData.value) {
                if (element['kode'] == '006') {
                  intervalControl.value = int.parse(element['name']);
                }
              }
              this.intervalControl.refresh();
              print("dapat interval ${intervalControl.value}");
              // Navigator.pop(Get.context!);
              Get.to(BerhasilAbsensi(
                dataBerhasil: [
                  titleAbsen.value,
                  timeString.value,
                  typeAbsen.value,
                  intervalControl.value
                ],
              ));
            }
          });
        }
      } else {
        UtilsAlert.showToast("Periksa GPS anda");
      }
    } else if (Platform.isIOS) {
      var statusPosisi = await validasiRadius();
      if (statusPosisi == true) {
        var latLangAbsen = "${latUser.value},${langUser.value}";
        var dataUser = AppData.informasiUser;
        var getEmpId = dataUser![0].em_id;
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
          'em_id': getEmpId,
          'tanggal_absen': tanggalUserFoto.value,
          'waktu': timeString.value,
          // 'gambar': validasiGambar,
          'reg_type': regType.value.toString(),
          'gambar': base64fotoUser.value,
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
            for (var element in sysData.value) {
              if (element['kode'] == '006') {
                intervalControl.value = int.parse(element['name']);
              }
            }
            this.intervalControl.refresh();
            print("dapat interval ${intervalControl.value}");
            Get.back();
            Get.offAll(BerhasilAbsensi(
              dataBerhasil: [
                titleAbsen.value,
                timeString.value,
                typeAbsen.value,
                intervalControl.value
              ],
            ));
          }
        });
      }
    }

    //  }
  }

  void getCheckMock() async {
    try {
      TrustLocation.onChange.listen((values) => getValMock(values));
    } on PlatformException catch (e) {
      print('PlatformException $e');
    }
  }

  void getValMock(values) {
    print(values);
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
    print("lat validasi" + latUser.value.toString());
    print("long validasi" + langUser.value.toString());
    // var from = Point(-6.1716917, 106.7305503);
    print("place cordinate value ${placeCoordinate.value}");
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

    var getEmpId = dataUser![0].em_id;
    print(getEmpId);
    Map<String, dynamic> body = {
      'em_id': getEmpId,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "history-attendance");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          List data = valueBody['data'];
          loading.value =
              data.length == 0 ? "Data tidak ditemukan" : "Memuat data...";
          for (var el in data) {
            historyAbsen.value.add(AbsenModel(
                id: el['id'] ?? "",
                em_id: el['em_id'] ?? "",
                atten_date: el['atten_date'] ?? "",
                signin_time: el['signin_time'] ?? "",
                signout_time: el['signout_time'] ?? "",
                working_hour: el['working_hour'] ?? "",
                place_in: el['place_in'] ?? "",
                place_out: el['place_out'] ?? "",
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
                reqType: el['reg_type'] ?? 0,
                atttype: el['atttype'] ?? 0));
          }
          if (historyAbsen.value.length != 0) {
            var listTanggal = [];
            var finalData = [];
            for (var element in historyAbsen.value) {
              listTanggal.add(element.atten_date);
            }
            listTanggal = listTanggal.toSet().toList();
            for (var element in listTanggal) {
              var valueTurunan = [];
              var stringDateAdaTurunan = "";
              for (var element1 in historyAbsen.value) {
                if (element == element1.atten_date) {
                  var dataTurunan = {
                    'id': element1.id,
                    'signin_time': element1.signin_time,
                    'signout_time': element1.signout_time,
                    'atten_date': element1.atten_date,
                    'place_in': element1.place_in,
                    'place_out': element1.place_out,
                    'signin_note': element1.signin_note,
                    'signin_longlat': element1.signin_longlat,
                    'signout_longlat': element1.signout_longlat,
                    'reg_type': element1.reqType
                  };
                  stringDateAdaTurunan = "${element1.atten_date}";
                  valueTurunan.add(dataTurunan);
                }
              }
              List hasilFilter = [];
              List hasilFilterPengajuan = [];
              for (var element1 in valueTurunan) {
                if (element1['place_in'] == 'pengajuan') {
                  hasilFilterPengajuan.add(element1);
                } else {
                  hasilFilter.add(element1);
                }
              }
              List hasilFinalPengajuan = [];
              if (hasilFilterPengajuan.isNotEmpty) {
                var data = hasilFilterPengajuan;
                var seen = Set<String>();
                List filter = data
                    .where((pengajuan) => seen.add(pengajuan['signin_note']))
                    .toList();
                hasilFinalPengajuan = filter;
              }
              List finalAllData = new List.from(hasilFilter)
                ..addAll(hasilFinalPengajuan);

              var lengthTurunan = finalAllData.length == 1 ? false : true;

              if (lengthTurunan == false) {
                var data = {
                  'id': finalAllData[0]['id'],
                  'signin_time': finalAllData[0]['signin_time'],
                  'signout_time': finalAllData[0]['signout_time'],
                  'atten_date': finalAllData[0]['atten_date'],
                  'place_in': finalAllData[0]['place_in'],
                  'place_out': finalAllData[0]['place_out'],
                  'signin_note': finalAllData[0]['signin_note'],
                  'signin_longlat': finalAllData[0]['signin_longlat'],
                  'signout_longlat': finalAllData[0]['signout_longlat'],
                  'reg_type': finalAllData[0]['reg_type'],
                  'view_turunan': lengthTurunan,
                  'turunan': [],
                };
                finalData.add(data);
              } else {
                var data = {
                  'id': "",
                  'signout_time': "",
                  'atten_date': stringDateAdaTurunan,
                  'place_in': "",
                  'place_out': "",
                  'signin_note': "",
                  'signin_longlat': "",
                  'signout_longlat': "",
                  'view_turunan': lengthTurunan,
                  'status_view': false,
                  'turunan': finalAllData,
                };
                stringDateAdaTurunan = "";
                finalData.add(data);
              }
            }
            finalData.sort((a, b) {
              return DateTime.parse(b['atten_date'])
                  .compareTo(DateTime.parse(a['atten_date']));
            });
            historyAbsenShow.value = finalData;
            this.historyAbsenShow.refresh();
          }
          this.historyAbsen.refresh();
        } else {
          loading.value = "Data tidak ditemukan";
        }
      }
    });
  }

  void showTurunan(tanggal) {
    for (var element in historyAbsenShow.value) {
      if (element['atten_date'] == tanggal) {
        if (element['status_view'] == false) {
          element['status_view'] = true;
        } else {
          element['status_view'] = false;
        }
      }
    }
    this.historyAbsenShow.refresh();
  }

  void historySelected(id_absen, status) {
    if (status == 'history') {
      var getSelected =
          historyAbsen.value.firstWhere((element) => element.id == id_absen);
      // print(getSelected);
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

  void historySelected1(id_absen, status, index, index1) {
    //  print(listLaporanFilter[index]['data'].toList());
    var getSelected = listLaporanFilter[index]['data'][index1];
    // print(getSelected);

    // print(getSelected);
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

  void loadAbsenDetail(emId, attenDate, fullName) {
    Map<String, dynamic> body = {'id_absen': emId, 'atten_date': attenDate};
    var connect = Api.connectionApi("post", body, "whereOnce-attendance");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].isNotEmpty) {
          //  print(listLaporanFilter[index]['data'].toList());
          var getSelected = valueBody['data'][0];

          // print(getSelected);
          if (getSelected['signin_longlat'] == null ||
              getSelected['signin_longlat'] == "") {
            UtilsAlert.showToast("Terjadi kesalahan terhadap data absen ini");
          } else {
            Get.to(DetailAbsen(
              absenSelected: [getSelected],
              status: true,
              fullName: fullName,
            ));
          }
          // absenModel.value = AbsenModel.fromMap(valueBody);
        } else {}
      }
    });
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

  void filterDataArray() {
    var data = departementAkses.value;
    var seen = Set<String>();
    List filter = data.where((divisi) => seen.add(divisi['name'])).toList();
    departementAkses.value = filter;
    this.departementAkses.refresh();
  }

  showDataDepartemenAkses(status) {
    filterDataArray();
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                        "Pilih Divisi",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Expanded(
                        flex: 10,
                        child: InkWell(
                            onTap: () => Navigator.pop(Get.context!),
                            child: Icon(Iconsax.close_circle)))
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  flex: 3,
                  child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          itemCount: departementAkses.value.length,
                          itemBuilder: (context, index) {
                            var id = departementAkses.value[index]['id'];
                            var dep_name =
                                departementAkses.value[index]['name'];
                            return InkWell(
                              onTap: () {
                                filterLokasiKoordinate.value = "Lokasi";
                                selectedViewFilterAbsen.value = 0;
                                Rx<AbsenModel> absenModel = AbsenModel().obs;
                                var jumlahData = 0.obs;

                                idDepartemenTerpilih.value = "$id";
                                namaDepartemenTerpilih.value = dep_name;
                                departemen.value.text =
                                    departementAkses.value[index]['name'];
                                this.departemen.refresh();
                                Navigator.pop(context);
                                carilaporanAbsenkaryawan(status);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: "$id" == idDepartemenTerpilih.value
                                          ? Constanst.colorPrimary
                                          : Colors.transparent,
                                      borderRadius: Constanst
                                          .styleBoxDecoration1.borderRadius,
                                      border: Border.all(
                                          color: Constanst.colorText2)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        dep_name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: "$id" ==
                                                    idDepartemenTerpilih.value
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          );
        });
  }

  showDataLokasiKoordinate() {
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                        "Pilih Lokasi",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Expanded(
                        flex: 10,
                        child: InkWell(
                            onTap: () => Navigator.pop(Get.context!),
                            child: Icon(Iconsax.close_circle)))
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  flex: 3,
                  child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          itemCount: placeCoordinate.value.length,
                          itemBuilder: (context, index) {
                            var id = placeCoordinate.value[index]['id'];
                            var place = placeCoordinate.value[index]['place'];
                            return InkWell(
                              onTap: () {
                                if (selectedViewFilterAbsen.value == 0) {
                                  filterLokasiAbsenBulan(place);
                                } else {
                                  filterLokasiAbsen(place);
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: "$id" == idDepartemenTerpilih.value
                                          ? Constanst.colorPrimary
                                          : Colors.transparent,
                                      borderRadius: Constanst
                                          .styleBoxDecoration1.borderRadius,
                                      border: Border.all(
                                          color: Constanst.colorText2)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        place,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: "$id" ==
                                                    idDepartemenTerpilih.value
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          );
        });
  }

  void filterLokasiAbsenBulan(place) {
    print("tes");
    Navigator.pop(Get.context!);
    statusLoadingSubmitLaporan.value = true;
    listLaporanFilter.value.clear();
    Map<String, dynamic> body = {
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
      'status': idDepartemenTerpilih.value
    };
    var connect =
        Api.connectionApi("post", body, "load_laporan_absensi_filter_lokasi");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      if (valueBody['status'] == false) {
        statusLoadingSubmitLaporan.value = false;
        UtilsAlert.showToast(
            "Data periode $bulanSelectedSearchHistory belum tersedia, harap hubungi HRD");
      } else {
        var data = valueBody['data'];
        List listFilterLokasi = [];
        for (var element in data) {
          if (element['place_in'] == place) {
            listFilterLokasi.add(element);
          }
        }
        listLaporanFilter.value = listFilterLokasi;
        allListLaporanFilter.value = listFilterLokasi;
        filterLokasiKoordinate.value = place;

        this.listLaporanFilter.refresh();
        this.filterLokasiKoordinate.refresh();
        loading.value = listLaporanFilter.value.length == 0
            ? "Data tidak tersedia"
            : "Memuat data...";

        statusLoadingSubmitLaporan.value = false;
        this.statusLoadingSubmitLaporan.refresh();
        groupData();
      }
    });
  }

  void filterLokasiAbsen(place) {
    List listFilterLokasi = [];
    for (var element in allListLaporanFilter.value) {
      if (element['place_in'] == place) {
        listFilterLokasi.add(element);
      }
    }
    listLaporanFilter.value = listFilterLokasi;
    filterLokasiKoordinate.value = place;
    this.listLaporanFilter.refresh();
    this.filterLokasiKoordinate.refresh();
    loading.value = listLaporanFilter.value.length == 0
        ? "Data tidak tersedia"
        : "Memuat data...";
    Navigator.pop(Get.context!);
    groupData();
  }

  void refreshFilterKoordinate() {
    if (selectedViewFilterAbsen.value == 0) {
      onReady();
    } else {
      listLaporanFilter.value = allListLaporanFilter.value;
      filterLokasiKoordinate.value = "Lokasi";
      this.listLaporanFilter.refresh();
      this.filterLokasiKoordinate.refresh();
      loading.value = listLaporanFilter.value.length == 0
          ? "Data tidak tersedia"
          : "Memuat data...";
    }
  }

  void carilaporanAbsenkaryawan(status) {
    if (departemen.value.text == "") {
      UtilsAlert.showToast("Lengkapi form");
    } else {
      if (status == 'semua') {
        if (selectedViewFilterAbsen.value == 0) {
          // filter bulan
          aksiCariLaporan();
        } else if (selectedViewFilterAbsen.value == 1) {
          // filter tanggal
          cariLaporanAbsenTanggal(pilihTanggalTelatAbsen.value);
        }
      } else if (status == 'telat') {
        aksiEmployeeTerlambatAbsen(
            "${DateFormat('yyyy-MM-dd').format(pilihTanggalTelatAbsen.value)}");
      } else if (status == 'belum') {
        aksiEmployeeBelumAbsen(
            "${DateFormat('yyyy-MM-dd').format(pilihTanggalTelatAbsen.value)}");
      }
    }
  }

  void aksiCariLaporan() async {
    statusLoadingSubmitLaporan.value = true;
    listLaporanFilter.value.clear();
    Map<String, dynamic> body = {
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
      'status': idDepartemenTerpilih.value
    };
    var connect = Api.connectionApi("post", body, "load_laporan_absensi");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          statusLoadingSubmitLaporan.value = false;
          UtilsAlert.showToast(
              "Data periode $bulanSelectedSearchHistory belum tersedia, harap hubungi HRD");
        } else {
          var data = valueBody['data'];
          loading.value =
              data.length == 0 ? "Data tidak tersedia" : "Memuat data...";
          listLaporanFilter.value = data;
          allListLaporanFilter.value = data;
          this.listLaporanFilter.refresh();
          this.allListLaporanFilter.refresh();
          statusLoadingSubmitLaporan.value = false;
          this.statusLoadingSubmitLaporan.refresh();
          groupData();
        }
      }
    });
  }

  void cariLaporanAbsenTanggal(tanggal) {
    var tanggalSubmit = "${DateFormat('yyyy-MM-dd').format(tanggal)}";
    statusLoadingSubmitLaporan.value = true;
    listLaporanFilter.value.clear();
    Map<String, dynamic> body = {
      'atten_date': tanggalSubmit,
      'status': idDepartemenTerpilih.value
    };
    var connect =
        Api.connectionApi("post", body, "load_laporan_absensi_tanggal");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          statusLoadingSubmitLaporan.value = false;
          UtilsAlert.showToast(
              "Data periode $bulanSelectedSearchHistory belum tersedia, harap hubungi HRD");
        } else {
          var data = valueBody['data'];
          loading.value =
              data.length == 0 ? "Data tidak tersedia" : "Memuat data...";
          listLaporanFilter.value = data;
          allListLaporanFilter.value = data;
          this.listLaporanFilter.refresh();
          this.allListLaporanFilter.refresh();
          statusLoadingSubmitLaporan.value = false;
          filterLaporanAbsenTanggal.value = true;
          this.filterLaporanAbsenTanggal.refresh();
          this.statusLoadingSubmitLaporan.refresh();
          groupData();
        }
      }
    });
  }

  void pencarianNamaKaryawan(value) {
    var textCari = value.toLowerCase();
    var filter = allListLaporanFilter.where((laporan) {
      var namaEmployee = laporan['full_name'].toLowerCase();
      return namaEmployee.contains(textCari);
    }).toList();
    listLaporanFilter.value = filter;
    statusCari.value = true;
    this.listLaporanFilter.refresh();
    this.statusCari.refresh();
    groupData();
  }

  void groupData() async {
    listLaporanFilter.value = listLaporanFilter
        .fold(Map<String, List<dynamic>>(), (Map<String, List<dynamic>> a, b) {
          a.putIfAbsent(b['em_id'], () => []).add(b);
          return a;
        })
        .values
        .where((l) => l.isNotEmpty)
        .map((l) => {
              'full_name': l.first['full_name'],
              'job_title': l.first['job_title'],
              'em_id': l.first['em_id'],
              'atten_date': l.first['atten_date'],
              'signin_time': l.first['signin_time'],
              'signout_time': l.first['signout_time'],
              'signin_note': l.first['signin_note'],
              'place_in': l.first['place_in'],
              'place_out': l.first['place_out'],
              'signin_longlat': l.first['signin_longlat'],
              'id': l.first['id_absen'],
              'signout_longlat': l.first['signout_longlat'],
              'is_open': false,
              'data': l
                  .map((e) => {
                        'full_name': e['full_name'],
                        'id': e['id_absen'],
                        'job_title': e['job_title'],
                        'em_id': e['em_id'],
                        'atten_date': e['atten_date'],
                        'signin_time': e['signin_time'],
                        'signout_time': e['signout_time'],
                        'signin_note': e['signin_note'],
                        'place_in': l.first['place_in'],
                        'place_out': l.first['place_out'],
                        'signin_longlat': l.first['signin_longlat'],
                        'signout_longlat': l.first['signout_longlat'],
                      })
                  .toList()
                ..sort((a, b) => b['atten_date'].compareTo(a['atten_date']))
            })
        .toList();
  }

  void pencarianNamaKaryawanTelat(value) {
    var textCari = value.toLowerCase();
    var filter = alllistEmployeeTelat.where((laporan) {
      var namaEmployee = laporan['full_name'].toLowerCase();
      return namaEmployee.contains(textCari);
    }).toList();
    listEmployeeTelat.value = filter;
    statusCari.value = true;
    this.listLaporanFilter.refresh();
    this.statusCari.refresh();
    groupData();
  }

  void pencarianNamaKaryawanBelumAbsen(value) {
    var textCari = value.toLowerCase();
    var filter = allListLaporanBelumAbsen.where((laporan) {
      var namaEmployee = laporan['full_name'].toLowerCase();
      return namaEmployee.contains(textCari);
    }).toList();
    listLaporanBelumAbsen.value = filter;
    statusCari.value = true;
    this.listLaporanFilter.refresh();
    this.statusCari.refresh();
  }

  void widgetButtomSheetFilterData() {
    showModalBottomSheet(
      context: Get.context!,
      isDismissible: false,
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
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 90,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            "Filter",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: IconButton(
                          onPressed: () => Navigator.pop(Get.context!),
                          icon: Icon(Iconsax.close_circle),
                        ),
                      )
                    ],
                  ),
                  Divider(
                    height: 5,
                    color: Constanst.colorText2,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  lineTitleKategori(),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: pageViewKategoriFilter(),
                      )),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget lineTitleKategori() {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                selectedViewFilterAbsen.value = 0;
                pageViewFilterAbsen!.jumpToPage(0);
                this.selectedViewFilterAbsen.refresh();
              },
              child: Container(
                margin: EdgeInsets.only(left: 6, right: 6),
                decoration: BoxDecoration(
                    color: selectedViewFilterAbsen.value == 0
                        ? Constanst.colorPrimary
                        : Colors.transparent,
                    borderRadius: Constanst.borderStyle1),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Bulan',
                      style: TextStyle(
                        color: selectedViewFilterAbsen.value == 0
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                selectedViewFilterAbsen.value = 1;
                pageViewFilterAbsen!.jumpToPage(1);
                this.selectedViewFilterAbsen.refresh();
              },
              child: Container(
                margin: EdgeInsets.only(left: 6, right: 6),
                decoration: BoxDecoration(
                    color: selectedViewFilterAbsen.value == 1
                        ? Constanst.colorPrimary
                        : Colors.transparent,
                    borderRadius: Constanst.borderStyle1),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tanggal',
                      style: TextStyle(
                        color: selectedViewFilterAbsen.value == 1
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget pageViewKategoriFilter() {
    return PageView.builder(
        physics: BouncingScrollPhysics(),
        controller: pageViewFilterAbsen,
        onPageChanged: (index) {
          selectedViewFilterAbsen.value = index;
        },
        itemCount: 2,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.all(0),
              child: index == 0
                  ? filterBulan()
                  : index == 1
                      ? filterTanggal()
                      : SizedBox());
        });
  }

  Widget filterBulan() {
    return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: InkWell(
          onTap: () {
            DatePicker.showPicker(
              Get.context!,
              pickerModel: CustomMonthPicker(
                minTime: DateTime(2000, 1, 1),
                maxTime: DateTime(2100, 1, 1),
                currentTime: DateTime.now(),
              ),
              onConfirm: (time) {
                if (time != null) {
                  print("$time");
                  filterLokasiKoordinate.value = "Lokasi";
                  selectedViewFilterAbsen.value = 0;
                  var filter = DateFormat('yyyy-MM').format(time);
                  var array = filter.split('-');
                  var bulan = array[1];
                  var tahun = array[0];
                  bulanSelectedSearchHistory.value = bulan;
                  tahunSelectedSearchHistory.value = tahun;
                  bulanDanTahunNow.value = "$bulan-$tahun";
                  this.bulanSelectedSearchHistory.refresh();
                  this.tahunSelectedSearchHistory.refresh();
                  this.bulanDanTahunNow.refresh();
                  Navigator.pop(Get.context!);
                  aksiCariLaporan();
                }
              },
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius: Constanst.borderStyle1,
                border: Border.all(color: Constanst.colorText2)),
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(Iconsax.calendar_2),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text(
                              "${Constanst.convertDateBulanDanTahun(bulanDanTahunNow.value)}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget filterTanggal() {
    return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: InkWell(
          onTap: () {
            filterLokasiKoordinate.value = "Lokasi";
            selectedViewFilterAbsen.value = 0;
            DatePicker.showDatePicker(Get.context!,
                showTitleActions: true,
                minTime: DateTime(2000, 1, 1),
                maxTime: DateTime(2100, 1, 1), onConfirm: (date) {
              Navigator.pop(Get.context!);
              pilihTanggalTelatAbsen.value = date;
              this.pilihTanggalTelatAbsen.refresh();
              cariLaporanAbsenTanggal(pilihTanggalTelatAbsen.value);
            }, currentTime: DateTime.now(), locale: LocaleType.en);
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius: Constanst.borderStyle1,
                border: Border.all(color: Constanst.colorText2)),
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(Iconsax.calendar_2),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              "${Constanst.convertDate('${DateFormat('yyyy-MM-dd').format(pilihTanggalTelatAbsen.value)}')}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void faceIdRegistration({faceId, emId}) async {
    try {
      final box = GetStorage();
      box.write("face_recog", true);
      UtilsAlert.showLoadingIndicator(Get.context!);

      Map<String, dynamic> body = {"em_id": emId, "": faceId};
      Map<String, String> headers = {
        'Authorization': Api.basicAuth,
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      print("body" + body.toString());

      final response = await http.post(Uri.parse('${Api.basicUrl}edit_face'),
          body: jsonEncode(body), headers: headers);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data.toString());
        Get.back();

        // print("body " + jsonDecode(response.body.toString()).toString());
        Get.to(BerhasilRegistration());
      }

      // var data = jsonDecode(response.body);

      // if (response.statusCode == 200) {
      //   UtilsAlert.showToast(data['message']);
      //   Navigator.pop(Get.context!);
      // } else {
      //   Navigator.pop(Get.context!);
      //   UtilsAlert.showToast(data['message']);
      // }
    } catch (e) {
      Navigator.pop(Get.context!);
      UtilsAlert.showToast(e.toString());
    }
    // UtilsAlert.showLoadingIndicator(Get.context!);
    // Map<String, dynamic> body = {'face': faceId, 'em_id': emId};

    // var connect = Api.connectionApi("post", body, "edit_face");
    // connect.then((dynamic res) {
    //   if (res.statusCode == 200) {
    //     var valueBody = jsonDecode(res.body);
    //     if (valueBody['status'] == false) {
    //       Navigator.pop(Get.context!);
    //       UtilsAlert.showToast("Data has been saved");
    //     } else {
    //       UtilsAlert.showToast("Eerror");
    //       Navigator.pop(Get.context!);
    //       sysData.value = valueBody['data'];
    //       this.sysData.refresh();
    //     }
    //   }
    // }).catchError((e) {
    //   UtilsAlert.showToast('${e}');
    // });
  }

  void employeDetail() {
    // UtilsAlert.showLoadingIndicator(Get.context!);
    var dataUser = AppData.informasiUser;
    final box = GetStorage();

    var id = dataUser![0].em_id;
    print("em id ${id}");
    Map<String, dynamic> body = {'val': 'em_id', 'cari': id};
    var connect = Api.connectionApi("post", body, "whereOnce-employee");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        bool lastAbsen = AppData.statusAbsen;
        print("ASEE ABSEN ${lastAbsen}");

        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var data = valueBody['data'];
          // isTracking.value = data[0]['em_control'];
          if (lastAbsen == true) {
            if (data[0]['em_control'] == 1) {
              isTracking.value = 1;
            } else {
              isTracking.value = 0;
            }
          } else {
            isTracking.value = 0;
          }
          regType.value = data[0]['reg_type'];
          print("Req tye ${regType.value}");
          box.write("file_face", data[0]['file_face']);

          if (data[0]['file_face'] == "" || data[0]['file_face'] == null) {
            box.write("face_recog", false);
          } else {
            box.write("face_recog", true);
          }
        }
        // Get.back();
      }
    });
  }

  void employeDetaiBpjs() {
    // UtilsAlert.showLoadingIndicator(Get.context!);
    var dataUser = AppData.informasiUser;
    final box = GetStorage();

    var id = dataUser![0].em_id;
    print("em id ${id}");
    Map<String, dynamic> body = {'val': 'em_id', 'cari': id};
    var connect = Api.connectionApi("post", body, "whereOnce-employee");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          var data = valueBody['data'];
          isTracking.value = data[0]['em_control'];
          regType.value = data[0]['reg_type'];
          print("Req tye ${regType.value}");
          box.write("file_face", data[0]['file_face']);

          if (data[0]['file_face'] == "" || data[0]['file_face'] == null) {
            box.write("face_recog", false);
          } else {
            box.write("face_recog", true);
          }
        }
        // Get.back();
      }
    });
  }

  void userShift() {
    // UtilsAlert.showLoadingIndicator(Get.context!);
    var dataUser = AppData.informasiUser;
    final box = GetStorage();

    var id = dataUser![0].em_id;

    var connect = Api.connectionApi("get", "", "setting_shift");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          List data = valueBody['data'];
          print("data setting ${data}");
          if (data.isNotEmpty) {
            shift.value = OfficeShiftModel.fromJson(data[0]);
          }
        }
        // Get.back();
      }
    });
  }

  void widgetButtomSheetFaceRegistrattion() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(5.0),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Tambahkan Data Wajah",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.close))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Pastikan wajah Kamu tidak tertutup dan terlihat jelas. Kamu juga harus berada di ruangan dengan penerangan yang cukup.",
                    style: TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Image.asset(
                    "assets/face-recognition-icon.png",
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Constanst.colorPrimaryLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1,
                          color: Constanst.colorPrimary,
                        )),
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Icon(
                            Icons.info_outline,
                            color: Constanst.colorPrimary,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          flex: 60,
                          child: Text(
                            "Data wajah ini akan digunakan setiap kali Kamu melakukan Absen Masuk dan Keluar.",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextButtonWidget(
                    title: "Mulai",
                    onTap: () async {
                      // Get.to(FaceidRegistration(
                      //   status: "registration",
                      // ));
                      facedDetection(status: "registration");
                      // Get.to(FaceRecognitionView());
                      // if (type == "checkTracking") {
                      //   print('kesini');
                      //   controllerAbsensi.kirimDataAbsensi();
                      // } else {
                      //   Navigator.pop(context);
                      //   await Permission.camera.request();
                      //   await Permission.location.request();
                      // }
                    },
                    colorButton: Constanst.colorButton1,
                    colortext: Constanst.colorWhite,
                    border: BorderRadius.circular(15.0),
                  ),
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
}
