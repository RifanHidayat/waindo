import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget/text_labe.dart';

class TextGroupRow extends StatelessWidget {
  final title, subtitle;
  const TextGroupRow({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
                flex: 50,
                child: Container(
                    child: TextLabell(
                  text: title,
                  color: Constanst.colorText1,
                ))),
            Expanded(
                flex: 50,
                child: Container(
                    child: TextLabell(
                  align: TextAlign.right,
                  weight: FontWeight.w500,
                  text: subtitle,
                )))
          ],
        ));
  }
}
