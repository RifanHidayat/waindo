import 'dart:convert';

class MenuDashboardModel {
  String? gambar;
  String? title;


  MenuDashboardModel({
    this.gambar,
    this.title
  });

  Map<String, dynamic> toMap() {
    return {
      'gambar': gambar,
      'title': title
    };
  }

  factory MenuDashboardModel.fromMap(Map<String, dynamic> map) {
    return MenuDashboardModel(
      gambar: map['gambar'],
      title: map['title']
    );
  }

  String toJson() => json.encode(toMap());
}
