import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:siscom_operasional/controller/tab_controller.dart';
import 'package:siscom_operasional/screen/aktifitas/aktifitas.dart';
import 'package:siscom_operasional/screen/akun/setting.dart';
import 'package:siscom_operasional/screen/dashboard.dart';
import 'package:siscom_operasional/screen/kontrol/kontrol_list.dart';
import 'package:siscom_operasional/screen/pesan/pesan.dart';
import 'package:siscom_operasional/utils/constans.dart';

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  final controller = Get.put(TabbController());

  List<Widget> _buildScreens() {
    return [
      Dashboard(),
      KontrolList(),
      Aktifitas(),
      Pesan(
        status: false,
      ),
      Setting(),
    ];
  }

  List<Widget> _buildScreens1() {
    return [
      Dashboard(),
      Aktifitas(),
      Pesan(
        status: false,
      ),
      Setting(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/beranda_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/beranda.png")),
        title: "Beranda",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/kontrol_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/kontrol.png")),
        title: "Kontrol",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/aktifitas_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/aktifitas.png")),
        title: "Aktivitas",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/pesan_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/pesan.png")),
        title: "Pesan",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/akun_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/akun.png")),
        title: "Akun",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems1() {
    return [
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/beranda_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/beranda.png")),
        title: "Beranda",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/aktifitas_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/aktifitas.png")),
        title: "Aktivitas",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/pesan_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/pesan.png")),
        title: "Pesan",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
      PersistentBottomNavBarItem(
        icon: ImageIcon(AssetImage("assets/akun_fill.png")),
        inactiveIcon: ImageIcon(AssetImage("assets/akun.png")),
        title: "Akun",
        activeColorPrimary: Constanst.colorButton1,
        inactiveColorPrimary: Constanst.color1,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PersistentTabView(
        context,
        controller: controller.tabPersistantController.value,
        screens: controller.kontrolAkses.value == true
            ? _buildScreens()
            : _buildScreens1(),
        items: controller.kontrolAkses.value == true
            ? _navBarsItems()
            : _navBarsItems1(),
        confineInSafeArea: true,
        onWillPop: (s) async => await controller.onWillPop(),
        onItemSelected: (s) => controller.onClickItem(s),
        backgroundColor: Colors.white, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: const NavBarDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
                color: Color(0xffE9F5FE), blurRadius: 0.5, spreadRadius: 0.1)
          ],
          colorBehindNavBar: Colors.red,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: const ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 100),
        ),
        navBarStyle:
            NavBarStyle.style9, // Choose the nav bar style with this property.
      ),
    );
  }
}
