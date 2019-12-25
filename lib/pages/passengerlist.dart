import 'dart:async';

import 'package:expange/colors.dart';
import 'package:expange/model/bookedPassenger.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/canceldialog.dart';
import 'package:expange/ui/check.dart';
import 'package:expange/ui/dropdialog.dart';
import 'package:expange/ui/google_map.dart';
import 'package:expange/ui/infocard.dart';
import 'package:expange/ui/inputdialog.dart';
import 'package:expange/ui/pininput.dart';
import 'package:expange/ui/snackbardisplay.dart';
import 'package:expange/utils/constants/constants.dart';
import 'package:expange/utils/outlined.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';

class PassengerList extends StatefulWidget {
  final MainModel model;
  final BookedPassenger passenger;
  final bool privateMode;

  PassengerList(
      {@required this.model, this.passenger, @required this.privateMode});

  @override
  _PassengerList createState() => _PassengerList();
}

enum driverOptions { pickup, drop, cancel }

class _PassengerList extends State<PassengerList> {
  final TextEditingController otpController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Location location = Location();
  String selectedPassenger;
  StreamSubscription loc;
  var position;

  @override
  void initState() {
    widget.model.travelInfo.bookStatus = null;
    widget.model.updateLocation();
    super.initState();
  }

  @override
  void dispose() {
    if (loc != null) {
      loc.cancel();
    }
    widget.model.stopLocationUpdate();
    super.dispose();
  }

  void setSelectedPassenger({String passengerId}) {
    this.selectedPassenger = passengerId;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          key: _scaffoldKey,
          body: SafeArea(
            child: Container(
              color: kSurfaceColor,
              child: Stack(
                children: <Widget>[
                  _buildMainBody(),
                  (widget.privateMode && widget.passenger == null)
                      ? SizedBox(height: 0.1)
                      : _buildStackBody(model),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainBody() {
    if (widget.privateMode) {
      return _buildBody();
    } else {
      if (widget.passenger != null) {
        return MapDisplay(
            positions: [LatLng(widget.passenger.pLat, widget.passenger.pLng)],
            isFetchingDisplay: false);
      }
      return MapDisplay(
          passengerList: widget.model.passengerList, isFetchingDisplay: false);
    }
  }

  Widget _buildBody() {
    Widget displayWidget = MapDisplay(
        positions: [LatLng(widget.passenger.pLat, widget.passenger.pLng)],
        isFetchingDisplay: false);

    if (widget.model.travelInfo.bookStatus == statusCancelled) {
      displayWidget = RideCompletedDisplay(
          rideCompleted: false, onClickFunction: _navigateBack);
    }
    return displayWidget;
  }

  void _navigateBack() {
    Navigator.of(context).pushReplacementNamed('/privateDriver');
  }

  Widget _buildStackBody(MainModel model) {
    return Positioned(
      left: 8.0,
      bottom: 8.0,
      child: (model.isLoading)
          ? FloatingActionButton(
              child: CupertinoActivityIndicator(radius: 14.0),
              onPressed: null,
              backgroundColor: kBlackColor,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton(
                    child: PopupMenuButton<driverOptions>(
                      icon: Icon(Icons.settings, size: 30.0),
                      onSelected: (driverOptions option) {
                        _setMenuSelection(option);
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<driverOptions>>[
                        (widget.passenger == null)
                            ? _buildMenuItem(driverOptions.pickup,
                                Icons.person_add, 'Confirm Pickup')
                            : (widget.passenger.status == statusBooked)
                                ? _buildMenuItem(driverOptions.pickup,
                                    Icons.person_add, 'Confirm Pickup')
                                : null,
                        (widget.passenger == null) ? PopupMenuDivider() : null,
                        (widget.passenger == null)
                            ? _buildMenuItem(driverOptions.drop,
                                Icons.person_pin, 'Confirm Drop')
                            : (widget.passenger.status == statusPicked)
                                ? _buildMenuItem(driverOptions.drop,
                                    Icons.person_pin, 'Confirm Drop')
                                : null,
                        widget.privateMode ? PopupMenuDivider() : null,
                        widget.privateMode
                            ? PopupMenuItem<driverOptions>(
                                value: driverOptions.cancel,
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.cancel),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Cancel Ride',
                                      style: TextStyle(
                                          color: kRedDarkColor,
                                          fontFamily: 'Ubuntu',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ],
                    ),
                    backgroundColor: kBlackColor,
                    onPressed: () {}),
              ],
            ),
    );
  }

  PopupMenuItem<driverOptions> _buildMenuItem(
      driverOptions menuoption, IconData icon, String buttonText) {
    return PopupMenuItem<driverOptions>(
      value: menuoption,
      child: Row(
        children: <Widget>[
          Icon(icon),
          SizedBox(width: 8.0),
          Text(buttonText, style: smallBoldTextStyle()),
        ],
      ),
    );
  }

  void _setMenuSelection(driverOptions option) {
    double _cardHeight = 202.0;
    switch (option) {
      case driverOptions.pickup:
        {
          inputDialog(
              context, _buildOTPDisply(_cardHeight, context), _cardHeight);
        }
        break;
      case driverOptions.drop:
        {
          widget.model.isPrivateVehicle
              ? _confirmDrop()
              : inputDialog(
                  context,
                  DropDialog(widget.model, processDrop, setSelectedPassenger),
                  _cardHeight);
        }
        break;
      case driverOptions.cancel:
        {
          inputDialog(context, CancelDialog(_processCancellation), _cardHeight);
        }
        break;
    }
  }

  void _confirmDrop() async {
    double _cardHeight = 232.0;
    final String uID = widget.model.driver.id;
    final Map<String, dynamic> dropMap = {
      "vehicle": widget.model.boundCustomer.ticketId,
      "passengerID": widget.model.boundCustomer.id
    };
    final Map<String, dynamic> response =
        await widget.model.dropPassenger(dropMap, uID);
    if (response['status'] == "ERROR") {
      _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
    } else {
      inputDialog(
        context,
        InfoCard(widget.model, widget.model.boundCustomer, false, true),
        _cardHeight,
      );
      widget.model.boundCustomer = null;
    }
  }

  void _processCancellation() async {
    Navigator.pop(context);
    final String uID = widget.model.driver.id;
    final Map<String, dynamic> cancMap = {
      "ticket": widget.model.boundCustomer.ticketId,
      "status": "CANCELLED"
    };
    final Map<String, dynamic> response =
        await widget.model.cancelPrivateBooking(cancMap, uID);
    _scaffoldKey.currentState.showSnackBar(
      snackbarDisplay(response),
    );
    if (response['status'] == "OK") {
      Navigator.pop(context);
      widget.model.boundCustomer = null;
    }
  }

  Widget _buildOTPDisply(double cHeight, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Enter OTP', style: smallBoldTextStyle()),
            leading: Icon(Icons.textsms),
          ),
          SizedBox(height: cHeight / 24),
          PinInput(4, null, otpController),
          SizedBox(height: 10.0),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return OutlinedButton('Verify OTP', Icons.done_all, () async {
      Navigator.pop(context);
      final String userID = widget.model.driver.id;
      final Map<String, dynamic> otpData = {
        "OTP": otpController.text,
        "vehicle": (widget.model.isPrivateVehicle)
            ? widget.model.boundCustomer.ticketId
            : widget.model.driver.vehicleNo
      };
      Map<String, dynamic> response;
      if (widget.model.isPrivateVehicle) {
        response = await widget.model.confirmPrivatePickup(otpData, userID);
      } else {
        response = await widget.model.confirmPublicPickup(otpData, userID);
      }
      _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
    }, kDarkRedColor);
  }

  void processDrop() async {
    final String userID = widget.model.driver.id;
    final Map<String, dynamic> userData = {
      "vehicle": widget.model.driver.vehicleNo,
      "passengerID": this.selectedPassenger
    };
    Navigator.pop(context);
    final Map<String, dynamic> response =
        await widget.model.refreshSeat(userData, userID);
    if (response['status'] == "ERROR") {
      _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
    } else {
      double _cardHeight = 232.0;
      inputDialog(
        context,
        InfoCard(
          widget.model,
          widget.model.passengerList[response['id']],
          false,
          false,
        ),
        _cardHeight,
      );
    }
  }
}
