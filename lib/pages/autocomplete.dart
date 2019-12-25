import 'package:expange/colors.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/google_places_autocomplete.dart';
import 'package:flutter/material.dart';

class AutoCompleteDisplay extends StatefulWidget {
  final TextEditingController controller;
  final MainModel model;
  final String hintText;

  AutoCompleteDisplay(this.controller, this.model, this.hintText);

  @override
  _AutoCompleteDisplay createState() => _AutoCompleteDisplay();
}

class _AutoCompleteDisplay extends State<AutoCompleteDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBlackColor,
        child: Icon(Icons.arrow_back),
        onPressed: () => _navigateBack(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            GooglePlacesAutocompleteWidget(
              apiKey: widget.model.apiKey,
              hint: widget.hintText,
              query: widget.controller,
              placesId: _getPlacesId,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  void _getPlacesId(String placesId) {
    widget.model.getPickLocationDetails(placesId);
  }
}
