import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/controller/pesan_controller.dart';
import 'package:siscom_operasional/controller/tab_controller.dart';
import 'package:siscom_operasional/screen/absen/absen_masuk_keluar.dart';
import 'package:siscom_operasional/screen/akun/personal_info.dart';
import 'package:siscom_operasional/screen/informasi.dart';
import 'package:siscom_operasional/screen/pesan/pesan.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final controller = Get.put(DashboardController());
  final controllerAbsensi = Get.put(AbsenController());
  final controllerPesan = Get.put(PesanController());

  Future<void> refreshData() async {
    controller.refreshPagesStatus.value = true;
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      controller.updateInformasiUser();
      controller.onInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constanst.coloBackgroundScreen,
      body: Stack(
        children: [
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/bg_dashboard.png'),
                    fit: BoxFit.cover)),
          ),
          Obx(
            () => Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "PT. Shan Informasi Sistem",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  controller.refreshPagesStatus.value
                      ? UtilsAlert.shimmerInfoPersonal(Get.context!)
                      : Obx(() => informasiUser()),
                  SizedBox(
                    height: 20,
                  ),
                  cardInfoAbsen(),
                  SizedBox(
                    height: 20,
                  ),
                  Flexible(
                      flex: 3,
                      child: RefreshIndicator(
                        onRefresh: refreshData,
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              controller.menuShowInMain.value.isEmpty
                                  ? SizedBox()
                                  : listModul(),
                              SizedBox(
                                height: 15,
                              ),
                              controller.menuShowInMain.value.isEmpty
                                  ? UtilsAlert.shimmerMenuDashboard(
                                      Get.context!)
                                  : MenuDashboard(),
                              cardFormPengajuan(),
                              SizedBox(
                                height: 8,
                              ),
                              controller.bannerDashboard.value.isEmpty
                                  ? SizedBox()
                                  : sliderBanner(),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 70,
                                      child: Text(
                                        "Informasi",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Constanst.colorText3),
                                      )),
                                  Expanded(
                                      flex: 30,
                                      child: InkWell(
                                        onTap: () => Get.offAll(Informasi()),
                                        child: Text(
                                          "Lihat semua",
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Constanst.colorPrimary),
                                        ),
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              listInformasi(),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                      ))

                  // Padding(
                  //   padding: const EdgeInsets.only(left: 5, right: 5),
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Expanded(
                  //         child: Text(
                  //           "Menu",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 14),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: Text(
                  //           "Lihat semua",
                  //           textAlign: TextAlign.right,
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold,
                  //               color: Constanst.colorPrimary,
                  //               fontSize: 10),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget informasiUser() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 85,
            child: InkWell(
              onTap: () => Get.to(PersonalInfo()),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  controller.user.value[0]['em_image'] == ""
                      ? Image.asset(
                          'assets/avatar_default.png',
                          width: 40,
                          height: 40,
                        )
                      : CircleAvatar(
                          radius: 25, // Image radius
                          child: ClipOval(
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: Api.UrlfotoProfile +
                                    "${controller.user.value[0]['em_image']}",
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        Container(
                                  alignment: Alignment.center,
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  width: MediaQuery.of(context).size.width,
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress),
                                ),
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            "${controller.user.value[0]['full_name'] ?? ""}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${controller.user.value[0]['emp_jobTitle'] ?? ""} - ${controller.user.value[0]['posisi'] ?? ""}",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
              flex: 15,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      var pesanCtrl = Get.find<PesanController>();
                      pesanCtrl.routesIcon();
                      pushNewScreen(
                        Get.context!,
                        screen: Pesan(
                          status: true,
                        ),
                        withNavBar: false,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: Icon(
                          Iconsax.notification,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  controllerPesan.jumlahNotifikasiBelumDibaca.value == 0
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 24, left: 16),
                          child: Center(
                              child: AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText(
                                // "${controllerPesan.jumlahNotifikasiBelumDibaca.value}",
                                "🔴",
                                textStyle: const TextStyle(
                                  fontSize: 10.0,
                                  // color: Color.fromARGB(255, 255, 174, 0),
                                  fontWeight: FontWeight.bold,
                                ),
                                duration: const Duration(milliseconds: 2000),
                              ),
                            ],
                            totalRepeatCount: 500,
                            pause: const Duration(milliseconds: 100),
                            displayFullTextOnTap: true,
                            stopPauseOnTap: true,
                          )),
                        )
                ],
              )),
        ],
      ),
    );
  }

  Widget cardInfoAbsen() {
    return Container(
      width: MediaQuery.of(Get.context!).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Constanst.borderStyle1,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 155, 155, 155).withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(1, 1), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                      // onTap: () => controller.getMenuTest(),
                      child: Text(
                    "Live Attendance",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Constanst.color2),
                  )),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => UtilsAlert.informasiDashboard(Get.context!),
                      child: Icon(
                        Iconsax.info_circle,
                        size: 20,
                        color: Constanst.colorPrimary,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              height: 5,
              color: Colors.grey,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.timeString.value,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Constanst.color2),
                      ),
                      Text(
                        controller.dateNow.value,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Constanst.color2),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Absensi harian",
                        style: TextStyle(
                            fontSize: 12, color: Constanst.colorText2),
                      ),
                      Text(
                        "08:30 - 18:00",
                        style: TextStyle(
                            fontSize: 12, color: Constanst.colorText2),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(
                        right: 8,
                      ),
                      child: TextButtonWidget2(
                          title: "Absen Masuk",
                          onTap: () {
                            if (controllerAbsensi.absenStatus.value == true) {
                              UtilsAlert.showToast(
                                  "Anda harus absen keluar terlebih dahulu");
                            } else {
                              var statusCamera = Permission.camera.status;
                              statusCamera.then((value) {
                                var statusLokasi = Permission.location.status;
                                statusLokasi.then((value2) {
                                  if (value != PermissionStatus.granted ||
                                      value2 != PermissionStatus.granted) {
                                    UtilsAlert.showToast(
                                        "Anda harus aktifkan kamera dan lokasi anda");
                                    controller.widgetButtomSheetAktifCamera();
                                  } else {
                                    controllerAbsensi.getPlaceCoordinate();
                                    controllerAbsensi.titleAbsen.value =
                                        "Absen Masuk";
                                    controllerAbsensi.typeAbsen.value = 1;
                                    Get.offAll(AbsenMasukKeluar());
                                    controllerAbsensi.absenSelfie();
                                    // var validasiAbsenMasukUser =
                                    //     controller.validasiAbsenMasukUser();
                                    // if (!validasiAbsenMasukUser) {

                                    // } else {
                                    //   var kalkulasiRadius =
                                    //       controller.radiusNotOpen();
                                    //   kalkulasiRadius.then((value) {
                                    //     print(value);
                                    //     if (value) {
                                    //       controllerAbsensi.titleAbsen.value =
                                    //           "Absen Masuk";
                                    //       controllerAbsensi.typeAbsen.value = 1;
                                    //       Get.offAll(AbsenMasukKeluar());
                                    //       controllerAbsensi.absenSelfie();
                                    //     }
                                    //   });
                                    // }
                                  }
                                });
                              });
                            }
                          },
                          colorButton: !controllerAbsensi.absenStatus.value
                              ? Constanst.colorPrimary
                              : Constanst.colorNonAktif,
                          colortext: !controllerAbsensi.absenStatus.value
                              ? Constanst.colorWhite
                              : Color.fromARGB(168, 166, 167, 158),
                          border: BorderRadius.circular(5.0),
                          icon: Icon(
                            Iconsax.login,
                            size: 18,
                            color: !controllerAbsensi.absenStatus.value
                                ? Constanst.colorWhite
                                : Color.fromARGB(168, 166, 167, 158),
                          ))),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: TextButtonWidget2(
                          title: "Absen Keluar",
                          onTap: () {
                            if (!controllerAbsensi.absenStatus.value) {
                              UtilsAlert.showToast(
                                  "Absen Masuk terlebih dahulu");
                            } else {
                              controllerAbsensi.getPlaceCoordinate();
                              controllerAbsensi.titleAbsen.value =
                                  "Absen Keluar";
                              controllerAbsensi.typeAbsen.value = 2;
                              Get.offAll(AbsenMasukKeluar());
                              controllerAbsensi.absenSelfie();
                              // var validasiAbsenMasukUser =
                              //     controller.validasiAbsenMasukUser();
                              // print(validasiAbsenMasukUser);
                              // if (validasiAbsenMasukUser == false) {

                              // } else {
                              //   var kalkulasiRadius =
                              //       controller.radiusNotOpen();
                              //   kalkulasiRadius.then((value) {
                              //     if (value) {
                              //       controllerAbsensi.titleAbsen.value =
                              //           "Absen Keluar";
                              //       controllerAbsensi.typeAbsen.value = 2;
                              //       Get.offAll(AbsenMasukKeluar());
                              //       controllerAbsensi.absenSelfie();
                              //     }
                              //   });
                              // }
                            }
                          },
                          colorButton: controllerAbsensi.absenStatus.value
                              ? Constanst.colorPrimary
                              : Constanst.colorNonAktif,
                          colortext: controllerAbsensi.absenStatus.value
                              ? Constanst.colorWhite
                              : Color.fromARGB(168, 166, 167, 158),
                          border: BorderRadius.circular(5.0),
                          icon: Icon(
                            Iconsax.logout,
                            size: 18,
                            color: controllerAbsensi.absenStatus.value
                                ? Constanst.colorWhite
                                : Color.fromARGB(168, 166, 167, 158),
                          ))),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget cardFormPengajuan() {
    return Container(
      decoration: BoxDecoration(
          color: Constanst.colorButton2, borderRadius: Constanst.borderStyle2),
      child: InkWell(
        onTap: () => controller.widgetButtomSheetFormPengajuan(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Iconsax.document_text_15,
                            color: Constanst.colorPrimary,
                            size: 26,
                          )
                          // Image.asset("assets/document_dash.png"),
                          ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Buat Pengajuan",
                          style: TextStyle(
                              color: Constanst.colorText3,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Constanst.colorText2,
                        size: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget sliderBanner() {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CarouselSlider.builder(
              carouselController: controller.corouselDashboard,
              options: CarouselOptions(
                onPageChanged: (index, reason) {
                  controller.indexBanner.value = index;
                },
                autoPlay: true,
                height: controller.heightbanner.value,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                initialPage: 1,
              ),
              itemCount: controller.bannerDashboard.value.length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                return Obx(
                  () => SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: Constanst.borderStyle2,
                        ),
                        child: Image.network(
                          Api.UrlgambarDashboard +
                              controller.bannerDashboard.value[itemIndex]
                                  ['gambar'],
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return UtilsAlert.shimmerBannerDashboard(
                                Get.context!);
                          },
                        ),
                      )),
                );
              }),
          DotsIndicator(
            dotsCount: controller.bannerDashboard.value.length,
            position: double.parse("${controller.indexBanner.value}"),
            decorator: DotsDecorator(
              size: const Size.square(9.0),
              activeColor: Constanst.colorPrimary,
              activeSize: const Size(30.0, 9.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
            ),
          )
        ],
      ),
    );
  }

  Widget listModul() {
    return SizedBox(
      height: 30,
      child: ListView.builder(
          itemCount: controller.menuShowInMain.value.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => controller.changePageModul(
                  controller.menuShowInMain.value[index]['index']),
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                margin: EdgeInsets.only(left: 8, right: 8),
                decoration: BoxDecoration(
                  color:
                      controller.menuShowInMain.value[index]['status'] == false
                          ? Colors.transparent
                          : Constanst.colorButton2,
                  borderRadius: Constanst.borderStyle3,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Text(
                      controller.menuShowInMain.value[index]['nama_modul'],
                      style: TextStyle(
                          fontSize: 12,
                          color: controller.menuShowInMain.value[index]
                                      ['status'] ==
                                  false
                              ? Constanst.colorText1
                              : Constanst.colorPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget MenuDashboard() {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width,
      height: controller.heightPageView.value,
      child: PageView.builder(
          controller: controller.menuController,
          onPageChanged: (index) {
            controller.changePageModul(index);
          },
          itemCount: controller.menuShowInMain.value.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: GridView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  itemCount:
                      controller.menuShowInMain.value[index]['menu'].length,
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height /
                            controller.ratioDevice.value),
                  ),
                  itemBuilder: (context, idxMenu) {
                    var gambar = controller.menuShowInMain[index]['menu']
                        [idxMenu]['gambar'];
                    var namaMenu = controller.menuShowInMain[index]['menu']
                        [idxMenu]['nama'];
                    return InkWell(
                      onTap: () => controller.routePageDashboard(controller
                          .menuShowInMain[index]['menu'][idxMenu]['url']),
                      highlightColor: Colors.white,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            gambar != ""
                                ? Container(
                                    decoration: BoxDecoration(
                                        color: Constanst.colorButton2,
                                        borderRadius: Constanst
                                            .styleBoxDecoration1.borderRadius),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 3, right: 3, top: 3, bottom: 3),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            Api.UrlgambarDashboard + gambar,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                Container(
                                          alignment: Alignment.center,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                        ),
                                        fit: BoxFit.cover,
                                        width: 32,
                                        height: 32,
                                        color: Constanst.colorButton1,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Constanst.colorButton2,
                                    height: 32,
                                    width: 32,
                                  ),
                            SizedBox(
                              height: 3,
                            ),
                            Center(
                              child: Text(
                                namaMenu.length > 20
                                    ? namaMenu.substring(0, 20) + '...'
                                    : namaMenu,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 10, color: Constanst.colorText3),
                              ),
                            ),
                          ]),
                    );
                  }),

              // Column(
              //   children: [

              //     SizedBox(height: 5,),
              //     Divider(height: 5, color: Constanst.colorNonAktif,),
              //     SizedBox(height: 20,
              //       child: Center(child: Text("Menu Lainnya", style: TextStyle(fontSize: 12),),),
              //     )
              //   ],
              // )
            );
          }),
    );
  }

  Widget listInformasi() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: controller.informasiDashboard.value.length > 4
            ? 4
            : controller.informasiDashboard.value.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 70,
                      child: Text(
                        controller.informasiDashboard.value[index]['title'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Constanst.colorText3),
                      ),
                    ),
                    Expanded(
                      flex: 30,
                      child: Text(
                        Constanst.convertDate3(
                            controller.informasiDashboard.value[index]['date']),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Constanst.colorText2),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  controller.informasiDashboard.value[index]['desc'],
                  style: TextStyle(color: Constanst.colorText2),
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(
                  height: 5,
                  color: Constanst.colorNonAktif,
                ),
                SizedBox(
                  height: 8,
                )
              ],
            ),
          );
        });
  }
}
