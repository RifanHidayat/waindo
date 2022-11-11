import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/screen/login.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ApprovalController extends GetxController {
  var cari = TextEditingController().obs;
  var alasanReject = TextEditingController().obs;

  var titleAppbar = "".obs;
  var bulanSelected = "".obs;
  var tahunSelected = "".obs;
  var fullNameDelegasi = "".obs;
  var valuePolaPersetujuan = "".obs;
  var loadingString = "Memuat Data...".obs;

  var statusCari = false.obs;

  var listNotModif = [].obs;
  var listData = [].obs;
  var listDataAll = [].obs;
  var detailData = [].obs;

  var jumlahCuti = 0.obs;
  var typeIdEdit = 0.obs;
  var cutiTerpakai = 0.obs;
  var persenCuti = 0.0.obs;
  var durasiIzin = 0.obs;

  var statusHitungCuti = false.obs;

  void startLoadData(title, bulan, tahun) {
    getLoadsysData(title, bulan, tahun);
  }

  void getLoadsysData(title, bulan, tahun) {
    var connect = Api.connectionApi("get", "", "sysdata");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        for (var element in valueBody['data']) {
          if (element['kode'] == "013") {
            valuePolaPersetujuan.value = "${element['name']}";
            this.valuePolaPersetujuan.refresh();
            titleAppbar.value = title;
            bulanSelected.value = bulan;
            tahunSelected.value = tahun;
            if (title == "Cuti") {
              loadDataCuti();
            } else if (title == "Lembur") {
              loadDataLembur();
            } else if (title == "Tidak Hadir") {
              loadDataTidakHadir();
            } else if (title == "Tugas Luar") {
              loadDataTugasLuar();
            } else if (title == "Dinas Luar") {
              loadDataDinasLuar();
            } else if (title == "Klaim") {
              loadDataKlaim();
            }
          }
        }
      }
    });
  }

  void loadDataCuti() {
    var urlLoad = valuePolaPersetujuan.value == "1"
        ? "spesifik_approval"
        : "spesifik_approval_multi";
    listNotModif.value.clear();
    listData.value.clear();
    listDataAll.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmCode,
      'name_data': 'cuti',
      'bulan': bulanSelected.value,
      'tahun': tahunSelected.value,
    };
    var connect = Api.connectionApi("post", body, urlLoad);
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].length == 0) {
          loadingString.value = 'Tidak ada pengajuan';
        }
        listNotModif.value = valueBody['data'];
        for (var element in valueBody['data']) {
          var fullName = element['full_name'] ?? "";
          var convertNama = "$fullName";
          var tanggalDari = Constanst.convertDate1("${element['start_date']}");
          var tanggalSampai = Constanst.convertDate1("${element['end_date']}");
          var filterStatus = element['leave_status'] == "Approve"
              ? "Approve 1"
              : element['leave_status'];
          var data = {
            'id': element['id'],
            'nama_pengaju': convertNama,
            'emId_pengaju': element['em_id'],
            'title_ajuan': 'Pengajuan Cuti',
            'waktu_dari': tanggalDari,
            'waktu_sampai': tanggalSampai,
            'durasi': element['leave_duration'],
            'leave_status': filterStatus,
            'delegasi': element['em_delegation'],
            'nama_approve1': element['apply_by'],
            'waktu_pengajuan': element['atten_date'],
            'catatan': element['reason'],
            'type': 'Cuti',
            'lainnya': "",
            'file': element['leave_files']
          };
          listData.value.add(data);
          listDataAll.value.add(data);
        }
        listData.value.sort(
            (a, b) => b['waktu_pengajuan'].compareTo(a['waktu_pengajuan']));
        this.listData.refresh();
        this.listNotModif.refresh();
      }
    });
  }

  void loadDataLembur() {
    var urlLoad = valuePolaPersetujuan.value == "1"
        ? "spesifik_approval"
        : "spesifik_approval_multi";
    listNotModif.value.clear();
    listData.value.clear();
    listDataAll.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmCode,
      'name_data': 'lembur',
      'bulan': bulanSelected.value,
      'tahun': tahunSelected.value,
    };
    var connect = Api.connectionApi("post", body, urlLoad);
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].length == 0) {
          loadingString.value = 'Tidak ada pengajuan';
        }
        print(valueBody['data']);
        listNotModif.value = valueBody['data'];
        for (var element in valueBody['data']) {
          var fullName = element['full_name'] ?? "";
          var convertNama = "$fullName";
          var filterStatus =
              element['status'] == "Approve" ? "Approve 1" : element['status'];
          var data = {
            'id': element['id'],
            'nama_pengaju': convertNama,
            'title_ajuan': 'Pengajuan Lembur',
            'waktu_dari': element['dari_jam'],
            'waktu_sampai': element['sampai_jam'],
            'durasi': "",
            'leave_status': filterStatus,
            'delegasi': element['em_delegation'],
            'nama_approve1': element['approve_by'],
            'waktu_pengajuan': element['atten_date'],
            'catatan': element['uraian'],
            'type': 'Lembur',
            'lainnya': "",
            'file': ""
          };
          listData.value.sort(
              (a, b) => b['waktu_pengajuan'].compareTo(a['waktu_pengajuan']));
          listData.value.add(data);
          listDataAll.value.add(data);
        }
        this.listData.refresh();
        this.listNotModif.refresh();
      }
    });
  }

  void loadDataTidakHadir() {
    var urlLoad = valuePolaPersetujuan.value == "1"
        ? "spesifik_approval"
        : "spesifik_approval_multi";
    listNotModif.value.clear();
    listData.value.clear();
    listDataAll.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmCode,
      'name_data': 'tidak_hadir',
      'bulan': bulanSelected.value,
      'tahun': tahunSelected.value,
    };
    var connect = Api.connectionApi("post", body, urlLoad);
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].length == 0) {
          loadingString.value = 'Tidak ada pengajuan';
        }
        ;
        listNotModif.value = valueBody['data'];
        for (var element in valueBody['data']) {
          var fullName = element['full_name'] ?? "";
          var convertNama = "$fullName";
          var tanggalDari = Constanst.convertDate1("${element['start_date']}");
          var tanggalSampai = Constanst.convertDate1("${element['end_date']}");
          var filterStatus = element['leave_status'] == "Approve"
              ? "Approve 1"
              : element['leave_status'];
          var data = {
            'id': element['id'],
            'nama_pengaju': convertNama,
            'title_ajuan': 'Pengajuan Tidak Hadir',
            'waktu_dari': tanggalDari,
            'waktu_sampai': tanggalSampai,
            'durasi': element['leave_duration'],
            'leave_status': filterStatus,
            'delegasi': element['em_delegation'],
            'nama_approve1': element['apply_by'],
            'waktu_pengajuan': element['atten_date'],
            'catatan': element['reason'],
            'type': element['nama_tipe'],
            'lainnya': "",
            'file': element['leave_files']
          };
          listData.value.add(data);
          listDataAll.value.add(data);
        }
        listData.value.sort(
            (a, b) => b['waktu_pengajuan'].compareTo(a['waktu_pengajuan']));
        this.listData.refresh();
        this.listNotModif.refresh();
      }
    });
  }

  void loadDataTugasLuar() {
    var urlLoad = valuePolaPersetujuan.value == "1"
        ? "spesifik_approval"
        : "spesifik_approval_multi";
    listNotModif.value.clear();
    listData.value.clear();
    listDataAll.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmCode,
      'name_data': 'tugas_luar',
      'bulan': bulanSelected.value,
      'tahun': tahunSelected.value,
    };
    var connect = Api.connectionApi("post", body, urlLoad);
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].length == 0) {
          loadingString.value = 'Tidak ada pengajuan';
        }
        ;
        listNotModif.value = valueBody['data'];
        for (var element in valueBody['data']) {
          var fullName = element['full_name'] ?? "";
          var convertNama = "$fullName";
          var filterStatus =
              element['status'] == "Approve" ? "Approve 1" : element['status'];
          var data = {
            'id': element['id'],
            'nama_pengaju': convertNama,
            'title_ajuan': 'Pengajuan Lembur',
            'waktu_dari': element['dari_jam'],
            'waktu_sampai': element['sampai_jam'],
            'durasi': '',
            'leave_status': filterStatus,
            'delegasi': element['em_delegation'],
            'nama_approve1': element['approve_by'],
            'waktu_pengajuan': element['atten_date'],
            'catatan': element['uraian'],
            'type': 'Tugas Luar',
            'lainnya': "",
            'file': ''
          };
          listData.value.add(data);
          listDataAll.value.add(data);
        }
        listData.value.sort(
            (a, b) => b['waktu_pengajuan'].compareTo(a['waktu_pengajuan']));
        this.listData.refresh();
        this.listNotModif.refresh();
      }
    });
  }

  void loadDataDinasLuar() {
    var urlLoad = valuePolaPersetujuan.value == "1"
        ? "spesifik_approval"
        : "spesifik_approval_multi";
    listNotModif.value.clear();
    listData.value.clear();
    listDataAll.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmCode,
      'name_data': 'dinas_luar',
      'bulan': bulanSelected.value,
      'tahun': tahunSelected.value,
    };
    var connect = Api.connectionApi("post", body, urlLoad);
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].length == 0) {
          loadingString.value = 'Tidak ada pengajuan';
        }
        ;
        listNotModif.value = valueBody['data'];
        for (var element in valueBody['data']) {
          var fullName = element['full_name'] ?? "";
          var convertNama = "$fullName";
          var tanggalDari = Constanst.convertDate1("${element['start_date']}");
          var tanggalSampai = Constanst.convertDate1("${element['end_date']}");
          var filterStatus = element['leave_status'] == "Approve"
              ? "Approve 1"
              : element['leave_status'];
          var data = {
            'id': element['id'],
            'nama_pengaju': convertNama,
            'title_ajuan': 'Pengajuan Dinas Luar',
            'waktu_dari': tanggalDari,
            'waktu_sampai': tanggalSampai,
            'durasi': element['leave_duration'],
            'leave_status': filterStatus,
            'delegasi': element['em_delegation'],
            'nama_approve1': element['apply_by'],
            'waktu_pengajuan': element['atten_date'],
            'catatan': element['reason'],
            'type': "Dinas Luar",
            'lainnya': "",
            'file': element['leave_files']
          };
          listData.value.add(data);
          listDataAll.value.add(data);
        }
        listData.value.sort(
            (a, b) => b['waktu_pengajuan'].compareTo(a['waktu_pengajuan']));
        this.listData.refresh();
        this.listNotModif.refresh();
      }
    });
  }

  void loadDataKlaim() {
    var urlLoad = valuePolaPersetujuan.value == "1"
        ? "spesifik_approval"
        : "spesifik_approval_multi";
    listNotModif.value.clear();
    listData.value.clear();
    listDataAll.value.clear();
    var dataUser = AppData.informasiUser;
    var getEmCode = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmCode,
      'name_data': 'klaim',
      'bulan': bulanSelected.value,
      'tahun': tahunSelected.value,
    };
    var connect = Api.connectionApi("post", body, urlLoad);
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].length == 0) {
          loadingString.value = 'Tidak ada pengajuan';
        }
        listNotModif.value = valueBody['data'];
        for (var element in valueBody['data']) {
          var fullName = element['full_name'] ?? "";
          var convertNama = "$fullName";
          DateTime fltr1 = DateTime.parse("${element['tgl_ajuan']}");
          DateTime fltr2 = DateTime.parse("${element['created_on']}");
          var tanggalDari = "${DateFormat('dd-MM-yyyy').format(fltr1)}";
          var tanggalSampai = "${DateFormat('dd-MM-yyyy').format(fltr1)}";
          var tanggalPembuatan = "${DateFormat('yyyy-MM-dd').format(fltr2)}";
          var filterStatus =
              element['status'] == "Approve" ? "Approve 1" : element['status'];
          var data = {
            'id': element['id'],
            'nama_pengaju': convertNama,
            'title_ajuan': 'Pengajuan Klaim',
            'waktu_dari': tanggalDari,
            'waktu_sampai': "",
            'durasi': "",
            'leave_status': filterStatus,
            'delegasi': "",
            'nama_approve1': element['approve_by'],
            'waktu_pengajuan': tanggalPembuatan,
            'catatan': element['description'],
            'type': "Klaim",
            'lainnya': element,
            'file': element['nama_file']
          };
          listData.value.add(data);
          listDataAll.value.add(data);
        }
        listData.value.sort(
            (a, b) => b['waktu_pengajuan'].compareTo(a['waktu_pengajuan']));
        this.listData.refresh();
        this.listNotModif.refresh();
      }
    });
  }

  void cariData(value) {
    var textCari = value.toLowerCase();
    var filter = listDataAll.where((laporan) {
      var namaEmployee = laporan['nama_pengaju'].toLowerCase();
      return namaEmployee.contains(textCari);
    }).toList();
    listData.value = filter;
    statusCari.value = true;
    this.listData.refresh();
    this.statusCari.refresh();
  }

  void getDetailData(idxDetail, emId, title, delegasi) {
    if (title == "Cuti") {
      loadCutiPengaju(emId);
    }
    if (title != "Klaim") {
      infoDelegasi(delegasi);
    }
    detailData.value.clear();
    for (var element in listData.value) {
      if ("${element['id']}" == "$idxDetail") {
        detailData.value.add(element);
      }
    }
    this.detailData.refresh();
  }

  void infoDelegasi(delegasi) {
    Map<String, dynamic> body = {
      'val': 'em_id',
      'cari': delegasi,
    };
    var connect = Api.connectionApi("post", body, "whereOnce-employee");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        fullNameDelegasi.value = valueBody['data'][0]['full_name'];
        this.fullNameDelegasi.refresh();
      }
    });
  }

  String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }

  void loadCutiPengaju(emId) {
    Map<String, dynamic> body = {
      'val': 'em_id',
      'cari': emId,
    };
    var connect = Api.connectionApi("post", body, "whereOnce-assign_leave");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['data'].isNotEmpty) {
          var totalDay = valueBody['data'][0]['total_day'];
          var terpakai = valueBody['data'][0]['terpakai'];
          print("ini data cuti user ${valueBody['data']}");
          jumlahCuti.value = totalDay;
          cutiTerpakai.value = terpakai;
          this.jumlahCuti.refresh();
          this.cutiTerpakai.refresh();
          statusHitungCuti.value = true;
          hitungCuti(totalDay, terpakai);
          this.statusHitungCuti.refresh();
        } else {
          statusHitungCuti.value = false;
          this.statusHitungCuti.refresh();
        }
      }
    });
  }

  void hitungCuti(totalDay, terpakai) {
    var hitung1 = (terpakai / totalDay) * 100;
    // var convert1 = hitung1.toInt();
    var convert1 = hitung1;
    var convertedValue = double.parse("${convert1}") / 100;
    persenCuti.value = convertedValue;
    this.persenCuti.refresh();
  }

  void showBottomAlasanReject() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
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
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.close_circle,
                        color: Colors.red,
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, top: 2),
                        child: Text(
                          "Alasan Tolak Pengajuan",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Constanst.borderStyle1,
                        border: Border.all(
                            width: 1.0,
                            color: Color.fromARGB(255, 211, 205, 205))),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 8,
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: alasanReject.value,
                        maxLines: null,
                        maxLength: 225,
                        autofocus: true,
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            hintText: "Alasan Menolak"),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                            fontSize: 12.0, height: 2.0, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButtonWidget(
                          title: "Kembali",
                          onTap: () => Navigator.pop(Get.context!),
                          colorButton: Colors.red,
                          colortext: Colors.white,
                          border: BorderRadius.circular(8.0),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButtonWidget(
                          title: "Tolak",
                          onTap: () {
                            if (alasanReject.value.text != "") {
                              Navigator.pop(Get.context!);
                              validasiMenyetujui(false);
                            } else {
                              UtilsAlert.showToast(
                                  "Harap isi alasan terlebih dahulu");
                            }
                          },
                          colorButton: Constanst.colorPrimary,
                          colortext: Colors.white,
                          border: BorderRadius.circular(8.0),
                        ),
                      ))
                    ],
                  )
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

  void validasiMenyetujui(pilihan) {
    int styleChose = pilihan == false ? 1 : 2;
    var stringPilihan = pilihan == false ? 'Tolak' : 'Menyetujui';
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
            // our custom dialog
            title: "Peringatan",
            content: "Yakin $stringPilihan Pengajuan ini ?",
            positiveBtnText: "Lanjutkan",
            negativeBtnText: "Kembali",
            style: styleChose,
            buttonStatus: 1,
            positiveBtnPressed: () {
              UtilsAlert.loadingSimpanData(
                  Get.context!, "Proses $stringPilihan pengajuan");
              aksiMenyetujui(pilihan);
            },
          ),
        );
      },
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return null!;
      },
    );
  }

  void aksiMenyetujui(pilihan) {
    List dataEditFinal = [];
    for (var element in listNotModif.value) {
      if (element['id'] == detailData[0]['id']) {
        dataEditFinal.add(element);
      }
    }
    var dt = DateTime.now();
    var dateString = "${dt.day}-${dt.month}-${dt.year}";
    var tanggalNow = Constanst.convertDateSimpan(dateString);

    var url_tujuan;

    if (detailData[0]['type'] == 'Klaim') {
      url_tujuan = 'edit-emp_claim';
    } else {
      url_tujuan = detailData[0]['type'] == 'Tugas Luar' ||
              detailData[0]['type'] == 'Lembur'
          ? 'edit-emp_labor'
          : 'edit-emp_leave';
    }

    if (valuePolaPersetujuan.value == "1") {
      if (pilihan == true && url_tujuan == "edit-emp_leave") {
        print("kesiniiii atuh");
        validasiPemakaianCuti(dataEditFinal);
      }
    } else {
      if (pilihan == true && url_tujuan == "edit-emp_leave") {
        if (dataEditFinal[0]['leave_status'] == "Approve") {
          print("kesiniiii atuh");
          validasiPemakaianCuti(dataEditFinal);
        }
      }
    }
    var dataUser = AppData.informasiUser;
    var getEmpid = dataUser![0].em_id;
    var fullName = dataUser[0].full_name ?? "";
    var namaAtasanApprove = "$fullName";

    var statusPengajuan = "";
    var applyDate1 = "";
    var applyBy1 = "";
    var applyId1 = "";
    var applyDate2 = "";
    var applyBy2 = "";
    var applyId2 = "";
    if (valuePolaPersetujuan.value == "1") {
      statusPengajuan = pilihan == true ? 'Approve' : 'Rejected';
      applyDate1 = tanggalNow;
      applyBy1 = namaAtasanApprove;
      applyId1 = "$getEmpid";
      applyDate2 = "";
      applyBy2 = "";
      applyId2 = "";
    } else {
      if (url_tujuan == "edit-emp_leave") {
        if (dataEditFinal[0]['leave_status'] == "Pending") {
          statusPengajuan = pilihan == true ? 'Approve' : 'Rejected';
          applyDate1 = tanggalNow;
          applyBy1 = namaAtasanApprove;
          applyId1 = "$getEmpid";
          applyDate2 = "";
          applyBy2 = "";
          applyId2 = "";
        } else if (dataEditFinal[0]['leave_status'] == "Approve") {
          statusPengajuan = pilihan == true ? 'Approve2' : 'Rejected';
          applyDate1 = dataEditFinal[0]['apply_date'];
          applyBy1 = dataEditFinal[0]['apply_by'];
          applyId1 = dataEditFinal[0]['apply_id'];
          applyDate2 = tanggalNow;
          applyBy2 = namaAtasanApprove;
          applyId2 = "$getEmpid";
        }
      } else {
        if (dataEditFinal[0]['status'] == "Pending") {
          statusPengajuan = pilihan == true ? 'Approve' : 'Rejected';
          applyDate1 = tanggalNow;
          applyBy1 = namaAtasanApprove;
          applyId1 = "$getEmpid";
          applyDate2 = "";
          applyBy2 = "";
          applyId2 = "";
        } else if (dataEditFinal[0]['status'] == "Approve") {
          statusPengajuan = pilihan == true ? 'Approve2' : 'Rejected';
          applyDate1 = dataEditFinal[0]['approve_date'];
          applyBy1 = dataEditFinal[0]['approve_by'];
          applyId1 = dataEditFinal[0]['approve_id'];
          applyDate2 = tanggalNow;
          applyBy2 = namaAtasanApprove;
          applyId2 = "$getEmpid";
        }
      }
    }

    var alasanRejectShow = alasanReject.value.text != ""
        ? ", Alasan pengajuan di tolak = ${alasanReject.value.text}"
        : "";
    if (url_tujuan == 'edit-emp_leave') {
      // emp_leave
      Map<String, dynamic> body = {
        'em_id': dataEditFinal[0]['em_id'],
        'typeid': dataEditFinal[0]['typeid'],
        'leave_type': dataEditFinal[0]['leave_type'],
        'start_date': dataEditFinal[0]['start_date'],
        'end_date': dataEditFinal[0]['end_date'],
        'leave_duration': dataEditFinal[0]['leave_duration'],
        'apply_date': applyDate1,
        'apply_by': applyBy1,
        'apply_id': applyId1,
        'apply2_date': applyDate2,
        'apply2_by': applyBy2,
        'apply2_id': applyId2,
        'alasan_reject': alasanReject.value.text,
        'reason': dataEditFinal[0]['reason'],
        'leave_status': statusPengajuan,
        'atten_date': dataEditFinal[0]['atten_date'],
        'em_delegation': dataEditFinal[0]['em_delegation'],
        'leave_files': dataEditFinal[0]['leave_files'],
        'ajuan': dataEditFinal[0]['ajuan'],
        'created_by': getEmpid,
        'menu_name': detailData[0]['type'],
        'val': 'id',
        'cari': dataEditFinal[0]['id'],
        'activity_name':
            "$statusPengajuan Pengajuan ${detailData[0]['type']} pada tanggal $tanggalNow. Pengajuan atas nama ${detailData[0]['nama_pengaju']} $alasanRejectShow"
      };
      var connect = Api.connectionApi("post", body, "edit-emp_leave");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          if (pilihan == true) {
            if (valuePolaPersetujuan.value == '1') {
              if (statusPengajuan == 'Approve') {
                insertAbsensiUserAfterApprove(dataEditFinal);
              }
            } else {
              if (statusPengajuan == 'Approve2') {
                insertAbsensiUserAfterApprove(dataEditFinal);
              }
            }
          }
          print('berhasil sampai sini edit emp leave');
          print('pola persetujuan ${valuePolaPersetujuan.value}');
          print('pilihan $pilihan');
          print('status pengajuan $statusPengajuan');
          insertNotifikasi(dataEditFinal, statusPengajuan, tanggalNow, dt,
              pilihan, namaAtasanApprove, url_tujuan, alasanRejectShow);
        }
      });
    } else if (url_tujuan == 'edit-emp_labor') {
      Map<String, dynamic> body = {
        'em_id': dataEditFinal[0]['em_id'],
        'dari_jam': dataEditFinal[0]['dari_jam'],
        'sampai_jam': dataEditFinal[0]['sampai_jam'],
        'atten_date': dataEditFinal[0]['atten_date'],
        'status': statusPengajuan,
        'approve_date': applyDate1,
        'approve_by': applyBy1,
        'approve_id': applyId1,
        'approve2_date': applyDate2,
        'approve2_by': applyBy2,
        'approve2_id': applyId2,
        'alasan_reject': alasanReject.value.text,
        'em_delegation': dataEditFinal[0]['em_delegation'],
        'uraian': dataEditFinal[0]['uraian'],
        'ajuan': dataEditFinal[0]['ajuan'],
        'created_by': getEmpid,
        'menu_name': detailData[0]['type'],
        'val': 'id',
        'cari': dataEditFinal[0]['id'],
        'activity_name':
            "$statusPengajuan Pengajuan ${detailData[0]['type']} pada tanggal $tanggalNow. Pengajuan atas nama ${detailData[0]['nama_pengaju']} $alasanRejectShow"
      };
      var connect = Api.connectionApi("post", body, "edit-emp_labor");
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          print('berhasil sampai sini edit emp labor');
          insertNotifikasi(dataEditFinal, statusPengajuan, tanggalNow, dt,
              pilihan, namaAtasanApprove, url_tujuan, alasanRejectShow);
        }
      });
    } else if (url_tujuan == 'edit-emp_claim') {
      Map<String, dynamic> body = {
        'status': statusPengajuan,
        'atten_date': detailData[0]['waktu_pengajuan'],
        'approve_date': applyDate1,
        'approve_by': applyBy1,
        'approve_id': applyId1,
        'approve2_date': applyDate2,
        'approve2_by': applyBy2,
        'approve2_id': applyId2,
        'alasan_reject': alasanReject.value.text,
        'created_by': getEmpid,
        'menu_name': detailData[0]['type'],
        'val': 'id',
        'cari': dataEditFinal[0]['id'],
        'activity_name':
            "$statusPengajuan Pengajuan ${detailData[0]['type']} pada tanggal $tanggalNow. Pengajuan atas nama ${detailData[0]['nama_pengaju']} $alasanRejectShow"
      };
      var connect = Api.connectionApi("post", body, 'edit-emp_claim');
      connect.then((dynamic res) {
        if (res.statusCode == 200) {
          print('berhasil sampai sini klaim');
          insertNotifikasi(dataEditFinal, statusPengajuan, tanggalNow, dt,
              pilihan, namaAtasanApprove, url_tujuan, alasanRejectShow);
        }
      });
    }
  }

  void validasiPemakaianCuti(dataEditFinal) {
    Map<String, dynamic> body = {
      'val': 'name',
      'cari': dataEditFinal[0]['nama_tipe']
    };
    var connect = Api.connectionApi("post", body, "whereOnce-leave_types");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var statusPemotongan = valueBody['data'][0]['cut_leave'];
        if (statusPemotongan == 1) {
          cariEmployee(dataEditFinal);
        }
      }
    });
  }

  insertAbsensiUserAfterApprove(dataEditFinal) {
    Map<String, dynamic> body = {
      'dataAbsen': dataEditFinal,
    };
    var connect =
        Api.connectionApi("post", body, "insert_absen_approve_pengajuan");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          UtilsAlert.showToast('Berhasil menyetujui pengajuan employee');
        } else {
          print(valueBody);
        }
      }
    });
  }

  void cariEmployee(dataEditFinal) {
    Map<String, dynamic> body = {
      'val': 'full_name',
      'cari': dataEditFinal[0]['full_name']
    };
    var connect = Api.connectionApi("post", body, "whereOnce-employee");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var getEmidEmployee = valueBody['data'][0]['em_id'];
        potongCuti(dataEditFinal, getEmidEmployee);
      }
    });
  }

  void potongCuti(dataEditFinal, getEmidEmployee) {
    Map<String, dynamic> body = {
      'em_id': getEmidEmployee,
      'terpakai': dataEditFinal[0]['leave_duration'],
    };
    var connect = Api.connectionApi("post", body, "potong_cuti");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        UtilsAlert.showToast("${valueBody['message']}");
      }
    });
  }

  void insertNotifikasi(dataEditFinal, statusPengajuan, tanggalNow, dt, pilihan,
      namaAtasanApprove, url_tujuan, alasanRejectShow) {
    var statusNotif = pilihan == true ? 1 : 0;
    var jamSekarang = DateFormat('HH:mm:ss').format(dt);
    var url_notifikasi = detailData[0]['type'] == 'Cuti'
        ? 'RiwayatCuti'
        : detailData[0]['type'] == 'Izin' || detailData[0]['type'] == 'Sakit'
            ? 'TidakMasukKerja'
            : detailData[0]['type'] == 'Lembur'
                ? 'Lembur'
                : detailData[0]['type'] == 'Tugas Luar'
                    ? 'TugasLuar'
                    : '';
    var title = "Pengajuan ${detailData[0]['type']} telah di $statusPengajuan";
    var stringDeskripsi =
        "Pengajuan ${detailData[0]['type']} kamu telah di $statusPengajuan oleh $namaAtasanApprove $alasanRejectShow";
    Map<String, dynamic> body = {
      'title': title,
      'deskripsi': stringDeskripsi,
      'url': url_notifikasi,
      'atten_date': tanggalNow,
      'jam': jamSekarang,
      'status': statusNotif,
      'view': '0',
    };
    if (url_tujuan == 'edit-emp_leave') {
      body['em_id'] = dataEditFinal[0]['em_id'];
    } else if (url_tujuan == 'edit-emp_labor') {
      body['em_id'] = dataEditFinal[0]['em_id'];
    }

    var connect = Api.connectionApi("post", body, "insert-notifikasi");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        var pesanController = Get.find<PesanController>();
        pesanController.loadApproveInfo();
        startLoadData(
            titleAppbar.value, bulanSelected.value, tahunSelected.value);
        Navigator.pop(Get.context!);
        Navigator.pop(Get.context!);
        UtilsAlert.showToast(
            "Pengajuan ${detailData[0]['type']} berhasil di $statusPengajuan");
        Get.back();
      }
    });
  }

  void viewFile(status, file) async {
    if (status == "tidak_hadir") {
      var urlViewGambar = Api.UrlfileTidakhadir + file;

      final url = Uri.parse(urlViewGambar);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        UtilsAlert.showToast('Tidak dapat membuka file');
      }
    } else if (status == "cuti") {
      var urlViewGambar = Api.UrlfileCuti + file;

      final url = Uri.parse(urlViewGambar);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        UtilsAlert.showToast('Tidak dapat membuka file');
      }
    } else if (status == "klaim") {
      var urlViewGambar = Api.UrlfileKlaim + file;

      final url = Uri.parse(urlViewGambar);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        UtilsAlert.showToast('Tidak dapat membuka file');
      }
    }
  }
}
