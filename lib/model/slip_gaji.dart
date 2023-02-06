import 'dart:convert';

import 'package:siscom_operasional/model/compent_slip_gaji.dart';

List<SlipGajiModel> componentSlipGajiModelFromJson(String str) =>
    List<SlipGajiModel>.from(
        json.decode(str).map((x) => SlipGajiModel.fromJson(x)));

String componentSlipGajiModelToJson(List<SlipGajiModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SlipGajiModel {
  SlipGajiModel(
      {this.id,
      this.name,
      this.amount,
      this.month,
      this.date,
      this.pemotong,
      this.pendapatan,
      this.jumlahPemotong,
      this.jumllahPendapatan,
      this.monthNumber,
      this.index});

  var id;
  var name;
  var amount;
  var month;
  var date;
  var index;
  var monthNumber;
  List<ComponentSlipGajiModel>? pendapatan;
  List<ComponentSlipGajiModel>? pemotong;
  var jumllahPendapatan;
  var jumlahPemotong;
  var hideAmout = "*********";

  factory SlipGajiModel.fromJson(Map<String, dynamic> json) => SlipGajiModel(
      id: json["id"],
      name: json['name'],
      amount: json['month'],
      index: json['index'] ?? 0,
      monthNumber: json['month_number'],
      jumlahPemotong: json['jumlah_pemotong'],
      jumllahPendapatan: json['jumlahpendapata'],
      pendapatan:
          ComponentSlipGajiModel.fromJsonToList(json['pendapatan'] ?? []),
      pemotong: ComponentSlipGajiModel.fromJsonToList(json['pemotong'] ?? []),
      date: json['date']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "amount": amount,
        "month": month,
        "date": date,
        "index": index
      };
  static List<SlipGajiModel> fromJsonToList(List data) {
    return List<SlipGajiModel>.from(data.map(
      (item) => SlipGajiModel.fromJson(item),
    ));
  }
}
