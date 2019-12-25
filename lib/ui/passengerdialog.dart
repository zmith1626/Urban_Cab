import 'package:expange/colors.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/utils/materialbutton.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class PassengerDialog extends StatefulWidget {
  final int seatsLeft;
  final MainModel model;
  final Function lockSeatFunction;

  PassengerDialog(this.seatsLeft, this.lockSeatFunction, this.model);

  @override
  _PassengerDialog createState() => _PassengerDialog();
}

class _PassengerDialog extends State<PassengerDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.people),
            SizedBox(width: 5.0),
            Text('No of Seats', style: boldTextStyle()),
          ],
        ),
        SizedBox(height: 30.0),
        Text('Upto ${widget.seatsLeft} seats can be selected',
            style: errorTextStyle()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove_circle, color: kRedDarkColor),
              onPressed: () {
                setState(() {
                  if (widget.model.travelInfo.noSeats > 1) {
                    widget.model.travelInfo.noSeats =
                        widget.model.travelInfo.noSeats - 1;
                  }
                });
              },
            ),
            SizedBox(width: 5.0),
            Text(widget.model.travelInfo.noSeats.toString(),
                style: smallBoldTextStyle()),
            SizedBox(width: 5.0),
            IconButton(
              icon: Icon(Icons.add_circle, color: kGreenColor),
              onPressed: () {
                setState(() {
                  if (widget.model.travelInfo.noSeats < widget.seatsLeft) {
                    widget.model.travelInfo.noSeats =
                        widget.model.travelInfo.noSeats + 1;
                  }
                });
              },
            )
          ],
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: MaterialedButton(Icons.arrow_forward_ios, 'Continue', () {
            if (widget.model.travelInfo.noSeats <= widget.seatsLeft &&
                widget.model.travelInfo.noSeats != 0) {
              Navigator.pop(context);
              widget.lockSeatFunction();
            }
          }),
        ),
      ],
    );
  }
}
