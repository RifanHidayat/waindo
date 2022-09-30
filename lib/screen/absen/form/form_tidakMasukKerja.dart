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
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
      var convertDariTanggal = widget.dataForm![0]['start_date'];
      var convertSampaiTanggal = widget.dataForm![0]['end_date'];
      controller.dariTanggal.value.text = "$convertDariTanggal";
      controller.sampaiTanggal.value.text = "$convertSampaiTanggal";
      controller.alasan.value.text = "${widget.dataForm![0]['reason']}";
      controller.namaFileUpload.value = "${widget.dataForm![0]['leave_files']}";
      controller.tanggalBikinPengajuan.value =
          "${widget.dataForm![0]['atten_date']}";
      controller.idEditFormTidakMasukKerja.value =
          "${widget.dataForm![0]['id']}";
      controller.selectedDropdownFormTidakMasukKerjaTipe.value =
          "${widget.dataForm![0]['name']}";
      controller.nomorAjuan.value.text =
          "${widget.dataForm![0]['nomor_ajuan']}";
      controller.durasiIzin.value =
          int.parse(widget.dataForm![0]['leave_duration']);
      controller.screenTanggalSelected.value = false;
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
                  physics: BouncingScrollPhysics(),
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
                      SizedBox(
                        height: 20,
                      ),
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
        Text("Tanggal*", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 5,
        ),
        widget.dataForm![1] == true
            ? customTanggalDariSampaiDari()
            : SizedBox(),
        controller.screenTanggalSelected.value == true
            ? Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: Constanst.colorButton2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.multiple,
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    weekendTextStyle: TextStyle(color: Colors.red),
                    blackoutDateTextStyle: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough),
                  ),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    controller.tanggalSelected.value = args.value;
                    this.controller.tanggalSelected.refresh();
                  },
                ))
            : SizedBox(),
      ],
    );
  }

  Widget customTanggalDariSampaiDari() {
    return Container(
        height: 50,
        width: MediaQuery.of(Get.context!).size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Constanst.borderStyle1,
            border: Border.all(
                width: 0.5, color: Color.fromARGB(255, 211, 205, 205))),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 90,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Constanst.convertDate1(
                            "${controller.dariTanggal.value.text}")),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text("sd"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(Constanst.convertDate1(
                              "${controller.sampaiTanggal.value.text}")),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: IconButton(
                    onPressed: () {
                      controller.screenTanggalSelected.value =
                          !controller.screenTanggalSelected.value;
                    },
                    icon: Icon(
                      Iconsax.edit,
                      size: 18,
                    ),
                  ),
                )
              ],
            )));
  }

  Widget formDelegasiKepada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Delegasikan Kepada",
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
          child: Text(
            "Upload File (Max 5MB)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
        Text(
          "Alasan*",
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
              controller: controller.alasan.value,
              maxLines: null,
              maxLength: 225,
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
