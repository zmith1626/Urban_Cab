import 'package:flutter/material.dart';

//@Private Vehicle --> Contains data associated to a vehicle when operated as private.
class PrivateVehicle {
  final String id;
  final String model;
  final double distance;

  PrivateVehicle({
    @required this.id,
    @required this.model,
    @required this.distance,
  });
}
