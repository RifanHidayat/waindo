import 'dart:convert';

class NotificationModel {
  final String route;
  final String id;

  NotificationModel({required this.route, required this.id});

  //Add these methods below

  factory NotificationModel.fromJsonString(String str) =>
      NotificationModel._fromJson(jsonDecode(str));

  String toJsonString() => jsonEncode(_toJson());

  factory NotificationModel._fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        route: json['route'],
        id: json['id'],
      );

  Map<String, dynamic> _toJson() => {
        'route': route,
        'id': id,
      };
}
