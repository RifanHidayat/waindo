import 'package:flutter/material.dart';
import 'package:siscom_operasional/utils/constans.dart';

class TextButtonWidget extends StatelessWidget {
  final String? title;
  final Function()? onTap;
  final Color? colorButton;
  final Color? colortext;
  final bool? iconShow;
  final BorderRadius? border;
  const TextButtonWidget({
    Key? key,
    this.title,
    this.onTap,
    this.colorButton,
    this.colortext,
    this.iconShow,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(colorButton!),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: border!,
          ))),
      onPressed: () {
        if (onTap != null) onTap!();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Text(
                title!,
                style: TextStyle(color: colortext),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextButtonWidget2 extends StatelessWidget {
  final String? title;
  final Function()? onTap;
  final Color? colorButton;
  final Color? colortext;
  final BorderRadius? border;
  final Icon? icon;
  const TextButtonWidget2({
    Key? key,
    this.title,
    this.onTap,
    this.colorButton,
    this.colortext,
    this.border,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(colorButton!),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: border!,
          ))),
      onPressed: () {
        if (onTap != null) onTap!();
      },
      child: Padding(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon!,
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
                child: Text(
                  title!,
                  overflow:TextOverflow.clip,
                  style: TextStyle(color: colortext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
