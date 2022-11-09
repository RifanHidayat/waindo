import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siscom_operasional/controller/api_controller.dart';
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
  HtmlEditorController controllerHtmlEditor = HtmlEditorController();
  PageController DetailController = PageController(initialPage: 0);

  var cari = TextEditingController().obs;
  var posisi = TextEditingController().obs;
  var kebutuhan = TextEditingController().obs;
  var spesifikasi = TextEditingController().obs;
  var keterangan = TextEditingController().obs;
  var nomorAjuan = TextEditingController().obs;

  var filePengajuan = File("").obs;

  var bulanSelectedSearchHistory = "".obs;
  var tahunSelectedSearchHistory = "".obs;
  var bulanDanTahunNow = "".obs;
  var namaFileUpload = "".obs;
  var tanggalPermintaan = "".obs;
  var selectedIdDetail = "".obs;
  var loadingString = "Sedang memuat...".obs;

  var selectType = 0.obs;
  var selectedInformasiView = 0.obs;

  var statusCari = false.obs;
  var uploadFile = false.obs;
  var loadingUpdateData = false.obs;

  var listTypeStatus = [].obs;
  var listProsesKandidat = [].obs;
  var listPermintaanKandidat = [].obs;
  var listPermintaanKandidatAll = [].obs;
  var detailPermintaan = [].obs;
  var listKandidatProses = [].obs;
  var listKandidatProsesAll = [].obs;

  var dumyTypeStatus = ["Semua", "Aktif", "Tidak Aktif"];
  var dumyTypeProsesKandidat = ["Sortir", "Test", "Interview", "Hasil"];

  @override
  void startData() async {
    getTimeNow();
    loadTypeStatus();
    loadTypeProsesKandidat();
    loadPermintaanKandidat();
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
    var dataUser = AppData.informasiUser;
    var getEmid = dataUser![0].em_id;
    Map<String, dynamic> body = {
      'em_id': getEmid,
      'bulan': bulanSelectedSearchHistory.value,
      'tahun': tahunSelectedSearchHistory.value,
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
        selectedInformasiView.value = 0;
        listKandidatProsesAll.value = valueBody['data'];
        this.loadingString.refresh();
        this.selectedInformasiView.refresh();
        this.listKandidatProses.refresh();
        this.listKandidatProsesAll.refresh();
        if (aksi == 'load_first') {
          Get.to(DetailPermintaan());
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
    List tampung = [];
    for (var element in listKandidatProsesAll.value) {
      if (name == "Sortir") {
        if (element['status'] == "Open") {
          tampung.add(element);
        }
      } else if (name == "Test") {
        if (element['status'] == "Testing") {
          tampung.add(element);
        }
      } else if (name == "Interview") {
        if (element['status'] == "Interview") {
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
                  status
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
                          child: status
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
        ? "Testing"
        : statusKandidat == "Testing"
            ? "Interview"
            : statusKandidat == "Interview"
                ? "Accepted"
                : "Open";
    Map<String, dynamic> body = {
      'id': '$id',
      'status': '$status',
    };
    var connect = Api.connectionApi("post", body, "edit_status_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          var typeProsesCurent = "";
          for (var element in listProsesKandidat.value) {
            if (element['status'] == true) {
              typeProsesCurent = element['name'];
            }
          }
          if (statusKandidat == "Interview") {
            aksiGantiStatusAkhirKandidat(id, true);
          }
          getKandidatPelemar(selectedIdDetail.value, 'load');
          loadTypeProsesKandidat();
          Navigator.pop(Get.context!);
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
      'status_remaks': '$statusKandidat',
    };
    var connect = Api.connectionApi("post", body, "tolak_kandidat");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        if (valueBody['status'] == true) {
          Navigator.pop(Get.context!);
          UtilsAlert.showToast('Berhasil tolak kandidat...');
          getKandidatPelemar(selectedIdDetail.value, 'load');
          loadTypeProsesKandidat();
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
                Flexible(
                  flex: 3,
                  child: HtmlEditor(
                    controller: controllerHtmlEditor, //required
                    htmlEditorOptions: HtmlEditorOptions(
                      hint: "Your text here...",
                      initialText: spesifikasi.value.text,
                    ),
                    htmlToolbarOptions: HtmlToolbarOptions(
                      toolbarPosition: ToolbarPosition.aboveEditor, //by default
                      toolbarType: ToolbarType.nativeScrollable, //by default
                      onButtonPressed: (ButtonType type, bool? status,
                          Function? updateStatus) {
                        return true;
                      },
                      defaultToolbarButtons: [
                        //add any other buttons here otherwise only a few buttons will show up!
                        // OtherButtons(copy: true, paste: true),
                        StyleButtons(),
                        FontSettingButtons(),
                        FontButtons(),
                        ColorButtons(),
                        ListButtons(),
                        ParagraphButtons(),
                        InsertButtons(),
                        OtherButtons(),
                      ],
                      onDropdownChanged: (DropdownType type, dynamic changed,
                          Function(dynamic)? updateSelectedItem) {
                        return true;
                      },
                    ),
                    otherOptions: OtherOptions(
                      height: 500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.blueGrey),
                        onPressed: () {
                          controllerHtmlEditor.undo();
                        },
                        child:
                            Text('Undo', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.blueGrey),
                        onPressed: () {
                          controllerHtmlEditor.clear();
                        },
                        child: Text('Reset',
                            style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary),
                        onPressed: () async {
                          var txt = await controllerHtmlEditor.getText();
                          if (txt.contains('src=\"data:')) {
                            txt =
                                '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                          }
                          spesifikasi.value.text = txt;
                          this.spesifikasi.refresh();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                ),
              ]),
        );
      },
    );
  }

  void viewLampiranPermintaan(value) async {
    var urlViewFile = Api.urlFilePermintaanKandidat + value;

    final url = Uri.parse(urlViewFile);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      UtilsAlert.showToast('Tidak dapat membuka file');
    }
  }

  void viewLampiranKandidat(value) async {
    var urlViewFile = Api.urlFileKandidat + value;

    final url = Uri.parse(urlViewFile);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      UtilsAlert.showToast('Tidak dapat membuka file');
    }
  }

  void viewUrlPendukung(value) async {
    var urlViewFile = value;

    final url = Uri.parse(urlViewFile);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      UtilsAlert.showToast('Tidak dapat membuka file');
    }
  }
}
