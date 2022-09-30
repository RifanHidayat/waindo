import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/screen/absen/history_absen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';

class LaporanAbsen extends StatefulWidget {
  var dataForm;
  LaporanAbsen({Key? key, this.dataForm}) : super(key: key);
  @override
  _LaporanAbsenState createState() => _LaporanAbsenState();
}

class _LaporanAbsenState extends State<LaporanAbsen> {
  var controller = Get.put(AbsenController());

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
              title: "Laporan Absensi",
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      cariData(),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        height: 5,
                        color: Constanst.colorNonAktif,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 85,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Riwayat Absensi Karyawan ${controller.namaDepartemenTerpilih.value}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 15,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PopupMenuButton(
                                    padding: EdgeInsets.all(0.0),
                                    icon: Icon(
                                      Iconsax.filter,
                                    ),
                                    offset: const Offset(0, 40),
                                    elevation: 2,
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                          value: "1",
                                          onTap: () =>
                                              controller.filterData('1'),
                                          child: Text("Terlambat absen masuk")),
                                      PopupMenuItem(
                                          value: "2",
                                          onTap: () =>
                                              controller.filterData('2'),
                                          child: Text("Pulang lebih lama")),
                                      PopupMenuItem(
                                          value: "3",
                                          onTap: () =>
                                              controller.filterData('3'),
                                          child: Text("Tidak absen keluar"))
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Flexible(
                        child: controller.listLaporanFilter.value.isEmpty
                            ? Center(
                                child: Text(controller.loading.value),
                              )
                            : listAbsensiKaryawan(),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget cariData() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tanggal",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: Constanst.borderStyle4,
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
                            controller: controller.tanggalLaporan.value,
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
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Departement",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      InkWell(
                        onTap: () {
                          controller.showDataDepartemenAkses();
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(Get.context!).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15)),
                              border: Border.all(
                                  width: 0.5,
                                  color: Color.fromARGB(255, 211, 205, 205))),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(controller.departemen.value.text),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: InkWell(
              onTap: () => controller.carilaporanAbsenkaryawan(),
              child: Container(
                  decoration: BoxDecoration(
                    color: Constanst.colorPrimary,
                    borderRadius: Constanst.borderStyle3,
                  ),
                  child: textSubmit()),
            ),
          ),
        ],
      ),
    );
  }

  Widget listAbsensiKaryawan() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: controller.listLaporanFilter.value.length,
        itemBuilder: (context, index) {
          var fullName =
              controller.listLaporanFilter.value[index]['full_name'] ?? "";
          var namaKaryawan = "$fullName";
          var jamMasuk =
              controller.listLaporanFilter.value[index]['signin_time'];
          var jamKeluar =
              controller.listLaporanFilter.value[index]['signout_time'];
          var tanggal = controller.listLaporanFilter.value[index]['atten_date'];
          var listJamMasuk = (jamMasuk!.split(':'));
          var listJamKeluar = (jamKeluar!.split(':'));
          var perhitunganJamMasuk1 =
              830 - int.parse("${listJamMasuk[0]}${listJamMasuk[1]}");
          var perhitunganJamMasuk2 =
              1800 - int.parse("${listJamKeluar[0]}${listJamKeluar[1]}");

          var getColorMasuk;
          var getColorKeluar;

          if (perhitunganJamMasuk1 < 0) {
            getColorMasuk = Colors.red;
          } else {
            getColorMasuk = Colors.black;
          }

          if (perhitunganJamMasuk2 == 0) {
            getColorKeluar = Colors.black;
          } else if (perhitunganJamMasuk2 > 0) {
            getColorKeluar = Colors.red;
          } else if (perhitunganJamMasuk2 < 0) {
            getColorKeluar = Colors.blue;
          }

          return InkWell(
            onTap: () {
              controller.historySelected(
                  controller.listLaporanFilter.value[index]['id'], 'laporan');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 40,
                      child: Text(
                        namaKaryawan,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      flex: 25,
                      child: Row(
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: getColorMasuk,
                            size: 14,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              jamMasuk,
                              style:
                                  TextStyle(color: getColorMasuk, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 25,
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: getColorKeluar,
                            size: 14,
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: controller.listLaporanFilter.value[index]
                                          ['signout_longlat'] ==
                                      ""
                                  ? Text("")
                                  : Text(
                                      jamKeluar,
                                      style: TextStyle(
                                          color: getColorKeluar, fontSize: 14),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
              ],
            ),
          );
        });
  }

  Widget textSubmit() {
    return controller.statusLoadingSubmitLaporan.value == false
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.search_favorite,
                size: 18,
                color: Constanst.colorWhite,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Submit Data",
                  style: TextStyle(color: Constanst.colorWhite),
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Center(
                  child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      )),
                ),
              )
            ],
          );
  }
}
