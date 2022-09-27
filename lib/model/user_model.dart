import 'dart:convert';

class UserModel {
  String? emp_id;
  String? em_code;
  int? des_id;
  int? dep_id;
  String? first_name;
  String? last_name;
  String? em_email;
  String? em_phone;
  String? em_birthday;
  String? em_gender;
  String? em_image;
  String? em_joining_date;
  String? em_status;
  String? em_blood_group;
  String? emp_jobTitle;
  String? emp_departmen;
  int? emp_att_working;
  String? em_hak_akses;

  UserModel(
      {this.emp_id,
      this.em_code,
      this.des_id,
      this.dep_id,
      this.first_name,
      this.last_name,
      this.em_email,
      this.em_phone,
      this.em_birthday,
      this.em_gender,
      this.em_image,
      this.em_joining_date,
      this.em_status,
      this.em_blood_group,
      this.emp_jobTitle,
      this.emp_departmen,
      this.emp_att_working,
      this.em_hak_akses});

  Map<String, dynamic> toMap() {
    return {
      'emp_id': emp_id,
      'em_code': em_code,
      'des_id': des_id,
      'dep_id': dep_id,
      'first_name': first_name,
      'last_name': last_name,
      'em_email': em_email,
      'em_phone': em_phone,
      'em_birthday': em_birthday,
      'em_gender': em_gender,
      'em_image': em_image,
      'em_joining_date': em_joining_date,
      'em_status': em_status,
      'em_blood_group': em_blood_group,
      'emp_jobTitle': emp_jobTitle,
      'emp_departmen': emp_departmen,
      'emp_att_working': emp_att_working,
      'em_hak_akses': em_hak_akses
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        emp_id: map['emp_id'],
        em_code: map['em_code'],
        des_id: map['des_id'],
        dep_id: map['dep_id'],
        first_name: map['first_name'],
        last_name: map['last_name'],
        em_email: map['em_email'],
        em_phone: map['em_phone'],
        em_birthday: map['em_birthday'],
        em_gender: map['em_gender'],
        em_image: map['em_image'],
        em_joining_date: map['em_joining_date'],
        em_status: map['em_status'],
        em_blood_group: map['em_blood_group'],
        emp_jobTitle: map['emp_jobTitle'],
        emp_departmen: map['emp_departmen'],
        emp_att_working: map['emp_att_working'],
        em_hak_akses: map['em_hak_akses']);
  }

  String toJson() => json.encode(toMap());
}
