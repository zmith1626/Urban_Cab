import 'package:expange/colors.dart';
import 'package:expange/model/driver.dart';
import 'package:expange/model/passenger.dart';
import 'package:expange/pages/orderlist.dart';
import 'package:expange/pages/profileupdate.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:expange/utils/terms.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class SideDrawer extends StatelessWidget {
  final Driver driver;
  final Passenger passenger;
  final bool isPrivateVehicle;

  SideDrawer({this.driver, this.passenger, this.isPrivateVehicle});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Drawer(
          child: (passenger != null || driver != null)
              ? Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(1.0),
                        children: <Widget>[
                          DrawerHeader(
                            decoration: BoxDecoration(color: kRedColor),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Wrap(
                                    spacing: 10.0,
                                    children: <Widget>[
                                      Icon(Icons.widgets),
                                      Text('Timeline Settings',
                                          style: smallBoldTextStyle()),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: 90.0,
                                        width: 90.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: kSurfaceColor),
                                        ),
                                        child: CircleAvatar(
                                          backgroundImage: driver == null
                                              ? NetworkImage(passenger.image)
                                              : NetworkImage(driver.image),
                                        ),
                                      ),
                                      SizedBox(width: 5.0),
                                      _buildInfoColumn()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          ListTile(
                            leading: Icon(Icons.local_taxi),
                            title: Text('Your Trips', style: labelTextStyle()),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                CustomRoute(builder: (BuildContext context) {
                                  return ScopedModelDescendant<MainModel>(
                                    builder: (BuildContext context,
                                        Widget child, MainModel model) {
                                      return OrderList(model);
                                    },
                                  );
                                }),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.edit),
                            title:
                                Text('Edit Profile', style: labelTextStyle()),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return ProfileUpdate(
                                        model: model, isProfileSettings: true);
                                  },
                                ),
                              );
                            },
                          ),
                          (driver == null)
                              ? SizedBox(height: 0.1)
                              : ListTile(
                                  leading: Icon(Icons.settings),
                                  title:
                                      Text('Settings', style: labelTextStyle()),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return ProfileUpdate(
                                              model: model,
                                              isProfileSettings: false,
                                              isPrivateVehicle:
                                                  isPrivateVehicle);
                                        },
                                      ),
                                    );
                                  },
                                ),
                          ListTile(
                            leading: Icon(Icons.power_settings_new),
                            title: Text('Sign Out', style: labelTextStyle()),
                            onTap: () {
                              model.signOutUser();
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed('/');
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.help_outline),
                            title:
                                Text('Terms of Use', style: labelTextStyle()),
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomRoute(
                                  builder: (BuildContext context) {
                                    return Terms();
                                  },
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Align(
                        alignment: FractionalOffset.bottomRight,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Divider(indent: 30.0),
                              Text('     Expange Tech Pvt LTD, Dibrugarh',
                                  style: smallBoldTextStyle()),
                              SizedBox(height: 14.0)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: <Widget>[
                    SizedBox(height: 100.0),
                    DrawerHeader(
                      child: Container(
                        color: kSurfaceColor,
                        child: Image.asset('assets/wifi.png'),
                      ),
                    ),
                    SizedBox(height: 50.0),
                    Text('Oops! No Internet Connection', style: hugeTextStyle())
                  ],
                ),
        );
      },
    );
  }

  Widget _buildInfoColumn() {
    return Flexible(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(driver == null ? passenger.username : driver.username,
                overflow: TextOverflow.ellipsis, style: smallBoldTextStyle()),
            Text(driver == null ? passenger.email : driver.email,
                overflow: TextOverflow.ellipsis, style: labelTextStyle()),
            SizedBox(height: 5.0),
            (driver == null)
                ? SizedBox(width: 0.1)
                : Wrap(
                    spacing: 5.0,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Icon(Icons.star, size: 16.0),
                      Text(
                        driver.rating > 0 ? driver.rating.toString() : '--',
                        style: smallBoldTextStyle(),
                      )
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
