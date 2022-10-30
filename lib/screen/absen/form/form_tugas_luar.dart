// ignore_for_file: deprecated_member_use
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/lembur_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/controller/tugas_luar_controller.dart';
import 'package:siscom_operasional/screen/absen/lembur.dart';
import 'package:siscom_operasional/screen/absen/tugas_luar.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class FormTugasLuar extends StatefulWidget {
  List? dataForm;
  FormTugasLuar({Key? key, this.dataForm}) : super(key: key);
  @override
  _FormTugasLuarState createState() => _FormTugasLuarState();
}

class _FormTugasLuarState extends State<FormTugasLuar> {
  var controller = Get.put(TugasLuarController());

  @override
  void initState() {
    if (widget.dataForm![1] == true) {
      print("nomor ajuan ${widget.dataForm![0]['nomor_ajuan']}");
      controller.nomorAjuan.value.text =
          "${widget.dataForm![0]['nomor_ajuan']}";
      controller.idpengajuanTugasLuar.value = "${widget.dataForm![0]['id']}";
      controller.statusForm.value = true;
      controller.emDelegation.value = "${widget.dataForm![0]['em_delegation']}";
      controller.tanggalTugasLuar.value.text =
          Constanst.convertDate("${widget.dataForm![0]['atten_date']}");
      if (controller.viewTugasLuar.value) {
        var convertDariJam = widget.dataForm![0]['dari_jam'].split(":");
        var convertSampaiJam = widget.dataForm![0]['sampai_jam'].split(":");
        var hasilDarijam = "${convertDariJam[0]}:${convertDariJam[1]}";
        var hasilSampaijam = "${convertSampaiJam[0]}:${convertSampaiJam[1]}";
        controller.dariJam.value.text = hasilDarijam;
        controller.sampaiJam.value.text = hasilSampaijam;
        controller.catatan.value.text = widget.dataForm![0]['uraian'];
      } else {
        controller.screenTanggalSelected.value = false;
        controller.dariTanggal.value.text = widget.dataForm![0]['start_date'];
        controller.sampaiTanggal.value.text = widget.dataForm![0]['end_date'];
        controller.catatan.value.text = widget.dataForm![0]['reason'];
        var listDateTerpilih = widget.dataForm![0]['date_selected'].split(',');
        List<DateTime> getDummy = [];
        for (var element in listDateTerpilih) {
          var convertDate = DateTime.parse(element);
          getDummy.add(convertDate);
        }
        controller.tanggalSelectedEdit.value = getDummy;
      }
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
          flexibleSpace: Obx(
            () => AppbarMenu1(
              title: controller.viewTugasLuar.value
                  ? "Form Tugas Luar"
                  : "Form Dinas Luar",
              colorTitle: Colors.black,
              icon: 1,
              onTap: () {
                Get.back();
              },
            ),
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
                        widget.dataForm![1] == true ? SizedBox() : formTipe(),
                        widget.dataForm![1] == true
                            ? SizedBox()
                            : SizedBox(
                                height: 20,
                              ),
                        !controller.viewTugasLuar.value
                            ? formPilihTanggal()
                            : formHariDanTanggal(),
                        !controller.viewTugasLuar.value
                            ? SizedBox()
                            : SizedBox(
                                height: 20,
                              ),
                        !controller.viewTugasLuar.value
                            ? SizedBox()
                            : formJam(),
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

  Widget formPilihTanggal() {
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
                    if (controller.idpengajuanTugasLuar.value != "") {
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
                autofocus: true,
                focusColor: Colors.grey,
                items: controller.allTipeFormTugasLuar.value
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                value: controller.selectedDropdownFormTugasLuarTipe.value,
                onChanged: (selectedValue) {
                  controller.gantiTypeAjuan(selectedValue);
                },
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
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
                child: InkWell(
                  onTap: () async {
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
                      controller.tanggalTugasLuar.value.text =
                          Constanst.convertDate("$dateSelect");
                      this.controller.tanggalTugasLuar.refresh();
                    }
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        controller.tanggalTugasLuar.value.text,
                        style: TextStyle(
                            fontSize: 14.0, height: 2.0, color: Colors.black),
                      )),
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
                      controller.tanggalTugasLuar.value.text =
                          Constanst.convertDate("$dateSelect");
                      this.controller.tanggalTugasLuar.refresh();
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
        controller.viewTugasLuar.value
            ? Text(
                "Tujuan Tugas Luar *",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                "Tujuan Dinas Luar *",
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
                  border: InputBorder.none, hintText: "Uraian Tujuan"),
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
