import 'package:expange/colors.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class MaterialedButton extends StatelessWidget {
  final IconData buttonIcon;
  final String buttonText;
  final Function onButtonClick;

  MaterialedButton(this.buttonIcon, this.buttonText, this.onButtonClick);

  @override
  Widget build(BuildContext context) {
    double _buttonWidth = MediaQuery.of(context).size.width;
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      color: kBlackColor,
      elevation: 1.0,
      child: MaterialButton(
        minWidth: _buttonWidth,
        splashColor: kRedColor,
        height: 42.0,
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Icon(buttonIcon, color: Colors.white70, size: 20.0),
            SizedBox(width: 5.0),
            Text(
              buttonText,
              style: whiteTextStyle(),
            ),
          ],
        ),
        onPressed: onButtonClick,
      ),
    );
  }
}
