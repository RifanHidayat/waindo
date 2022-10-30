import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/model/absen_model.dart';
import 'package:siscom_operasional/screen/absen/berhasil_absen.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:google_maps_utils/google_maps_utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:trust_location/trust_location.dart';

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

  var jumlahData = 0.obs;
  var selectedViewFilterAbsen = 0.obs;

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

  @override
  void onReady() async {
    getTimeNow();
    getLoadsysData();
    loadHistoryAbsenUser();
    getDepartemen(1, "");
    filterLokasiKoordinate.value = "Lokasi";
    selectedViewFilterAbsen.value = 0;
    pilihTanggalTelatAbsen.value = DateTime.now();
    super.onReady();
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
    var connect = Api.connectionApi("get", {}, "places_coordinate");
    connect.then((dynamic res) {
      if (res == false) {
        UtilsAlert.koneksiBuruk();
      } else {
        if (res.statusCode == 200) {
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
          this.placeCoordinate.refresh();
          this.placeCoordinate.refresh();
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
      'atten_date': tanggal,
      'status': idDepartemenTerpilih.value
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
              for (var element in sysData.value) {
                if (element['kode'] == '006') {
                  intervalControl.value = int.parse(element['name']);
                }
              }
              this.intervalControl.refresh();
              print("dapat interval ${intervalControl.value}");
              Navigator.pop(Get.context!);
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
    var getEmpId = dataUser![0].em_id;
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
              var valueNonTurunan = [];
              var valueTurunan = [];
              var stringDateAdaTurunan = "";
              int nomorAdaTurunan = 0;
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
                  };
                  stringDateAdaTurunan = "${element1.atten_date}";
                  valueTurunan.add(dataTurunan);
                } else {
                  var dataNonTurunan = {
                    'id': element1.id,
                    'signin_time': element1.signin_time,
                    'signout_time': element1.signout_time,
                    'atten_date': element1.atten_date,
                    'place_in': element1.place_in,
                    'place_out': element1.place_out,
                    'signin_note': element1.signin_note,
                    'signin_longlat': element1.signin_longlat,
                    'signout_longlat': element1.signout_longlat,
                  };
                  valueNonTurunan.add(dataNonTurunan);
                }
              }
              var lengthTurunan = valueTurunan.length == 0 ? false : true;
              if (lengthTurunan == false) {
                var data = {
                  'id': valueNonTurunan[0]['id'],
                  'signin_time': valueNonTurunan[0]['signin_time'],
                  'signout_time': valueNonTurunan[0]['signout_time'],
                  'atten_date': valueNonTurunan[0]['atten_date'],
                  'place_in': valueNonTurunan[0]['place_in'],
                  'place_out': valueNonTurunan[0]['place_out'],
                  'signin_note': valueNonTurunan[0]['signin_note'],
                  'signin_longlat': valueNonTurunan[0]['signin_longlat'],
                  'signout_longlat': valueNonTurunan[0]['signout_longlat'],
                  'view_turunan': lengthTurunan,
                  'turunan': valueTurunan,
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
                  'turunan': valueTurunan,
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
}
