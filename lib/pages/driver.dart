import 'package:expange/colors.dart';
import 'package:expange/model/bookedPassenger.dart';
import 'package:expange/pages/passengerlist.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:expange/ui/infocard.dart';
import 'package:expange/ui/inputdialog.dart';
import 'package:expange/ui/listcard.dart';
import 'package:expange/ui/sidedrawer.dart';
import 'package:expange/utils/loading.dart';
import 'package:expange/utils/materialbutton.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class DriverPage extends StatefulWidget {
  final MainModel model;

  DriverPage(this.model);

  @override
  _DriverPage createState() => _DriverPage();
}

class _DriverPage extends State<DriverPage> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    widget.model.fetchDriverDetails(initLoad: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Scaffold(
                backgroundColor: kSurfaceColor,
                body: Loading(),
              )
            : Scaffold(
                backgroundColor: kSurfaceColor,
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
                drawer:
                    SideDrawer(driver: model.driver, isPrivateVehicle: false),
                body: RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: () =>
                      model.fetchPassengerList(model.driver.vehicleNo),
                  child: _buildBody(model),
                ),
                bottomNavigationBar: Container(
                  color: kSurfaceColor,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: MaterialedButton(
                        Icons.keyboard_arrow_right, 'Start Trip', _startTrip),
                  ),
                ),
              );
      },
    );
  }

  Widget _buildBody(MainModel model) {
    if (model.passengerList.length > 0) {
      return _buildListBody(model);
    }
    return _buildEmptyBody();
  }

  Widget _buildListBody(MainModel model) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListCard(model.passengerList[index], () {
              _showInfoCard(context, model.passengerList[index]);
            }, null, false);
          },
          itemCount: model.passengerList.length,
        );
      },
    );
  }

  Widget _buildEmptyBody() {
    return Container(
      color: kSurfaceColor,
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height / 3),
              Icon(Icons.departure_board, size: 50.0),
              SizedBox(height: 10.0),
              Text(
                'Any new ride request will appear here',
                style: smallBoldTextStyle(),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _startTrip() {
    widget.model.startJourney();
    Navigator.of(context).push(
      CustomRoute(
        builder: (BuildContext context) {
          return PassengerList(model: widget.model, privateMode: false);
        },
      ),
    );
  }

  void _showInfoCard(BuildContext context, BookedPassenger passenger) {
    double _cardHeight = 232.0;
    inputDialog(
      context,
      InfoCard(widget.model, passenger, true, false),
      _cardHeight,
    );
  }
}
