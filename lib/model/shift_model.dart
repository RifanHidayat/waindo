// To parse this JSON data, do
//
//     final officeShiftModel = officeShiftModelFromJson(jsonString);

import 'dart:convert';

OfficeShiftModel officeShiftModelFromJson(String str) =>
    OfficeShiftModel.fromJson(json.decode(str));

String officeShiftModelToJson(OfficeShiftModel data) =>
    json.encode(data.toJson());

class OfficeShiftModel {
  OfficeShiftModel({
    this.id,
    this.name,
    this.timeIn,
    this.timeOut,
    this.defaultShift,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  var id;
  var name;
  var timeIn;
  var timeOut;
  var defaultShift;
  var createdBy;
  var createdOn;
  var modifiedBy;
  var modifiedOn;

  factory OfficeShiftModel.fromJson(Map<String, dynamic> json) =>
      OfficeShiftModel(
        id: json["id"],
        name: json["name"] ?? "",
        timeIn: json["time_in"] ?? "",
        timeOut: json["time_out"] ?? "",
        defaultShift: json["default_shift"],
        createdBy: json["created_by"] ?? "",
        createdOn: json["created_on"] ?? "",
        modifiedBy: json["modified_by"] ?? "",
        modifiedOn: json["modified_on"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "time_in": timeIn,
        "time_out": timeOut,
        "default_shift": defaultShift,
        "created_by": createdBy,
        "created_on": createdOn,
        "modified_by": modifiedBy,
        "modified_on": modifiedOn,
      };
}
