import 'package:flutter/material.dart';

class SavedTicket {
  final String id;
  final String pickAddress;
  final String dropAddress;
  final String passengerId;
  final String passengerName;
  final String vehicleModel;
  final String vehicleReg;
  final String driverId;
  final double compPrice;
  final double price;
  final String status;
  final String date;

  SavedTicket({
    @required this.id,
    @required this.pickAddress,
    @required this.dropAddress,
    @required this.passengerId,
    @required this.passengerName,
    @required this.vehicleModel,
    @required this.vehicleReg,
    @required this.driverId,
    @required this.compPrice,
    @required this.price,
    @required this.status,
    @required this.date,
  });
}
