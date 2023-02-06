// To parse this JSON data, do
//
//     final bpjsKesehatanModel = bpjsKesehatanModelFromJson(jsonString);

import 'dart:convert';

List<BpjsKesehatanModel> bpjsKesehatanModelFromJson(String str) =>
    List<BpjsKesehatanModel>.from(
        json.decode(str).map((x) => BpjsKesehatanModel.fromJson(x)));

String bpjsKesehatanModelToJson(List<BpjsKesehatanModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BpjsKesehatanModel {
  BpjsKesehatanModel({
    this.emBpjsKesehatan,
    this.fullName,
    this.tk,
  });

  var emBpjsKesehatan;
  var fullName;
  var tk;

  factory BpjsKesehatanModel.fromJson(Map<String, dynamic> json) =>
      BpjsKesehatanModel(
        emBpjsKesehatan: json["em_bpjs_kesehatan"],
        fullName: json["full_name"],
        tk: json["TK"],
      );

  Map<String, dynamic> toJson() => {
        "em_bpjs_kesehatan": emBpjsKesehatan,
        "full_name": fullName,
        "TK": tk,
      };

      static List<BpjsKesehatanModel> fromJsonToList(List data) {
    return List<BpjsKesehatanModel>.from(data.map(
      (item) => BpjsKesehatanModel.fromJson(item),
    ));
  }
}
