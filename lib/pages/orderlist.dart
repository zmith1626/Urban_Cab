import 'package:expange/colors.dart';
import 'package:expange/pages/findcab.dart';
import 'package:expange/pages/ticket.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:expange/ui/listcard.dart';
import 'package:expange/utils/constants/constants.dart';
import 'package:expange/utils/loading.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class OrderList extends StatefulWidget {
  final MainModel model;

  OrderList(this.model);

  @override
  _OrderList createState() => _OrderList();
}

class _OrderList extends State<OrderList> {
  @override
  void initState() {
    super.initState();
    if (widget.model.driver == null) {
      widget.model.checkActiveRides();
      widget.model.userRides();
    } else {
      widget.model.driverRides();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          backgroundColor: kSurfaceColor,
          appBar: AppBar(
            backgroundColor: kDarkRedColor,
            title: Text('My Trips', style: whiteTextStyle()),
            actions: (widget.model.passenger == null)
                ? <Widget>[]
                : <Widget>[
                    Stack(
                      children: <Widget>[
                        PopupMenuButton<String>(
                          icon: Icon(Icons.receipt, color: kSurfaceColor),
                          onSelected: (String selection) {
                            if (widget.model.hasActiveRides) {
                              Navigator.of(context).push(
                                CustomRoute(
                                  builder: (BuildContext context) {
                                    return widget.model.travelInfo.travelMode ==
                                            publicVehicle
                                        ? TicketPage(
                                            model: model,
                                            locateCabmode: false,
                                            hasActiveTicket: true,
                                          )
                                        : FindCab(
                                            model: model,
                                            hasActiveTicket: true,
                                          );
                                  },
                                ),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'ticketDetail',
                              child: Row(
                                children: <Widget>[
                                  widget.model.hasActiveRides
                                      ? Icon(Icons.check_circle_outline,
                                          color: kGreenColor)
                                      : Icon(Icons.not_interested,
                                          color: kRedDarkColor),
                                  SizedBox(width: 8.0),
                                  Text(
                                      widget.model.hasActiveRides
                                          ? 'View Active Ticket'
                                          : 'No Active Ride',
                                      style: smallBoldTextStyle()),
                                ],
                              ),
                            ),
                          ],
                        ),
                        widget.model.hasActiveRides
                            ? Positioned(
                                top: 10.0,
                                right: 10.0,
                                child: Container(
                                  padding: EdgeInsets.all(0.5),
                                  height: 15.0,
                                  width: 15.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kGreenColor,
                                      border: Border.all(color: kSurfaceColor)),
                                ),
                              )
                            : SizedBox(width: 0.1),
                      ],
                    )
                  ],
          ),
          body: model.isLoading
              ? SafeArea(child: Loading())
              : SafeArea(
                  child: model.driver == null
                      ? _buildUserTrips(model)
                      : _buildDriverTrips(model),
                ),
        );
      },
    );
  }

  Widget _buildUserTrips(MainModel model) {
    return model.getRides.length > 0
        ? ListView.builder(
            itemCount: model.getRides.length,
            itemBuilder: (BuildContext context, int index) {
              return ListCard(null, null, model.getRides[index], false);
            },
          )
        : _buildEmptyBody();
  }

  Widget _buildDriverTrips(MainModel model) {
    return model.getRides.length > 0
        ? ListView.builder(
            itemCount: model.getRides.length,
            itemBuilder: (BuildContext context, int index) {
              return ListCard(null, null, model.getRides[index], true);
            },
          )
        : _buildEmptyBody();
  }

  Widget _buildEmptyBody() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/norides.png'), fit: BoxFit.cover),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
            ),
          ),
          SizedBox(height: 50.0),
          Text('Oho ! You have no ride history.', style: hugeTextStyle())
        ],
      ),
    );
  }
}
