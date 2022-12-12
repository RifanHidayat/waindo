import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class Constanst {
  static double defaultMarginPadding = 16.0;
  static double sizeTitle = 16.0;
  static double sizeText = 14.0;
  // static Color coloBackgroundScreen = Color(0xffF8FAFF);
  static Color coloBackgroundScreen = Colors.white;
  static Color colorWhite = Colors.white;
  static Color colorBlack = Colors.black;
  static Color radiusColor = HexColor('#3d889c');
  static Color colorBGApprove = Color(0xffE6FCE6);
  static Color colorBGRejected = Color(0xffFFF2EB);
  static Color colorBGPending = Color(0xffFEF9E6);
  static Color colorText1 = Color(0xff687182);
  static Color colorText2 = Color(0xff868FA0);
  static Color colorText3 = Color(0xff333B4A);
  static Color colorText4 = HexColor('#333B4A');

  static Color colorNonAktif = Color(0xffD5DBE5);
  static Color colorButton1 = Color(0xff001767);
  static Color colorButton2 = Color(0xffE9F5FE);
  static Color colorButton3 = Color(0xffE1E9FA);

  static Color colorPrimary = Color(0xff001767);
  static Color color1 = Color(0xffBCC2CE);
  static Color color2 = Color(0xff11151E);
  static Color color3 = Color(0xffF2AA0D);
  static Color color4 = Color(0xffFF463D);
  static Color color5 = Color(0xff14B156);
  static Color infoLight = HexColor('#2F80ED');
  static Color infoLight1 = HexColor('#E9F5FE');
  static Color grey = HexColor('#E9EDF5');

  static Color color6 = Color.fromARGB(88, 230, 230, 230);

  static BorderRadius borderStyle1 = BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
      bottomLeft: Radius.circular(15),
      bottomRight: Radius.circular(15));

  static BorderRadius borderStyle2 = BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(10));

  static BorderRadius borderStyle3 = BorderRadius.only(
      topLeft: Radius.circular(25),
      topRight: Radius.circular(25),
      bottomLeft: Radius.circular(25),
      bottomRight: Radius.circular(25));

  static BorderRadius borderStyle4 = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20));

  static BorderRadius borderStyle5 = BorderRadius.only(
      topLeft: Radius.circular(6),
      topRight: Radius.circular(6),
      bottomLeft: Radius.circular(6),
      bottomRight: Radius.circular(6));

  static TextStyle style1 =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold);
  static TextStyle boldType1 =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  static TextStyle boldType2 =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
  static TextStyle colorGreenBold =
      TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12);
  static TextStyle colorRedBold =
      TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12);

  static BoxDecoration styleBoxDecoration1 = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6)),
      border: Border.all(color: Color(0xffD5DBE5)));
  static BoxDecoration styleBoxDecoration2(color) {
    return BoxDecoration(
      color: color!,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10)),
    );
  }

  static String convertDate(String date) {
    DateTime convert = DateTime.parse(date);
    var hari = DateFormat('EEEE');
    var tanggal = DateFormat('dd-MM-yyyy');
    var convertHari = hari.format(convert);
    var hasilConvertHari = hariIndo(convertHari);
    var valid2 = tanggal.format(convert);
    var validFinal = "$hasilConvertHari, $valid2";
    return validFinal;
  }

  static String convertDate1(String date) {
    var inputFormat = DateFormat('yyyy-MM-dd');
    var inputDate = inputFormat.parse(date);
    var outputFormat = DateFormat('dd-MM-yyyy');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static String convertDate2(String date) {
    var inputFormat = DateFormat('yyyy-MM-dd');
    var inputDate = inputFormat.parse(date);
    var outputFormat = DateFormat('EEEE, dd-MM-yyyy');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static String convertDate3(String date) {
    DateTime convert = DateTime.parse(date);
    var tanggal = DateFormat('dd MMM');
    var valid2 = tanggal.format(convert);
    return valid2;
  }

  static String convertDate4(String date) {
    var inputFormat = DateFormat('yyyy-MM-dd');
    var inputDate = inputFormat.parse(date);
    var outputFormat = DateFormat('dd MMM');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static String convertDateSimpan(String date) {
    var inputFormat = DateFormat('dd-MM-yyyy');
    var inputDate = inputFormat.parse(date);
    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static String convertDateBulanDanTahun(String date) {
    var inputFormat = DateFormat('MM-yyyy');
    var inputDate = inputFormat.parse(date);
    var outputFormat = DateFormat('MMMM yyyy');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static String convertDateBulanDanHari(String date) {
    var inputFormat = DateFormat('MM-dd');
    var inputDate = inputFormat.parse(date);
    var outputFormat = DateFormat('dd MMMM');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static String convertOnlyDate(String date) {
    var inputFormat = DateFormat('dd-MM-yyyy');
    var inputDate = inputFormat.parse(date);
    var outputFormat = DateFormat('dd');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static String convertGetMonth(String date) {
    DateTime convert = DateTime.parse(date);
    var outputDate = DateFormat('MM');
    return outputDate.format(convert);
  }

  static String hariIndo(String hari) {
    if (hari == "Monday") {
      hari = "Senin";
    } else if (hari == "Tuesday") {
      hari = "Selasa";
    } else if (hari == "Wednesday") {
      hari = "Rabu";
    } else if (hari == "Thursday") {
      hari = "Kamis";
    } else if (hari == "Friday") {
      hari = "Jumat";
    } else if (hari == "Saturday") {
      hari = "Sabtu";
    } else if (hari == "Sunday") {
      hari = "Minggu";
    } else {
      hari = hari;
    }
    return hari;
  }

  // boxShadow: [
  //   BoxShadow(
  //     color: Color.fromARGB(255, 199, 199, 199).withOpacity(0.5),
  //     spreadRadius: 2,
  //     blurRadius: 1,
  //     offset: Offset(1, 1), // changes position of shadow
  //   ),
  // ],

}
