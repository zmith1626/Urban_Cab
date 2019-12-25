import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expange/colors.dart';
import 'package:expange/model/driver.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/canceldialog.dart';
import 'package:expange/ui/check.dart';
import 'package:expange/ui/google_map.dart';
import 'package:expange/ui/inputdialog.dart';
import 'package:expange/ui/snackbardisplay.dart';
import 'package:expange/utils/constants/constants.dart';
import 'package:expange/utils/constants/resources.dart';
import 'package:expange/utils/loading.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class TicketPage extends StatefulWidget {
  final MainModel model;
  final bool locateCabmode;
  final bool hasActiveTicket;

  TicketPage({this.model, this.locateCabmode, this.hasActiveTicket});

  @override
  _TicketPage createState() => _TicketPage();
}

class _TicketPage extends State<TicketPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool locateCab;
  BitmapDescriptor myIcon;

  @override
  void initState() {
    super.initState();
    locateCab = widget.locateCabmode;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(36, 36)), 'assets/car_one.png')
        .then((onValue) {
      myIcon = onValue;
    });
    if (!widget.locateCabmode && !widget.hasActiveTicket) {
      widget.model.fetchBookingDetails();
    }

    if (widget.hasActiveTicket) {
      widget.model.fetchTicketData();
    }
  }

  @override
  void dispose() {
    if (!widget.hasActiveTicket &&
        widget.model.travelInfo.bookStatus != null &&
        widget.model.travelInfo.bookStatus == statusBooked) {
      widget.model.saveTicketData(publicVehicle);
    }
    if (widget.hasActiveTicket &&
        widget.model.travelInfo.bookStatus == statusCancelled)
      widget.model.removeTicket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return widget.model.isRequesting
            ? Scaffold(backgroundColor: kSurfaceColor, body: Loading())
            : Scaffold(
                key: _scaffoldKey,
                backgroundColor: kRedColor,
                appBar: AppBar(
                  backgroundColor: kRedColor,
                  elevation: 0.0,
                  title: Text(
                    'Booking Confirmed',
                    style: whiteTextStyle(),
                  ),
                ),
                body: SafeArea(
                  child: this.locateCab
                      ? _locateCabMode()
                      : _ticketDetails(model.driver),
                ),
              );
      },
    );
  }

  Widget _ticketDetails(Driver driver) {
    return widget.model.travelInfo.bookStatus == statusDroped
        ? RideCompletedDisplay(
            rideCompleted: true, onClickFunction: _navigateBack)
        : Container(
            child: Stack(
              children: <Widget>[
                _buildList(),
                _buildLeading(_leadingImage().toString()),
              ],
            ),
          );
  }

  void _navigateBack() {
    if (widget.model.travelInfo.bookStatus == statusCancelled) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/rateDriver');
    }
  }

  dynamic _leadingImage() {
    String imageUrl = ResourcesUri().getDefaultImageUri;
    if (widget.hasActiveTicket) {
      imageUrl = widget.model.ticket.driverImage;
    }
    if (!widget.locateCabmode && !widget.hasActiveTicket) {
      if (widget.model.ticket.driverImage != null) {
        imageUrl = widget.model.ticket.driverImage;
      }
    }

    return imageUrl;
  }

  Widget _buildList() {
    return Container(
      margin: EdgeInsets.only(top: 100.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        color: kSurfaceColor,
      ),
      child: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          SizedBox(height: 20.0),
          ListTile(
            title: Text(
              widget.model.ticket.driverName,
              style: smallBoldTextStyle(),
            ),
            subtitle: _buildSubtitleWidget(),
            trailing: Container(
              child: IconButton(
                color: kDarkRedColor,
                icon: Icon(Icons.phone),
                onPressed: () {
                  String tel = 'tel://' + widget.model.ticket.driverPhone;
                  launcher.launch(tel);
                },
              ),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                shape: BoxShape.circle,
                border: Border.all(),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 8.0),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              widget.model.ticket.vehicleModel,
              style: smallBoldTextStyle(),
            ),
            subtitle: Text(
              widget.model.ticket.vehicleReg,
              style: labelTextStyle(),
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildRowDisplay(
                  icon: Icons.watch_later,
                  text: widget.model.ticket.vehicleTime,
                ),
                SizedBox(width: 20.0),
                _buildRowDisplay(
                  icon: Icons.local_atm,
                  text: '₹ ' + _getFareDisplay().toString(),
                ),
                SizedBox(width: 20.0),
                _buildRowDisplay(
                    icon: Icons.transit_enterexit,
                    text: widget.model.ticket.travelDistance),
                SizedBox(width: 20.0),
                Column(
                  children: <Widget>[
                    Text('OTP', style: smallBoldTextStyle()),
                    SizedBox(height: 5.0),
                    Text(
                      widget.model.ticket.otp.toString(),
                      style: smallBoldTextStyle(),
                    )
                  ],
                )
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 2.0),
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: 10.0),
              Icon(Icons.local_taxi),
              SizedBox(width: 5.0),
              Flexible(
                child: Container(
                  child: Text(
                    widget.model.ticket.pickup,
                    overflow: TextOverflow.ellipsis,
                    style: labelTextStyle(),
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SizedBox(width: 10.0),
              Icon(Icons.arrow_downward)
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: 10.0),
              Icon(Icons.home),
              SizedBox(width: 5.0),
              Flexible(
                child: Container(
                  child: Text(
                    widget.model.ticket.drop,
                    overflow: TextOverflow.ellipsis,
                    style: labelTextStyle(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildSubtitleWidget() {
    return Row(
      children: <Widget>[
        Text(
          widget.model.ticket.driverPhone,
          style: labelTextStyle(),
        ),
        SizedBox(width: 10.0),
        Icon(Icons.star, size: 16.0),
        Text(
          widget.model.ticket.driverRating > 0
              ? widget.model.ticket.driverRating.toString()
              : '- -',
          style: smallBoldTextStyle(),
        )
      ],
    );
  }

  double _getFareDisplay() {
    dynamic distance = widget.model.ticket.travelDistance;
    double singleFare = widget.model.travelFare(publicVehicle, distance);
    double totalFare = widget.model.ticket.passCount * singleFare;
    totalFare = totalFare + widget.model.ticket.pendingDues;
    return totalFare;
  }

  Widget _buildRowDisplay({IconData icon, String text}) {
    return Column(
      children: <Widget>[Icon(icon), Text(text, style: smallBoldTextStyle())],
    );
  }

  Widget _buildLeading(String image) {
    return Container(
      alignment: FractionalOffset(0.0, 0.0),
      margin: const EdgeInsets.only(left: 16.0),
      child: Container(
        width: 120.0,
        height: 120.0,
        padding: const EdgeInsets.all(1.0),
        // border width
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: kSurfaceColor),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black, blurRadius: 10.0, offset: Offset(0.0, 5.0))
          ],
        ),
      ),
    );
  }

  void _processCancellation() async {
    Navigator.pop(context);
    widget.model.saveDues(_getFareDisplay());
    final String vehicleId = widget.model.ticket.vehicleReg;
    final Map<String, dynamic> response =
        await widget.model.cancelPublicBooking(vehicleId);
    _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
  }

  Widget _buildButton() {
    return ButtonBar(
      children: <Widget>[
        ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
            return model.isFetching
                ? CupertinoActivityIndicator(radius: 14.0)
                : FlatButton(
                    child: _buildWrap(Icon(Icons.block), 'Cancel'),
                    onPressed: () {
                      double cardHeight = 202.0;
                      inputDialog(context, CancelDialog(_processCancellation),
                          cardHeight);
                    },
                  );
          },
        ),
        RaisedButton(
          color: kBlackColor,
          padding: EdgeInsets.all(10.0),
          elevation: 8.0,
          textColor: kSurfaceColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          child: _buildWrap(Icon(Icons.local_taxi), 'Locate Cab'),
          onPressed: _locateCab,
        )
      ],
    );
  }

  Widget _buildWrap(Icon icon, String text) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5.0,
      children: <Widget>[
        icon,
        Text(text, style: TextStyle(fontFamily: 'Ubuntu'))
      ],
    );
  }

  Widget _locateCabMode() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      child: Stack(
        children: <Widget>[
          _buildMapDisplay(),
          (widget.model.travelInfo.bookStatus == statusDroped)
              ? RideCompletedDisplay(
                  rideCompleted: true, onClickFunction: _navigateBack)
              : Positioned(
                  left: 10.0,
                  bottom: 10.0,
                  child: FloatingActionButton.extended(
                    icon: Icon(Icons.receipt),
                    label: Text('View Ticket', style: whiteTextStyle()),
                    backgroundColor: kDarkRedColor,
                    onPressed: () {
                      setState(() {
                        locateCab = false;
                      });
                    },
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildMapDisplay() {
    String vehicleId = widget.model.ticket.vehicleReg;
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Vehicles')
            .document(vehicleId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return MapDisplay(positions: [
              widget.model.ticket.userPos,
              widget.model.ticket.vehiclePos
            ], isFetchingDisplay: false, descriptor: myIcon);
          }
          return MapDisplay(positions: [
            widget.model.ticket.userPos,
            LatLng(snapshot.data['Position']['geopoint'].latitude,
                snapshot.data['Position']['geopoint'].longitude)
          ], isFetchingDisplay: false, descriptor: myIcon);
        });
  }

  void _locateCab() {
    setState(() {
      this.locateCab = !this.locateCab;
    });
  }
}
