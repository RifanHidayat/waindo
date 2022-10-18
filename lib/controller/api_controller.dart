import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:siscom_operasional/utils/api.dart';

class ApiController extends GetxController {
  // METHOD GET

  Future<List> getDepartemen() async {
    List dataFinal = [];
    var connect = Api.connectionApi("get", "", "all_department");
    connect.then((dynamic res) {
      if (res.statusCode == 200) {
        var valueBody = jsonDecode(res.body);
        for (var element in valueBody['data']) {
          dataFinal.add(element);
        }
      }
    });

    return dataFinal;
  }

  // Future<List> getPosisi() async {
  //   List dataFinal = [];
  //   var connect = Api.connectionApi("get", "", "all_department");
  //   connect.then((dynamic res) {
  //     if (res.statusCode == 200) {
  //       var valueBody = jsonDecode(res.body);
  //       for (var element in valueBody['data']) {
  //         dataFinal.add(element);
  //       }
  //     }
  //   });

  //   return dataFinal;
  // }
}
