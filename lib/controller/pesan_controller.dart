import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/screen/pesan/approval.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class PesanController extends GetxController {
  PageController menuController = PageController(initialPage: 0);
  RefreshController refreshController = RefreshController(initialRefresh: true);

  var selectedView = 0.obs;

  var listNotifikasi = [].obs;
  var dataScreenPersetujuan = [].obs;
  var riwayatPersetujuan = [].obs;
  var allRiwayatPersetujuan = [].obs;

  var jumlahApproveCuti = 0.obs;
  var jumlahApproveLembur = 0.obs;
  var jumlahApproveTidakHadir = 0.obs;
  var jumlahApproveTugasLuar = 0.obs;
  var jumlahNotifikasiBelumDibaca = 0.obs;
  var jumlahPersetujuan = 0.obs;
  var jumlahRiwayat = 0.obs;

  var stringLoading = "Memuat Data...".obs;
  var stringFilterSelected = "".obs;
  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;

  var statusScreenInfoApproval = false.obs;
  var statusFilteriwayat = false.obs;
  var listDummy = ["Cuti", "Lembur", "Tidak Hadir", "Tugas Luar"];

  @override
  void onReady() async {
    getTimeNow();
    loadNotifikasi();
    super.onReady();
  }

  void routesIcon() {
    selectedView.value = 0;
  }

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";

    this.bulanSelectedSearchHistory.refresh();
    this.tahunSelectedSearchHistory.refresh();
    this.bulanDanTahunNow.refresh();
    loadApproveInfo();
    loadApproveHistory();
  }

  void loadApproveInfo() {
    statusScreenInfoApproval.value = true;
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "load_approve_info");
    connect.then((dynamic res) async {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          jumlahApproveCuti.value = valueBody['jumlah_cuti'];
          jumlahApproveLembur.value = valueBody['jumlah_lembur'];
          jumlahApproveTidakHadir.value = valueBody['jumlah_tidak_hadir'];
          jumlahApproveTugasLuar.value = valueBody['jumlah_tugasluar'];
          jumlahPersetujuan.value = jumlahApproveCuti.value +
              jumlahApproveLembur.value +
              jumlahApproveTidakHadir.value +
              jumlahApproveTugasLuar.value;
          this.jumlahApproveCuti.refresh();
          this.jumlahApproveLembur.refresh();
          this.jumlahApproveTidakHadir.refresh();
          this.jumlahApproveTugasLuar.refresh();
          this.jumlahPersetujuan.refresh();
          loadScreenPersetujuan();
        } else {
          statusScreenInfoApproval.value = false;
          UtilsAlert.showToast(
              "Data periode ${bulanSelectedSearchHistory.value}-${tahunSelectedSearchHistory.value} belum tersedia, harap hubungi HRD");
        }
      }
    });
  }

  void loadApproveHistory() {
    riwayatPersetujuan.value.clear();
    allRiwayatPersetujuan.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
    };
    var connect = Api.connectionApi("post", body, "load_approve_history");
    connect.then((dynamic res) async {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          var tampungRiwayatPersetujuan = [];
          if (valueBody['data_tidak_hadir'].length != 0) {
            for (var element in valueBody['data_tidak_hadir']) {
              if (element['leave_status'] != 'Pending') {
                var fullName = element['full_name'] ?? "";
                var convertNama = "$fullName";
                var tanggalDari =
                    Constanst.convertDate1("${element['start_date']}");
                var tanggalSampai =
                    Constanst.convertDate1("${element['end_date']}");
                var tipe = element['typeid'] == 12 ? 'Izin' : 'Sakit';
                var data = {
                  'id': element['id'],
                  'nama_pengaju': convertNama,
                  'title_ajuan': 'Pengajuan Tidak Hadir',
                  'waktu_dari': tanggalDari,
                  'waktu_sampai': tanggalSampai,
                  'durasi': element['leave_duration'],
                  'waktu_pengajuan': element['atten_date'],
                  'catatan': element['reason'],
                  'status': element['leave_status'],
                  'apply_date': element['apply_date'],
                  'apply_by': element['apply_by'],
                  'alasan_reject': element['alasan_reject'],
                  'type': tipe,
                  'file': element['leave_files']
                };
                tampungRiwayatPersetujuan.add(data);
              }
            }
          }
          if (valueBody['data_cuti'].length != 0) {
            for (var element in valueBody['data_cuti']) {
              if (element['leave_status'] != 'Pending') {
                var fullName = element['full_name'] ?? "";
                var convertNama = "$fullName";
                var tanggalDari =
                    Constanst.convertDate1("${element['start_date']}");
                var tanggalSampai =
                    Constanst.convertDate1("${element['end_date']}");
                var data = {
                  'id': element['id'],
                  'nama_pengaju': convertNama,
                  'title_ajuan': 'Pengajuan Cuti',
                  'waktu_dari': tanggalDari,
                  'waktu_sampai': tanggalSampai,
                  'durasi': element['leave_duration'],
                  'waktu_pengajuan': element['atten_date'],
                  'catatan': element['reason'],
                  'status': element['leave_status'],
                  'apply_date': element['apply_date'],
                  'apply_by': element['apply_by'],
                  'alasan_reject': element['alasan_reject'],
                  'type': 'Cuti',
                  'file': element['leave_files']
                };
                tampungRiwayatPersetujuan.add(data);
              }
            }
          }
          if (valueBody['data_lembur'].length != 0) {
            for (var element in valueBody['data_lembur']) {
              if (element['status'] != 'Pending') {
                var fullName = element['full_name'] ?? "";
                var convertNama = "$fullName";
                var data = {
                  'id': element['id'],
                  'nama_pengaju': convertNama,
                  'title_ajuan': 'Pengajuan Lembur',
                  'waktu_dari': element['dari_jam'],
                  'waktu_sampai': element['sampai_jam'],
                  'durasi': "",
                  'waktu_pengajuan': element['atten_date'],
                  'catatan': element['uraian'],
                  'status': element['status'],
                  'apply_date': element['approve_date'],
                  'apply_by': element['approve_by'],
                  'alasan_reject': element['alasan_reject'],
                  'type': 'Lembur',
                  'file': ""
                };
                tampungRiwayatPersetujuan.add(data);
              }
            }
          }
          if (valueBody['data_tugas_luar'].length != 0) {
            for (var element in valueBody['data_tugas_luar']) {
              if (element['status'] != 'Pending') {
                var fullName = element['full_name'] ?? "";
                var convertNama = "$fullName";
                var data = {
                  'id': element['id'],
                  'nama_pengaju': convertNama,
                  'title_ajuan': 'Pengajuan Tugas Luar',
                  'waktu_dari': element['dari_jam'],
                  'waktu_sampai': element['sampai_jam'],
                  'durasi': '',
                  'waktu_pengajuan': element['atten_date'],
                  'catatan': element['uraian'],
                  'status': element['status'],
                  'apply_date': element['approve_date'],
                  'apply_by': element['approve_by'],
                  'alasan_reject': element['alasan_reject'],
                  'type': 'Tugas Luar',
                  'file': ''
                };
                tampungRiwayatPersetujuan.add(data);
              }
            }
          }
          if (tampungRiwayatPersetujuan.length != 0) {
            allRiwayatPersetujuan.value = tampungRiwayatPersetujuan;
            var listTanggal = [];
            var finalData = [];
            for (var element in tampungRiwayatPersetujuan) {
              listTanggal.add(element['waktu_pengajuan']);
            }
            listTanggal = listTanggal.toSet().toList();
            for (var element in listTanggal) {
              var valueTurunan = [];
              for (var element1 in tampungRiwayatPersetujuan) {
                if (element == element1['waktu_pengajuan']) {
                  valueTurunan.add(element1);
                }
              }
              var data = {
                'waktu_pengajuan': element,
                'turunan': valueTurunan,
              };
              finalData.add(data);
            }
            finalData.sort((a, b) {
              return DateTime.parse(b['waktu_pengajuan'])
                  .compareTo(DateTime.parse(a['waktu_pengajuan']));
            });
            riwayatPersetujuan.value = finalData;
          }
          jumlahRiwayat.value = allRiwayatPersetujuan.value.length;
          this.riwayatPersetujuan.refresh();
          this.allRiwayatPersetujuan.refresh();
          this.jumlahRiwayat.refresh();
        }
      }
    });
  }

  void filterApproveHistory(title) {
    riwayatPersetujuan.value.clear();
    var data = [];
    allRiwayatPersetujuan.forEach((element) {
      if (element['title_ajuan'] == title) {
        data.add(element);
      }
    });
    data.sort((a, b) {
      return DateTime.parse(b['waktu_pengajuan'])
          .compareTo(DateTime.parse(a['waktu_pengajuan']));
    });
    if (data.length != 0) {
      riwayatPersetujuan.value = data;
      statusFilteriwayat.value = true;
      stringFilterSelected.value = title;
      this.riwayatPersetujuan.refresh();
      this.statusFilteriwayat.refresh();
      this.stringFilterSelected.refresh();
    } else {
      UtilsAlert.showToast('Data tidak ditemukan');
    }
  }

  void clearFilter() {
    UtilsAlert.loadingSimpanData(Get.context!, "Hapus Filter");
    statusFilteriwayat.value = false;
    riwayatPersetujuan.value.clear();
    allRiwayatPersetujuan.value.clear();
    loadApproveHistory();
    Navigator.pop(Get.context!);
    this.statusFilteriwayat.refresh();
    this.riwayatPersetujuan.refresh();
    this.allRiwayatPersetujuan.refresh();
  }

  void loadScreenPersetujuan() {
    dataScreenPersetujuan.value.clear();
    for (var element in listDummy) {
      if (element == "Cuti") {
        var data = {
          'title': element,
          'jumlah_approve': "${jumlahApproveCuti.value}",
        };
        dataScreenPersetujuan.value.add(data);
        this.dataScreenPersetujuan.refresh();
      } else if (element == "Lembur") {
        var data = {
          'title': element,
          'jumlah_approve': "${jumlahApproveLembur.value}",
        };
        dataScreenPersetujuan.value.add(data);
        this.dataScreenPersetujuan.refresh();
      } else if (element == "Tidak Hadir") {
        var data = {
          'title': element,
          'jumlah_approve': "${jumlahApproveTidakHadir.value}",
        };
        dataScreenPersetujuan.value.add(data);
        this.dataScreenPersetujuan.refresh();
      } else if (element == "Tugas Luar") {
        var data = {
          'title': element,
          'jumlah_approve': "${jumlahApproveTugasLuar.value}",
        };
        dataScreenPersetujuan.value.add(data);
        this.dataScreenPersetujuan.refresh();
      }
    }
    statusScreenInfoApproval.value = false;
  }

  void routeApproval(index) {
    print(index);
    if (index['jumlah_approve'] == "0") {
      UtilsAlert.showToast("Tidak ada data yang harus di approve");
    } else {
      Get.to(Approval(
        title: index['title'],
        bulan: bulanSelectedSearchHistory.value,
        tahun: tahunSelectedSearchHistory.value,
      ));
    }
  }

  void loadNotifikasi() {
    listNotifikasi.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    var dt = DateTime.now();
    var tanggalSekarang =
        Constanst.convertDate1("${dt.year}-${dt.month}-${dt.day}");
    var getBulan = dt.month <= 9 ? "0${dt.month}" : dt.month;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': getBulan,
      'tahun': dt.year
    };
    var connect = Api.connectionApi("post", body, "load_notifikasi");
    connect.then((dynamic res) async {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        for (var element in valueBody['data']) {
          var tanggalDataApi = Constanst.convertDate1("${element['tanggal']}");
          var filterTanggal =
              tanggalDataApi == tanggalSekarang ? 'Hari ini' : tanggalDataApi;
          var data = {
            'tanggal': filterTanggal,
            'notifikasi': element['notifikasi'],
          };
          listNotifikasi.value.add(data);
          hitungNotifikasiBelumDibaca();
        }
        this.listNotifikasi.refresh();
      }
    });
  }

  void hitungNotifikasiBelumDibaca() {
    var data = [];
    listNotifikasi.value.forEach((element) {
      element['notifikasi'].forEach((element1) {
        if (element1['view'] == 0) {
          data.add(element1);
        }
      });
    });
    jumlahNotifikasiBelumDibaca.value = data.length;
    this.jumlahNotifikasiBelumDibaca.refresh();
  }

  void aksilihatNotif(id) {
    var pisahkanData = [];
    listNotifikasi.value.forEach((element) {
      element['notifikasi'].forEach((element1) {
        if (element1['id'] == id) {
          element1['view'] = 1;
          pisahkanData.add(element1);
        }
      });
    });
    this.listNotifikasi.refresh();
    hitungNotifikasiBelumDibaca();
    updateDataNotif(pisahkanData);
  }

  void redirectToPage(url) {
    var dashboardController = Get.find<DashboardController>();
    dashboardController.routePageDashboard(url);
  }

  void updateDataNotif(data) {
    Map<String, dynamic> body = {
      "em_id": data[0]['em_id'],
      "title": data[0]['title'],
      "deskripsi": data[0]['deskripsi'],
      "url": data[0]['url'],
      "atten_date": data[0]['atten_date'],
      "jam": data[0]['jam'],
      "status": data[0]['status'],
      "view": data[0]['view'],
      "val": 'id',
      "cari": data[0]['id']
    };
    var connect = Api.connectionApi("post", body, "edit-notifikasi");
    connect.then((dynamic res) async {
      if (res.statusCode == 200) {
        print("berhasil ganti status notif");
      }
    });
  }

  void filterDetailRiwayatApproval(id, type) {
    var dataDetail = [];
    allRiwayatPersetujuan.forEach((element) {
      if (element['id'] == id && element['type'] == type) {
        dataDetail.add(element);
      }
    });
    if (dataDetail.length != 0) {
      showDetailRiwayatApproval(dataDetail);
    } else {
      UtilsAlert.showToast('Data tidak tersedia');
    }
  }

  void showDetailRiwayatApproval(dataDetail) {
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 90,
                    child: Text(
                      "Detail Riwayat",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(Get.context!);
                        },
                        child: Icon(
                          Iconsax.close_circle,
                          color: Colors.red,
                        )),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 5,
                color: Constanst.colorText2,
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  dataDetail[0]['title_ajuan'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Center(
                child: Text(
                  Constanst.convertDate2("${dataDetail[0]['waktu_pengajuan']}"),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                dataDetail[0]['nama_pengaju'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "${dataDetail[0]['title_ajuan']} pada : ",
                style: TextStyle(color: Constanst.colorText2),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 45,
                    child: Text(
                      dataDetail[0]['waktu_dari'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Text("s.d",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 45,
                    child: Text(
                      dataDetail[0]['waktu_sampai'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Deskripsi",
                style: TextStyle(color: Constanst.colorText2),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                dataDetail[0]['catatan'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              dataDetail[0]['durasi'] == ""
                  ? SizedBox()
                  : SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Durasi",
                            style: TextStyle(color: Constanst.colorText2),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${dataDetail[0]['durasi']} Hari",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Tipe",
                style: TextStyle(color: Constanst.colorText2),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                dataDetail[0]['type'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Tanggal persetujuan / penolakan",
                style: TextStyle(color: Constanst.colorText2),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                Constanst.convertDate2("${dataDetail[0]['apply_date']}"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Status Pengajuan",
                style: TextStyle(color: Constanst.colorText2),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                dataDetail[0]['status'],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dataDetail[0]['status'] == 'Approve'
                        ? Constanst.color5
                        : Constanst.color4),
              ),
              SizedBox(
                height: 10,
              ),
              dataDetail[0]['alasan_reject'] == ""
                  ? SizedBox()
                  : SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Alasan Reject",
                            style: TextStyle(color: Constanst.colorText2),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            dataDetail[0]['alasan_reject'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
              dataDetail[0]['file'] == ""
                  ? SizedBox()
                  : SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "File",
                            style: TextStyle(color: Constanst.colorText2),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 60,
                                child: Text(
                                  dataDetail[0]['file'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Lihat File",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
