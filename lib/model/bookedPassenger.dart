import 'package:flutter/material.dart';

//@Booked Passenger --> Contains data for a passenger when displayed to driver.
class BookedPassenger {
  final String id;
  final String name;
  final String image;
  final String phone;
  final double travelFare;
  final double compFare;
  final String pAddress;
  final double pLat;
  final double pLng;
  final String dAddress;
  final double dLat;
  final double dLng;
  final String ticketId;
  final int otp;
  String status;
  int pCount;

  BookedPassenger({
    @required this.id,
    @required this.name,
    @required this.image,
    @required this.phone,
    @required this.travelFare,
    @required this.compFare,
    @required this.pAddress,
    @required this.pLat,
    @required this.pLng,
    @required this.dAddress,
    @required this.dLat,
    @required this.dLng,
    @required this.pCount,
    @required this.status,
    this.ticketId,
    this.otp,
  });
}
