import 'package:expange/colors.dart';
import 'package:expange/model/bookedPassenger.dart';
import 'package:expange/model/savedTicket.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final BookedPassenger passenger;
  final Function clickFunction;
  final SavedTicket ticket;
  final bool isDriver;

  ListCard(this.passenger, this.clickFunction, this.ticket, this.isDriver);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: GestureDetector(
        onTap: () => clickFunction(),
        child: Stack(
          children: <Widget>[
            userCard(),
            passenger == null ? buildLeadingDisplay() : userImage(),
          ],
        ),
      ),
    );
  }

  Widget userImage() {
    return Container(
      alignment: FractionalOffset(0.0, 0.5),
      margin: const EdgeInsets.only(left: 16.0),
      child: Container(
        child: CircleAvatar(
          backgroundImage: NetworkImage(passenger.image),
        ),
        width: 100.0,
        height: 100.0,
        padding: const EdgeInsets.all(1.0),
        // border width
        decoration: BoxDecoration(
          color: kSurfaceColor, // border color
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget buildLeadingDisplay() {
    return Container(
      alignment: FractionalOffset(0.0, 0.5),
      margin: const EdgeInsets.only(left: 16.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(ticket.date.split(' ')[0], style: smallBoldTextStyle()),
            Text(ticket.date.split(' ')[1], style: smallBoldTextStyle()),
            Text(ticket.date.split(' ')[2], style: boldTextStyle()),
          ],
        ),
        width: 100.0,
        height: 100.0,
        padding: const EdgeInsets.only(right: 20.0),
        // border width
        decoration: BoxDecoration(
            color: kSurfaceColor,
            border: Border.all(),
            borderRadius: BorderRadius.circular(20.0) // border color
            ),
      ),
    );
  }

  Widget userCard() {
    String pCount = '';
    double totalFare = 0;
    if (passenger == null) {
      totalFare = ticket.price + ticket.compPrice;
    } else {
      if (passenger.pCount > 0) {
        pCount = '  +${passenger.pCount} more';
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 60.0, right: 10.0),
      decoration: BoxDecoration(
        color: kGreyColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black, blurRadius: 10.0, offset: Offset(0.0, 10.0))
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(
            top: 8.0, left: 68.0, right: 4.0, bottom: 8.0),
        constraints: BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              (passenger == null)
                  ? (isDriver)
                      ? ticket.passengerName
                      : ticket.vehicleModel + ' (' + ticket.vehicleReg + ')'
                  : passenger.name + pCount,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: smallBoldTextStyle(),
            ),
            Container(
                color: const Color(0xFF00C6FF),
                width: 36.0,
                height: 1.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0)),
            Row(
              children: <Widget>[
                Image.asset('assets/pin_one.png', width: 18.0, height: 18.0),
                SizedBox(width: 5.0),
                Flexible(
                  child: Container(
                    child: Text(
                      (passenger == null)
                          ? ticket.pickAddress
                          : passenger.pAddress,
                      overflow: TextOverflow.ellipsis,
                      style: labelTextStyle(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Row(
              children: <Widget>[
                Icon(Icons.location_on, size: 18.0),
                SizedBox(width: 5.0),
                Flexible(
                  child: Container(
                    child: Text(
                      (passenger == null)
                          ? ticket.dropAddress
                          : passenger.dAddress,
                      overflow: TextOverflow.ellipsis,
                      style: labelTextStyle(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Row(
              children: <Widget>[
                (passenger == null)
                    ? Text('₹', style: smallBoldTextStyle())
                    : Icon(Icons.phone, size: 18.0),
                SizedBox(width: 5.0),
                Flexible(
                  child: Container(
                    child: Text(
                      (passenger == null)
                          ? totalFare.toStringAsFixed(2)
                          : passenger.phone,
                      overflow: TextOverflow.ellipsis,
                      style: labelTextStyle(),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
