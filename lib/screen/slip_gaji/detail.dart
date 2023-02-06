import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/controller/slip_gaji.controller.dart';
import 'package:siscom_operasional/model/slip_gaji.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/helper.dart';
import 'package:siscom_operasional/utils/month_picker.dart';
import 'package:siscom_operasional/utils/month_year_picker.dart';
import 'package:siscom_operasional/utils/widget/appbar.dart';
import 'package:siscom_operasional/utils/widget/text_group_row.dart';
import 'package:siscom_operasional/utils/widget/text_labe.dart';
import 'dart:math' as math;

import 'package:siscom_operasional/utils/widget_utils.dart';

class SlipGajiDetail extends StatelessWidget {
  SlipGajiDetail({
    super.key,
  });
  var controller = Get.put(SlipGajiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.colorWhite,
      appBar: AppBarApp(
        text: "Sllip gaji",
        elevation: 0.0,
        textSize: 16.0,
        color: Constanst.colorWhite,
        action: [
          IconButton(
            icon: Icon(
              Icons.download,
            ),
            onPressed: () {
              // do something
            },
          )
        ],
      ),
      body: Obx(() {
        return controller.args.value.amount == null
            ? Container(
                child: Center(
                    child: TextLabell(
                  text: "Data tidak ditemukan",
                )),
              )
            : Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10),
                        height: double.maxFinite,
                        child: SingleChildScrollView(
                          child: Container(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    DatePicker.showPicker(
                                      Get.context!,
                                      pickerModel: CustomMonthOnlyPicker(
                                        minTime: DateTime(2020, 1, 1),
                                        maxTime: DateTime(2050, 1, 1),
                                        currentTime:
                                            DateTime(controller.tahun.value),
                                      ),
                                      onConfirm: (time) {
                                        if (time != null) {
                                          print("$time");
                                          var filter = DateFormat('yyyy-MM')
                                              .format(time);
                                          var array = filter.split('-');
                                          var bulan = array[1];
                                          var tahun = array[0];

                                          if (controller.slipGaji
                                              .where((p0) =>
                                                  p0.monthNumber ==
                                                  int.parse(bulan.toString()))
                                              .toList()
                                              .isNotEmpty) {
                                            if (int.parse(bulan) == 1) {
                                              controller.bulan.value =
                                                  "January";
                                            } else if (int.parse(bulan) == 2) {
                                              controller.bulan.value =
                                                  "February";
                                            } else if (int.parse(bulan) == 3) {
                                              controller.bulan.value = "Maret";
                                            } else if (int.parse(bulan) == 4) {
                                              controller.bulan.value = "April";
                                            } else if (int.parse(bulan) == 5) {
                                              controller.bulan.value = "Mei";
                                            } else if (int.parse(bulan) == 7) {
                                              controller.bulan.value = "Juni";
                                            } else if (int.parse(bulan) == 8) {
                                              controller.bulan.value = "Juli";
                                            } else if (int.parse(bulan) == 9) {
                                              controller.bulan.value =
                                                  "Agustus";
                                            } else if (int.parse(bulan) == 9) {
                                              controller.bulan.value =
                                                  "september";
                                            } else if (int.parse(bulan) == 10) {
                                              controller.bulan.value =
                                                  "Oktober";
                                            } else if (int.parse(bulan) == 11) {
                                              controller.bulan.value =
                                                  "November";
                                            } else if (int.parse(bulan) == 12) {
                                              controller.bulan.value =
                                                  "Desember";
                                            }

                                            controller.args.value = controller
                                                .slipGaji
                                                .where((p0) =>
                                                    p0.monthNumber ==
                                                    int.parse(bulan.toString()))
                                                .toList()
                                                .first;
                                          } else {
                                            UtilsAlert.showToast(
                                                "Data tidak terseedia");
                                          }
                                        }
                                      },
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: Constanst.borderStyle2,
                                        border: Border.all(
                                            color: Constanst.colorText2)),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Iconsax.calendar_1,
                                            size: 16,
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 8),
                                              child: Obx(() {
                                                return Text(
                                                  controller.bulan.value,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                );
                                              }),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),

                                //pendapatan
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1, color: Constanst.grey)),
                                  child: Column(
                                    children: [
                                      Container(
                                          padding: EdgeInsets.all(20),
                                          child: InkWell(
                                            onTap: () {
                                              controller.isPendapatan.value =
                                                  !controller
                                                      .isPendapatan.value;
                                              controller.slipGaji.refresh();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextLabell(
                                                  text: "Pendapatan",
                                                  color: Constanst.colorPrimary,
                                                  size: 14,
                                                ),
                                                // const Icon(
                                                //   Icons.arrow_forward_ios,
                                                //   size: 14,
                                                // ),
                                                Obx(() {
                                                  return controller.isPendapatan
                                                              .value ==
                                                          true
                                                      ? Transform.rotate(
                                                          angle: -math.pi / 2,
                                                          child: const Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            size: 14,
                                                          ),
                                                        )
                                                      : Transform.rotate(
                                                          angle: -math.pi / 2,
                                                          child: const Icon(
                                                            Icons
                                                                .arrow_back_ios,
                                                            size: 14,
                                                          ),
                                                        );
                                                })
                                              ],
                                            ),
                                          )),
                                      Obx(() {
                                        return controller.args.value.pendapatan!
                                                .isNotEmpty
                                            ? controller.isPendapatan.value ==
                                                    true
                                                ? Container(
                                                    padding: EdgeInsets.all(20),
                                                    child: Column(
                                                      children: List.generate(
                                                          controller
                                                              .args
                                                              .value
                                                              .pendapatan!
                                                              .length, (index) {
                                                        var data = controller
                                                            .args
                                                            .value
                                                            .pendapatan![index];

                                                        return TextGroupRow(
                                                            title: data.name,
                                                            subtitle: controller
                                                                        .args
                                                                        .value
                                                                        .index ==
                                                                    "value01"
                                                                ? toCurrency(data
                                                                    .value01)
                                                                : controller
                                                                            .args
                                                                            .value
                                                                            .index
                                                                            .toString() ==
                                                                        "value02"
                                                                    ? toCurrency(data
                                                                        .value02)
                                                                    : controller.args.value.index ==
                                                                            "value03"
                                                                        ? toCurrency(data
                                                                            .value03)
                                                                        : controller.args.value.index ==
                                                                                "value04"
                                                                            ? toCurrency(data.value04)
                                                                            : controller.args.value.index == "value05"
                                                                                ? toCurrency(data.value05)
                                                                                : controller.args.value.index == "value06"
                                                                                    ? toCurrency(data.value06)
                                                                                    : controller.args.value.index == "value07"
                                                                                        ? toCurrency(data.value07)
                                                                                        : controller.args.value.index == "value08"
                                                                                            ? toCurrency(data.value08)
                                                                                            : controller.args.value.index == "value09"
                                                                                                ? toCurrency(data.value09)
                                                                                                : controller.args.value.index == "value10"
                                                                                                    ? toCurrency(data.value10)
                                                                                                    : controller.args.value.index == "value11"
                                                                                                        ? toCurrency(data.value11)
                                                                                                        : controller.args.value.index == "value12"
                                                                                                            ? toCurrency(data.value12)
                                                                                                            : toCurrency(data.value12));
                                                      }),
                                                    ),
                                                  )
                                                : Container()
                                            : Container();
                                      }),
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Constanst.grey,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10))),
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  flex: 50,
                                                  child: Container(
                                                      child: TextLabell(
                                                    text: "Total Pendapatan",
                                                    size: 16,
                                                    color:
                                                        Constanst.colorPrimary,
                                                  ))),
                                              Expanded(
                                                  flex: 50,
                                                  child: Container(
                                                      child: TextLabell(
                                                          align:
                                                              TextAlign.right,
                                                          weight:
                                                              FontWeight.w600,
                                                          text: toCurrency(
                                                              controller
                                                                  .args
                                                                  .value
                                                                  .jumllahPendapatan))))
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),

                                //pendapatan
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1, color: Constanst.grey)),
                                  child: Column(
                                    children: [
                                      Container(
                                          padding: EdgeInsets.all(20),
                                          child: InkWell(
                                            onTap: () {
                                              controller.isPemotong.value =
                                                  !controller.isPemotong.value;
                                              controller.slipGaji.refresh();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextLabell(
                                                  text: "Pemotong",
                                                  color: Constanst.colorPrimary,
                                                  size: 14,
                                                ),
                                                Obx(() {
                                                  return InkWell(
                                                    onTap: () {
                                                      controller.isPemotong
                                                              .value =
                                                          !controller
                                                              .isPemotong.value;
                                                      controller.slipGaji
                                                          .refresh();
                                                    },
                                                    child: controller.isPemotong
                                                                .value ==
                                                            true
                                                        ? Transform.rotate(
                                                            angle: -math.pi / 2,
                                                            child: const Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: 14,
                                                            ),
                                                          )
                                                        : Transform.rotate(
                                                            angle: -math.pi / 2,
                                                            child: const Icon(
                                                              Icons
                                                                  .arrow_back_ios,
                                                              size: 14,
                                                            ),
                                                          ),
                                                  );
                                                })
                                                // InkWell(
                                                //   onTap: () {
                                                //     controller.isPemotong.value =
                                                //         !controller.isPemotong.value;
                                                //     controller.slipGaji.refresh();
                                                //   },
                                                //   child: const Icon(
                                                //     Icons.arrow_forward_ios,
                                                //     size: 14,
                                                //   ),
                                                // )
                                              ],
                                            ),
                                          )),
                                      controller.args.value.pemotong!.isNotEmpty
                                          ? Obx(() {
                                              return controller
                                                          .isPemotong.value ==
                                                      true
                                                  ? Container(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      child: Column(
                                                        children: List.generate(
                                                            controller
                                                                .args
                                                                .value
                                                                .pemotong!
                                                                .length,
                                                            (index) {
                                                          var data = controller
                                                              .args
                                                              .value
                                                              .pemotong![index];
                                                          return TextGroupRow(
                                                              title: data.name,
                                                              subtitle: controller
                                                                          .args
                                                                          .value
                                                                          .index ==
                                                                      "value01"
                                                                  ? toCurrency(data
                                                                      .value01)
                                                                  : controller
                                                                              .args
                                                                              .value
                                                                              .index
                                                                              .toString() ==
                                                                          "value02"
                                                                      ? toCurrency(data
                                                                          .value02)
                                                                      : controller.args.value.index ==
                                                                              "value03"
                                                                          ? toCurrency(
                                                                              data.value03)
                                                                          : controller.args.value.index == "value04"
                                                                              ? toCurrency(data.value04)
                                                                              : controller.args.value.index == "value05"
                                                                                  ? toCurrency(data.value05)
                                                                                  : controller.args.value.index == "value06"
                                                                                      ? toCurrency(data.value06)
                                                                                      : controller.args.value.index == "value07"
                                                                                          ? toCurrency(data.value07)
                                                                                          : controller.args.value.index == "value08"
                                                                                              ? toCurrency(data.value08)
                                                                                              : controller.args.value.index == "value09"
                                                                                                  ? toCurrency(data.value09)
                                                                                                  : controller.args.value.index == "value10"
                                                                                                      ? toCurrency(data.value10)
                                                                                                      : controller.args.value.index == "value11"
                                                                                                          ? toCurrency(data.value11)
                                                                                                          : controller.args.value.index == "value12"
                                                                                                              ? toCurrency(data.value12)
                                                                                                              : toCurrency(data.value12));
                                                        }),
                                                      ),
                                                    )
                                                  : Container();
                                            })
                                          : Container(),
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Constanst.grey,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10))),
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  flex: 50,
                                                  child: Container(
                                                      child: TextLabell(
                                                    text: "Total Pemotong",
                                                    size: 16,
                                                    color:
                                                        Constanst.colorPrimary,
                                                  ))),
                                              Expanded(
                                                  flex: 50,
                                                  child: Container(
                                                      child: TextLabell(
                                                          align:
                                                              TextAlign.right,
                                                          weight:
                                                              FontWeight.w600,
                                                          text: toCurrency(
                                                              controller
                                                                  .args
                                                                  .value
                                                                  .jumlahPemotong))))
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          image: const DecorationImage(
                            image: AssetImage("assets/bg_header_slip_gaji.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          children: [
                            TextLabell(
                              text: "Gaji Bersih",
                              size: 14,
                              color: Constanst.colorWhite,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextLabell(
                              text: toCurrency(controller.args.value.amount),
                              size: 14,
                              weight: FontWeight.bold,
                              color: Constanst.colorWhite,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
      }),
    );
  }
}
