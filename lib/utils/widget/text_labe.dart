import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:siscom_operasional/utils/constans.dart';

class TextLabell extends StatelessWidget {
  final text, color, weight, align;
  final size;
  const TextLabell({
    super.key,
    required this.text,
    this.color,
    this.weight,
    this.size,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: double.parse(size != null ? size.toString() : '12.0'),
          color: color ?? Constanst.colorBlack,
          fontWeight: weight ?? FontWeight.w400),
      textAlign: align ?? TextAlign.left,
    );
  }
}
