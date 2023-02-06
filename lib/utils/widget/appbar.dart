import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget/text_labe.dart';

class AppBarApp extends StatelessWidget implements PreferredSizeWidget {
  final text, color, elevation, textColor, textSize, action;
  const AppBarApp(
      {super.key,
      this.text,
      this.color,
      this.elevation,
      this.textSize,
      this.textColor,
      this.action});
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: action ?? [],
      elevation: elevation ?? 1,
      backgroundColor: color ?? Constanst.colorPrimary,
      title: TextLabell(
        text: text ?? "",
        size: textSize ?? 12,
        color: textColor ?? Constanst.colorBlack,
      ),
      centerTitle: true,
      leading: IconButton(
        color: textColor ?? Constanst.colorBlack,
        onPressed: () {
          Get.back();
        },
        icon: Icon(Icons.chevron_left),
      ),
    );
  }
}
