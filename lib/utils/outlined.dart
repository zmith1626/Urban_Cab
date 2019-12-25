import 'package:expange/colors.dart';
import 'package:flutter/material.dart';

class OutlinedButton extends StatelessWidget {
  final String buttonTitle;
  final IconData buttonIcon;
  final Function onClickFunction;
  final Color outlineButtonColor;

  OutlinedButton(this.buttonTitle, this.buttonIcon, this.onClickFunction,
      this.outlineButtonColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlineButton(
        borderSide: BorderSide(color: outlineButtonColor, width: 2.0),
        splashColor: kBlackColor,
        onPressed: onClickFunction,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(buttonIcon, color: outlineButtonColor),
            SizedBox(width: 10.0),
            Text(
              buttonTitle,
              style: TextStyle(color: outlineButtonColor, fontFamily: 'Ubuntu'),
            ),
          ],
        ),
      ),
    );
  }
}
