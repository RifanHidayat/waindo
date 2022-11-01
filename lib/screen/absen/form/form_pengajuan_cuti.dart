// ignore_for_file: deprecated_member_use
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/cuti_controller.dart';
import 'package:siscom_operasional/screen/absen/riwayat_cuti.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class FormPengajuanCuti extends StatefulWidget {
  List? dataForm;
  FormPengajuanCuti({Key? key, this.dataForm}) : super(key: key);
  @override
  _FormPengajuanCutiState createState() => _FormPengajuanCutiState();
}

class _FormPengajuanCutiState extends State<FormPengajuanCuti> {
  final controller = Get.put(CutiController());

  @override
  void initState() {
    print(widget.dataForm![0]);
    if (widget.dataForm![1] == true) {
      controller.dariTanggal.value.text = widget.dataForm![0]['start_date'];
      controller.sampaiTanggal.value.text = widget.dataForm![0]['end_date'];
      controller.alasan.value.text = widget.dataForm![0]['reason'];
      controller.atten_date_edit.value = widget.dataForm![0]['atten_date'];
      controller.typeIdEdit.value = widget.dataForm![0]['typeid'];
      controller.statusForm.value = true;
      controller.idEditFormCuti.value = "${widget.dataForm![0]['id']}";
      controller.emDelegationEdit.value =
          "${widget.dataForm![0]['em_delegation']}";
      controller.durasiIzin.value =
          int.parse(widget.dataForm![0]['leave_duration']);
      controller.nomorAjuan.value.text =
          "${widget.dataForm![0]['nomor_ajuan']}";
      controller.screenTanggalSelected.value = false;
      print(widget.dataForm![0]['id']);
      var listDateTerpilih = widget.dataForm![0]['date_selected'].split(',');
      List<DateTime> getDummy = [];
      for (var element in listDateTerpilih) {
        var convertDate = DateTime.parse(element);
        getDummy.add(convertDate);
      }
      setState(() {
        controller.tanggalSelectedEdit.value = getDummy;
      });
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
            title: "Pengajuan Cuti",
            colorTitle: Colors.black,
            colorIcon: Colors.black,
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
                  physics: BouncingScrollPhysics(),
                  child: !controller.statusHitungCuti.value
                      ? Container(
                          width: MediaQuery.of(Get.context!).size.width,
                          height: MediaQuery.of(Get.context!).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/amico.png",
                                height: 250,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text("Anda belum memiliki hak cuti"),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            informasiSisaCuti(),
                            SizedBox(
                              height: 16,
                            ),
                            Text("Tipe *",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            formTipe(),
                            SizedBox(
                              height: 16,
                            ),
                            formTanggalCuti(),
                            SizedBox(
                              height: 16,
                            ),
                            formDelegasiKepada(),
                            SizedBox(
                              height: 30,
                            ),
                            formUploadFile(),
                            SizedBox(
                              height: 30,
                            ),
                            formAlasan(),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          )),
      bottomNavigationBar: Obx(
        () => Padding(
            padding: EdgeInsets.all(16.0),
            child: !controller.statusHitungCuti.value
                ? SizedBox()
                : TextButtonWidget(
                    title: "Simpan",
                    onTap: () {
                      controller.validasiKirimPengajuan();
                    },
                    colorButton: Constanst.colorPrimary,
                    colortext: Constanst.colorWhite,
                    border: BorderRadius.circular(20.0),
                  )),
      ),
    );
  }

  Widget informasiSisaCuti() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Constanst.styleBoxDecoration1.borderRadius),
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(
                    "Cuti Pribadi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  Expanded(
                      child: Text(
                    "${controller.cutiTerpakai.value}/${controller.jumlahCuti.value}",
                    textAlign: TextAlign.right,
                  )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(Get.context!).size.width,
                child: Center(
                  child: LinearPercentIndicator(
                    barRadius: Radius.circular(15.0),
                    lineHeight: 8.0,
                    percent: controller.persenCuti.value,
                    progressColor: Constanst.colorPrimary,
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              // Text("Cuti Khusus"),
            ],
          ),
        ),
      ),
    );
  }

  Widget formTipe() {
    return Container(
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
            items: controller.allTipeFormCutiDropdown.value
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            value: controller.selectedTypeCuti.value,
            onChanged: (selectedValue) {
              controller.selectedTypeCuti.value = selectedValue!;
            },
            isExpanded: true,
          ),
        ),
      ),
    );
  }

  Widget formTanggalCuti() {
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.multiple,
                  initialSelectedDates: controller.tanggalSelectedEdit.value,
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    weekendTextStyle: TextStyle(color: Colors.red),
                    blackoutDateTextStyle: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough),
                  ),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (controller.statusForm.value == true) {
                      controller.tanggalSelectedEdit.value = args.value;
                      this.controller.tanggalSelectedEdit.refresh();
                    } else {
                      controller.tanggalSelected.value = args.value;
                      this.controller.tanggalSelected.refresh();
                    }
                  },
                ))
            : SizedBox(),
      ],
    );

    //  Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: [
    //         Expanded(
    //           child: Padding(
    //             padding: const EdgeInsets.only(right: 8),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text("Tanggal*",
    //                     style: TextStyle(fontWeight: FontWeight.bold)),
    //                 SizedBox(
    //                   height: 5,
    //                 ),
    //                 Positioned(
    //                   left: 0,
    //                   top: 80,
    //                   right: 0,
    //                   bottom: 0,
    //                   child: SfDateRangePicker(
    //                     selectionMode: DateRangePickerSelectionMode.range,
    //                     initialSelectedRange: PickerDateRange(
    //                         DateTime.now().subtract(const Duration(days: 4)),
    //                         DateTime.now().add(const Duration(days: 3))),
    //                   ),
    //                 )
    //                 // Container(
    //                 //   height: 50,
    //                 //   decoration: BoxDecoration(
    //                 //       color: Colors.white,
    //                 //       borderRadius: Constanst.borderStyle1,
    //                 //       border: Border.all(
    //                 //           width: 0.5,
    //                 //           color: Color.fromARGB(255, 211, 205, 205))),
    //                 //   child: Padding(
    //                 //       padding: const EdgeInsets.all(8.0),
    //                 //       child: SfDateRangePicker(
    //                 //         initialSelectedRange: PickerDateRange(
    //                 //             DateTime.now()
    //                 //                 .subtract(const Duration(days: 4)),
    //                 //             DateTime.now().add(const Duration(days: 3))),
    //                 //         selectionMode: DateRangePickerSelectionMode.range,
    //                 //       )
    //                 //       // DateTimeField(
    //                 //       //   format: DateFormat('dd-MM-yyyy'),
    //                 //       //   decoration: const InputDecoration(
    //                 //       //     border: InputBorder.none,
    //                 //       //   ),
    //                 //       //   controller: controller.dariTanggal.value,
    //                 //       //   onShowPicker: (context, currentValue) {
    //                 //       //     // DateTime now = DateTime.now();
    //                 //       //     // DateTime firstDateOfMonth =
    //                 //       //     //     DateTime(now.year, now.month + 0, 1);
    //                 //       //     // DateTime lastDayOfMonth =
    //                 //       //     //     DateTime(now.year, now.month + 1, 0);
    //                 //       //     return showDatePicker(
    //                 //       //       context: context,
    //                 //       //       firstDate: DateTime(2000),
    //                 //       //       lastDate: DateTime(2100),
    //                 //       //       initialDate: currentValue ?? DateTime.now(),
    //                 //       //     );
    //                 //       //   },
    //                 //       // ),
    //                 //       ),
    //                 // ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         Expanded(
    //           child: Padding(
    //             padding: const EdgeInsets.only(left: 8),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text("Sampai Tanggal*",
    //                     style: TextStyle(fontWeight: FontWeight.bold)),
    //                 SizedBox(
    //                   height: 5,
    //                 ),
    //                 Container(
    //                   height: 50,
    //                   decoration: BoxDecoration(
    //                       color: Colors.white,
    //                       borderRadius: Constanst.borderStyle1,
    //                       border: Border.all(
    //                           width: 0.5,
    //                           color: Color.fromARGB(255, 211, 205, 205))),
    //                   child: Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: DateTimeField(
    //                       format: DateFormat('dd-MM-yyyy'),
    //                       decoration: const InputDecoration(
    //                         border: InputBorder.none,
    //                       ),
    //                       controller: controller.sampaiTanggal.value,
    //                       onShowPicker: (context, currentValue) {
    //                         // DateTime now = DateTime.now();
    //                         // DateTime firstDateOfMonth =
    //                         //     DateTime(now.year, now.month + 0, 1);
    //                         // DateTime lastDayOfMonth =
    //                         //     DateTime(now.year, now.month + 1, 0);
    //                         return showDatePicker(
    //                           context: context,
    //                           firstDate: DateTime(2000),
    //                           lastDate: DateTime(2100),
    //                           initialDate: currentValue ?? DateTime.now(),
    //                         );
    //                       },
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         )
    //       ],
    //     )
    //   ],
    // );
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
        Text("Delegasikan Kepada",
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                value: controller.selectedDelegasi.value,
                onChanged: (selectedValue) {
                  controller.selectedDelegasi.value = selectedValue!;
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
          child: Text("Upload File (Max 5MB)",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(right: 10),
              child: controller.namaFileUpload.value == ""
                  ? InkWell(
                      onTap: () {
                        controller.takeFile();
                      },
                      child: Icon(
                        Iconsax.document_upload,
                        color: Constanst.colorPrimary,
                      ))
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
                                // controller.namaFileUpload.value == "";
                                // controller.base64FilePengajuan.value == "";
                                // controller.takeFile();
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
        Text("Alasan*", style: TextStyle(fontWeight: FontWeight.bold)),
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
