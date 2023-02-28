import 'dart:convert';

import 'package:get/get.dart';
import 'package:siscom_operasional/screen/absen/detail_absen.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class LaporanAbsenKaryawanController extends GetxController {
  var detailRiwayat = [].obs;
  var AlldetailRiwayat = [].obs;

  var emIdKaryawan = "".obs;
  var bulanSelected = "".obs;
  var namaEmpoloyee = "".obs;
  var loading = "".obs;

  var prosesLoad = false.obs;

  void loadData(emId, bulan, fullName) {
    emIdKaryawan.value = emId;
    bulanSelected.value = bulan;
    namaEmpoloyee.value = fullName;
    this.emIdKaryawan.refresh();
    this.bulanSelected.refresh();
    this.namaEmpoloyee.refresh();
    loadHistoryAbsenEmployee();
  }

  void loadHistoryAbsenEmployee() {
    var listPeriode = bulanSelected.value.split("-");
    var bulan = listPeriode[0];
    var tahun = listPeriode[1];
    detailRiwayat.value.clear();
    Map<String, dynamic> body = {
      'em_id': emIdKaryawan.value,
      'bulan': bulan,
      'tahun': tahun,
    };
    var connect = Api.connectionApi("post", body, "history-attendance");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          List data = valueBody['data'];

          List dataAbsen = [];
          List dataPengajuan = [];

          for (var element in data) {
            if (element['atttype'] == 0) {
              dataPengajuan.add(element);
            } else {
              dataAbsen.add(element);
            }
          }
          List finalFilterPengajuan = [];
          if (dataPengajuan.isNotEmpty) {
            final seen = Set<String>();
            List unique = dataPengajuan
                .where((str) => seen.add(str['atten_date']))
                .toList();
            finalFilterPengajuan = unique;
          }

          List finalAllData = new List.from(dataAbsen)
            ..addAll(finalFilterPengajuan);

          finalAllData.sort((a, b) {
            return DateTime.parse(b['atten_date'])
                .compareTo(DateTime.parse(a['atten_date']));
          });
          detailRiwayat.value = finalAllData;
          AlldetailRiwayat.value = finalAllData;
        }
        this.detailRiwayat.refresh();
        this.AlldetailRiwayat.refresh();
      }
    });
  }

  void historySelected(id_absen, status) {
    var getSelected =
        detailRiwayat.value.firstWhere((element) => element['id'] == id_absen);
    if (getSelected['signin_longlat'] == null ||
        getSelected['signin_longlat'] == "") {
      UtilsAlert.showToast("Terjadi kesalahan terhadap data absen ini");
    } else {
      Get.to(DetailAbsen(
          absenSelected: [getSelected],
          status: true,
          fullName: namaEmpoloyee.value));
    }
  }

  void filterData(id) {
    if (id == '0') {
      detailRiwayat.value = AlldetailRiwayat.value;
      this.detailRiwayat.refresh();
    } else if (id == '1') {
      prosesLoad.value = true;
      var tampung = [];
      for (var element in AlldetailRiwayat.value) {
        print(element);
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
      var seen = Set<String>();
      List t =
          tampung.where((country) => seen.add(country['atten_date'])).toList();

      detailRiwayat.value = t;
      prosesLoad.value = false;
      this.detailRiwayat.refresh();
    } else if (id == '2') {
      prosesLoad.value = true;
      var tampung = [];
      for (var element in AlldetailRiwayat.value) {
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
      detailRiwayat.value = tampung;
      prosesLoad.value = false;
      this.detailRiwayat.refresh();
    } else if (id == '3') {
      prosesLoad.value = true;
      var tampung = [];
      for (var element in AlldetailRiwayat.value) {
        if (element['signout_time'] == '00:00:00') {
          tampung.add(element);
        }
      }
      loading.value =
          tampung.length == 0 ? "Data tidak tersedia" : "Memuat data...";
      detailRiwayat.value = tampung;
      prosesLoad.value = false;
      this.detailRiwayat.refresh();
    }
  }
}
