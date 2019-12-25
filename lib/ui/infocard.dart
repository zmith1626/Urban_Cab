import 'package:expange/colors.dart';
import 'package:expange/model/bookedPassenger.dart';
import 'package:expange/pages/passengerlist.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class InfoCard extends StatelessWidget {
  final MainModel model;
  final bool isInfoDisplay;
  final bool isPrivateVehicle;
  final BookedPassenger passenger;

  InfoCard(
    this.model,
    this.passenger,
    this.isInfoDisplay,
    this.isPrivateVehicle,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          _buildImageDisplay(passenger.image),
          _buildDetails(context, passenger),
        ],
      ),
    );
  }

  Widget _buildImageDisplay(String imageUrl) {
    return Container(
      alignment: FractionalOffset(0.48, -1.0),
      margin: const EdgeInsets.only(left: 16.0),
      child: Container(
        child: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        width: 150.0,
        height: 150.0,
        padding: const EdgeInsets.all(1.0),
        // border width
        decoration: BoxDecoration(
          color: Colors.white, // border color
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, BookedPassenger passenger) {
    double totalFare = passenger.travelFare + passenger.compFare;
    return Container(
      margin: EdgeInsets.only(top: 75.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Center(
              child: Text(passenger.name, style: boldTextStyle()),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(width: 5.0),
                isInfoDisplay
                    ? Icon(Icons.place, size: 18.0)
                    : Icon(Icons.check_circle, color: Colors.green, size: 24.0),
                Flexible(
                  child: Container(
                    child: Text(
                      isInfoDisplay
                          ? '  ' + passenger.pAddress
                          : ' Drop Confirmed !',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Ubuntu'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Center(
              child: Wrap(
                children: <Widget>[
                  isInfoDisplay
                      ? Icon(Icons.phone, size: 18.0)
                      : Text('₹', style: smallBoldTextStyle()),
                  isInfoDisplay
                      ? Text('+91-' + passenger.phone,
                          style: smallBoldTextStyle())
                      : Text(totalFare.toStringAsFixed(2),
                          style: smallBoldTextStyle())
                ],
              ),
            ),
            isInfoDisplay ? SizedBox(height: 20.0) : SizedBox(height: 10.0),
            Center(
              child: Wrap(
                spacing: 8.0,
                children: <Widget>[
                  isInfoDisplay
                      ? _buildFunctionButton(Icon(Icons.place), () {
                          Navigator.of(context).push(
                            CustomRoute(
                              builder: (BuildContext context) {
                                return PassengerList(
                                    model: model,
                                    passenger: passenger,
                                    privateMode: false);
                              },
                            ),
                          );
                        })
                      : SizedBox(width: 0.1),
                  isInfoDisplay
                      ? _buildFunctionButton(Icon(Icons.close), () {
                          Navigator.pop(context);
                        })
                      : _buildFunctionButton(
                          Icon(Icons.done),
                          isPrivateVehicle
                              ? () {
                                  Navigator.pop(context);
                                  model.removeBoundCustomer(null);
                                }
                              : () {
                                  Navigator.pop(context);
                                  model.removeBoundCustomer(passenger.id);
                                },
                        ),
                  isInfoDisplay
                      ? _buildFunctionButton(Icon(Icons.phone), () {
                          launcher.launch('tel://${passenger.phone}');
                        })
                      : SizedBox(width: 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionButton(Icon icon, Function function) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: kSurfaceColor,
        border: Border.all(),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black, blurRadius: 10.0, offset: Offset(0.0, 10.0))
        ],
      ),
      child: GestureDetector(
        onTap: () => function(),
        child: icon,
      ),
    );
  }
}
