import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
// import 'package:html_editor_enhanced/html_editor.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siscom_operasional/controller/api_controller.dart';
import 'package:siscom_operasional/controller/global_controller.dart';
import 'package:siscom_operasional/screen/absen/form/berhasil_pengajuan.dart';
import 'package:siscom_operasional/screen/absen/form/form_lembur.dart';
import 'package:siscom_operasional/screen/kandidat/detail_permintaan.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/custom_dialog.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class KandidatController extends GetxController {
  var controllerApiGlobal = Get.put(ApiController());
  // HtmlEditorController controllerHtmlEditor = HtmlEditorController();
  PageController DetailController = PageController(initialPage: 0);

  var cari = TextEditingController().obs;
  var posisi = TextEditingController().obs;
  var kebutuhan = TextEditingController().obs;
  var spesifikasi = TextEditingController().obs;
  var keterangan = TextEditingController().obs;
  var nomorAjuan = TextEditingController().obs;
  var alasanTerima = TextEditingController().obs;
  var alasanTolak = TextEditingController().obs;
  var urlFormSchedule = TextEditingController().obs;
  var nama_calon_kandidat = TextEditingController().obs;

  var filePengajuan = File("").obs;

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var namaFileUpload = "".obs;
  var tanggalPermintaan = "".obs;
  var selectedIdDetail = "".obs;
  var idDepartemenTerpilih = "".obs;
  var namaDepartemenTerpilih = "".obs;
  var typeProsesTerpilih = "".obs;
  var selectedKandidatUntuk = "BARU".obs;
  var departemen = "".obs;
  var loadingString = "Sedang memuat...".obs;

  Rx<DateTime> pilihTanggalSchedule1 = DateTime.now().obs;
  Rx<DateTime> pilihTanggalSchedule2 = DateTime.now().obs;

  Rx<List<String>> permintaanKandidatUntuk = Rx<List<String>>([]);

  var selectType = 0.obs;
  var selectedInformasiView = 0.obs;

  var statusCari = false.obs;
  var uploadFile = false.obs;
  var loadingUpdateData = false.obs;
  var viewWidgetPilihDepartement = false.obs;

  var listTypeStatus = [].obs;
  var listProsesKandidat = [].obs;
  var listPermintaanKandidat = [].obs;
  var listPermintaanKandidatAll = [].obs;
  var detailPermintaan = [].obs;
  var listKandidatProses = [].obs;
  var listKandidatProsesAll = [].obs;
  var departementAkses = [].obs;

  var dumyTypeStatus = ["Semua", "Aktif", "Tidak Aktif"];
  var loadPermintaanUntuk = ["BARU", "PENGGANTI"];
  var dumyTypeProsesKandidat = [
    "Sortir",
    "Schedule 1",
    "Interview 1",
    "Schedule 2",
    "Interview 2",
    "Hasil"
  ];

  GlobalController globalCt = Get.put(GlobalController());

  @override
  void startData() async {
    getTimeNow();
    loadTypeStatus();
    loadTypeProsesKandidat();
    getDepartemen();
  }

  void removeAll() {}

  void getTimeNow() {
    var dt = DateTime.now();
    bulanSelectedSearchHistory.value = "${dt.month}";
    tahunSelectedSearchHistory.value = "${dt.year}";
    bulanDanTahunNow.value = "${dt.month}-${dt.year}";
    tanggalPermintaan.value = "${DateFormat('yyyy-MM-dd').format(dt)}";

    this.tanggalPermintaan.refresh();
    this.bulanSelectedSearchHistory.refresh();
    this.tahunSelectedSearchHistory.refresh();
    this.bulanDanTahunNow.refresh();
  }

  void getDepartemen() {
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
            if (hakAkses == '0') {
              viewWidgetPilihDepartement.value = true;
            } else {
              viewWidgetPilihDepartement.value =
                  convert.length > 1 ? true : false;
            }
            for (var element in dataDepartemen) {
              if (hakAkses == '0') {
                departementAkses.add(element);
              } else {
                for (var element1 in convert) {
                  if ("${element['id']}" == element1) {
                    departementAkses.add(element);
                  }
                }
              }
            }
          }
          this.departementAkses.refresh();
          if (departementAkses.value.isNotEmpty) {
            idDepartemenTerpilih.value = "${departementAkses[0]['id']}";
            namaDepartemenTerpilih.value = departementAkses[0]['name'];
            departemen.value = departementAkses[0]['name'];
            this.idDepartemenTerpilih.refresh();
            this.namaDepartemenTerpilih.refresh();
            this.viewWidgetPilihDepartement.refresh();
            this.departemen.refresh();
            loadPermintaanKandidat();
          }
        }
      }
    });
  }

  void loadTypeStatus() {
    List tampung = [];
    int no = 1;
    for (var element in dumyTypeStatus) {
      var data = {
        'id': no,
        'name': element,
        'status': false,
      };
      no++;
      tampung.add(data);
    }
    tampung.firstWhere((element) => element['id'] == 1)['status'] = true;
    listTypeStatus.value = tampung;
    this.listTypeStatus.refresh();

    for (var element in loadPermintaanUntuk) {
      permintaanKandidatUntuk.value.add(element);
    }
    this.permintaanKandidatUntuk.refresh();
  }

  void loadTypeProsesKandidat() {
    List tampung = [];
    int no = 1;
    for (var element in dumyTypeProsesKandidat) {
      var data = {
        'id': no,
        'name': element,
        'status': false,
      };
      no++;
      tampung.add(data);
    }
    tampung.firstWhere((element) => element['id'] == 1)['status'] = true;
    listProsesKandidat.value = tampung;
    this.listProsesKandidat.refresh();
  }

  void cariData(value) {
    var textCari = value.toLowerCase();
    var filter = listPermintaanKandidatAll.where((ajuan) {
      var selectedNomor = ajuan['nomor_ajuan'].toLowerCase();
      var selectedPosisi = ajuan['position'].toLowerCase();
      return selectedNomor.contains(textCari) ||
          selectedPosisi.contains(textCari);
    }).toList();
    listPermintaanKandidat.value = filter;
    statusCari.value = true;
    this.listPermintaanKandidat.refresh();
    this.statusCari.refresh();
  }

  void changeType(value) {
    selectType.value = value;
    this.selectType.refresh();
  }

  void changeTypeStatus(id, namaType) {
    listTypeStatus.value.forEach((element) {
      if (element['id'] == id) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    });
    this.listTypeStatus.refresh();
    if (namaType == "Semua") {
      listPermintaanKandidat.value = listPermintaanKandidatAll.value;
      this.listPermintaanKandidat.refresh();
    } else {
      List tampung = [];
      for (var element in listPermintaanKandidatAll.value) {
        if (namaType == "Aktif") {
          if (element['status_transaksi'] == 1) {
            tampung.add(element);
          }
        } else if (namaType == "Tidak Aktif") {
          if (element['status_transaksi'] == 0) {
            tampung.add(element);
          }
        }
      }
      loadingString.value =
          tampung.isEmpty ? "Tidak ada permintaan" : "Sedang memuat...";
      listPermintaanKandidat.value = tampung;
      this.loadingString.refresh();
      this.listPermintaanKandidat.refresh();
    }
  }

  void loadPermintaanKandidat() {
    loadingUpdateData.value = true;
    listPermintaanKandidatAll.value.clear();
    listPermintaanKandidat.value.clear();
    Map<String, dynamic> body = {
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
      'status': idDepartemenTerpilih.value
    };
    var connect =
        Api.connectionApi("post", body, "history-permintaan_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == false) {
          loadingString.value = "Tidak ada permintaan";
          this.loadingString.refresh();
        } else {
          listPermintaanKandidat.value = valueBody['data'];
          listPermintaanKandidatAll.value = valueBody['data'];
          loadingString.value = listPermintaanKandidat.value.isEmpty
              ? "Tidak ada permintaan"
              : "Sedang memuat...";
          loadingUpdateData.value = false;

          this.loadingUpdateData.refresh();
          this.loadingString.refresh();
          this.listPermintaanKandidat.refresh();
          this.listPermintaanKandidatAll.refresh();
        }
      }
    });
  }

  void getDetail(id) {
    var tampung = [];
    for (var element in listPermintaanKandidatAll.value) {
      if (element['id'] == id) {
        tampung.add(element);
      }
    }
    detailPermintaan.value = tampung;
    selectedIdDetail.value = "$id";
    this.selectedIdDetail.refresh();
    this.detailPermintaan.refresh();
    loadTypeProsesKandidat();
    getKandidatPelemar(id, 'load_first');
  }

  void getKandidatPelemar(id, aksi) {
    listKandidatProses.value.clear();
    listKandidatProsesAll.value.clear();
    Map<String, dynamic> body = {
      'val': 'req_id',
      'cari': '$id',
    };
    var connect = Api.connectionApi("post", body, "whereOnce-candidate");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        List data = valueBody['data'];
        for (var element in data) {
          if (element['status'] == 'Open') {
            listKandidatProses.value.add(element);
          }
        }
        loadingString.value = listKandidatProses.value.isEmpty
            ? "Belum ada kandidat yang tersedia"
            : "Memuat data...";

        listKandidatProsesAll.value = valueBody['data'];
        this.loadingString.refresh();
        this.selectedInformasiView.refresh();
        this.listKandidatProses.refresh();
        this.listKandidatProsesAll.refresh();
        if (aksi == 'load_first') {
          selectedInformasiView.value = 0;
          Get.to(DetailPermintaan());
        } else {
          changeProsesRekrut(typeProsesTerpilih.value);
        }
      }
    });
  }

  void changeProsesRekrut(name) {
    listProsesKandidat.value.forEach((element) {
      if (element['name'] == name) {
        element['status'] = true;
      } else {
        element['status'] = false;
      }
    });
    typeProsesTerpilih.value = name;
    this.typeProsesTerpilih.refresh();
    List tampung = [];
    for (var element in listKandidatProsesAll.value) {
      if (name == "Sortir") {
        if (element['status'] == "Open") {
          tampung.add(element);
        }
      } else if (name == "Schedule 1") {
        if (element['status'] == "Schedule1") {
          tampung.add(element);
        }
      } else if (name == "Interview 1") {
        if (element['status'] == "Interview1") {
          tampung.add(element);
        }
      } else if (name == "Schedule 2") {
        if (element['status'] == "Schedule2") {
          tampung.add(element);
        }
      } else if (name == "Interview 2") {
        if (element['status'] == "Interview2") {
          tampung.add(element);
        }
      } else if (name == "Hasil") {
        if (element['status'] == "Accepted") {
          tampung.add(element);
        }
      }
    }
    loadingString.value =
        tampung.isEmpty ? "Tidak ada kandidat" : "Sedang memuat...";
    listKandidatProses.value = tampung;
    this.loadingString.refresh();
    this.listKandidatProses.refresh();
    this.listProsesKandidat.refresh();
  }

  void showBottomAlasan(status, id, namaKandidat, statusKandidat) {
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
                      Padding(
                        padding: EdgeInsets.only(left: 8, top: 2),
                        child: status == false
                            ? Text(
                                "Keterangan Tolak Kandidat",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              )
                            : Text(
                                "Keterangan Terima Kandidat",
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
                      child: status == false
                          ? TextField(
                              cursorColor: Colors.black,
                              controller: alasanTolak.value,
                              maxLines: null,
                              maxLength: 225,
                              autofocus: true,
                              decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Alasan Tolak Kandidat"),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  height: 2.0,
                                  color: Colors.black),
                            )
                          : TextField(
                              cursorColor: Colors.black,
                              controller: alasanTerima.value,
                              maxLines: null,
                              maxLength: 225,
                              autofocus: true,
                              decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Alasan Terima Kandidat"),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  height: 2.0,
                                  color: Colors.black),
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
                        child: status == false
                            ? TextButtonWidget(
                                title: "Tolak",
                                onTap: () {
                                  if (alasanTolak.value.text != "") {
                                    Navigator.pop(Get.context!);
                                    updateStatusKandidat(id, namaKandidat,
                                        statusKandidat, status);
                                  } else {
                                    UtilsAlert.showToast(
                                        "Harap isi alasan terlebih dahulu");
                                  }
                                },
                                colorButton: Constanst.colorPrimary,
                                colortext: Colors.white,
                                border: BorderRadius.circular(8.0),
                              )
                            : TextButtonWidget(
                                title: "Terima",
                                onTap: () {
                                  if (alasanTerima.value.text != "") {
                                    Navigator.pop(Get.context!);
                                    if (namaKandidat == "" &&
                                        statusKandidat == "") {
                                      validasiSebelumAksi(
                                          "Terima Final",
                                          "Terima Kandidat ini ketahap akhir/final ?",
                                          "",
                                          "terima_final",
                                          false,
                                          id);
                                    } else {
                                      updateStatusKandidat(id, namaKandidat,
                                          statusKandidat, status);
                                    }
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

  void updateStatusKandidat(id, namaKandidat, statusKandidat, status) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 90,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            status
                                ? Text(
                                    "Terima Kandidat",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                : Text(
                                    "Tolak Kandidat",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 10,
                          child: InkWell(
                            onTap: () => Navigator.pop(Get.context!),
                            child: Icon(
                              Iconsax.close_circle,
                              color: Colors.red,
                            ),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  status == true
                      ? Text(
                          "Terima $namaKandidat ke tahap selanjutnya ?",
                          textAlign: TextAlign.justify,
                          style: TextStyle(color: Constanst.colorText2),
                        )
                      : Text(
                          "Tolak $namaKandidat, tidak melanjutkan ke tahap selanjutnya ?",
                          textAlign: TextAlign.justify,
                          style: TextStyle(color: Constanst.colorText2),
                        ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: status == true
                              ? TextButtonWidget(
                                  title: "Ya, Terima",
                                  onTap: () async {
                                    Navigator.pop(Get.context!);
                                    aksiTerimaKeTahapLanjutan(
                                        id, namaKandidat, statusKandidat);
                                  },
                                  colorButton: Constanst.colorButton1,
                                  colortext: Constanst.colorWhite,
                                  border: BorderRadius.circular(10.0),
                                )
                              : TextButtonWidget(
                                  title: "Ya, Tolak",
                                  onTap: () async {
                                    Navigator.pop(Get.context!);
                                    aksiTolakKandidat(
                                        id, namaKandidat, statusKandidat);
                                  },
                                  colorButton: Constanst.colorButton1,
                                  colortext: Constanst.colorWhite,
                                  border: BorderRadius.circular(10.0),
                                ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(Get.context!),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: Constanst.borderStyle2,
                                  border: Border.all(
                                      color: Constanst.colorPrimary)),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12, bottom: 12),
                                  child: Text(
                                    "Urungkan",
                                    style: TextStyle(
                                        color: Constanst.colorPrimary),
                                  ),
                                ),
                              )),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            )
          ],
        );
      },
    );
  }

  void aksiTerimaKeTahapLanjutan(id, namaKandidat, statusKandidat) {
    UtilsAlert.loadingSimpanData(
        Get.context!, "Proses terima kandidat ke tahap selanjutnya...");
    var status = statusKandidat == "Open"
        ? "Schedule1"
        : statusKandidat == "Schedule1"
            ? "Interview1"
            : statusKandidat == "Interview1"
                ? "Schedule2"
                : statusKandidat == "Schedule2"
                    ? "Interview2"
                    : statusKandidat == "Interview2"
                        ? "Accepted"
                        : "Open";

    Map<String, dynamic> body = {
      'id': '$id',
      'status': '$status',
      'alasan_terima': '${alasanTerima.value.text}',
    };
    var connect = Api.connectionApi("post", body, "edit_status_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          selectedInformasiView.value = 2;
          DetailController.jumpToPage(2);
          alasanTerima.value.text = "";
          getKandidatPelemar(selectedIdDetail.value, 'load');
          Navigator.pop(Get.context!);
          this.selectedInformasiView.refresh();
          if (statusKandidat == "Interview2") {
            aksiGantiStatusAkhirKandidat(id, true);
          }
        }
      }
    });
  }

  void aksiGantiStatusAkhirKandidat(id, type) {
    var statusAkhir = type == true ? 1 : 2;
    Map<String, dynamic> body = {
      'id': '$id',
      'status_akhir': '$statusAkhir',
    };
    var connect = Api.connectionApi("post", body, "edit_statusAkhir_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          UtilsAlert.showToast('Calon kandidat selesai di proses');
        }
      }
    });
  }

  void aksiTolakKandidat(id, namaKandidat, statusKandidat) {
    UtilsAlert.loadingSimpanData(Get.context!, "Proses tolak kandidat...");

    Map<String, dynamic> body = {
      'id': '$id',
      'status': 'Accepted',
      'status_akhir': '2',
      'alasan_tolak': alasanTolak.value.text,
      'status_remaks': '$statusKandidat',
    };
    var connect = Api.connectionApi("post", body, "tolak_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          Navigator.pop(Get.context!);
          UtilsAlert.showToast('Berhasil tolak kandidat...');
          alasanTolak.value.text = "";
          getKandidatPelemar(selectedIdDetail.value, 'load');
        }
      }
    });
  }

  void takeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.size > 5000000) {
        UtilsAlert.showToast("Maaf file terlalu besar...Max 5MB");
      } else {
        namaFileUpload.value = "${file.name}";
        filePengajuan.value = await saveFilePermanently(file);
        uploadFile.value = true;
        this.namaFileUpload.refresh();
        this.filePengajuan.refresh();
        this.uploadFile.refresh();
      }
    } else {
      UtilsAlert.showToast("Gagal mengambil file");
    }
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appStorage.path}/${file.name}');
    return File(file.path!).copy(newFile.path);
  }

  void validasiKirimPermintaan(status) async {
    if (posisi.value.text == "" ||
        kebutuhan.value.text == "" ||
        spesifikasi.value.text == "" ||
        keterangan.value.text == "") {
      UtilsAlert.showToast("Lengkapi form *");
    } else {
      if (uploadFile.value == true) {
        UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan File");
        var connectUpload = await Api.connectionApiUploadFile(
            "upload_file_permintaan_kandidat", filePengajuan.value);
        var valueBody = jsonDecode(connectUpload);
        if (valueBody['status'] == true) {
          UtilsAlert.showToast("Berhasil upload file");
          Navigator.pop(Get.context!);
          checkNomorAjuan(status);
        } else {
          UtilsAlert.showToast("Gagal kirim file");
        }
      } else {
        if (status == false) {
          UtilsAlert.loadingSimpanData(Get.context!, "Sedang Menyimpan Data");
          checkNomorAjuan(status);
        } else {
          UtilsAlert.loadingSimpanData(Get.context!, "Proses edit data");
          kirimPermintaanKandidat(status, nomorAjuan.value.text);
        }
      }
    }
  }

  void checkNomorAjuan(status) {
    Map<String, dynamic> body = {'pola': "PK"};
    var connect = Api.connectionApi("post", body, "emp_request_lastrow");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          print(valueBody['data']);
          if (valueBody['data'].isEmpty) {
            var now = DateTime.now();
            var convertBulan = now.month <= 9 ? "0${now.month}" : now.month;
            var finalNomor = "PK${now.year}${convertBulan}0001";
            kirimPermintaanKandidat(status, finalNomor);
          } else {
            var getNomorAjuanTerakhir = valueBody['data'][0]['nomor_ajuan'];
            var keyNomor = getNomorAjuanTerakhir.replaceAll("PK", '');
            var hasilTambah = int.parse(keyNomor) + 1;
            var finalNomor = "PK$hasilTambah";
            kirimPermintaanKandidat(status, finalNomor);
          }
        } else {
          UtilsAlert.showToast("");
        }
      }
    });
  }

  void checkNomorAjuanDalamAntrian(status, nomorAjuanTerakhirDalamAntrian) {
    var getNomorAjuanTerakhir = nomorAjuanTerakhirDalamAntrian;
    var keyNomor = getNomorAjuanTerakhir.replaceAll("PK", '');
    var hasilTambah = int.parse(keyNomor) + 1;
    var finalNomor = "PK$hasilTambah";
    kirimPermintaanKandidat(status, finalNomor);
  }

  void kirimPermintaanKandidat(status, nomorAjuanTerakhir) {
    // data user
    var dataUser = AppData.informasiUser;
    var getEmid = "${dataUser![0].em_id}";
    var getFullName = "${dataUser[0].full_name}";

    Map<String, dynamic> body = {
      'em_id': '$getEmid',
      'nomor_ajuan': '$nomorAjuanTerakhir',
      'position': '${posisi.value.text}',
      'purpose': '${selectedKandidatUntuk.value}',
      'emp_needs': '${kebutuhan.value.text}',
      'requirements': '${spesifikasi.value.text}',
      'remark': '${keterangan.value.text}',
      'nama_file': '${namaFileUpload.value}',
      'tgl_ajuan': '${tanggalPermintaan.value}',
      'created_by': '$getEmid',
      'menu_name': 'Permintaan Kandidat',
      'activity_name':
          'Membuat Permintaan karyawan. posisi = ${posisi.value.text}',
    };
    var connect = Api.connectionApi("post", body, "insert-employee_request");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          var pesan1 = "Permintaan Kandidat berhasil dibuat";
          var pesan2 =
              "Silakan menunggu HRD untuk meninjau pengajuan yang telah dibuat";
          var pesan3 = "";

          var pesan4 = "";
          var data = jsonDecode(globalCt.konfirmasiAtasan.toString());
          var newList = [];
          for (var e in data) {
            newList.add(e.values.join('token'));
          }
          globalCt.kirimNotifikasiFcm(
              title: "Lembur", message: pesan4, tokens: newList);

          Get.offAll(BerhasilPengajuan(
            dataBerhasil: [pesan1, pesan2, pesan3, false],
          ));
        } else {
          if (valueBody['message'] == "ulang") {
            var nomorAjuanTerakhirDalamAntrian =
                valueBody['data'][0]['nomor_ajuan'];
            checkNomorAjuanDalamAntrian(status, nomorAjuanTerakhirDalamAntrian);
          } else {
            Navigator.pop(Get.context!);
            UtilsAlert.showToast("Terjadi kesalahan");
          }
        }
      }
    });
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
                                departemen.value =
                                    departementAkses.value[index]['name'];
                                this.idDepartemenTerpilih.refresh();
                                this.namaDepartemenTerpilih.refresh();
                                this.departemen.refresh();
                                Navigator.pop(context);
                                loadPermintaanKandidat();
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

  void showModalHtmlEditor() {
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
          padding: EdgeInsets.only(
              left: 6,
              right: 6,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    "Spesifikasi Kandidat",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                // Flexible(
                //   flex: 3,
                //   child: HtmlEditor(
                //     controller: controllerHtmlEditor, //required
                //     htmlEditorOptions: HtmlEditorOptions(
                //       hint: "Your text here...",
                //       initialText: spesifikasi.value.text,
                //     ),
                //     htmlToolbarOptions: HtmlToolbarOptions(
                //       toolbarPosition: ToolbarPosition.aboveEditor, //by default
                //       toolbarType: ToolbarType.nativeScrollable, //by default
                //       onButtonPressed: (ButtonType type, bool? status,
                //           Function? updateStatus) {
                //         return true;
                //       },
                //       defaultToolbarButtons: [
                //         //add any other buttons here otherwise only a few buttons will show up!
                //         // OtherButtons(copy: true, paste: true),
                //         StyleButtons(),
                //         FontSettingButtons(),
                //         FontButtons(),
                //         ColorButtons(),
                //         ListButtons(),
                //         ParagraphButtons(),
                //         InsertButtons(),
                //         OtherButtons(),
                //       ],
                //       onDropdownChanged: (DropdownType type, dynamic changed,
                //           Function(dynamic)? updateSelectedItem) {
                //         return true;
                //       },
                //     ),
                //     otherOptions: OtherOptions(
                //       height: 500,
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: <Widget>[
                //       TextButton(
                //         style: TextButton.styleFrom(
                //             backgroundColor: Colors.blueGrey),
                //         onPressed: () {
                //           controllerHtmlEditor.undo();
                //         },
                //         child:
                //             Text('Undo', style: TextStyle(color: Colors.white)),
                //       ),
                //       SizedBox(
                //         width: 16,
                //       ),
                //       TextButton(
                //         style: TextButton.styleFrom(
                //             backgroundColor: Colors.blueGrey),
                //         onPressed: () {
                //           controllerHtmlEditor.clear();
                //         },
                //         child: Text('Reset',
                //             style: TextStyle(color: Colors.white)),
                //       ),
                //       SizedBox(
                //         width: 16,
                //       ),
                //       TextButton(
                //         style: TextButton.styleFrom(
                //             backgroundColor:
                //                 Theme.of(context).colorScheme.secondary),
                //         onPressed: () async {
                //           var txt = await controllerHtmlEditor.getText();
                //           if (txt.contains('src=\"data:')) {
                //             txt =
                //                 '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                //           }
                //           spesifikasi.value.text = txt;
                //           this.spesifikasi.refresh();
                //           Navigator.pop(context);
                //         },
                //         child: Text(
                //           'Submit',
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ),
                //       SizedBox(
                //         width: 16,
                //       ),
                //     ],
                //   ),
                // ),
              ]),
        );
      },
    );
  }

  void showBottomFormSchedule(typeSchedule, id) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30,
                ),
                typeSchedule == false
                    ? Text(
                        "Jadwal Interview 1 *",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )
                    : Text(
                        "Jadwal Interview 2 *",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () async {
                    var dateSelect = await showDatePicker(
                      context: Get.context!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: typeSchedule == false
                          ? pilihTanggalSchedule1.value
                          : pilihTanggalSchedule2.value,
                    );
                    if (dateSelect == null) {
                      UtilsAlert.showToast("Tanggal tidak terpilih");
                    } else {
                      setState(() {
                        if (typeSchedule == false) {
                          pilihTanggalSchedule1.value = dateSelect;
                        } else {
                          pilihTanggalSchedule2.value = dateSelect;
                        }
                        this.pilihTanggalSchedule1.refresh();
                        this.pilihTanggalSchedule2.refresh();
                      });
                    }
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(Get.context!).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Constanst.borderStyle5,
                        border: Border.all(
                            width: 0.5,
                            color: Color.fromARGB(255, 211, 205, 205))),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: typeSchedule == false
                            ? Text(
                                '${Constanst.convertDate("$pilihTanggalSchedule1")}')
                            : Text(
                                '${Constanst.convertDate("$pilihTanggalSchedule2")}')),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Link url *",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: Constanst.borderStyle5,
                      border: Border.all(
                          width: 0.5,
                          color: Color.fromARGB(255, 211, 205, 205))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: urlFormSchedule.value,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                          fontSize: 14.0, height: 2.0, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                TextButtonWidget(
                  title: "Update Data",
                  onTap: () {
                    Navigator.pop(Get.context!);
                    UtilsAlert.loadingSimpanData(
                        Get.context!, "Proses update data...");
                    var typeEdit =
                        typeSchedule == false ? 'Schedule1' : 'Schedule2';
                    editTanggalDanUrlSchedule(id, typeEdit);
                  },
                  colorButton: Constanst.colorPrimary,
                  colortext: Constanst.colorWhite,
                  border: BorderRadius.circular(8.0),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void editTanggalDanUrlSchedule(id, typeEdit) {
    var getTanggalInterviewAll = "";
    var getTanggalInterviewLast = "";
    var getBanyakTanggalInterview = 0;
    for (var element in listKandidatProses.value) {
      if (element['id'] == id) {
        if (typeEdit == 'Schedule1') {
          if (element['interview1_date'] == "" ||
              element['interview1_date'] == null ||
              element['interview1_date'] == "0000-00-00") {
            getBanyakTanggalInterview = 0;
            getTanggalInterviewLast = "";
          } else {
            List convert = element['interview1_date'].split(',');
            getBanyakTanggalInterview = convert.length;
            getTanggalInterviewLast = convert.last;
            getTanggalInterviewAll = element['interview1_date'];
          }
        } else {
          if (element['interview2_date'] == "" ||
              element['interview2_date'] == null ||
              element['interview2_date'] == "0000-00-00") {
            getBanyakTanggalInterview = 0;
            getTanggalInterviewLast = "";
          } else {
            List convert = element['interview2_date'].split(',');
            getBanyakTanggalInterview = convert.length;
            getTanggalInterviewLast = convert.last;
            getTanggalInterviewAll = element['interview2_date'];
          }
        }
      }
    }

    var convertDate = "";
    if (getBanyakTanggalInterview == 0) {
      if (typeEdit == 'Schedule1') {
        convertDate =
            "${DateFormat('yyyy-MM-dd').format(pilihTanggalSchedule1.value)}";
      } else {
        convertDate =
            "${DateFormat('yyyy-MM-dd').format(pilihTanggalSchedule2.value)}";
      }
    } else {
      if (typeEdit == 'Schedule1') {
        convertDate =
            "$getTanggalInterviewAll,${"${DateFormat('yyyy-MM-dd').format(pilihTanggalSchedule1.value)}"}";
      } else {
        convertDate =
            "$getTanggalInterviewAll,${"${DateFormat('yyyy-MM-dd').format(pilihTanggalSchedule2.value)}"}";
      }
    }

    Map<String, dynamic> body = {
      'id': '$id',
      'url': '${urlFormSchedule.value.text}',
    };

    if (typeEdit == 'Schedule1') {
      body['interview1_date'] = '$convertDate';
    } else {
      body['interview2_date'] = '$convertDate';
    }

    var connect = Api.connectionApi("post", body, "edit_status_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          alasanTerima.value.text = "";
          urlFormSchedule.value.text = "";
          getKandidatPelemar(selectedIdDetail.value, 'load');
          Navigator.pop(Get.context!);
        }
      }
    });
  }

  void showBottomFormInterview(typeInterview, id) {
    // typeInterview = false -> interview 1 & Schedule 1
    // typeInterview = true -> interview 2 & Schedule 2
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 18.0,
              right: 18.0,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 18,
              ),
              InkWell(
                onTap: () {
                  validasiSebelumAksi(
                      "Atur jadwal",
                      "Atur ulang jadwal interview",
                      "",
                      "atur_ulang_jadwal",
                      typeInterview,
                      id);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.clock,
                        color: Colors.orange,
                        size: 22,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text("Jadwalkan ulang",
                              style: TextStyle(fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              typeInterview == false
                  ? SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(Get.context!);
                              showBottomAlasan(true, id, "", "");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Iconsax.tick_circle,
                                    color: Colors.green,
                                    size: 22,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        "Terima Final",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        );
      },
    );
  }

  void aksiJadwalUlangSchedule(id, updateStatus) {
    Map<String, dynamic> body = {
      'id': '$id',
      'status': '$updateStatus',
    };
    var connect = Api.connectionApi("post", body, "edit_status_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          getKandidatPelemar(selectedIdDetail.value, 'load');
          Navigator.pop(Get.context!);
        }
      }
    });
  }

  void aksiTerimaFinalKandidat(id) {
    UtilsAlert.loadingSimpanData(Get.context!, 'Proses terima kandidat');
    Map<String, dynamic> body = {
      'id': '$id',
      'status': 'Accepted',
      'status_akhir': '1',
      'status_remaks': 'Interview1',
      'alasan_terima': '${alasanTerima.value.text}',
    };
    var connect = Api.connectionApi("post", body, "edit_status_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          alasanTerima.value.text = "";
          getKandidatPelemar(selectedIdDetail.value, 'load');
          Navigator.pop(Get.context!);
        }
      }
    });
  }

  void aksiUploadKandidatBaru() {
    UtilsAlert.loadingSimpanData(Get.context!, 'Sedang proses...');
    Map<String, dynamic> body = {
      'req_id': '${selectedIdDetail.value}',
      'candidate_name': '${nama_calon_kandidat.value.text}',
      'nama_file': '${namaFileUpload.value}',
      'status': 'Open',
      'status_akhir': '0',
      'alasan_terima': '${keterangan.value.text}',
    };
    var connect = Api.connectionApi("post", body, "insert-candidate");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          nama_calon_kandidat.value.text = "";
          keterangan.value.text = "";
          namaFileUpload.value = "";
          this.nama_calon_kandidat.refresh();
          this.keterangan.refresh();
          this.namaFileUpload.refresh();
          selectedInformasiView.value = 1;
          DetailController.jumpToPage(1);
          getKandidatPelemar(selectedIdDetail.value, 'load');
          Navigator.pop(Get.context!);
        }
      }
    });
  }

  void validasiSebelumAksi(pesan1, pesan2, pesan3, typeAksi, statusType, id) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 90,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$pesan1",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 10,
                          child: InkWell(
                            onTap: () => Navigator.pop(Get.context!),
                            child: Icon(
                              Iconsax.close_circle,
                              color: Colors.red,
                            ),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "$pesan2",
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Constanst.colorText2),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: typeAksi == "atur_ulang_jadwal"
                                ? TextButtonWidget(
                                    title: "Ya, atur ulang",
                                    onTap: () async {
                                      Navigator.pop(Get.context!);
                                      var updateStatus = statusType == false
                                          ? "Schedule1"
                                          : "Schedule2";
                                      aksiJadwalUlangSchedule(id, updateStatus);
                                    },
                                    colorButton: Constanst.colorButton1,
                                    colortext: Constanst.colorWhite,
                                    border: BorderRadius.circular(10.0),
                                  )
                                : typeAksi == "terima_final"
                                    ? TextButtonWidget(
                                        title: "Ya, Terima Final",
                                        onTap: () async {
                                          Navigator.pop(Get.context!);
                                          aksiTerimaFinalKandidat(id);
                                        },
                                        colorButton: Constanst.colorButton1,
                                        colortext: Constanst.colorWhite,
                                        border: BorderRadius.circular(10.0),
                                      )
                                    : typeAksi == "upload_kandidat"
                                        ? TextButtonWidget(
                                            title: "Submit",
                                            onTap: () async {
                                              Navigator.pop(Get.context!);
                                              UtilsAlert.loadingSimpanData(
                                                  Get.context!,
                                                  "Sedang Menyimpan File");
                                              var connectUpload = await Api
                                                  .connectionApiUploadFile(
                                                      "upload_file_kandidat",
                                                      filePengajuan.value);
                                              var valueBody =
                                                  jsonDecode(connectUpload);
                                              if (valueBody['status'] == true) {
                                                Navigator.pop(Get.context!);
                                                aksiUploadKandidatBaru();
                                              } else {
                                                UtilsAlert.showToast(
                                                    "Gagal kirim file");
                                              }
                                            },
                                            colorButton: Constanst.colorButton1,
                                            colortext: Constanst.colorWhite,
                                            border: BorderRadius.circular(10.0),
                                          )
                                        : SizedBox()),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(Get.context!),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: Constanst.borderStyle2,
                                  border: Border.all(
                                      color: Constanst.colorPrimary)),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12, bottom: 12),
                                  child: Text(
                                    "Urungkan",
                                    style: TextStyle(
                                        color: Constanst.colorPrimary),
                                  ),
                                ),
                              )),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            )
          ],
        );
      },
    );
  }

  void viewLampiranPermintaan(value) async {
    var urlViewFile = Api.urlFilePermintaanKandidat + value;

    final url = Uri.parse(urlViewFile);
    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } on Exception catch (_) {
      UtilsAlert.showToast('Tidak dapat membuka file');
    }
  }

  void viewLampiranKandidat(value) async {
    var urlViewFile = Api.urlFileKandidat + value;

    final url = Uri.parse(urlViewFile);
    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } on Exception catch (_) {
      UtilsAlert.showToast('Tidak dapat membuka file');
    }
  }

  void viewUrlPendukung(value) async {
    var urlViewFile = value;

    final url = Uri.parse(urlViewFile);
    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } on Exception catch (_) {
      UtilsAlert.showToast('Url / Link tidak valid');
    }
  }
}
