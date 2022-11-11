import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class GlobalController extends GetxController {
  var valuePolaPersetujuan = "".obs;
  var konfirmasiAtasan = [].obs;
  var sysData = [].obs;
  var employeeSisaCuti = [].obs;

  @override
  void onReady() async {
    getLoadsysData();
    super.onReady();
  }

  void getLoadsysData() {
    var connect = Api.connectionApi("get", "", "sysdata");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        sysData.value = valueBody['data'];
        this.sysData.refresh();
        loadAllReportTo();
        loadAllSisaCuti();
      }
    });
  }

  void loadAllReportTo() async {
    // validasi multi persetujuan
    var statusPersetujuan = "";
    for (var element in sysData.value) {
      if (element['kode'] == "013") {
        statusPersetujuan = "${element['name']}";
      }
    }
    valuePolaPersetujuan.value = statusPersetujuan;
    this.valuePolaPersetujuan.refresh();
    print("di kontroller global ${valuePolaPersetujuan.value}");
    // em id user
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {'em_id': getEmid, 'kode': statusPersetujuan};
    var connect = Api.connectionApi("post", body, "informasi_wa_atasan");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        var seen = Set<String>();
        List filter =
            data.where((atasan) => seen.add(atasan['full_name'])).toList();
        konfirmasiAtasan.value = filter;
        this.konfirmasiAtasan.refresh();
      }
    });
  }

  void loadAllSisaCuti() {
    var statusReminder = "";
    for (var element in sysData.value) {
      if (element['kode'] == "015") {
        statusReminder = "${element['name']}";
      }
    }
    Map<String, dynamic> body = {'reminder': statusReminder};
    var connect = Api.connectionApi("post", body, "info_sisa_kontrak");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        employeeSisaCuti.value = valueBody['data'];
        this.employeeSisaCuti.refresh();
      }
    });
  }

  showDataPilihAtasan(dataEmployee) {
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
                        "Konfirmasi via whatsapp",
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
                          itemCount: konfirmasiAtasan.value.length,
                          itemBuilder: (context, index) {
                            var full_name =
                                konfirmasiAtasan.value[index]['full_name'];
                            var job_title =
                                konfirmasiAtasan.value[index]['job_title'];
                            var gambar =
                                konfirmasiAtasan.value[index]['em_image'];
                            var nohp =
                                konfirmasiAtasan.value[index]['em_mobile'];
                            var jeniKelamin =
                                konfirmasiAtasan.value[index]['em_gender'];
                            return InkWell(
                              onTap: () {
                                kirimKonfirmasiWa(
                                    dataEmployee, full_name, nohp, jeniKelamin);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 15,
                                        child: gambar == ""
                                            ? Image.asset(
                                                'assets/avatar_default.png',
                                                width: 40,
                                                height: 40,
                                              )
                                            : CircleAvatar(
                                                radius: 25, // Image radius
                                                child: ClipOval(
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          Api.UrlfotoProfile +
                                                              "$gambar",
                                                      progressIndicatorBuilder:
                                                          (context, url,
                                                                  downloadProgress) =>
                                                              Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        'assets/avatar_default.png',
                                                        width: 40,
                                                        height: 40,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                      Expanded(
                                        flex: 75,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "$full_name",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                "$job_title",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Center(
                                          child: Image.asset(
                                            'assets/whatsapp.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      ),
                                    ],
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

  void kirimKonfirmasiWa(
      dataEmployee, namaAtasan, nomorAtasan, jeniKelamin) async {
    print('jenis kelamin $jeniKelamin');
    print('nomor atasan $nomorAtasan');
    if (nomorAtasan == "" || nomorAtasan == null || nomorAtasan == "null") {
      UtilsAlert.showToast("Nomor wa atasan tidak valid");
    } else {
      var dataUser = AppData.informasiUser;
      var getEmid = dataUser![0].em_id;
      var getFullName = dataUser[0].full_name;
      var pesan;
      if (jeniKelamin == "PRIA") {
        pesan =
            "Hallo pak ${namaAtasan}, saya ${getFullName} mengajukan ${dataEmployee['nameType']} dengan nomor ajuan ${dataEmployee['nomor_ajuan']}";
      } else {
        pesan =
            "Hallo bu ${namaAtasan}, saya ${getFullName} mengajukan ${dataEmployee['nameType']} dengan nomor ajuan ${dataEmployee['nomor_ajuan']}";
      }
      var gabunganPesan = pesan;
      var notujuan = nomorAtasan;
      var filternohp = notujuan.substring(1);
      var kodeNegara = 62;
      var gabungNohp = "$kodeNegara$filternohp";

      var whatsappURl_android =
          "whatsapp://send?phone=$gabungNohp&text=${Uri.parse(gabunganPesan)}";
      var whatappURL_ios =
          "https://wa.me/$gabungNohp?text=${Uri.parse(gabunganPesan)}";

      if (Platform.isIOS) {
        // for iOS phone only
        final url = Uri.parse(whatappURL_ios);
        if (!await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        )) {
          UtilsAlert.showToast('Terjadi kesalahan $whatappURL_ios');
        }
      } else {
        // android , web
        final url = Uri.parse(whatsappURl_android);
        if (!await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        )) {
          UtilsAlert.showToast('Terjadi kesalahan $whatsappURl_android');
        }
      }
    }
  }

  void kirimUcapanWa(message, nomorUltah) async {
    if (nomorUltah == "" || nomorUltah == null || nomorUltah == "null") {
      UtilsAlert.showToast("Nomor wa atasan tidak valid");
    } else {
      var dataUser = AppData.informasiUser;
      var getEmid = dataUser![0].em_id;
      var getFullName = dataUser[0].full_name;
      var gabunganPesan = message;
      var notujuan = nomorUltah;
      var filternohp = notujuan.substring(1);
      var kodeNegara = 62;
      var gabungNohp = "$kodeNegara$filternohp";

      var whatsappURl_android =
          "whatsapp://send?phone=" + gabungNohp + "&text=" + gabunganPesan;
      var whatappURL_ios =
          "https://wa.me/$gabungNohp?text=${Uri.parse(gabunganPesan)}";

      if (Platform.isIOS) {
        // for iOS phone only
        if (await canLaunch(whatappURL_ios)) {
          await launch(whatappURL_ios, forceSafariVC: false);
        } else {
          UtilsAlert.showToast("Whatsapp tidak terinstall");
        }
      } else {
        // android , web
        if (await canLaunch(whatsappURl_android)) {
          await launch(whatsappURl_android);
        } else {
          UtilsAlert.showToast("Whatsapp tidak terinstall");
        }
      }
    }
  }
}
