import 'dart:async';

import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/controller/dashboard_controller.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_textButton.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

class AbsenMasukKeluar extends StatefulWidget {
  var type, status;
  AbsenMasukKeluar({super.key, this.type, this.status});

  @override
  State<AbsenMasukKeluar> createState() => _AbsenMasukKeluarState();
}

class _AbsenMasukKeluarState extends State<AbsenMasukKeluar> {
  final controller = Get.put(AbsenController());
  final controllerDashboard = Get.put(DashboardController());

  Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> markers = new Set();
  Set<Circle> circles = Set();
  GoogleMapController? mapController;
  BitmapDescriptor? destinationIcon;

  bool isCollapse = false;

  int minExtent = 150;
  int maxExtend = 250;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      'assets/avatar_default.png',
    ).then((onValue) {
      destinationIcon = onValue;
    });
    setState(() {
      controller.getPlaceCoordinate();
      controller.titleAbsen.value = widget.status;
      controller.typeAbsen.value = widget.type;
      controller.absenSelfie();
    });
    // controller.getPosisition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        flexibleSpace: Container(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      controller.removeAll();
                      controllerDashboard.onInit();
                      Get.offAll(InitScreen());
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Constanst.colorText2,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Constanst.grey,
                        borderRadius: BorderRadius.circular(25)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Refresh",
                            style: TextStyle(color: Constanst.colorText4),
                          ),
                          Icon(Icons.refresh, color: Constanst.colorText4)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          controller.removeAll();
          controllerDashboard.onInit();
          Get.offAll(InitScreen());
          return true;
        },
        child: Obx(() {
          return controller.latUser.value == 0.0 ||
                  controller.langUser.value == 0.0 ||
                  controller.alamatUserFoto.value == ""
              ? SizedBox(
                  height: 50,
                  child: Center(
                    child: SizedBox(
                        child: CircularProgressIndicator(strokeWidth: 3),
                        width: 35,
                        height: 35),
                  ),
                )
              : screenAbsenMasuk();
        }),
      ),
    );
  }

  void getMarker() {
    markers.add(Marker(
        //add first marker
        markerId: MarkerId("1"),
        icon: destinationIcon!,
        // icon: BitmapDescriptor.defaultMarker,
        position: LatLng(
          double.parse(controller.latUser.toString()),
          double.parse(controller.langUser.toString()),
        )));

    circles.add(Circle(
      circleId: CircleId("1"),
      center: LatLng(
        double.parse(controller.latUser.toString()),
        double.parse(controller.langUser.toString()),
      ),
      radius: 10,
      strokeColor: Constanst.radiusColor.withOpacity(0.25),
      fillColor: Constanst.radiusColor.withOpacity(0.25),
      strokeWidth: 1,
    ));
  }

  Widget _backgroundWidget() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              // initialCameraPosition: _kGooglePlex,
              markers: markers,
              circles: circles,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      controller.latUser.value, controller.langUser.value),
                  zoom: 20.0),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  mapController = controller;
                });
              },
            ),
            Positioned(
              bottom: 10,
              child: Column(
                children: [],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _previewWidget() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  controller.getPosisition();
                  mapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: LatLng(controller.latUser.value,
                              controller.langUser.value),
                          zoom: 20)
                      //17 is new zoom level
                      ));
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Image.asset(
                        "assets/radar.png",
                        width: 25,
                        height: 25,
                      )),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                width: MediaQuery.of(Get.context!).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Iconsax.location_tick,
                              size: 24,
                              color: Constanst.colorPrimary,
                            )
                            // Image.asset(
                            //     "assets/ic_location.png"),
                            ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lokasi kamu saat ini",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width:
                                  MediaQuery.of(Get.context!).size.width * 0.7,
                              child: Text(
                                controller.alamatUserFoto.value
                                        .toString()
                                        .substring(0, 50) +
                                    '...',
                                style: TextStyle(
                                    fontSize: 12, color: Constanst.colorText2),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                isCollapse = false;
                              });
                            },
                            child: Center(
                              child: InkWell(
                                onTap: () {},
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      color: Constanst.grey,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(Get.context!).size.width,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Constanst.colorPrimary),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          side: BorderSide(
                                              color: Colors.white)))),
                              onPressed: () {
                                controllerDashboard
                                    .widgetButtomSheetAktifCamera(
                                        'checkTracking');
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                child: Text('OK, Absen sekarang'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget screenAbsenMasuk1() {
    getMarker();
    return DraggableBottomSheet(
      minExtent: 250,
      barrierDismissible: false,
      useSafeArea: true,
      barrierColor: Colors.transparent,
      curve: Curves.easeIn,
      previewWidget: _previewWidget(),
      expandedWidget: Expanded(child: _expandedWidget()),
      backgroundWidget: _backgroundWidget(),
      maxExtent: MediaQuery.of(context).size.height * 0.8,
      collapsed: false,
      onDragging: (pos) {
        if (pos > 400) {
          isCollapse = true;
          print("pos ${pos.toString()}");
        }
      },
    );
  }

  Widget screenAbsenMasuk() {
    getMarker();

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return DraggableBottomSheet(
        minExtent: 250,
        useSafeArea: true,
        barrierColor: Colors.transparent,
        curve: Curves.easeIn,
        previewWidget: _previewWidget(),
        expandedWidget: Expanded(child: _expandedWidget()),
        backgroundWidget: _backgroundWidget(),
        maxExtent: MediaQuery.of(context).size.height * 0.8,
        collapsed: true,
        onDragging: (pos) {},
      );
    });
  }

  Widget _expandedWidget() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: MediaQuery.of(Get.context!).size.width,
        height: double.maxFinite,
        child: Expanded(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        controller.getPosisition();
                        mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                                CameraPosition(
                                    target: LatLng(controller.latUser.value,
                                        controller.langUser.value),
                                    zoom: 20)
                                //17 is new zoom level
                                ));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Image.asset(
                              "assets/radar.png",
                              width: 25,
                              height: 25,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  width: MediaQuery.of(Get.context!).size.width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Iconsax.location_tick,
                                size: 24,
                                color: Constanst.colorPrimary,
                              )
                              // Image.asset(
                              //     "assets/ic_location.png"),
                              ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lokasi kamu saat ini",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(Get.context!).size.width *
                                    0.7,
                                child: Text(
                                  controller.alamatUserFoto.value
                                          .toString()
                                          .substring(0, 50) +
                                      '...',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Constanst.colorText2),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  width: MediaQuery.of(Get.context!).size.width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Obx(
                      () => Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 20, right: 20, top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isCollapse = true;
                                });
                              },
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isCollapse = true;
                                    });
                                  },
                                  child: Icon(Icons.keyboard_arrow_down,
                                      size: 30, color: Colors.grey),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                      alignment: Alignment.topCenter,
                                      child: Icon(
                                        Iconsax.clock,
                                        size: 24,
                                        color: Constanst.colorPrimary,
                                      )),
                                ),
                                Expanded(
                                  flex: 90,
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 8, top: 3),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                                controller.timeString.value,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Expanded(
                                              child: controller
                                                          .typeAbsen.value ==
                                                      1
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(
                                                            156, 223, 253, 223),
                                                        borderRadius: Constanst
                                                            .borderStyle1,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 8),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                right: 10),
                                                        child: Text(
                                                          controller
                                                              .titleAbsen.value,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: Constanst
                                                              .colorGreenBold,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(
                                                            156, 241, 171, 171),
                                                        borderRadius: Constanst
                                                            .borderStyle1,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 8),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                right: 10),
                                                        child: Text(
                                                          controller
                                                              .titleAbsen.value,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: Constanst
                                                              .colorRedBold,
                                                        ),
                                                      ),
                                                    ))
                                        ],
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                      alignment: Alignment.topCenter,
                                      child: Icon(
                                        Iconsax.calendar_2,
                                        size: 24,
                                        color: Constanst.colorPrimary,
                                      )
                                      // Image.asset(
                                      //     "assets/ic_calender.png"),
                                      ),
                                ),
                                Expanded(
                                  flex: 90,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8, top: 3),
                                    child: Text(controller.dateNow.value,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 20,
                                  child: Container(
                                      alignment: Alignment.topCenter,
                                      child: Icon(
                                        Iconsax.location_tick,
                                        size: 24,
                                        color: Constanst.colorPrimary,
                                      )
                                      // Image.asset(
                                      //     "assets/ic_location.png"),
                                      ),
                                ),
                                Expanded(
                                    flex: 90,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, top: 3),
                                      child: Text("Tipe lokasi",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )),
                                Expanded(
                                  flex: 90,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: Constanst.borderStyle2,
                                          border: Border.all(
                                              color: Constanst.colorText1)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 8,
                                            bottom: 8),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isDense: true,
                                            items: controller
                                                .placeCoordinateDropdown.value
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              );
                                            }).toList(),
                                            value:
                                                controller.selectedType.value,
                                            onChanged: (selectedValue) {
                                              controller.selectedType.value =
                                                  selectedValue!;
                                            },
                                            isExpanded: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 25,
                                  child: Container(
                                      alignment: Alignment.topCenter,
                                      child: Icon(
                                        Iconsax.note_1,
                                        size: 24,
                                        color: Constanst.colorPrimary,
                                      )
                                      // Image.asset("assets/ic_note.png"),
                                      ),
                                ),
                                Expanded(
                                  flex: 90,
                                  child: Text("Catatan",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(
                                  height: 90,
                                ),
                                Expanded(
                                  flex: 90,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: Constanst.borderStyle2,
                                        border: Border.all(
                                            width: 1.0,
                                            color: Color.fromARGB(
                                                255, 211, 205, 205))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: TextField(
                                        cursorColor: Colors.black,
                                        controller: controller.deskripsiAbsen,
                                        maxLines: null,
                                        decoration: new InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Tambahkan Catatan"),
                                        keyboardType: TextInputType.multiline,
                                        textInputAction: TextInputAction.done,
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            height: 2.0,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(Get.context!).size.width,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Constanst.colorPrimary),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: BorderSide(
                                                color: Colors.white)))),
                                onPressed: () {
                                  controllerDashboard
                                      .widgetButtomSheetAktifCamera(
                                          'checkTracking');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  child: Text('OK, Absen sekarang'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
