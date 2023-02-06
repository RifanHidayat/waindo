import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/bpjs.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/helper.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget/appbar.dart';
import 'package:siscom_operasional/utils/widget/text_group_column.dart';
import 'package:siscom_operasional/utils/widget/text_labe.dart';

class BpjsKetenagakerjaan extends StatelessWidget {
  BpjsKetenagakerjaan({super.key});
  var controller = Get.put(BpjsController());

  @override
  Widget build(BuildContext context) {
    controller.fetchBpjsKetenagakerjaam();
    return Scaffold(
      backgroundColor: Constanst.colorWhite,
      appBar: AppBarApp(
        text: "Bpjs Ketenagakerjaan",
        elevation: 0.0,
        color: Constanst.colorWhite,
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 10, bottom: 10),
                  child: InkWell(
                    onTap: () {
                      DatePicker.showPicker(
                        Get.context!,
                        pickerModel: CustomMonthPicker(
                          minTime: DateTime(2020, 1, 1),
                          maxTime: DateTime(2050, 1, 1),
                          currentTime: DateTime.now(),
                        ),
                        onConfirm: (time) {
                          if (time != null) {
                            print("$time");
                            var filter = DateFormat('yyyy-MM').format(time);
                            var array = filter.split('-');
                            var bulan = array[1];
                            var tahun = array[0];
                            controller.bulanKetenagakerjaan.value =
                                bulan.toString();
                            controller.tahunKetenagakerjaan.value =
                                tahun.toString();
                            controller.fetchBpjsKetenagakerjaam();
                            ;
                          }
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: Constanst.borderStyle2,
                          border: Border.all(color: Constanst.colorText2)),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Iconsax.calendar_1,
                              size: 16,
                            ),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  "${Constanst.convertDateBulanDanTahun("${controller.bulanKetenagakerjaan.value}-${controller.tahunKetenagakerjaan.value}")}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                if (controller.isLoadingBpjsKetenagakerjaan.value == true) {
                  return Expanded(
                    child: Container(
                      height: double.maxFinite,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (controller.bpjsKetenagakerjaan.isEmpty) {
                  return Expanded(
                    child: Container(
                      height: double.maxFinite,
                      child: const Center(
                        child: TextLabell(
                          text: "Data tidak ditemukan",
                        ),
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                        controller.bpjsKetenagakerjaan.length, (index) {
                      return _list(index);
                    }),
                  ),
                );
                // return controller.isLoadingBpjsKetenagakerjaan.value == true
                //     ? Container(
                //         child: Center(child: CircularProgressIndicator()),
                //       )
                //     : SingleChildScrollView(
                //         child: Column(
                //           children: List.generate(
                //               controller.bpjsKetenagakerjaan.length, (index) {
                //             return _list(index);
                //           }),
                //         ),
                //       );
              }),
            ],
          )),
    );
  }

  Widget _list(index) {
    var data = controller.bpjsKetenagakerjaan[index];
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            color: Constanst.colorPrimary,
            borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 20,
                  backgroundImage: AssetImage("assets/avatar_default.png"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextLabell(
                      text: data.fullName,
                      color: Constanst.colorWhite,
                    ),
                    TextLabell(
                      text: "No JKN. ${data.emBpjsTenagakerja}",
                      color: Constanst.colorWhite,
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Constanst.colorWhite),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextGroupColumn(
                      title: "Jaminan Kecelakaan kerja(JKK)",
                      subtitle: toCurrency(data.jkk)),
                  Divider(),
                  TextGroupColumn(
                      title: "Jaminan Kematian(JKM)",
                      subtitle: toCurrency(data.jkm)),
                  Divider(),
                  TextGroupColumn(
                      title: "Jaminan Hari Tua(JHT)",
                      subtitle: toCurrency(data.jhtTk)),
                  Divider(),
                  TextGroupColumn(
                      title: "Jaminan Pensiun(JP)",
                      subtitle: toCurrency(data.jpTk)),
                  Divider(),
                  // Row(
                  //   children: const [
                  //     Expanded(
                  //         flex: 10,
                  //         child: TextGroupColumn(title: "JKK", subtitle: "")),
                  //     Expanded(
                  //         flex: 30,
                  //         child: TextGroupColumn(
                  //             title: "PT  (5%)", subtitle: "Rp.2000m,00")),
                  //     // Expanded(
                  //     //     flex: 30,
                  //     //     child: TextGroupColumn(
                  //     //         title: "TK (1%)", subtitle: "Rp.2000m,00"))
                  //   ],
                  // ),
                  // Divider(),
                  // Row(
                  //   children: const [
                  //     Expanded(
                  //         flex: 10,
                  //         child: TextGroupColumn(title: "JKM", subtitle: "")),
                  //     Expanded(
                  //         flex: 30,
                  //         child: TextGroupColumn(
                  //             title: "TK (4%)", subtitle: "Rp.2000m,00")),
                  //     // Expanded(
                  //     //     flex: 30,
                  //     //     child: TextGroupColumn(
                  //     //         title: "TK (1%)", subtitle: "Rp.2000m,00"))
                  //   ],
                  // ),
                  // Divider(),
                  // Row(
                  //   children: const [
                  //     Expanded(
                  //         flex: 10,
                  //         child: TextGroupColumn(title: "JHT", subtitle: "")),
                  //     Expanded(
                  //         flex: 15,
                  //         child: TextGroupColumn(
                  //             title: "PT(4%)", subtitle: "Rp.2000m,00")),
                  //     Expanded(
                  //         flex: 15,
                  //         child: TextGroupColumn(
                  //             title: "TK(4%)", subtitle: "Rp.2000m,00")),
                  //     // Expanded(
                  //     //     flex: 30,
                  //     //     child: TextGroupColumn(
                  //     //         title: "TK (1%)", subtitle: "Rp.2000m,00"))
                  //   ],
                  // ),
                  // Divider(),
                  // Row(
                  //   children: const [
                  //     Expanded(
                  //         flex: 10,
                  //         child: TextGroupColumn(title: "JP", subtitle: "")),
                  //     Expanded(
                  //         flex: 15,
                  //         child: TextGroupColumn(
                  //             title: "PT(2%)", subtitle: "Rp.2000m,00")),
                  //     Expanded(
                  //         flex: 15,
                  //         child: TextGroupColumn(
                  //             title: "TK(4%)", subtitle: "Rp.2000m,00")),
                  //     // Expanded(
                  //     //     flex: 30,
                  //     //     child: TextGroupColumn(
                  //     //         title: "TK (1%)", subtitle: "Rp.2000m,00"))
                  //   ],
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
