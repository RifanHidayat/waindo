// ignore_for_file: deprecated_member_use
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/Izin_controller.dart';
import 'package:siscom_operasional/controller/lembur_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/screen/absen/izin.dart';
import 'package:siscom_operasional/screen/absen/lembur.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class Formizin extends StatefulWidget {
  List? dataForm;
  Formizin({Key? key, this.dataForm}) : super(key: key);
  @override
  _FormizinState createState() => _FormizinState();
}

class _FormizinState extends State<Formizin> {
  var controller = Get.put(IzinController());

  @override
  void initState() {
    controller.startData();
    if (widget.dataForm![1] == true) {
      controller.tanggalAjuan.value.text =
          Constanst.convertDate("${widget.dataForm![0]['tgl_ajuan']}");
      controller.initialDate.value =
          DateTime.parse("${widget.dataForm![0]['atten_date']}");
      var convertDariJam = widget.dataForm![0]['dari_jam'].split(":");
      var hasilDarijam = "${convertDariJam[0]}:${convertDariJam[1]}";
      controller.jamAjuan.value.text = hasilDarijam;
      controller.catatan.value.text = widget.dataForm![0]['uraian'];
      controller.statusForm.value = true;
      controller.idpengajuanIzin.value = "${widget.dataForm![0]['id']}";
      controller.emIdDelegasi.value = "${widget.dataForm![0]['em_delegation']}";
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
            title: "Pengajuan Izin",
            colorTitle: Colors.black,
            icon: 1,
            onTap: () {
              Get.offAll(Izin());
            },
          )),
      body: WillPopScope(
          onWillPop: () async {
            Get.offAll(Izin());
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
                        formTipeIzin(),
                        SizedBox(
                          height: 20,
                        ),
                        formWaktuDanTanggal(),
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
            colorButton: Constanst.colorPrimary,
            colortext: Constanst.colorWhite,
            border: BorderRadius.circular(20.0),
          )),
    );
  }

  Widget formTipeIzin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tipe*",
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
                autofocus: true,
                focusColor: Colors.grey,
                items: controller.allTypeIzin.value
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                value: controller.selectedDropdownFormIzinType.value,
                onChanged: (selectedValue) {
                  controller.selectedDropdownFormIzinType.value =
                      selectedValue!;
                },
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget formWaktuDanTanggal() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 8,
      ),
      Text(
        "Waktu & Tanggal *",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: 6,
      ),
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
                  Container(
                    height: 45,
                    width: MediaQuery.of(Get.context!).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Constanst.borderStyle1,
                        border: Border.all(
                            width: 0.5,
                            color: Color.fromARGB(255, 211, 205, 205))),
                    child: Padding(
                        padding: const EdgeInsets.all(6.0),
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
                                  controller.jamAjuan.value.text =
                                      "$convertJam:$convertMenit";
                                  this.controller.jamAjuan.refresh();
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 5),
                              child: Text(
                                controller.jamAjuan.value.text,
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
                  Container(
                    height: 45,
                    width: MediaQuery.of(Get.context!).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Constanst.borderStyle1,
                        border: Border.all(
                            width: 0.5,
                            color: Color.fromARGB(255, 211, 205, 205))),
                    child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                            onTap: () {
                              DatePicker.showDatePicker(Get.context!,
                                  showTitleActions: true,
                                  minTime: DateTime(2000, 1, 1),
                                  maxTime: DateTime(2100, 1, 1),
                                  onConfirm: (date) {
                                controller.tanggalAjuan.value.text =
                                    Constanst.convertDate("$date");
                                this.controller.tanggalAjuan.refresh();
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 5),
                              child: Text(
                                "${controller.tanggalAjuan.value.text}",
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
          "Delegasikan kepada",
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
                items: controller.allDelegasiIzin.value
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                value: controller.selectedDropdownFormIzinDelegasi.value,
                onChanged: (selectedValue) {
                  controller.selectedDropdownFormIzinDelegasi.value =
                      selectedValue!;
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
          "Alasan *",
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
                  border: InputBorder.none, hintText: "Tambahkan Alasan"),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              style:
                  TextStyle(fontSize: 14.0, height: 2.0, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
