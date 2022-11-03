// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/klaim_controller.dart';
import 'package:siscom_operasional/controller/lembur_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/screen/absen/lembur.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/dashed_rect.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class FormKlaim extends StatefulWidget {
  List? dataForm;
  FormKlaim({Key? key, this.dataForm}) : super(key: key);
  @override
  _FormKlaimState createState() => _FormKlaimState();
}

class _FormKlaimState extends State<FormKlaim> {
  var controller = Get.put(KlaimController());

  @override
  void initState() {
    print(widget.dataForm![0]);
    if (widget.dataForm![1] == true) {
      // check id dan nomor ajuan
      controller.idpengajuanKlaim.value = "${widget.dataForm![0]['id']}";
      controller.nomorAjuan.value.text =
          "${widget.dataForm![0]['nomor_ajuan']}";
      controller.statusForm.value = true;
      // check type
      controller.checkTypeEdit(widget.dataForm![0]['cost_id']);
      // check tanggal klaim
      DateTime fltr1 = DateTime.parse("${widget.dataForm![0]['tgl_ajuan']}");
      controller.tanggalTerpilih.value =
          "${DateFormat('yyyy-MM-dd').format(fltr1)}";
      controller.tanggalShow.value =
          "${DateFormat('dd MMMM yyyy').format(fltr1)}";
      // check total klaim
      var totalKlaim = widget.dataForm![0]['total_claim'];
      var convertTotal = controller.convertToIdr(totalKlaim, 0);
      controller.totalKlaim.value.text = convertTotal;
      // check file
      var namaFile = widget.dataForm![0]['nama_file'];
      controller.namaFileUpload.value = namaFile == "" ? "" : namaFile;
      // check catatan
      controller.catatan.value.text = widget.dataForm![0]['description'];
      // check tanggal klaim / created on
      DateTime ftr1 = DateTime.parse(widget.dataForm![0]['created_on']);
      var filterTanggal = "${DateFormat('yyyy-MM-dd').format(ftr1)}";
      controller.tanggalKlaim.value.text = filterTanggal;
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
            title: "Form Klaim",
            colorTitle: Colors.black,
            icon: 1,
            onTap: () {
              Get.back();
            },
          )),
      body: WillPopScope(
          onWillPop: () async {
            Get.back();
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
                        formTipe(),
                        SizedBox(
                          height: 20,
                        ),
                        formTanggalKlaim(),
                        SizedBox(
                          height: 20,
                        ),
                        formTotalKlaim(),
                        SizedBox(
                          height: 20,
                        ),
                        formUnggahFile(),
                        SizedBox(
                          height: 20,
                        ),
                        formAlasan(),
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

  Widget formTipe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tipe Klaim *",
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
                items: controller.allTypeKlaim.value
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                value: controller.selectedDropdownType.value,
                onChanged: (selectedValue) {
                  controller.selectedDropdownType.value = selectedValue!;
                  this.controller.selectedDropdownType.refresh();
                },
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget formTanggalKlaim() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Tanggal Klaim *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5,
        ),
        InkWell(
          onTap: () {
            DatePicker.showDatePicker(Get.context!,
                showTitleActions: true,
                minTime: DateTime(2000, 1, 1),
                maxTime: DateTime(2100, 1, 1), onConfirm: (date) {
              controller.tanggalTerpilih.value =
                  "${DateFormat('yyyy-MM-dd').format(date)}";
              controller.tanggalShow.value =
                  "${DateFormat('dd MMMM yyyy').format(date)}";
              this.controller.tanggalTerpilih.refresh();
              this.controller.tanggalShow.refresh();
            }, currentTime: DateTime.now(), locale: LocaleType.en);
          },
          child: Container(
            width: MediaQuery.of(Get.context!).size.width,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: Constanst.borderStyle1,
                border: Border.all(
                    width: 1.0, color: Color.fromARGB(255, 211, 205, 205))),
            child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 12),
                child: Text(
                  "${controller.tanggalShow.value}",
                  style: TextStyle(fontSize: 14),
                )),
          ),
        ),
      ],
    );
  }

  Widget formTotalKlaim() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Total Klaim *",
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
              inputFormatters: [
                CurrencyTextInputFormatter(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                )
              ],
              cursorColor: Colors.black,
              controller: controller.totalKlaim.value,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: new InputDecoration(border: InputBorder.none),
              style:
                  TextStyle(fontSize: 14.0, height: 2.0, color: Colors.black),
              onSubmitted: (value) {
                controller.totalKlaim.value.text = value;
                this.controller.totalKlaim.refresh();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget formUnggahFile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Unggah File *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 16,
        ),
        DashedRect(
          gap: 8,
          strokeWidth: 2,
          color: Constanst.colorNonAktif,
          child: Container(
            decoration: BoxDecoration(borderRadius: Constanst.borderStyle5),
            height: 60,
            width: MediaQuery.of(Get.context!).size.width,
            child: controller.namaFileUpload.value == ""
                ? InkWell(
                    onTap: () {
                      controller.takeFile();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.add_square,
                          size: 20,
                          color: Constanst.colorNonAktif,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text(
                            "Unggah file disini (Max 5MB)",
                            style: TextStyle(color: Constanst.colorNonAktif),
                          ),
                        )
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () {
                      controller.takeFile();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${controller.namaFileUpload.value}",
                          style: TextStyle(fontSize: 14),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: IconButton(
                            icon: Icon(
                              Iconsax.close_circle,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              controller.namaFileUpload.value = "";
                              controller.filePengajuan.value = File("");
                              controller.uploadFile.value = false;
                              this.controller.namaFileUpload.refresh();
                              this.controller.filePengajuan.refresh();
                              this.controller.uploadFile.refresh();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget formAlasan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Catatan *",
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
                  border: InputBorder.none, hintText: "Catatan klaim"),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              style:
                  TextStyle(fontSize: 12.0, height: 2.0, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
