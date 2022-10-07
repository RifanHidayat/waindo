// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:siscom_operasional/utils/constans.dart';

class CustomDialog extends StatelessWidget {
  final String? title, content, positiveBtnText, negativeBtnText;
  final int? style;
  final int? buttonStatus;
  final GestureTapCallback? positiveBtnPressed;

  CustomDialog({
    @required this.title,
    @required this.content,
    @required this.positiveBtnText,
    @required this.negativeBtnText,
    @required this.positiveBtnPressed,
    @required this.style,
    @required this.buttonStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          // Bottom rectangular box
          margin:
              EdgeInsets.only(top: 25), // to push the box half way below circle
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.only(
              top: 30, left: 20, right: 20), // spacing inside the box
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title!,
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                content!,
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              buttonStatus == 1
                  ? ButtonBar(
                      buttonMinWidth: 100,
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          child: Text(negativeBtnText!),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        FlatButton(
                          child: Text(positiveBtnText!),
                          onPressed: positiveBtnPressed,
                        ),
                      ],
                    )
                  : ButtonBar(
                      buttonMinWidth: 100,
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          child: Text(negativeBtnText!),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        CircleAvatar(
          backgroundColor: style == 1 ? Colors.red : Constanst.colorPrimary,
          maxRadius: 25.0,
          child: Icon(
            Iconsax.info_circle,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}
