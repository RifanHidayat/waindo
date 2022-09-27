import 'dart:convert';

class SettingAppModel {
  int? id;
  String? sitelogo;
  String? sitetitle;
  String? description;
  String? copyright;
  String? contact;
  String? currency;
  String? symbol;
  String? system_email;
  String? address;
  String? address2;
  String? longlat_comp;
  int? radius;
  String? saveimage_attend;


  SettingAppModel({
    this.id,
    this.sitelogo,
    this.sitetitle,
    this.description,
    this.copyright,
    this.contact,
    this.currency,
    this.symbol,
    this.system_email,
    this.address,
    this.address2,
    this.longlat_comp,
    this.radius,
    this.saveimage_attend
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sitelogo': sitelogo,
      'sitetitle': sitetitle,
      'description': description,
      'copyright': copyright,
      'contact': contact,
      'currency': currency,
      'symbol': symbol,
      'system_email': system_email,
      'address': address,
      'address2': address2,
      'longlat_comp': longlat_comp,
      'radius': radius,
      'saveimage_attend': saveimage_attend

    };
  }

  factory SettingAppModel.fromMap(Map<String, dynamic> map) {
    return SettingAppModel(
      id: map['id'],
      sitelogo: map['sitelogo'],
      sitetitle: map['sitetitle'],
      description: map['description'],
      copyright: map['copyright'],
      contact: map['contact'],
      currency: map['currency'],
      symbol: map['symbol'],
      system_email: map['system_email'],
      address: map['address'],
      address2: map['address2'],
      longlat_comp: map['longlat_comp'],
      radius: map['radius'],
      saveimage_attend: map['saveimage_attend']
    );
  }

  String toJson() => json.encode(toMap());
}
