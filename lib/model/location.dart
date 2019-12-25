import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

//@Location model --> Contains data associated to a location input.
class Location {
  final String address;
  final GeoFirePoint location;

  Location({@required this.address, @required this.location});
}
