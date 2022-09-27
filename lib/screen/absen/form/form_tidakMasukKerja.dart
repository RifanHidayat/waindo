// ignore_for_file: deprecated_member_use
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/controller/tidak_masuk_kerja_controller.dart';
import 'package:siscom_operasional/screen/absen/tidak_masuk_kerja.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class FormTidakMasukKerja extends StatefulWidget {
  List? dataForm;
  FormTidakMasukKerja({Key? key, this.dataForm}) : super(key: key);
  @override
  _FormTidakMasukKerjaState createState() => _FormTidakMasukKerjaState();
}

class _FormTidakMasukKerjaState extends State<FormTidakMasukKerja> {
  var controller = Get.put(TidakMasukKerjaController());

  @override
  void initState() {
    print(widget.dataForm![0]);
    if (widget.dataForm![1] == true) {
      var convertDariTanggal =
          Constanst.convertDate1(widget.dataForm![0]['start_date']);
      var convertSampaiTanggal =
          Constanst.convertDate1(widget.dataForm![0]['end_date']);
      controller.dariTanggal.value.text = "$convertDariTanggal";
      controller.sampaiTanggal.value.text = "$convertSampaiTanggal";
      controller.alasan.value.text = "${widget.dataForm![0]['reason']}";
      controller.namaFileUpload.value = "${widget.dataForm![0]['leave_files']}";
      controller.idEditFormTidakMasukKerja.value =
          "${widget.dataForm![0]['id']}";
      controller.selectedDropdownFormTidakMasukKerjaTipe.value = "${widget.dataForm![0]['name']}";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 2,
          flexibleSpace: AppbarMenu1(
            title: "Form Tidak Hadir",
            colorTitle: Colors.black,
            colorIcon: Colors.black,
            icon: 1,
            iconShow: true,
            onTap: () {
              Get.offAll(TidakMasukKerja());
            },
          )),
      body: WillPopScope(
          onWillPop: () async {
            Get.offAll(TidakMasukKerja());
            return true;
          },
          child: SafeArea(
            child: Obx(
              () => Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      formTipe(),
                      SizedBox(
                        height: 20,
                      ),
                      formAjuanTanggal(),
                      SizedBox(
                        height: 20,
                      ),
                      formDelegasiKepada(),
                      SizedBox(
                        height: 20,
                      ),
                      formUploadFile(),
                      SizedBox(
                        height: 20,
                      ),
                      formAlasan(),
                    ],
                  ),
                ),
              ),
            ),
          )),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16.0),
          child: TextButtonWidget(
            title: "Simpan",
            onTap: () {
              controller.validasiKirimPengajuan(widget.dataForm![1]);
            },
            colorButton: Colors.blue,
            colortext: Constanst.colorWhite,
            border: BorderRadius.circular(20.0),
          )),
    );
  }

  Widget formTipe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tipe*"),
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
                items: controller.allTipeFormTidakMasukKerja.value
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                value: controller.selectedDropdownFormTidakMasukKerjaTipe.value,
                onChanged: (selectedValue) {
                  controller.selectedDropdownFormTidakMasukKerjaTipe.value =
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

  Widget formAjuanTanggal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Text("Dari Tanggal*"),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: Constanst.borderStyle1,
                          border: Border.all(
                              width: 0.5,
                              color: Color.fromARGB(255, 211, 205, 205))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTimeField(
                          format: DateFormat('dd-MM-yyyy'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: controller.dariTanggal.value,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                              context: context,
                              firstDate: DateTime(1800),
                              lastDate: DateTime(2200),
                              initialDate: currentValue ?? DateTime.now(),
                            );
                          },
                        ),
                      ),
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
                    Text("Sampai Tanggal*"),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: Constanst.borderStyle1,
                          border: Border.all(
                              width: 0.5,
                              color: Color.fromARGB(255, 211, 205, 205))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTimeField(
                          format: DateFormat('dd-MM-yyyy'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: controller.sampaiTanggal.value,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                              context: context,
                              firstDate: DateTime(1800),
                              lastDate: DateTime(2200),
                              initialDate: currentValue ?? DateTime.now(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget formDelegasiKepada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Delegasikan Kepada"),
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
                value: controller
                    .selectedDropdownFormTidakMasukKerjaDelegasi.value,
                onChanged: (selectedValue) {
                  controller.selectedDropdownFormTidakMasukKerjaDelegasi.value =
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

  Widget formUploadFile() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text("Upload File (Max 5MB)"),
        ),
        Expanded(
          child: Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(right: 10),
              child: controller.namaFileUpload.value == ""
                  ? InkWell(
                      onTap: () => controller.takeFile(),
                      child: Icon(Iconsax.document_upload))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 85,
                          child: Text(
                            controller.namaFileUpload.value.length > 20
                                ? controller.namaFileUpload.value
                                        .substring(0, 15) +
                                    '...'
                                : controller.namaFileUpload.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 15,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: InkWell(
                              onTap: () {
                                controller.namaFileUpload.value == "";
                                controller.takeFile();
                              },
                              child: Icon(
                                Iconsax.close_circle,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
        )
      ],
    );
  }

  Widget formAlasan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Alasan*"),
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
              controller: controller.alasan.value,
              maxLines: null,
              decoration: new InputDecoration(
                  border: InputBorder.none, hintText: "Tambahkan Alasan"),
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
