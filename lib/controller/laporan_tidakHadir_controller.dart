import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class LaporanTidakHadirController extends GetxController {
  var departemen = TextEditingController().obs;
  var cari = TextEditingController().obs;

  var loadingString = "Memuat data...".obs;
  var idDepartemenTerpilih = "".obs;
  var namaDepartemenTerpilih = "".obs;
  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var title = "".obs;

  var showButtonlaporan = false.obs;
  var statusLoadingSubmitLaporan = false.obs;
  var statusCari = false.obs;

  var jumlahData = 0.obs;
  var selectedType = 0.obs;

  var listDetailLaporanEmployee = [].obs;
  var alllistDetailLaporanEmployee = [].obs;
  var dataTypeAjuan = [].obs;
  var departementAkses = [].obs;
  var allNameLaporanTidakhadir = [].obs;
  var allNameLaporanTidakhadirCopy = [].obs;

  var dataTypeAjuanDummy = ["Semua", "Approve", "Rejected", "Pending"];

  @override
  void onReady() async {
    super.onReady();
    getTimeNow();
    getTypeAjuan();
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
            }
          }
        }
      }
    });
  }

  void aksiCariLaporan() async {
    statusLoadingSubmitLaporan.value = true;
    allNameLaporanTidakhadir.value.clear();
    Map<String, dynamic> body = {
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
      'status': idDepartemenTerpilih.value,
      'type': title.value
    };
    var connect = Api.connectionApi("post", body, "load_laporan_pengajuan");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          statusLoadingSubmitLaporan.value = false;
          UtilsAlert.showToast(
              "Data periode $bulanSelectedSearchHistory belum tersedia, harap hubungi HRD");
        } else {
          var data = valueBody['data'];
          loadingString.value =
              data.length == 0 ? "Data tidak tersedia" : "Memuat data...";
          allNameLaporanTidakhadir.value = data;
          allNameLaporanTidakhadirCopy.value = data;
          this.allNameLaporanTidakhadir.refresh();
          this.allNameLaporanTidakhadirCopy.refresh();
          statusLoadingSubmitLaporan.value = false;
          this.statusLoadingSubmitLaporan.refresh();
        }
      }
    });
  }

  void getTypeAjuan() {
    dataTypeAjuan.value.clear();
    for (var element in dataTypeAjuanDummy) {
      var data = {'nama': element, 'status': false};
      dataTypeAjuan.value.add(data);
    }
    dataTypeAjuan.value
        .firstWhere((element) => element['nama'] == 'Semua')['status'] = true;
    this.dataTypeAjuan.refresh();
  }

  void loadDataTidakHadirEmployee(emId, bulan, tahun, title) {
    listDetailLaporanEmployee.value.clear();
    Map<String, dynamic> body = {
      'em_id': emId,
      'bulan': bulan,
      'tahun': tahun,
      'type': title,
    };
    var connect =
        Api.connectionApi("post", body, "load_detail_laporan_pengajuan");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var data = valueBody['data'];
        listDetailLaporanEmployee.value = data;
        alllistDetailLaporanEmployee.value = data;
        this.listDetailLaporanEmployee.refresh();
        this.alllistDetailLaporanEmployee.refresh();
        loadingString.value = listDetailLaporanEmployee.isEmpty
            ? "Data pengajuan tidak ada"
            : "Memuat data...";
        this.loadingString.refresh();
        typeAjuanRefresh("Semua");
      }
    });
  }

  void typeAjuanRefresh(name) {
    for (var element in dataTypeAjuan.value) {
      if (element['nama'] == name) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    }
    this.dataTypeAjuan.refresh();
  }

  void changeTypeAjuanLaporan(name, title) {
    print(name);
    for (var element in dataTypeAjuan.value) {
      if (element['nama'] == name) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    }
    if (name == "Semua") {
      List data = [];
      for (var element in alllistDetailLaporanEmployee.value) {
        data.add(element);
      }
      listDetailLaporanEmployee.value = data;
      this.listDetailLaporanEmployee.refresh();
      this.selectedType.refresh();
      loadingString.value = listDetailLaporanEmployee.value.length != 0
          ? "Memuat data..."
          : "Tidak ada pengajuan";
      this.loadingString.refresh();
    } else {
      List data = [];
      for (var element in alllistDetailLaporanEmployee.value) {
        if (title == "tidak_hadir" || title == "cuti") {
          if (element['leave_status'] == name) {
            data.add(element);
          }
        } else {
          if (element['status'] == name) {
            data.add(element);
          }
        }
      }
      listDetailLaporanEmployee.value = data;
      this.listDetailLaporanEmployee.refresh();
      this.selectedType.refresh();
      loadingString.value = listDetailLaporanEmployee.value.length != 0
          ? "Memuat data..."
          : "Tidak ada pengajuan";
      this.loadingString.refresh();
    }
  }

  void pencarianNamaKaryawan(value) {
    var textCari = value.toLowerCase();
    var filter = allNameLaporanTidakhadirCopy.where((laporan) {
      var namaEmployee = laporan['full_name'].toLowerCase();
      return namaEmployee.contains(textCari);
    }).toList();
    allNameLaporanTidakhadir.value = filter;
    statusCari.value = true;
    this.allNameLaporanTidakhadir.refresh();
    this.statusCari.refresh();
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
                                  aksiCariLaporan();
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

  void showDetailRiwayat(detailData) {
    var nomorAjuan = detailData['nomor_ajuan'];
    var tanggalMasukAjuan = detailData['atten_date'];
    var namaTypeAjuan = detailData['name'];
    var tanggalAjuanDari = detailData['start_date'];
    var tanggalAjuanSampai = detailData['end_date'];
    var alasan = detailData['reason'];
    var durasi = detailData['leave_duration'];
    var typeAjuan = detailData['leave_status'];
    var listTanggalTerpilih = detailData['date_selected'].split(',');
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 16,
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$namaTypeAjuan",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                              "${Constanst.convertDate("$tanggalMasukAjuan")}"),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 40,
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: typeAjuan == 'Approve'
                                ? Constanst.colorBGApprove
                                : typeAjuan == 'Rejected'
                                    ? Constanst.colorBGRejected
                                    : typeAjuan == 'Pending'
                                        ? Constanst.colorBGPending
                                        : Colors.grey,
                            borderRadius: Constanst.borderStyle1,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 3, right: 3, top: 5, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                typeAjuan == 'Approve'
                                    ? Icon(
                                        Iconsax.tick_square,
                                        color: Constanst.color5,
                                        size: 14,
                                      )
                                    : typeAjuan == 'Rejected'
                                        ? Icon(
                                            Iconsax.close_square,
                                            color: Constanst.color4,
                                            size: 14,
                                          )
                                        : typeAjuan == 'Pending'
                                            ? Icon(
                                                Iconsax.timer,
                                                color: Constanst.color3,
                                                size: 14,
                                              )
                                            : SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Text(
                                    '$typeAjuan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: typeAjuan == 'Approve'
                                            ? Colors.green
                                            : typeAjuan == 'Rejected'
                                                ? Colors.red
                                                : typeAjuan == 'Pending'
                                                    ? Constanst.color3
                                                    : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Divider(
                height: 5,
                color: Constanst.colorText2,
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nomor Ajuan"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(":"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$nomorAjuan"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tanggal izin"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(":"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${Constanst.convertDate("$tanggalAjuanDari")}  SD  ${Constanst.convertDate("$tanggalAjuanSampai")}"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Durasi Izin"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(":"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$durasi Hari"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Alasan"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(":"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$alasan"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Text("Tanggal Terpilih"),
              SizedBox(
                height: 8,
              ),
              ListView.builder(
                  itemCount: listTanggalTerpilih.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var nomor = index + 1;
                    var tanggalConvert =
                        Constanst.convertDate1(listTanggalTerpilih[index]);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$nomor."),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(tanggalConvert),
                        )
                      ],
                    );
                  }),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        );
      },
    );
  }
}
