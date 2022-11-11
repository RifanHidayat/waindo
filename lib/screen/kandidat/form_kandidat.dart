// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/kandidat_controller.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/dashed_rect.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class FormKandidat extends StatefulWidget {
  List? dataForm;
  FormKandidat({Key? key, this.dataForm}) : super(key: key);
  @override
  _FormKandidatState createState() => _FormKandidatState();
}

class _FormKandidatState extends State<FormKandidat> {
  var controller = Get.put(KandidatController());

  @override
  void initState() {
    if (widget.dataForm![1] == true) {}
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
          title: "Permintaan Kandidat",
          colorTitle: Colors.black,
          icon: 1,
          onTap: () {
            Get.back();
          },
        ),
      ),
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
                          height: 16,
                        ),
                        posisi(),
                        SizedBox(
                          height: 16,
                        ),
                        formTipe(),
                        SizedBox(
                          height: 16,
                        ),
                        kebutuhan(),
                        SizedBox(
                          height: 16,
                        ),
                        spesifikasi(),
                        SizedBox(
                          height: 16,
                        ),
                        keterangan(),
                        SizedBox(
                          height: 16,
                        ),
                        formUnggahFile(),
                      ],
                    ),
                  )),
            ),
          )),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16.0),
          child: TextButtonWidget(
            title: "Simpan",
            onTap: () =>
                controller.validasiKirimPermintaan(widget.dataForm![1]),
            colorButton: Constanst.colorPrimary,
            colortext: Constanst.colorWhite,
            border: BorderRadius.circular(20.0),
          )),
    );
  }

  Widget posisi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Posisi *",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle1,
              border: Border.all(
                  width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.posisi.value,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              style:
                  TextStyle(fontSize: 14.0, height: 2.0, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget formTipe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tujuan permintaan *",
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
                items: controller.permintaanKandidatUntuk.value
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                value: controller.selectedKandidatUntuk.value,
                onChanged: (selectedValue) {
                  controller.selectedKandidatUntuk.value = selectedValue!;
                },
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget kebutuhan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jumlah Kebutuhan Kandidat *",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle1,
              border: Border.all(
                  width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.kebutuhan.value,
              cursorColor: Colors.black,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              style:
                  TextStyle(fontSize: 14.0, height: 2.0, color: Colors.black),
              onSubmitted: (value) {
                controller.kebutuhan.value.text = value;
                this.controller.kebutuhan.refresh();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget spesifikasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Spesifikasi *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5,
        ),
        InkWell(
          onTap: () {
            controller.showModalHtmlEditor();
          },
          child: Container(
              width: MediaQuery.of(Get.context!).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: Constanst.borderStyle1,
                  border: Border.all(
                      width: 1.0, color: Color.fromARGB(255, 211, 205, 205))),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 10, bottom: 10),
                child: Html(
                  data: controller.spesifikasi.value.text,
                  style: {
                    "body": Style(
                      fontSize: FontSize(14),
                      color: Colors.black,
                    ),
                  },
                ),
              )),
        ),
      ],
    );
  }

  Widget keterangan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Keterangan *",
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
              controller: controller.keterangan.value,
              maxLines: null,
              maxLength: 225,
              decoration:
                  new InputDecoration(border: InputBorder.none, hintText: ""),
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
                        Expanded(
                          flex: 90,
                          child: Text(
                            "${controller.namaFileUpload.value}",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 10,
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
}
