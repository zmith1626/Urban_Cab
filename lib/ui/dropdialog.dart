import 'package:expange/model/bookedPassenger.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/utils/materialbutton.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class DropDialog extends StatefulWidget {
  final MainModel model;
  final Function dropFunction;
  final Function setSelectionFunction;

  DropDialog(this.model, this.dropFunction, this.setSelectionFunction);

  @override
  _DropDialog createState() => _DropDialog();
}

class _DropDialog extends State<DropDialog> {
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String selectedPassenger;

  @override
  void initState() {
    widget.model.updateLocation();
    _dropDownMenuItems = buildDropDownMenuItems(widget.model.passengerList);
    selectedPassenger = (widget.model.passengerList.length > 0)
        ? widget.model.passengerList[0].id
        : 'NULL_VALUE';
    super.initState();
  }

  onDropdownItemChange(String selectedValue) {
    setState(() {
      selectedPassenger = selectedValue;
      widget.setSelectionFunction(passengerId: selectedValue);
    });
  }

  List<DropdownMenuItem<String>> buildDropDownMenuItems(List passengerList) {
    List<DropdownMenuItem<String>> items = List();
    for (BookedPassenger passenger in passengerList) {
      items.add(
        DropdownMenuItem(
          value: passenger.id,
          child: Text(passenger.name, style: labelTextStyle()),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    double _cardHeight = 202.0;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Select Passenger', style: smallBoldTextStyle()),
            leading: Icon(Icons.person),
          ),
          SizedBox(height: _cardHeight / 24),
          DropdownButton(
            value: selectedPassenger,
            items: _dropDownMenuItems,
            onChanged: onDropdownItemChange,
          ),
          SizedBox(height: 10.0),
          MaterialedButton(Icons.refresh, 'Refresh Seat', widget.dropFunction),
        ],
      ),
    );
  }
}
