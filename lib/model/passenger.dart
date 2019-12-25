import 'package:flutter/material.dart';

//@Passenger model --> Contains data associated to a user as a passenger.
class Passenger {
  final String id;
  final String email;
  final String phone;
  final String image;
  final String username;
  final String imagePath;
  final bool isemailVerified;
  final double duesAmount;

  Passenger({
    this.imagePath,
    @required this.id,
    @required this.email,
    @required this.phone,
    @required this.image,
    @required this.username,
    @required this.duesAmount,
    @required this.isemailVerified,
  });
}
