import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:siscom_operasional/model/absen_model.dart';
import 'package:siscom_operasional/screen/absen/berhasil_absen.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
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
  var listLaporanBelumAbsen = [].obs;
  var allListLaporanBelumAbsen = [].obs;
  var listEmployeeTelat = [].obs;
  var alllistEmployeeTelat = [].obs;
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
  var jumlahData = 0.obs;

  Rx<DateTime> pilihTanggalTelatAbsen = DateTime.now().obs;

  var latUser = 0.0.obs;
  var langUser = 0.0.obs;

  var typeAbsen = 0.obs;

  var imageStatus = false.obs;
  var detailAlamat = false.obs;
  var mockLocation = false.obs;
  var showButtonlaporan = false.obs;
  var statusLoadingSubmitLaporan = false.obs;

  var absenStatus = false.obs;

  @override
  void onReady() async {
    getTimeNow();
    loadHistoryAbsenUser();
    getDepartemen(1, "");
    super.onReady();
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
          placeCoordinate.value = valueBody['data'];
          for (var element in valueBody['data']) {
            placeCoordinateDropdown.value.add(element['place']);
          }
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
          if (filterTelat.isEmpty) {
            loading.value = "Data tidak tersedia";
          } else {
            loading.value = "Memuat Data...";
          }
          jumlahData.value = filterTelat.length;
          listEmployeeTelat.value = filterTelat;
          alllistEmployeeTelat.value = filterTelat;
          this.jumlahData.refresh();
          this.listEmployeeTelat.refresh();
          this.alllistEmployeeTelat.refresh();
          this.loading.refresh();
          statusLoadingSubmitLaporan.value = false;
          this.statusLoadingSubmitLaporan.refresh();
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
          if (data.isEmpty) {
            loading.value = "Data tidak tersedia";
          } else {
            loading.value = "Memuat Data...";
          }
          jumlahData.value = valueBody['jumlah'];
          listLaporanBelumAbsen.value = data;
          allListLaporanBelumAbsen.value = data;
          this.jumlahData.refresh();
          this.listLaporanBelumAbsen.refresh();
          this.allListLaporanBelumAbsen.refresh();
          this.loading.refresh();
          statusLoadingSubmitLaporan.value = false;
          this.statusLoadingSubmitLaporan.refresh();
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
          var data = valueBody['data'];
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
          this.historyAbsen.refresh();
        } else {
          loading.value = "Data tidak ditemukan";
        }
      }
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

  void filterDataArray() {
    var data = departementAkses.value;
    var seen = Set<String>();
    List filter = data.where((divisi) => seen.add(divisi['name'])).toList();
    departementAkses.value = filter;
    this.departementAkses.refresh();
  }

  showDataDepartemenAkses() {
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
            padding:
                EdgeInsets.fromLTRB(0, AppBar().preferredSize.height, 0, 0),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 16,
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
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
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
                                              fontWeight: FontWeight.bold),
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
            ),
          );
        });
  }

  void carilaporanAbsenkaryawan() {
    if (departemen.value.text == "") {
      UtilsAlert.showToast("Lengkapi form");
    } else {
      aksiCariLaporan();
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
}
