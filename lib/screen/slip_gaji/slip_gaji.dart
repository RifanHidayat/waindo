import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/slip_gaji.controller.dart';
import 'package:siscom_operasional/screen/slip_gaji/detail.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/helper.dart';
import 'package:siscom_operasional/utils/widget/appbar.dart';
import 'package:siscom_operasional/utils/widget/text_labe.dart';
import 'package:intl/intl.dart';
import 'package:siscom_operasional/utils/year_picker.dart';

class SlipGaji extends StatelessWidget {
  SlipGaji({super.key});
  var controller = Get.put(SlipGajiController());

  @override
  Widget build(BuildContext context) {
    controller.fetchSlipGaji();
    controller.fetchSlipGajiCurrent();
    var startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    var endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    return Scaffold(
      appBar: AppBarApp(
        text: "Sllip gaji",
        elevation: 0.0,
        textSize: 16.0,
        textColor: Constanst.colorWhite,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //heeader
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/bg_header_slip_gaji.png"),
                  fit: BoxFit.cover,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextLabell(
                    text: "Gaji bulan ini",
                    color: Constanst.colorPrimaryLight,
                    size: 16,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Obx(() {
                        return controller.isLoading.value == true
                            ? TextLabell(text: "")
                            : controller.isHide.value == false
                                ? TextLabell(
                                    text: controller.slipGajiCurrent.isNotEmpty
                                        ? toCurrency(controller.slipGajiCurrent
                                                .where((p0) =>
                                                    int.parse(p0.index.toString().replaceAll("value", "")).toString() ==
                                                    DateTime.now()
                                                        .month
                                                        .toString())
                                                .isNotEmpty
                                            ? toCurrency(controller
                                                .slipGajiCurrent
                                                .where((p0) =>
                                                    int.parse(p0.index.toString().replaceAll("value", ""))
                                                        .toString() ==
                                                    DateTime.now()
                                                        .month
                                                        .toString())
                                                .first
                                                .amount
                                                .toString())
                                            : "0")
                                        : "0",
                                    color: Constanst.colorWhite,
                                    size: 12,
                                    weight: FontWeight.w600)
                                : TextLabell(
                                    text: controller.hideAmount.value,
                                    color: Constanst.colorWhite,
                                    size: 12);
                      }),
                      const SizedBox(
                        width: 14,
                      ),
                      Obx(() {
                        return controller.isHide.value == true
                            ? InkWell(
                                onTap: () {
                                  controller.isHide.value = false;
                                },
                                child: Icon(
                                  Iconsax.eye_slash,
                                  color: Constanst.colorWhite,
                                  size: 12,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  controller.isHide.value = true;
                                },
                                child: Icon(
                                  Icons.visibility_outlined,
                                  color: Constanst.colorWhite,
                                  size: 12,
                                ),
                              );
                      })
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextLabell(
                    text:
                        "${DateFormat.yMMMEd().format(startDate)},-${DateFormat.yMMMEd().format(endDate)}",
                    color: Constanst.colorPrimaryLight,
                    size: 12,
                  ),
                ],
              ),
            ),
            //body
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                height: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 50,
                            child: TextLabell(
                              text: "Riwayat Slip Gaji",
                              size: 16,
                              weight: FontWeight.w700,
                              color: Constanst.colorText3,
                            ),
                          ),
                          Expanded(
                              flex: 30,
                              child: InkWell(
                                onTap: () {
                                  DatePicker.showPicker(
                                    Get.context!,
                                    pickerModel: CustomYearchPicker(
                                      minTime: DateTime(2020, 1, 1),
                                      maxTime: DateTime(2050, 1, 1),
                                      currentTime:
                                          DateTime(controller.tahun.value),
                                    ),
                                    onConfirm: (time) {
                                      if (time != null) {
                                        print("$time");
                                        var filter =
                                            DateFormat('yyyy-MM').format(time);
                                        var array = filter.split('-');
                                        var bulan = array[1];
                                        var tahun = array[0];
                                        print(tahun);
                                        controller.tahun.value =
                                            int.parse(tahun);
                                        controller.fetchSlipGaji();
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
                                                controller.tahun.value
                                                    .toString(),
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            }),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                          height: double.maxFinite,
                          child: Obx(() {
                            return controller.isLoading.value == true
                                ? Container(
                                    child: Center(
                                      child: Container(
                                          width: 50,
                                          height: 50,
                                          child:
                                              const CircularProgressIndicator()),
                                    ),
                                  )
                                : controller.slipGaji.isNotEmpty
                                    ? SingleChildScrollView(
                                        child: Column(
                                            children: List.generate(
                                                controller.slipGaji.length,
                                                (index) => _list(index))),
                                      )
                                    : Container(
                                        child: Center(
                                          child: Container(
                                              child: const TextLabell(
                                            text: "Data tidak ditemukan",
                                            size: 16,
                                          )),
                                        ),
                                      );
                          })),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _list(index) {
    var data = controller.slipGaji[index];

    var date = DateTime(controller.tahun.value,
        int.parse(data.index.toString().replaceAll("value", "")) + 1, 0);
    print(date);

    return InkWell(
      onTap: () {
        controller.bulan.value = data.month;
        controller.args.value = data;
        Get.to(SlipGajiDetail());
      },
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 5,
          left: 20,
          right: 20,
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            //set border r,adius more than 50% of height and width to make circle
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: CircleAvatar(
                    backgroundColor: Constanst.grey,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Iconsax.receipt_item,
                        color: Constanst.colorBlack,
                      ),
                    ),
                  ),
                ),
                // const SizedBox(
                //   width: 10,
                // ),
                Expanded(
                  flex: 50,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextLabell(
                            text: data.month,
                            weight: FontWeight.bold,
                            size: 12,
                          ),
                          TextLabell(
                            text:
                                "01 ${data.month.toString().substring(0, 3)} ${controller.tahun} - ${date.day}  ${data.month.toString().substring(0, 3)} ${controller.tahun}",
                            size: 09,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 30,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 20,
                            child: TextLabell(
                              text: controller.isHide.value == false
                                  ? toCurrency(data.amount.toString())
                                  : controller.hideAmount.value,
                              size: 11,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const Expanded(
                            flex: 5,
                            child: Padding(
                              padding: EdgeInsets.only(left: 3),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
