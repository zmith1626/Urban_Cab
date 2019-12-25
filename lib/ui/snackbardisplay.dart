import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

Widget snackbarDisplay(Map<String, dynamic> response) {
  final String messageText =
      response['message'].toString().replaceAll(new RegExp(r'_'), ' ');
  return SnackBar(
    content: Wrap(
      spacing: 8.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        (response['status'] == 'OK')
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.error, color: Colors.red),
        Text(messageText, style: whiteTextStyle())
      ],
    ),
    duration: const Duration(seconds: 1),
  );
}
