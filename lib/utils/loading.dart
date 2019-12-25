import 'package:expange/colors.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurfaceColor,
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Image.asset('assets/load.png', width: 150.0, height: 150.0),
            Wrap(
              spacing: 5.0,
              alignment: WrapAlignment.center,
              children: <Widget>[
                CupertinoActivityIndicator(),
                Text('Please Wait . . .', style: smallBoldTextStyle()),
              ],
            ),
            Positioned(
              top: 95.0,
              left: 160.0,
              child: CircularProgressIndicator(),
            )
          ],
        ),
      ),
    );
  }
}
