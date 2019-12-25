import 'package:expange/colors.dart';
import 'package:expange/pages/passengerlist.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:expange/ui/sidedrawer.dart';
import 'package:expange/ui/snackbardisplay.dart';
import 'package:expange/utils/loading.dart';
import 'package:expange/utils/outlined.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class PrivateDriver extends StatefulWidget {
  final MainModel model;

  PrivateDriver(this.model);

  @override
  _PrivateDriver createState() => _PrivateDriver();
}

class _PrivateDriver extends State<PrivateDriver> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.model.fetchDriverDetails(initLoad: true);
    widget.model.setPrivateVehicle();
    widget.model.updateLocation();
  }

  @override
  void dispose() {
    widget.model.stopLocationUpdate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          backgroundColor: kSurfaceColor,
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              'Expange',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.0,
                fontFamily: 'Ubuntu',
              ),
            ),
          ),
          drawer: SideDrawer(driver: model.driver, isPrivateVehicle: true),
          body: model.isLoading
              ? SafeArea(child: Loading())
              : (model.boundCustomer == null)
                  ? Container(
                      color: kSurfaceColor,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.departure_board, size: 50.0),
                            SizedBox(height: 10.0),
                            Text(
                              'Any new ride request will appear here',
                              style: smallBoldTextStyle(),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: kSurfaceColor,
                      child: Center(
                        child: Card(
                          elevation: 8.0,
                          color: kGreyColor,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      width: 100.0,
                                      height: 100.0,
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          model.boundCustomer.image,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: kSurfaceColor,
                                          shape: BoxShape.circle,
                                          border: Border.all()),
                                    ),
                                    SizedBox(width: 10.0),
                                    Flexible(
                                      child: Container(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            model.boundCustomer.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: boldTextStyle(),
                                          ),
                                          Text(
                                            model.boundCustomer.phone,
                                            overflow: TextOverflow.ellipsis,
                                            style: labelTextStyle(),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  leading: Image.asset('assets/pin_one.png',
                                      scale: 2.5),
                                  title: Text(
                                      model.boundCustomer.pAddress + ' (Pick)',
                                      style: labelTextStyle()),
                                ),
                                ListTile(
                                  leading: Icon(Icons.place),
                                  title: Text(
                                      model.boundCustomer.dAddress + ' (Drop)',
                                      style: labelTextStyle()),
                                ),
                                _buildButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isRequesting
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: CupertinoActivityIndicator(radius: 16.0),
                ),
              )
            : Column(
                children: <Widget>[
                  OutlinedButton(
                    'ACCEPT',
                    Icons.done_all,
                    () async {
                      final Map<String, dynamic> statusData = {
                        "status": "ACCEPTED",
                        "ticket": model.boundCustomer.ticketId
                      };
                      final userID = model.driver.id;
                      final Map<String, dynamic> response =
                          await model.updatePrivateBookStatus(
                        statusData,
                        userID,
                      );
                      if (response['status'] == "OK") {
                        Navigator.of(context).push(
                          CustomRoute(
                            builder: (BuildContext context) {
                              return PassengerList(
                                  model: widget.model,
                                  passenger: model.boundCustomer,
                                  privateMode: true);
                            },
                          ),
                        );
                      } else {
                        _scaffoldKey.currentState
                            .showSnackBar(snackbarDisplay(response));
                      }
                    },
                    kGreenColor,
                  ),
                  OutlinedButton(
                    'DECLINE',
                    Icons.cancel,
                    () async {
                      final Map<String, dynamic> statusData = {
                        "status": "DECLINED",
                        "ticket": model.boundCustomer.ticketId
                      };
                      final userID = model.driver.id;
                      final Map<String, dynamic> response =
                          await model.updatePrivateBookStatus(
                        statusData,
                        userID,
                      );
                      _scaffoldKey.currentState
                          .showSnackBar(snackbarDisplay(response));
                      model.removeBoundCustomer(null);
                    },
                    kRedDarkColor,
                  ),
                ],
              );
      },
    );
  }
}
