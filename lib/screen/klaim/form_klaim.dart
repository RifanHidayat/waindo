// ignore_for_file: deprecated_member_use
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/lembur_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/controller/riwayat_controller.dart';
import 'package:siscom_operasional/screen/absen/lembur.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/dashed_rect.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

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
                        formNamaKlaim(),
                        SizedBox(
                          height: 20,
                        ),
                        formTanggal(),
                        SizedBox(
                          height: 20,
                        ),
                        formTotalKlaim(),
                        SizedBox(
                          height: 20,
                        ),
                        formUnggalFile(),
                      ],
                    ),
                  )),
            ),
          )),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16.0),
          child: TextButtonWidget(
            title: "Simpan",
            // onTap: () => controller.validasiKirimPengajuan(),
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
                },
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget formNamaKlaim() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Nama Klaim *",
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
              border: Border.all(width: 1.0, color: Constanst.colorNonAktif)),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextField(
              controller: controller.namaklaim.value,
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

  Widget formTanggal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Tanggal *",
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
              controller.tanggalShow.value =
                  "${DateFormat('dd MMMM yyyy').format(date)}";
              controller.tanggalTerpilih.value =
                  "${DateFormat('yyyy-MM-dd').format(date)}";
              this.controller.tanggalShow.refresh();
              this.controller.tanggalTerpilih.refresh();
            }, currentTime: DateTime.now(), locale: LocaleType.en);
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(Get.context!).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: Constanst.borderStyle1,
                border: Border.all(width: 1.0, color: Constanst.colorNonAktif)),
            child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 12),
                child: Text("${controller.tanggalShow.value}")),
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
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Constanst.borderStyle1,
              border: Border.all(width: 1.0, color: Constanst.colorNonAktif)),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextField(
              controller: controller.totalKlaim.value,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              style:
                  TextStyle(fontSize: 14.0, height: 2.0, color: Colors.black),
              onSubmitted: (value) {
                controller.changeTotalKlaim(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget formUnggalFile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Unggah File",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        DashedRect(
          gap: 8,
          strokeWidth: 2,
          color: Constanst.colorNonAktif,
          child: Container(
              decoration: BoxDecoration(
                borderRadius: Constanst.borderStyle5,
              ),
              height: 60,
              width: MediaQuery.of(Get.context!).size.width,
              child:  Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.add_square,
                    size: 20,
                    color: Constanst.colorNonAktif,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Unggah file disini (Max 5MB)",
                      style: TextStyle(color: Constanst.colorNonAktif),
                    ),
                  )
                ],
              )),
        ),
      ],
    );
  }
}
