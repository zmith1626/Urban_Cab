import 'package:expange/colors.dart';
import 'package:flutter/material.dart';

//Error TextStyle
TextStyle errorTextStyle() {
  return TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    fontSize: 10.0,
    color: kErrorColor,
  );
}

TextStyle labelTextStyle() {
  return TextStyle(color: kBlackColor, fontFamily: 'Ubuntu');
}

TextStyle redLabelTextStyle() {
  return TextStyle(color: kRedDarkColor, fontFamily: 'Ubuntu');
}

TextStyle hugeTextStyle() {
  return TextStyle(color: kBlackColor, fontFamily: 'Ubuntu', fontSize: 18.0);
}

TextStyle boldTextStyle() {
  return TextStyle(
    color: kBlackColor,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'Ubuntu',
  );
}

TextStyle redBoldTextStyle() {
  return TextStyle(
    color: kRedDarkColor,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'Ubuntu',
  );
}

TextStyle whiteBoldTextStyle() {
  return TextStyle(
    color: kSurfaceColor,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'Ubuntu',
  );
}

TextStyle smallBoldTextStyle() {
  return TextStyle(
    color: kBlackColor,
    fontWeight: FontWeight.bold,
    fontFamily: 'Ubuntu',
  );
}

TextStyle smallBoldWhiteTextStyle() {
  return TextStyle(
    color: kSurfaceColor,
    fontWeight: FontWeight.bold,
    fontFamily: 'Ubuntu',
  );
}

TextStyle whiteTextStyle() {
  return TextStyle(color: Colors.white70, fontFamily: 'Ubuntu');
}
