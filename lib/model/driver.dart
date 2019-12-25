import 'package:flutter/material.dart';

//@Driver model -- contains all the data associated to driver.
class Driver {
  final String id;
  final String email;
  final String phone;
  final String image;
  final String username;
  final String licenseNo;
  final String vehicleNo;
  final String imagePath;
  final double rating;
  final int votes;
  String status;

  Driver({
    @required this.id,
    @required this.email,
    @required this.phone,
    @required this.image,
    @required this.username,
    @required this.licenseNo,
    @required this.vehicleNo,
    @required this.status,
    @required this.rating,
    @required this.votes,
    this.imagePath,
  });
}
