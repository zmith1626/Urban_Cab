import 'package:flutter/material.dart';

//@Vehicle --> Contains data associated to a vehicle when operated as private.
class Vehicle {
  final String id;
  final String model;
  final String currentTime;
  final String registration;
  final String seatCapacity;
  final List<String> stops;
  final String driverPrimary;
  final int occupiedSeats;
  final String currentStatus;
  double latitude;
  double longitude;

  Vehicle({
    @required this.id,
    @required this.model,
    @required this.currentTime,
    @required this.registration,
    @required this.seatCapacity,
    @required this.stops,
    @required this.occupiedSeats,
    @required this.driverPrimary,
    @required this.currentStatus,
    @required this.latitude,
    @required this.longitude,
  });
}
