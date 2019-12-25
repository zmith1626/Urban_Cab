import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expange/colors.dart';
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

class FindCab extends StatefulWidget {
  final MainModel model;
  final bool hasActiveTicket;
  final double totalFare;

  FindCab({this.model, this.hasActiveTicket, this.totalFare});

  @override
  _FindCab createState() => _FindCab();
}

class _FindCab extends State<FindCab> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Marker myPosMarker;
  BitmapDescriptor myIcon;

  @override
  void initState() {
    super.initState();
    if (widget.hasActiveTicket) widget.model.fetchTicketData();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(36, 36)), 'assets/car_one.png')
        .then((onValue) {
      myIcon = onValue;
    });

    myPosMarker = Marker(
      markerId: MarkerId('pickupPt'),
      position: LatLng(widget.model.pickupLocation.location.latitude,
          widget.model.pickupLocation.location.longitude),
      draggable: true,
      icon: BitmapDescriptor.defaultMarker,
    );
    _markers.putIfAbsent(myPosMarker.markerId, () => myPosMarker);
  }

  @override
  void dispose() {
    if (!widget.hasActiveTicket &&
        widget.model.ticket != null &&
        (widget.model.travelInfo.bookStatus == statusBooked ||
            widget.model.travelInfo.bookStatus == statusPicked))
      widget.model.saveTicketData(privateVehicle);
    if (widget.hasActiveTicket &&
        widget.model.travelInfo.bookStatus == statusCancelled)
      widget.model.removeTicket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          key: _scaffoldKey,
          body: model.isFetching
              ? SafeArea(child: Loading())
              : SafeArea(
                  child: _buildBody(model),
                ),
        );
      },
    );
  }

  LatLng getVehicleLatLng(MainModel model) {
    LatLng vehPos = LatLng(model.pickupLocation.location.latitude,
        model.pickupLocation.location.longitude);
    if (model.ticket != null) {
      vehPos = model.ticket.vehiclePos;
      Marker vehicleMarker = Marker(
        markerId: MarkerId('vehicle'),
        position: model.ticket.vehiclePos,
        draggable: true,
        icon: BitmapDescriptor.defaultMarker,
      );

      if (_markers.containsKey('vehicle')) {
        _markers.remove('vehicle');
      }

      _markers[MarkerId('user')] = vehicleMarker;
    }
    return vehPos;
  }

  Widget _buildFindingDisplay(MainModel model) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          MapDisplay(positions: [
            LatLng(widget.model.pickupLocation.location.latitude,
                widget.model.pickupLocation.location.longitude)
          ], isFetchingDisplay: true),
          (widget.model.message != null)
              ? Positioned(
                  left: 2.0,
                  right: 2.0,
                  bottom: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0)),
                        color: kGreyColor,
                        border: Border.all(color: kBlackColor)),
                    height: (MediaQuery.of(context).size.height / 2.5),
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: Text(
                          model.message['data']['message'],
                          style: smallBoldTextStyle(),
                        ),
                      ),
                    ),
                  ),
                )
              : _buildStatusDisplay(model),
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

  Widget _buildStatusDisplay(MainModel model) {
    Widget displayWidget = Positioned(
      bottom: 50.0,
      left: 20.0,
      right: 20.0,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: kGreyColor,
        ),
        child: Wrap(
          spacing: 20.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: <Widget>[
            (model.travelInfo.bookStatus.contains('!')
                ? Icon(Icons.warning, color: kRedDarkColor)
                : CupertinoActivityIndicator(radius: 14.0)),
            Text(model.travelInfo.bookStatus, style: smallBoldTextStyle()),
          ],
        ),
      ),
    );
    if (model.travelInfo.bookStatus == statusCancelled) {
      displayWidget = RideCompletedDisplay(
          rideCompleted: false, onClickFunction: _navigateBack);
    }

    if (model.travelInfo.bookStatus == statusDroped) {
      displayWidget = RideCompletedDisplay(
          rideCompleted: true, onClickFunction: _navigateBack);
    }

    return displayWidget;
  }

  Widget _buildVehicleInfoDisplay(MainModel model) {
    return Container(
      child: Stack(
        children: <Widget>[
          StreamBuilder(
              stream: Firestore.instance
                  .collection('PrivateVehicles')
                  .document(widget.model.ticket.vehicleReg)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return MapDisplay(positions: [
                    LatLng(widget.model.pickupLocation.location.latitude,
                        widget.model.pickupLocation.location.longitude),
                    model.ticket.vehiclePos
                  ], isFetchingDisplay: false, descriptor: myIcon);
                }
                return MapDisplay(positions: [
                  LatLng(widget.model.pickupLocation.location.latitude,
                      widget.model.pickupLocation.location.longitude),
                  LatLng(snapshot.data['Position']['geopoint'].latitude,
                      snapshot.data['Position']['geopoint'].longitude)
                ], isFetchingDisplay: false, descriptor: myIcon);
              }),
          Positioned(
            left: 2.0,
            right: 2.0,
            bottom: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0)),
                  color: kGreyColor,
                  border: Border.all(color: kDarkBlackColor)),
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: widget.model.viewFullDetails
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Wrap(
                            spacing: 10.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Icon(Icons.verified_user),
                              Text('OTP  - ' + model.ticket.otp.toString(),
                                  style: smallBoldTextStyle())
                            ],
                          ),
                        ),
                        Divider(color: kBlackColor, indent: 20.0),
                        ListTile(
                          leading: CircleAvatar(
                            maxRadius: 28.0,
                            minRadius: 28.0,
                            backgroundImage:
                                NetworkImage(ResourcesUri().getDefaultImageUri),
                          ),
                          title: Text(model.ticket.driverName,
                              style: smallBoldTextStyle()),
                          subtitle: Text(model.ticket.driverPhone,
                              style: labelTextStyle()),
                          trailing: IconButton(
                              icon: Icon(Icons.phone),
                              splashColor: kSurfaceColor,
                              onPressed: () {
                                launcher.launch(
                                    'tel://${model.ticket.driverPhone}');
                              }),
                        ),
                        ListTile(
                          leading: Image.asset('assets/automobile.png'),
                          title: Text(model.ticket.vehicleModel,
                              style: smallBoldTextStyle()),
                          subtitle: Text(model.ticket.vehicleReg,
                              style: labelTextStyle()),
                        ),
                        _buildCancelButton(context),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.model.viewFullDetails =
                                    !widget.model.viewFullDetails;
                              });
                            },
                            child: Wrap(
                              spacing: 10.0,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Icon(Icons.reorder),
                                Text('View Details',
                                    style: smallBoldTextStyle())
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MainModel model) {
    if (model.ticket == null &&
        (model.travelInfo.bookStatus != null || model.message != null)) {
      return _buildFindingDisplay(model);
    } else {
      return _buildVehicleInfoDisplay(model);
    }
  }

  void _processCancellation() async {
    Navigator.pop(context);
    final double totalFare = widget.hasActiveTicket
        ? widget.model.travelInfo.travelFare
        : widget.totalFare;
    widget.model.saveDues(totalFare);
    final String userID = widget.model.passenger.id;
    final Map<String, dynamic> cancelMap = {
      "ticket": widget.model.ticket.ticketId,
      "status": "CANCELLED"
    };
    final Map<String, dynamic> response =
        await widget.model.cancelPrivateBooking(cancelMap, userID);
    _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
  }

  Widget _buildCancelButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
              '₹' +
                  (widget.hasActiveTicket
                          ? widget.model.travelInfo.travelFare
                          : widget.totalFare)
                      .toString(),
              style: smallBoldTextStyle()),
          SizedBox(width: 10.0),
          RaisedButton(
            child: Text('Hide Details', style: labelTextStyle()),
            onPressed: () {
              setState(() {
                widget.model.viewFullDetails = !widget.model.viewFullDetails;
              });
            },
            color: kGreyColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          ),
          SizedBox(width: 10.0),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Padding(
                padding: EdgeInsets.only(right: 50.0),
                child: CupertinoActivityIndicator(),
              )
            : RaisedButton(
                child: Text('Cancel', style: smallBoldWhiteTextStyle()),
                onPressed: () {
                  double height = 202.0;
                  inputDialog(
                      context, CancelDialog(_processCancellation), height);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              );
      },
    );
  }
}
