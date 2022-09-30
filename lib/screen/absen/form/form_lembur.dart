// ignore_for_file: deprecated_member_use
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/lembur_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/screen/absen/lembur.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class FormLembur extends StatefulWidget {
  List? dataForm;
  FormLembur({Key? key, this.dataForm}) : super(key: key);
  @override
  _FormLemburState createState() => _FormLemburState();
}

class _FormLemburState extends State<FormLembur> {
  var controller = Get.put(LemburController());

  @override
  void initState() {
    print(widget.dataForm![0]);
    if (widget.dataForm![1] == true) {
      controller.tanggalLembur.value.text =
          Constanst.convertDate("${widget.dataForm![0]['atten_date']}");
      var convertDariJam = widget.dataForm![0]['dari_jam'].split(":");
      var convertSampaiJam = widget.dataForm![0]['sampai_jam'].split(":");
      var hasilDarijam = "${convertDariJam[0]}:${convertDariJam[1]}";
      var hasilSampaijam = "${convertSampaiJam[0]}:${convertSampaiJam[1]}";
      controller.dariJam.value.text = hasilDarijam;
      controller.sampaiJam.value.text = hasilSampaijam;
      controller.catatan.value.text = widget.dataForm![0]['uraian'];
      controller.statusForm.value = true;
      controller.idpengajuanLembur.value = "${widget.dataForm![0]['id']}";
      controller.nomorAjuan.value.text =
          "${widget.dataForm![0]['nomor_ajuan']}";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Form Lembur",
            colorTitle: Colors.black,
            icon: 1,
            onTap: () {
              Get.offAll(Lembur());
            },
          )),
      body: WillPopScope(
          onWillPop: () async {
            Get.offAll(Lembur());
            return true;
          },
          child: SafeArea(
            child: Obx(
              () => Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        formHariDanTanggal(),
                        SizedBox(
                          height: 20,
                        ),
                        formJam(),
                        SizedBox(
                          height: 20,
                        ),
                        formDelegasiKepada(),
                        SizedBox(
                          height: 20,
                        ),
                        formCatatan(),
                      ],
                    ),
                  )),
            ),
          )),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16.0),
          child: TextButtonWidget(
            title: "Simpan",
            onTap: () => controller.validasiKirimPengajuan(),
            colorButton: Colors.blue,
            colortext: Constanst.colorWhite,
            border: BorderRadius.circular(20.0),
          )),
    );
  }

  Widget formHariDanTanggal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hari & Tanggal *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle1,
              border: Border.all(
                  width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 90,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    readOnly: true,
                    controller: controller.tanggalLembur.value,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                        fontSize: 14.0, height: 2.0, color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: IconButton(
                  onPressed: () async {
                    // DateTime now = DateTime.now();
                    // DateTime firstDateOfMonth =
                    //     DateTime(now.year, now.month + 0, 1);
                    // DateTime lastDayOfMonth =
                    //     DateTime(now.year, now.month + 1, 0);
                    var dateSelect = await showDatePicker(
                      context: Get.context!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: controller.initialDate.value,
                    );
                    if (dateSelect == null) {
                      UtilsAlert.showToast("Tanggal tidak terpilih");
                    } else {
                      controller.initialDate.value = dateSelect;
                      controller.tanggalLembur.value.text =
                          Constanst.convertDate("$dateSelect");
                      this.controller.tanggalLembur.refresh();
                      // DateTime now = DateTime.now();
                      // if (now.month == dateSelect.month) {
                      //   controller.initialDate.value = dateSelect;
                      //   controller.tanggalLembur.value.text =
                      //       Constanst.convertDate("$dateSelect");
                      //   this.controller.tanggalLembur.refresh();
                      // } else {
                      //   UtilsAlert.showToast(
                      //       "Tidak bisa memilih tanggal di luar bulan ini");
                      // }
                    }
                  },
                  icon: Icon(
                    Iconsax.arrow_down_14,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget formJam() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dari Jam *",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(Get.context!).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Constanst.borderStyle1,
                        border: Border.all(
                            width: 0.5,
                            color: Color.fromARGB(255, 211, 205, 205))),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            onTap: () {
                              showTimePicker(
                                context: Get.context!,
                                initialTime: TimeOfDay.now(),
                                initialEntryMode: TimePickerEntryMode.dial,
                              ).then((value) {
                                if (value == null) {
                                  UtilsAlert.showToast('gagal pilih jam');
                                } else {
                                  var convertJam = value.hour <= 9
                                      ? "0${value.hour}"
                                      : "${value.hour}";
                                  var convertMenit = value.minute <= 9
                                      ? "0${value.minute}"
                                      : "${value.minute}";
                                  controller.dariJam.value.text =
                                      "$convertJam:$convertMenit";
                                  this.controller.dariJam.refresh();
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 5),
                              child: Text(
                                controller.dariJam.value.text,
                                style: TextStyle(fontSize: 16),
                              ),
                            ))),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sampai Jam *",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(Get.context!).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Constanst.borderStyle1,
                        border: Border.all(
                            width: 0.5,
                            color: Color.fromARGB(255, 211, 205, 205))),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            onTap: () {
                              showTimePicker(
                                context: Get.context!,
                                initialTime: TimeOfDay.now(),
                                initialEntryMode: TimePickerEntryMode.dial,
                              ).then((value) {
                                if (value == null) {
                                  UtilsAlert.showToast('gagal pilih jam');
                                } else {
                                  var convertJam = value.hour <= 9
                                      ? "0${value.hour}"
                                      : "${value.hour}";
                                  var convertMenit = value.minute <= 9
                                      ? "0${value.minute}"
                                      : "${value.minute}";
                                  controller.sampaiJam.value.text =
                                      "$convertJam:$convertMenit";
                                  this.controller.sampaiJam.refresh();
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 5),
                              child: Text(
                                controller.sampaiJam.value.text,
                                style: TextStyle(fontSize: 16),
                              ),
                            ))),
                  ),
                ],
              ),
            ),
          )
        ],
      )
    ]);
  }

  Widget formDelegasiKepada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Pemberi Tugas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle1,
              border: Border.all(
                  width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                items: controller.allEmployeeDelegasi.value
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                value: controller.selectedDropdownDelegasi.value,
                onChanged: (selectedValue) {
                  controller.selectedDropdownDelegasi.value = selectedValue!;
                },
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget formCatatan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Catatan Tugas Lembur *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle1,
              border: Border.all(
                  width: 1.0, color: Color.fromARGB(255, 211, 205, 205))),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextField(
              cursorColor: Colors.black,
              controller: controller.catatan.value,
              maxLines: null,
              maxLength: 225,
              decoration: new InputDecoration(
                  border: InputBorder.none, hintText: "Tambahkan Uraian"),
              keyboardType: TextInputType.multiline,
              style:
                  TextStyle(fontSize: 12.0, height: 2.0, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
