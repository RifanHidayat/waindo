import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class Api {
  static var basicAuth = 'Basic ' +
      base64Encode(utf8
          .encode('aplikasioperasionalsiscom:siscom@ptshaninformasi#2022@'));

  static var basicUrl = "http://kantor.membersis.com:3000/";
  static var UrlfotoAbsen = basicUrl + "foto_absen/";
  static var UrlfotoProfile = basicUrl + "foto_profile/";
  static var UrlgambarDashboard = basicUrl + "gambar_dashboard/";
  static var UrlfileCuti = basicUrl + "file_cuti/";
  static var UrlfileKlaim = basicUrl + "file_klaim/";
  static var UrlfileTidakhadir = basicUrl + "file_tidak_masuk_ke rja/";
  static var urlGambarDariFinance = basicUrl + "gambar_banner/";
  static var urlFilePermintaanKandidat = basicUrl + "file_permintaan_kandidat/";
  static var urlFileKandidat = basicUrl + "file_kandidat/";
  static var urlFileRecog = basicUrl + "face_recog/";

  static Future connectionApi(
      String typeConnect, valFormData, String url) async {
    var getUrl = basicUrl + url;
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    if (typeConnect == "post") {
      try {
        final url = Uri.parse(getUrl);
        final response =
            await post(url, body: jsonEncode(valFormData), headers: headers);
        return response;
      } on SocketException catch (e) {
        return false;
      }
    } else {
      try {
        final url = Uri.parse(getUrl);
        final response = await get(url, headers: headers);
        return response;
      } on SocketException catch (e) {
        return false;
      }
    }
  }

  static Future connectionApiUploadFile(String url, File newFile) async {
    var getUrl = basicUrl + url;
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      final url = Uri.parse(getUrl);
      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath('sampleFile', newFile.path),
      );
      request.headers.addAll(headers);
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      return respStr;
    } on SocketException catch (e) {
      return false;
    }
  }
}
