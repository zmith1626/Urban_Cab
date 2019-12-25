import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//@Ticket --> Contains detail of the ticket when booking confirmed.
class Ticket {
  final int otp; 
  final String ticketId;
  final String driverId; 
  final String driverName; 
  final String driverImage; 
  final String driverEmail; 
  final String driverPhone; 
  final double driverRating;
  final String driverLicense; 
  final String vehicleReg; 
  final String vehicleModel; 
  final String vehicleTime; 
  final String travelDistance;
  final double travelFare;
  final double pendingDues;
  final String pickup;
  final String drop;
  final int passCount;
  LatLng vehiclePos; //
  LatLng userPos;

  Ticket({
    @required this.otp,
    @required this.ticketId,
    @required this.driverId,
    @required this.driverName,
    @required this.driverImage,
    @required this.driverEmail,
    @required this.driverPhone,
    @required this.driverRating,
    @required this.driverLicense,
    @required this.vehicleReg,
    @required this.vehicleModel,
    @required this.travelDistance,
    @required this.travelFare,
    @required this.pendingDues,
    @required this.pickup,
    @required this.drop,
    @required this.passCount,
    @required this.vehicleTime,
    @required this.vehiclePos,
    @required this.userPos,
  });
}
