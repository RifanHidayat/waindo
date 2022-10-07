import 'dart:convert';

class AbsenModel {
  int? id;
  String? em_id;
  String? atten_date;
  String? signin_time;
  String? signout_time;
  String? working_hour;
  String? place_in;
  String? place_out;
  String? absence;
  String? overtime;
  String? earnleave;
  String? status;
  String? signin_longlat;
  String? signout_longlat;
  String? att_type;
  String? signin_pict;
  String? signout_pict;
  String? signin_note;
  String? signout_note;
  String? signin_addr;
  String? signout_addr;
  int? atttype;

  AbsenModel(
      {this.id,
      this.em_id,
      this.atten_date,
      this.signin_time,
      this.signout_time,
      this.working_hour,
      this.place_in,
      this.place_out,
      this.absence,
      this.overtime,
      this.earnleave,
      this.status,
      this.signin_longlat,
      this.signout_longlat,
      this.att_type,
      this.signin_pict,
      this.signout_pict,
      this.signin_note,
      this.signout_note,
      this.signin_addr,
      this.signout_addr,
      this.atttype});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "em_id": em_id,
      "atten_date": atten_date,
      "signin_time": signin_time,
      "signout_time": signout_time,
      "working_hour": working_hour,
      "place_in": place_in,
      "place_out": place_out,
      "absence": absence,
      "overtime": overtime,
      "earnleave": earnleave,
      "status": status,
      "signin_longlat": signin_longlat,
      "signout_longlat": signout_longlat,
      "att_type": att_type,
      "signin_pict": signin_pict,
      "signout_pict": signout_pict,
      "signin_note": signin_note,
      "signout_note": signout_note,
      "signin_addr": signin_addr,
      "signout_addr": signout_addr,
      "atttype": atttype
    };
  }

  factory AbsenModel.fromMap(Map<String, dynamic> map) {
    return AbsenModel(
        id: map['id'],
        em_id: map['em_id'],
        atten_date: map['atten_date'],
        signin_time: map['signin_time'],
        signout_time: map['signout_time'],
        working_hour: map['working_hour'],
        place_in: map['place_in'],
        place_out: map['place_out'],
        absence: map['absence'],
        overtime: map['overtime'],
        earnleave: map['earnleave'],
        status: map['status'],
        signin_longlat: map['signin_longlat'],
        signout_longlat: map['signout_longlat'],
        att_type: map['att_type'],
        signin_pict: map['signin_pict'],
        signout_pict: map['signout_pict'],
        signin_note: map['signin_note'],
        signout_note: map['signout_note'],
        signin_addr: map['signin_addr'],
        signout_addr: map['signout_addr'],
        atttype: map['atttype']);
  }

  String toJson() => json.encode(toMap());
}
