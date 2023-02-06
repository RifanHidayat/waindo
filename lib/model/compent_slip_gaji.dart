// To parse this JSON data, do
//
//     final componentSlipGajiModel = componentSlipGajiModelFromJson(jsonString);

import 'dart:convert';

List<ComponentSlipGajiModel> componentSlipGajiModelFromJson(String str) =>
    List<ComponentSlipGajiModel>.from(
        json.decode(str).map((x) => ComponentSlipGajiModel.fromJson(x)));

String componentSlipGajiModelToJson(List<ComponentSlipGajiModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ComponentSlipGajiModel {
  ComponentSlipGajiModel({
    this.id,
    this.emId,
    this.code,
    this.tdis,
    this.seq,
    this.name,
    this.type,
    this.payroll,
    this.overtime,
    this.initial,
    this.awal,
    this.value01,
    this.value02,
    this.value03,
    this.value04,
    this.value05,
    this.value06,
    this.value07,
    this.value08,
    this.value09,
    this.value10,
    this.value11,
    this.value12,
    this.fiscal01,
    this.fiscal02,
    this.fiscal03,
    this.fiscal04,
    this.fiscal05,
    this.fiscal06,
    this.fiscal07,
    this.fiscal08,
    this.fiscal09,
    this.fiscal10,
    this.fiscal11,
    this.fiscal12,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  var id;
  var emId;
  var code;
  var tdis;
  var seq;
  var name;
  var type;
  var payroll;
  var overtime;
  var initial;
  var awal;
  var value01;
  var value02;
  var value03;
  var value04;
  var value05;
  var value06;
  var value07;
  var value08;
  var value09;
  var value10;
  var value11;
  var value12;
  var fiscal01;
  var fiscal02;
  var fiscal03;
  var fiscal04;
  var fiscal05;
  var fiscal06;
  var fiscal07;
  var fiscal08;
  var fiscal09;
  var fiscal10;
  var fiscal11;
  var fiscal12;
  var createdBy;
  var createdOn;
  var modifiedBy;
  var modifiedOn;

  factory ComponentSlipGajiModel.fromJson(Map<String, dynamic> json) =>
      ComponentSlipGajiModel(
        id: json["id"],
        emId: json["em_id"],
        code: json["code"],
        tdis: json["tdis"],
        seq: json["seq"],
        name: json["name"],
        type: json["type"],
        payroll: json["payroll"],
        overtime: json["overtime"],
        initial: json["initial"],
        awal: json["awal"],
        value01: json["value01"],
        value02: json["value02"],
        value03: json["value03"],
        value04: json["value04"],
        value05: json["value05"],
        value06: json["value06"],
        value07: json["value07"],
        value08: json["value08"],
        value09: json["value09"],
        value10: json["value10"],
        value11: json["value11"],
        value12: json["value12"],
        fiscal01: json["fiscal01"],
        fiscal02: json["fiscal02"],
        fiscal03: json["fiscal03"],
        fiscal04: json["fiscal04"],
        fiscal05: json["fiscal05"],
        fiscal06: json["fiscal06"],
        fiscal07: json["fiscal07"],
        fiscal08: json["fiscal08"],
        fiscal09: json["fiscal09"],
        fiscal10: json["fiscal10"],
        fiscal11: json["fiscal11"],
        fiscal12: json["fiscal12"],
        createdBy: json["created_by"],
        createdOn: DateTime.parse(json["created_on"]),
        modifiedBy: json["modified_by"],
        modifiedOn: json["modified_on"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "em_id": emId,
        "code": code,
        "tdis": tdis,
        "seq": seq,
        "name": name,
        "type": type,
        "payroll": payroll,
        "overtime": overtime,
        "initial": initial,
        "awal": awal,
        "value01": value01,
        "value02": value02,
        "value03": value03,
        "value04": value04,
        "value05": value05,
        "value06": value06,
        "value07": value07,
        "value08": value08,
        "value09": value09,
        "value10": value10,
        "value11": value11,
        "value12": value12,
        "fiscal01": fiscal01,
        "fiscal02": fiscal02,
        "fiscal03": fiscal03,
        "fiscal04": fiscal04,
        "fiscal05": fiscal05,
        "fiscal06": fiscal06,
        "fiscal07": fiscal07,
        "fiscal08": fiscal08,
        "fiscal09": fiscal09,
        "fiscal10": fiscal10,
        "fiscal11": fiscal11,
        "fiscal12": fiscal12,
        "created_by": createdBy,
        "created_on": createdOn.toIso8601String(),
        "modified_by": modifiedBy,
        "modified_on": modifiedOn,
      };
  static List<ComponentSlipGajiModel> fromJsonToList(List data) {
    return List<ComponentSlipGajiModel>.from(data.map(
      (item) => ComponentSlipGajiModel.fromJson(item),
    ));
  }
}
