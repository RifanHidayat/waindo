import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget/text_labe.dart';

class TextGroupColumn extends StatelessWidget {
  final title, subtitle;
  const TextGroupColumn(
      {super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                child: TextLabell(
              align: TextAlign.right,
              weight: FontWeight.w700,
              text: title,
            )),
            const SizedBox(
              height: 5,
            ),
            Container(
                child: TextLabell(
              text: subtitle,
              color: Constanst.colorText1,
              weight: FontWeight.w400,
            )),
          ],
        ));
  }
}
