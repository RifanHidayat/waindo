class AtasanModel {
  var name;
  var token;

  AtasanModel({
    this.name,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {'full_namename': name, 'token_notif': token};
  }

  factory AtasanModel.fromJson(Map<String, dynamic> map) {
    return AtasanModel(
        name: map['full_name'] ?? "", token: map['token_notif'] ?? "");
  }

  static List<AtasanModel> fromJsonToList(List data) {
    return List<AtasanModel>.from(data.map(
      (item) => AtasanModel.fromJson(item),
    ));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['full_name'] = name;
    data['token_notif'] = token;

    return data;
  }
}
