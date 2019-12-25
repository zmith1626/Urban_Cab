import 'package:expange/colors.dart';
import 'package:flutter/material.dart';

Future<bool> inputDialog(
    BuildContext context, Widget displayWidget, double cardHeight) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          color: Color(0xFF737373),
          height: cardHeight,
          child: Container(
            child: displayWidget,
            decoration: BoxDecoration(
              color: kGreyColor,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
          ),
        ),
      );
    },
  );
}
