import 'package:expange/colors.dart';
import 'package:expange/model/vehicle.dart';
import 'package:expange/pages/findcab.dart';
import 'package:expange/pages/ticket.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:expange/ui/inputdialog.dart';
import 'package:expange/ui/passengerdialog.dart';
import 'package:expange/ui/snackbardisplay.dart';
import 'package:expange/utils/loading.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class DetailPage extends StatefulWidget {
  final MainModel model;
  final bool privateMode;

  DetailPage(this.model, this.privateMode);

  @override
  _DetailPage createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> availableModels = ['Auto', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    if (!widget.privateMode) {
      widget.model.getAvailableCabs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: kSurfaceColor,
          appBar: AppBar(
            backgroundColor: kRedColor,
            title: Text('Select Vehicle', style: smallBoldWhiteTextStyle()),
          ),
          body: model.isRequesting
              ? Loading()
              : widget.privateMode
                  ? SafeArea(
                      child: ListView.builder(
                        itemCount: availableModels.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildCabCard(availableModels[index]);
                        },
                      ),
                    )
                  : SafeArea(
                      child: (model.availableVehicles.length > 0)
                          ? ListView.builder(
                              itemCount: model.availableVehicles.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildAutoCard(
                                    model.availableVehicles[index]);
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/bustand.jpg',
                                    width: 300.0,
                                  ),
                                  SizedBox(height: 10.0),
                                  Text('Oops!', style: boldTextStyle()),
                                  SizedBox(height: 5.0),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Text(
                                      'Our Service is not available in your selected location.',
                                      style: labelTextStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
        );
      },
    );
  }

  Widget _buildAutoCard(Vehicle vehicle) {
    return Container(
      decoration: BoxDecoration(
        color: kGreyColor,
        border: Border.all(),
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black, blurRadius: 10.0, offset: Offset(5.0, 8.0))
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Container(
        child: _buildListTile(vehicle),
      ),
    );
  }

  Widget _buildCabCard(String model) {
    return GestureDetector(
      onTap: () => _processPrivateBooking(context, model),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0))
          ],
          color: kGreyColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildLeading(model),
            SizedBox(width: 30.0),
            _buildSideContainer(model),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
      ),
    );
  }

  Widget _buildSideContainer(String model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
        color: kGreyColor,
      ),
      width: 200.0,
      child: _buildCabListTile(model),
    );
  }

  Widget _buildLeading(String model) {
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      padding: EdgeInsets.all(5.0),
      child: Center(child: _fetchIcon(model)),
      height: 100,
      width: 100,
    );
  }

  Widget _buildCabListTile(String model) {
    return ListTile(
      title: Text(model == 'Auto' ? model : 'Cab ' + model,
          style: smallBoldTextStyle()),
      subtitle: Text('₹ ' + _totalFare(model).toString(),
          style: TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w700)),
      trailing: Icon(Icons.arrow_right, size: 36.0),
    );
  }

  double _totalFare(String model) {
    double fare =
        widget.model.travelFare(model, widget.model.travelInfo.distance);
    double totalFare = fare + widget.model.passenger.duesAmount;
    double formattedFare = num.parse(totalFare.toStringAsFixed(2));
    return formattedFare;
  }

  void _processPrivateBooking(BuildContext context, String model) async {
    widget.model.processPrivateBooking(model);
    Navigator.of(context).push(
      CustomRoute(
        builder: (BuildContext context) {
          return FindCab(
            model: widget.model,
            hasActiveTicket: false,
            totalFare: _totalFare(model),
          );
        },
      ),
    );
  }

  Widget _fetchIcon(String model) {
    Widget icon;
    switch (model) {
      case 'Auto':
        {
          icon = Image.asset('assets/auto.png');
        }
        break;
      case 'L':
        {
          icon = Image.asset('assets/automobile.png');
        }
        break;
      case 'XL':
        {
          icon = Image.asset('assets/suv.png');
        }
        break;
      case 'XXL':
        {
          icon = Image.asset('assets/tourist.png');
        }
    }
    return icon;
  }

  Widget _buildListTile(Vehicle vehicle) {
    final String seats =
        (int.parse(vehicle.seatCapacity) - vehicle.occupiedSeats).toString() +
            ' Seats Left';
    return ListTile(
      leading: Container(
        padding: EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1.0, color: kBlackColor),
          ),
        ),
        child: _buildLeadingWidget(vehicle.currentTime),
      ),
      title: Text(vehicle.model, style: smallBoldTextStyle()),
      subtitle: Wrap(
        children: <Widget>[
          Text(vehicle.registration, style: labelTextStyle()),
          SizedBox(width: 10.0),
          Icon(Icons.airline_seat_recline_extra, size: 18.0),
          Text(seats, style: labelTextStyle()),
        ],
      ),
      trailing: Icon(Icons.arrow_right, size: 20.0),
      onTap: () {
        double cardHeight = 202.0;
        int availSeats =
            int.parse(vehicle.seatCapacity) - vehicle.occupiedSeats;
        widget.model.selectedVehicle = vehicle;
        inputDialog(
            context,
            PassengerDialog(
              availSeats,
              () => _bookTickets(context),
              widget.model,
            ),
            cardHeight);
      },
    );
  }

  _bookTickets(BuildContext context) async {
    final Map<String, dynamic> response = await widget.model.bookSeat();
    if (response['status'] == "OK") {
      widget.model.clearDues();
      Navigator.of(context).push(
        CustomRoute(
          builder: (BuildContext context) {
            return TicketPage(
              model: widget.model,
              locateCabmode: false,
              hasActiveTicket: false,
            );
          },
        ),
      );
    } else {
      _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
      return;
    }
  }

  Widget _buildLeadingWidget(String rTime) {
    List<String> time = rTime.split(':');
    var cHour = (int.parse(time[0]) - 12) > 0
        ? (int.parse(time[0]) - 12)
        : int.parse(time[0]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(cHour.toString(), style: boldTextStyle()),
            Text(':' + time[1], style: labelTextStyle()),
          ],
        ),
        Text(fetchDayNight(rTime), style: smallBoldTextStyle()),
      ],
    );
  }

  String fetchDayNight(String rTime) {
    List<String> time = rTime.split(':');
    if ((int.parse(time[0]) - 12) > 0) {
      return 'PM';
    } else {
      return 'AM';
    }
  }
}
