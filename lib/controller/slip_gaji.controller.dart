import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:siscom_operasional/model/compent_slip_gaji.dart';
import 'package:siscom_operasional/model/slip_gaji.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:get/get.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/helper.dart';

class SlipGajiController extends GetxController {
  var slipGaji = <SlipGajiModel>[].obs;
  var slipGajiCurrent = <SlipGajiModel>[].obs;

  var isLoading = true.obs;
  var tahun = DateTime.now().year.obs;
  var gajibulananini = 0.obs;
  var isPemotong = false.obs;
  var isPendapatan = false.obs;
  var isHide = false.obs;
  var bulan = "".obs;
  var args = SlipGajiModel().obs;
  var hideAmount =
      "*********".obs; // var dataPendapatan = <ComponentSlipGajiModel>[].obs;
  // var dataPemotong = <ComponentSlipGajiModel>[].obs;

  var month = [
    'value01',
    'value02',
    'value03',
    'value04',
    'value05',
    'value06',
    'value07',
    'value08',
    'value09',
    'value10',
    'value11',
    'value12'
  ];

  var index = 0;

  @override
  void oninit() {
    super.onInit();
  }

  Future<void> fetchSlipGaji() async {
    var dataUser = AppData.informasiUser;

    var id = dataUser![0].em_id;
    isLoading.value = true;
    slipGaji.value = [];
    Map<String, dynamic> body = {
      'tahun': tahun.value,
      'em_id': id.toString(),
    };

    var connect = Api.connectionApi("post", body, "slip_gaji");
    try {
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          if (valueBody['status'] == true) {
            List pendapatanList = valueBody['data_pendapatan'];
            List pemotongList =
                valueBody['data_pemotongan']; // dataPendapatan.value =
            index = 0;
            month.forEach((element) {
              var pendapatan =
                  pendapatanList.where((item) => item[element] != "0").toList();

              var pemotong = pemotongList
                  .where((item) => item[element.toString()] != "0")
                  .toList();

              // var jumlahPemotong =
              //     pemotong.reduce((a, b) => a[element.toString()] + b);

              int pendapatanSum = pendapatanList.fold(
                  0, (a, b) => a + int.parse(b[element.toString()] ?? "0.0"));

              int pemotongsum = pemotongList.fold(
                  0, (a, b) => a + int.parse(b[element.toString()] ?? "0.0"));

              print("pendapatan ${pemotongsum}");

              slipGaji.add(SlipGajiModel(
                  index: element,
                  monthNumber:
                      int.parse(element.toString().replaceAll("value", "")),
                  month: element == "value01"
                      ? "January"
                      : element == "value02"
                          ? "February"
                          : element == "value03"
                              ? "Maret"
                              : element == "value04"
                                  ? "April"
                                  : element == "value05"
                                      ? "Mei"
                                      : element == "value06"
                                          ? "juni"
                                          : element == "value07"
                                              ? "Juli"
                                              : element == "value08"
                                                  ? "Agustus"
                                                  : element == "value09"
                                                      ? "september"
                                                      : element == "value10"
                                                          ? "Oktober"
                                                          : element == "value11"
                                                              ? "November"
                                                              : "Deseember",
                  amount: pendapatanSum - pemotongsum,
                  pemotong: ComponentSlipGajiModel.fromJsonToList(pemotong),
                  jumlahPemotong: pemotongsum,
                  jumllahPendapatan: pendapatanSum,
                  pendapatan:
                      ComponentSlipGajiModel.fromJsonToList(pendapatan)));
            });
            slipGaji.value =
                slipGaji.value.where((element) => element.amount != 0).toList();
            isLoading.value = false;
          } else {
            isLoading.value = false;
          }
        }
        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> fetchSlipGajiCurrent() async {
    var dataUser = AppData.informasiUser;

    var id = dataUser![0].em_id;
    slipGajiCurrent.value = [];
    Map<String, dynamic> body = {
      'tahun': DateTime.now().year,
      'em_id': id.toString(),
    };

    var connect = Api.connectionApi("post", body, "slip_gaji");
    try {
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          var valueBody = jsonDecode(res.body);
          List pendapatanList = valueBody['data_pendapatan'];
          List pemotongList =
              valueBody['data_pemotongan']; // dataPendapatan.value =
          index = 0;
          month.forEach((element) {
            var pendapatan =
                pendapatanList.where((item) => item[element] != "0").toList();

            var pemotong = pemotongList
                .where((item) => item[element.toString()] != "0")
                .toList();

            // var jumlahPemotong =
            //     pemotong.reduce((a, b) => a[element.toString()] + b);

            int pendapatanSum = pendapatanList.fold(
                0, (a, b) => a + int.parse(b[element.toString()] ?? "0.0"));

            int pemotongsum = pemotongList.fold(
                0, (a, b) => a + int.parse(b[element.toString()] ?? "0.0"));

            slipGajiCurrent.add(SlipGajiModel(
                index: element,
                month: element == "value01"
                    ? "January"
                    : element == "value02"
                        ? "February"
                        : element == "value03"
                            ? "Maret"
                            : element == "value04"
                                ? "April"
                                : element == "value05"
                                    ? "Mei"
                                    : element == "value06"
                                        ? "juni"
                                        : element == "value07"
                                            ? "Juli"
                                            : element == "value08"
                                                ? "Agustus"
                                                : element == "value09"
                                                    ? "september"
                                                    : element == "value10"
                                                        ? "Oktober"
                                                        : element == "value11"
                                                            ? "November"
                                                            : "Deseember",
                amount: pendapatanSum - pemotongsum,
                pemotong: ComponentSlipGajiModel.fromJsonToList(pemotong),
                jumlahPemotong: pemotongsum,
                jumllahPendapatan: pendapatanSum,
                pendapatan: ComponentSlipGajiModel.fromJsonToList(pendapatan)));
          });
          slipGajiCurrent.value = slipGajiCurrent.value
              .where((element) => element.amount != 0)
              .toList();
          isLoading.value = false;
        }
      });
    } catch (e) {
      isLoading.value = false;
    }
  }
}
