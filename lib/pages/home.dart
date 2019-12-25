import 'dart:async';
import 'package:expange/colors.dart';
import 'package:expange/pages/autocomplete.dart';
import 'package:expange/pages/detail.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:expange/ui/inputdialog.dart';
import 'package:expange/ui/sidedrawer.dart';
import 'package:expange/ui/snackbardisplay.dart';
import 'package:expange/utils/constants/constants.dart';
import 'package:expange/utils/curve_clipper.dart';
import 'package:expange/utils/loader.dart';
import 'package:expange/utils/loading.dart';
import 'package:expange/utils/outlined.dart';
import 'package:expange/utils/responsive_screen.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  final MainModel model;

  HomePage(this.model);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();
  final _scaffoldStateKey = GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  GoogleMapController _mapController;
  Location location = new Location();
  BitmapDescriptor myIcon;
  VoidCallback _showBottomSheetCallback;
  Screen size;
  bool _displayMap = false;
  bool _isRouteDrawn = false;
  bool _priceDisplayed = false;

  @override
  void initState() {
    super.initState();
    _showBottomSheetCallback = _showPricing;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(36, 36)), 'assets/pin_one.png')
        .then((onValue) {
      myIcon = onValue;
    });

    location.getLocation();
    widget.model.fetchUserDetails(initLoad: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this.size = Screen(MediaQuery.of(context).size);
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return WillPopScope(
          onWillPop: () => _onBackPressed(context),
          child: Scaffold(
            key: _scaffoldStateKey,
            drawer: SideDrawer(passenger: model.passenger),
            floatingActionButton: model.isLoading
                ? SizedBox(width: 0.1)
                : (_priceDisplayed &&
                        widget.model.stepPoints != null &&
                        widget.model.stepPoints.length > 0)
                    ? SizedBox(width: 0.1)
                    : _buildExtendedFab(context),
            body: model.isLoading
                ? SafeArea(
                    child: Loading(),
                  )
                : SafeArea(
                    child: _displayMap
                        ? _buildAlternateBody()
                        : Container(
                            color: kSurfaceColor,
                            child: ListView(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    ClipPath(
                                      clipper: CurveClipper(),
                                      child: Container(
                                        height: size.getWidthPx(240),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [kRedColor, kDarkRedColor],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: size.getWidthPx(36)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          appBarTitle(),
                                          SizedBox(height: size.getWidthPx(10)),
                                          upperBoxCard(),
                                          SizedBox(height: size.getWidthPx(5)),
                                          navigationButton(context),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildAlternateBody() {
    return Container(
      child: Stack(
        children: <Widget>[
          _buildDefaultMap(),
          upperBoxCard(),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) {
    _dismissBottomSheet(context);
    return null;
  }

  Widget appBarTitle() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: size.getWidthPx(20),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: size.getWidthPx(20)),
          child: IconButton(
            icon: Icon(Icons.menu, size: 30.0, color: kSurfaceColor),
            onPressed: () => _scaffoldStateKey.currentState.openDrawer(),
          ),
        ),
        Text("Expange", style: whiteBoldTextStyle())
      ],
    );
  }

  Widget upperBoxCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: kGreyColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black, blurRadius: 10.0, offset: Offset(0.0, 10.0))
        ],
      ),
      margin: EdgeInsets.symmetric(
          horizontal: size.getWidthPx(20), vertical: size.getWidthPx(16)),
      child: Container(
        height: size.getWidthPx(150),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          children: <Widget>[
            _buildTextField(pick, _pickupController),
            SizedBox(height: size.getWidthPx(10)),
            _buildTextField(drop, _dropController),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: labelTextStyle(),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: kSurfaceColor,
        hintStyle: labelTextStyle(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      onTap: () => _navigateToFullPage(hintText, controller),
    );
  }

  void _navigateToFullPage(String hintText, TextEditingController controller) {
    if (hintText == pick) {
      widget.model.pickupLocation = null;
    } else {
      widget.model.dropLocation = null;
    }
    _removeRouteDisplay();
    Navigator.of(context).push(
      CustomRoute(
        builder: (BuildContext context) {
          return AutoCompleteDisplay(controller, widget.model, hintText);
        },
      ),
    );
  }

  Widget navigationButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: size.getWidthPx(20)),
      child: Container(
        decoration: BoxDecoration(
            color: kGreyColor,
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0))
            ],
            border: Border.all()),
        child: IconButton(
          icon: Icon(Icons.gps_fixed),
          onPressed: () => _mapDisplay(context, display: true),
        ),
      ),
    );
  }

  void _showPricing() {
    setState(
      () {
        _showBottomSheetCallback = null;
      },
    );
    _scaffoldStateKey.currentState
        .showBottomSheet(
          (BuildContext context) {
            return Container(
              color: kSurfaceColor,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                padding: EdgeInsets.only(left: 8.0, top: 20.0, right: 8.0),
                child: _buildPricingDisplay(),
                decoration: BoxDecoration(
                  color: kGreyColor,
                  border: Border.all(),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                  ),
                ),
              ),
            );
          },
        )
        .closed
        .whenComplete(
          () {
            if (mounted) {
              setState(
                () {
                  _showBottomSheetCallback = _showPricing;
                },
              );
            }
          },
        );
  }

  Widget _buildPricingDisplay() {
    double cardHeight = 202.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Travel Distance - ' + widget.model.travelInfo.distance,
            style: labelTextStyle()),
        SizedBox(height: 8.0),
        Text('Estimated Time - ' + widget.model.travelInfo.time,
            style: labelTextStyle()),
        SizedBox(height: 8.0),
        Text(
          'Estimated Passenger Vehicle Price - ₹' +
              _getEstimatedFare(publicVehicle).toString(),
          style: labelTextStyle(),
        ),
        SizedBox(height: 8.0),
        Text(
          'Estimated Cab Price - ₹' +
              _getEstimatedFare(privateVehicle).toString(),
          style: labelTextStyle(),
        ),
        SizedBox(height: 8.0),
        OutlinedButton('Confirm', Icons.done_all, () {
          _dismissBottomSheet(context);
          inputDialog(context, _buildVehicleTypeDisplay(), cardHeight);
        }, kGreenColor),
        OutlinedButton('Cancel', Icons.cancel, () {
          _dismissBottomSheet(context);
        }, kRedDarkColor),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildVehicleTypeDisplay() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          Text('Select Vehicle Type', style: smallBoldTextStyle()),
          SizedBox(height: 10.0),
          Divider(),
          SizedBox(height: 10.0),
          OutlinedButton('Passenger Vehicle', Icons.airport_shuttle, () {
            _changeDisplayMode();
            Navigator.of(context).pushReplacement(
              CustomRoute(
                builder: (BuildContext context) {
                  return DetailPage(widget.model, false);
                },
              ),
            );
          }, kDarkRedColor),
          OutlinedButton('Cab/Taxi', Icons.local_taxi, () {
            _changeDisplayMode();
            Navigator.of(context).pushReplacement(
              CustomRoute(
                builder: (BuildContext context) {
                  return DetailPage(widget.model, true);
                },
              ),
            );
          }, kBlackColor),
        ],
      ),
    );
  }

  _changeDisplayMode() {
    setState(() {
      _displayMap = false;
    });
  }

  _dismissBottomSheet(BuildContext context) {
    setState(() {
      _priceDisplayed = false;
    });
    _autoRouteDisplay();
    Navigator.of(context).pop();
  }

  Widget _buildExtendedFab(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'public_mode',
      backgroundColor: kBlackColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      label: Text('Continue', style: whiteTextStyle()),
      icon: Icon(Icons.arrow_forward, size: 18.0),
      onPressed: () => processLogic(context),
    );
  }

  void processLogic(BuildContext context) {
    if (widget.model.pickupLocation == null ||
        widget.model.dropLocation == null) {
      _scaffoldStateKey.currentState.showSnackBar(snackbarDisplay({
        "status": "ERROR",
        "message": "Error! Invalid pickup or drop Location."
      }));
      return;
    }
    if (!_displayMap) {
      _mapDisplay(context);
      return;
    }

    if (!_isRouteDrawn) {
      _processRouteDisplay();
      return;
    }

    setState(() {
      _priceDisplayed = true;
    });
    _autoRouteDisplay();
    _showBottomSheetCallback();
  }

  void _autoRouteDisplay() {
    setState(() {
      _polylines = new Map<PolylineId, Polyline>();
    });
    Timer(Duration(seconds: 1), () => _processRouteDisplay());
  }

  void _removeRouteDisplay() {
    setState(() {
      _polylines = new Map<PolylineId, Polyline>();
      _markers = new Map<MarkerId, Marker>();
      _isRouteDrawn = false;
    });
  }

  void _processRouteDisplay() {
    try {
      _animateCamera();
    } on MissingPluginException catch (_) {
      return;
    }
    if (!_polylines.containsKey('stepPoints')) {
      setState(
        () {
          _isRouteDrawn = true;
          Polyline stepsPolyline = Polyline(
            polylineId: PolylineId('stepPoints'),
            points: widget.model.stepPoints,
            jointType: JointType.round,
            color: Colors.indigo,
            width: 3,
          );
          _polylines.putIfAbsent(
            PolylineId('stepPoints'),
            () => stepsPolyline,
          );
        },
      );
    }
  }

  void _animateCamera() {
    if (_mapController == null) {
      return;
    }

    double firstLat = widget.model.pickupLocation.location.latitude;
    double firstLng = widget.model.pickupLocation.location.longitude;
    double secondLat = widget.model.dropLocation.location.latitude;
    double secondLng = widget.model.dropLocation.location.longitude;

    try {
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(firstLat <= secondLat ? firstLat : secondLat,
                firstLng <= secondLng ? firstLng : secondLng),
            northeast: LatLng(firstLat <= secondLat ? secondLat : firstLat,
                firstLng <= secondLng ? secondLng : firstLng),
          ),
          42.0,
        ),
      );
      Marker myPosMarker1 = Marker(
        markerId: MarkerId('pickPt'),
        position: LatLng(
          widget.model.pickupLocation.location.latitude,
          widget.model.pickupLocation.location.longitude,
        ),
        draggable: true,
        icon: myIcon,
      );
      Marker myPosMarker2 = Marker(
        markerId: MarkerId('dropPt'),
        position: LatLng(
          widget.model.dropLocation.location.latitude,
          widget.model.dropLocation.location.longitude,
        ),
        draggable: true,
        icon: BitmapDescriptor.defaultMarker,
      );
      setState(() {
        _markers.putIfAbsent(MarkerId('pickPt'), () => myPosMarker1);
        _markers.putIfAbsent(MarkerId('dropPt'), () => myPosMarker2);
      });
    } on MissingPluginException catch (_) {
      return;
    }
  }

  double _getEstimatedFare(String travelModel) {
    double dues = widget.model.passenger.duesAmount;
    double fare =
        widget.model.travelFare(travelModel, widget.model.travelInfo.distance);
    double totalFare = fare.toDouble() + dues;
    double formattedFare = num.parse(totalFare.toStringAsFixed(2));
    return formattedFare;
  }

  void _mapDisplay(BuildContext context, {bool display}) {
    setState(() {
      _displayMap = true;
    });
    if (display != null && display) {
      Timer(Duration(seconds: 5), () => _animateToUser(context));
    }
  }

  void _animateToUser(BuildContext context) async {
    if (_mapController == null) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoaderPopup();
      },
    );

    try {
      var pos = await location.getLocation();
      if (pos != null) {
        await widget.model.getAddressDetails(pos.latitude, pos.longitude);
      }

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(pos.latitude, pos.longitude), zoom: 16.0),
        ),
      );
      Marker myPosMarker = Marker(
        markerId: MarkerId('pickupPt'),
        position: LatLng(pos.latitude, pos.longitude),
        draggable: true,
        icon: myIcon,
      );
      Navigator.pop(context);
      setState(() {
        if (_markers.containsKey('pickPt')) {
          _markers.remove('pickPt');
        }
        _markers.putIfAbsent(MarkerId('pickPt'), () => myPosMarker);
        if (widget.model.pickupLocation != null) {
          _pickupController.text = widget.model.pickupLocation.address;
        }
      });
    } on PlatformException catch (_) {
      Navigator.pop(context);
      return;
    }
  }

  GoogleMap _buildDefaultMap() {
    return GoogleMap(
      onMapCreated: _onMapCreate,
      initialCameraPosition:
          CameraPosition(target: LatLng(27.472834, 94.911964), zoom: 15.0),
      compassEnabled: true,
      markers: Set<Marker>.of(_markers.values),
      mapType: MapType.normal,
      polylines: Set<Polyline>.of(_polylines.values),
    );
  }

  void _onMapCreate(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }
}
