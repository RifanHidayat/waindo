import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class LaporanTidakHadirController extends GetxController {
  PageController? pageViewFilterWaktu;

  var departemen = TextEditingController().obs;
  var cari = TextEditingController().obs;

  var loadingString = "Memuat data...".obs;
  var idDepartemenTerpilih = "".obs;
  var namaDepartemenTerpilih = "".obs;
  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var title = "".obs;
  var valuePolaPersetujuan = "".obs;
  var filterStatusAjuanTerpilih = "Semua".obs;

  var showButtonlaporan = false.obs;
  var statusLoadingSubmitLaporan = false.obs;
  var statusCari = false.obs;
  var statusFilterWaktu = 0.obs;

  var jumlahData = 0.obs;
  var selectedType = 0.obs;
  var selectedViewFilterPengajuan = 0.obs;

  var listDetailLaporanEmployee = [].obs;
  var alllistDetailLaporanEmployee = [].obs;
  var dataTypeAjuan = [].obs;
  var departementAkses = [].obs;
  var allNameLaporanTidakhadir = [].obs;
  var allNameLaporanTidakhadirCopy = [].obs;

  Rx<DateTime> pilihTanggalFilterAjuan = DateTime.now().obs;

  var dataTypeAjuanDummy1 = ["Semua", "Approve", "Rejected", "Pending"];
  var dataTypeAjuanDummy2 = [
    "Semua",
    "Approve 1",
    "Approve 2",
    "Rejected",
    "Pending"
  ];

  @override
  void onReady() async {
    super.onReady();
    getTimeNow();
    getLoadsysData();
    getDepartemen(1, "");
    filterStatusAjuanTerpilih.value = "Semua";
    selectedViewFilterPengajuan.value = 0;
    pilihTanggalFilterAjuan.value = DateTime.now();
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

  void cariLaporanPengajuanTanggal(tanggalTerpilih) async {
    var tanggalSubmit = "${DateFormat('yyyy-MM-dd').format(tanggalTerpilih)}";
    statusLoadingSubmitLaporan.value = true;
    allNameLaporanTidakhadir.value.clear();
    Map<String, dynamic> body = {
      'atten_date': tanggalSubmit,
      'status': idDepartemenTerpilih.value,
      'type': title.value
    };
    var connect =
        Api.connectionApi("post", body, "load_laporan_pengajuan_harian");
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

  void getLoadsysData() {
    var connect = Api.connectionApi("get", "", "sysdata");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        for (var element in valueBody['data']) {
          if (element['kode'] == "013") {
            valuePolaPersetujuan.value = "${element['name']}";
            this.valuePolaPersetujuan.refresh();
            getTypeAjuan();
          }
        }
      }
    });
  }

  void getTypeAjuan() {
    if (valuePolaPersetujuan.value == "1") {
      dataTypeAjuan.value.clear();
      for (var element in dataTypeAjuanDummy1) {
        var data = {'nama': element, 'status': false};
        dataTypeAjuan.value.add(data);
      }
      dataTypeAjuan.value
          .firstWhere((element) => element['nama'] == 'Semua')['status'] = true;
      this.dataTypeAjuan.refresh();
    } else {
      dataTypeAjuan.value.clear();
      for (var element in dataTypeAjuanDummy2) {
        var data = {'nama': element, 'status': false};
        dataTypeAjuan.value.add(data);
      }
      dataTypeAjuan.value
          .firstWhere((element) => element['nama'] == 'Semua')['status'] = true;
      this.dataTypeAjuan.refresh();
    }
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
        if (title == "tidak_hadir" ||
            title == "cuti" ||
            title == "dinas_luar") {
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
          // padding:
          //       EdgeInsets.fromLTRB(0, AppBar().preferredSize.height, 0, 0),
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
                                if (selectedViewFilterPengajuan.value == 0) {
                                  aksiCariLaporan();
                                } else {
                                  cariLaporanPengajuanTanggal(
                                      pilihTanggalFilterAjuan.value);
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

  showDataStatusAjuan() {
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
                        "Pilih Status Ajuan",
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
                          itemCount: valuePolaPersetujuan.value == "1"
                              ? dataTypeAjuanDummy1.length
                              : dataTypeAjuanDummy2.length,
                          itemBuilder: (context, index) {
                            var name = valuePolaPersetujuan.value == "1"
                                ? dataTypeAjuanDummy1[index]
                                : dataTypeAjuanDummy2[index];
                            return InkWell(
                              onTap: () {
                                if (selectedViewFilterPengajuan.value == 1) {
                                  filterStatusPengajuan(name);
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: "$name" ==
                                              filterStatusAjuanTerpilih.value
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
                                        name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: "$name" ==
                                                    filterStatusAjuanTerpilih
                                                        .value
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

  void filterStatusPengajuan(name) {
    List listFilterLokasi = [];
    for (var element in allNameLaporanTidakhadirCopy.value) {
      if (name == "Semua") {
        listFilterLokasi.add(element);
      } else {
        if (title == "lembur" || title == "tugas_luar") {
          if (element['status'] == name) {
            listFilterLokasi.add(element);
          }
        } else {
          if (element['leave_status'] == name) {
            listFilterLokasi.add(element);
          }
        }
      }
    }
    allNameLaporanTidakhadir.value = listFilterLokasi;
    filterStatusAjuanTerpilih.value = name;
    this.allNameLaporanTidakhadir.refresh();
    this.filterStatusAjuanTerpilih.refresh();
    loadingString.value = allNameLaporanTidakhadir.value.length != 0
        ? "Memuat data..."
        : "Tidak ada pengajuan";
    Navigator.pop(Get.context!);
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
                selectedViewFilterPengajuan.value = 0;
                pageViewFilterWaktu!.jumpToPage(0);
                this.selectedViewFilterPengajuan.refresh();
              },
              child: Container(
                margin: EdgeInsets.only(left: 6, right: 6),
                decoration: BoxDecoration(
                    color: selectedViewFilterPengajuan.value == 0
                        ? Constanst.colorPrimary
                        : Colors.transparent,
                    borderRadius: Constanst.borderStyle1),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Bulan',
                      style: TextStyle(
                        color: selectedViewFilterPengajuan.value == 0
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
                selectedViewFilterPengajuan.value = 1;
                pageViewFilterWaktu!.jumpToPage(1);
                this.selectedViewFilterPengajuan.refresh();
              },
              child: Container(
                margin: EdgeInsets.only(left: 6, right: 6),
                decoration: BoxDecoration(
                    color: selectedViewFilterPengajuan.value == 1
                        ? Constanst.colorPrimary
                        : Colors.transparent,
                    borderRadius: Constanst.borderStyle1),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tanggal',
                      style: TextStyle(
                        color: selectedViewFilterPengajuan.value == 1
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
        controller: pageViewFilterWaktu,
        onPageChanged: (index) {
          selectedViewFilterPengajuan.value = index;
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
                  statusFilterWaktu.value = 0;
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
              statusFilterWaktu.value = 1;
              pilihTanggalFilterAjuan.value = date;
              this.pilihTanggalFilterAjuan.refresh();
              cariLaporanPengajuanTanggal(pilihTanggalFilterAjuan.value);
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
                              "${Constanst.convertDate('${DateFormat('yyyy-MM-dd').format(pilihTanggalFilterAjuan.value)}')}",
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

  void showDetailRiwayat(detailData) {
    var nomorAjuan = detailData['nomor_ajuan'];
    var get2StringNomor = '${nomorAjuan[0]}${nomorAjuan[1]}';
    var tanggalMasukAjuan = detailData['atten_date'];
    var namaTypeAjuan = detailData['name'];
    var tanggalAjuanDari = detailData['start_date'];
    var tanggalAjuanSampai = detailData['end_date'];
    var alasan = detailData['reason'];
    var durasi = detailData['leave_duration'];
    var typeAjuan;
    if (valuePolaPersetujuan.value == "1") {
      typeAjuan = detailData['leave_status'];
    } else {
      typeAjuan = detailData['leave_status'] == "Approve"
          ? "Approve 1"
          : detailData['leave_status'] == "Approve2"
              ? "Approve 2"
              : detailData['leave_status'];
    }
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
                          get2StringNomor == "DL"
                              ? Text(
                                  "DINAS LUAR",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  "$namaTypeAjuan",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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
                                : typeAjuan == 'Approve 1'
                                    ? Constanst.colorBGApprove
                                    : typeAjuan == 'Approve 2'
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
                                    : typeAjuan == 'Approve 1'
                                        ? Icon(
                                            Iconsax.tick_square,
                                            color: Constanst.color5,
                                            size: 14,
                                          )
                                        : typeAjuan == 'Approve 2'
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
                                            : typeAjuan == 'Approve 1'
                                                ? Colors.green
                                                : typeAjuan == 'Approve 2'
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
