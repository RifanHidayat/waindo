import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:siscom_operasional/model/setting_app_model.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/login.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/onboard.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class KontrolController extends GetxController {
  var tanggalPilihKontrol = TextEditingController().obs;
  var departemen = TextEditingController().obs;
  var cari = TextEditingController().obs;

  Rx<DateTime> initialDate = DateTime.now().obs;

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var idDepartemenTerpilih = "".obs;
  var namaDepartemenTerpilih = "".obs;

  var jumlahData = 0.obs;
  var selectedType = 0.obs;
  var jumlahKontrol = 0.obs;

  var showViewKontrol = false.obs;
  var statusCari = false.obs;

  var departementAkses = [].obs;

  @override
  void onReady() async {
    super.onReady();
    getTimeNow();
    getDepartemen(1, "");
  }

  void getTimeNow() {
    var dt = DateTime.now();
    var outputFormat1 = DateFormat('MM');
    var outputFormat2 = DateFormat('yyyy');
    bulanSelectedSearchHistory.value = outputFormat1.format(dt);
    tahunSelectedSearchHistory.value = outputFormat2.format(dt);
    bulanDanTahunNow.value =
        "${bulanSelectedSearchHistory.value}-${tahunSelectedSearchHistory.value}";
    tanggalPilihKontrol.value.text = Constanst.convertDate("$dt");
    tanggalPilihKontrol.refresh();
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
              showViewKontrol.value = true;
              // aksiCariLaporan();
            }
          }
        }
      }
    });
  }

  // void callbackDispatcher() {
  //   Workmanager.executeTask((task, inputData) async {
  //     switch (task) {
  //       case fetchBackground:
  //         Position userLocation = await Geolocator()
  //             .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //         notif.Notification notification = new notif.Notification();
  //         notification.showNotificationWithoutSound(userLocation);
  //         break;
  //     }
  //     return Future.value(true);
  //   });
  // }

  void loadControlUser() {
    print("mulai di kontrol");
    print(jumlahKontrol.value);
    // Workmanager().registerPeriodicTask(
    //   "periodic-task-identifier",
    //   "simplePeriodicTask",
    //   // When no frequency is provided the default 15 minutes is set.
    //   // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
    //   frequency: Duration(seconds: 5),
    // );
    Future.delayed(Duration(seconds: 10), () {
      // getPosisition(getEmid);
    });
  }

  void getPosisition(getEmid) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      var latUser = position.latitude;
      var langUser = position.longitude;
      var alamatUser =
          "${placemarks[0].street} ${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}";
      jumlahKontrol.value = jumlahKontrol.value + 1;
      this.jumlahKontrol.refresh();
      var now = DateTime.now();
      var getJam = DateFormat('HH:mm:ss').format(now);
      var tanggal = DateFormat('yyyy-MM-dd').format(now);
      kirimDataKontrol(latUser, langUser, alamatUser, getJam, tanggal, getEmid);
    } on Exception catch (e) {}
  }

  void kirimDataKontrol(latUser, langUser, alamatUser, jam, tanggal, getEmid) {
    var latLangUserKontrol = "$latUser,$langUser";
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'atten_date': tanggal,
      'jam': jam,
      'latLangKontrol': latLangUserKontrol,
      'alamat': alamatUser,
    };
    var connect =
        Api.connectionApi("post", body, "insert_emp_control_employee");
    connect.then((dynamic res) {
      var valueBody = jsonDecode(res.body);
      print(valueBody);
      // loadControlUser();
    });
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
            padding:
                EdgeInsets.fromLTRB(0, AppBar().preferredSize.height, 0, 0),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                  // aksiCariLaporan();
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
}
