// To parse this JSON data, do
//
//     final bpjsKetenagakerjaanModel = bpjsKetenagakerjaanModelFromJson(jsonString);

import 'dart:convert';

List<BpjsKetenagakerjaanModel> bpjsKetenagakerjaanModelFromJson(String str) =>
    List<BpjsKetenagakerjaanModel>.from(
        json.decode(str).map((x) => BpjsKetenagakerjaanModel.fromJson(x)));

String bpjsKetenagakerjaanModelToJson(List<BpjsKetenagakerjaanModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BpjsKetenagakerjaanModel {
  BpjsKetenagakerjaanModel({
    this.emBpjsTenagakerja,
    this.fullName,
    this.jkk,
    this.jkm,
    this.jhtTk,
    this.jpTk,
  });

  var emBpjsTenagakerja;
  var fullName;
  var jkk;
  var jkm;
  var jhtTk;
  var jpTk;

  factory BpjsKetenagakerjaanModel.fromJson(Map<String, dynamic> json) =>
      BpjsKetenagakerjaanModel(
        emBpjsTenagakerja: json["em_bpjs_tenagakerja"],
        fullName: json["full_name"],
        jkk: json["JKK"],
        jkm: json["JKM"],
        jhtTk: json["JHT_TK"],
        jpTk: json["JP_TK"],
      );

  Map<String, dynamic> toJson() => {
        "em_bpjs_tenagakerja": emBpjsTenagakerja,
        "full_name": fullName,
        "JKK": jkk,
        "JKM": jkm,
        "JHT_TK": jhtTk,
        "JP_TK": jpTk,
      };

  static List<BpjsKetenagakerjaanModel> fromJsonToList(List data) {
    return List<BpjsKetenagakerjaanModel>.from(data.map(
      (item) => BpjsKetenagakerjaanModel.fromJson(item),
    ));
  }
}
