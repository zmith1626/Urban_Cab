import 'package:expange/colors.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class RideCompletedDisplay extends StatelessWidget {
  final bool rideCompleted;
  final Function onClickFunction;

  RideCompletedDisplay(
      {@required this.rideCompleted, @required this.onClickFunction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 240.0,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: kGreyColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: rideCompleted
                  ? Icon(Icons.thumb_up, color: kGreenColor, size: 80.0)
                  : Icon(Icons.sentiment_dissatisfied,
                      color: kRedDarkColor, size: 80.0),
            ),
            rideCompleted
                ? Text('Ride Completed !!', style: boldTextStyle())
                : Text('Ride Cancelled !!', style: boldTextStyle()),
            SizedBox(height: 5.0),
            rideCompleted
                ? Text('Thanks for Choosing us.', style: labelTextStyle())
                : Text('Inconvenience Regretted', style: labelTextStyle()),
            SizedBox(height: 10.0),
            OutlineButton(
              onPressed: () => onClickFunction(),
              child: Text('OKAY', style: smallBoldTextStyle()),
              borderSide: BorderSide(
                color: kGreenColor,
                width: 2.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
