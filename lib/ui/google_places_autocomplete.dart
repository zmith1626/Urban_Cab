library flutter_google_places_autocomplete.src;

import 'dart:async';
import 'dart:io';
import 'package:expange/colors.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class GooglePlacesAutocompleteWidget extends StatefulWidget {
  final String apiKey;
  final String hint;
  final Location location;
  final num offset;
  final num radius;
  final String language;
  final List<String> types;
  final List<Component> components;
  final bool strictbounds;
  final Function placesId;
  final TextEditingController query;
  final ValueChanged<PlacesAutocompleteResponse> onError;

  GooglePlacesAutocompleteWidget({
    @required this.apiKey,
    this.hint,
    this.offset,
    this.location,
    this.radius,
    this.language,
    this.types,
    this.components,
    this.strictbounds,
    this.placesId,
    this.onError,
    this.query,
    Key key,
  }) : super(key: key);

  @override
  State<GooglePlacesAutocompleteWidget> createState() {
    return _GooglePlacesAutocompleteOverlayState();
  }

  static GooglePlacesAutocompleteState of(BuildContext context) =>
      context.ancestorStateOfType(
        const TypeMatcher<GooglePlacesAutocompleteState>(),
      );
}

class _GooglePlacesAutocompleteOverlayState
    extends GooglePlacesAutocompleteState {
  final FocusNode queryFocusNode = FocusNode();
  bool isLocationSelected = false;

  void _setSelection() {
    setState(() {
      isLocationSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final header = _textField();
    var body;

    if (widget.query.text.isEmpty ||
        response == null ||
        response.predictions.isEmpty) {
      body = Material(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(2.0),
          bottomRight: Radius.circular(2.0),
        ),
      );
    } else {
      body = SingleChildScrollView(
        child: Material(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(2.0),
            bottomRight: Radius.circular(2.0),
          ),
          color: Colors.white,
          child: isLocationSelected
              ? SizedBox(height: 0.1)
              : ListBody(
                  children: response.predictions
                      .map(
                        (p) => PredictionTile(
                          prediction: p,
                          onTap: (Prediction p) {
                            setState(
                              () {
                                widget.query.text = p.description;
                                queryFocusNode.unfocus();
                                isLocationSelected = true;
                                widget.placesId(p.placeId);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
        ),
      );
    }

    final container = Container(
      child: Stack(
        children: <Widget>[
          header,
          Padding(padding: EdgeInsets.only(top: 48.0), child: body),
        ],
      ),
    );

    if (Platform.isIOS) {
      return Padding(padding: EdgeInsets.only(top: 8.0), child: container);
    }
    return container;
  }

  Widget _textField() => TextField(
        onTap: _setSelection,
        controller: widget.query,
        focusNode: queryFocusNode,
        autofocus: true,
        style: labelTextStyle(),
        decoration: InputDecoration(
          labelText: widget.hint,
          filled: true,
          fillColor: kSurfaceColor,
          labelStyle: labelTextStyle(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onChanged: search,
      );
}

class GooglePlacesAutocompleteResult extends StatefulWidget {
  final ValueChanged<Prediction> onTap;

  GooglePlacesAutocompleteResult({this.onTap});

  @override
  _GooglePlacesAutocompleteResult createState() =>
      _GooglePlacesAutocompleteResult();
}

class _GooglePlacesAutocompleteResult
    extends State<GooglePlacesAutocompleteResult> {
  @override
  Widget build(BuildContext context) {
    final state = GooglePlacesAutocompleteWidget.of(context);
    assert(state != null);

    if (state.widget.query.text.isEmpty ||
        state.response == null ||
        state.response.predictions.isEmpty) {
      final children = <Widget>[];

      return Stack(children: children);
    }
    return PredictionsListView(
      predictions: state.response.predictions,
      onTap: widget.onTap,
    );
  }
}

class PredictionsListView extends StatelessWidget {
  final List<Prediction> predictions;
  final ValueChanged<Prediction> onTap;

  PredictionsListView({@required this.predictions, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: predictions
          .map((Prediction p) => PredictionTile(prediction: p, onTap: onTap))
          .toList(),
    );
  }
}

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final ValueChanged<Prediction> onTap;

  PredictionTile({@required this.prediction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset('assets/pin_one.png', width: 24.0, height: 24.0),
      title: Text(prediction.description, style: labelTextStyle()),
      subtitle: Divider(),
      onTap: () {
        if (onTap != null) {
          onTap(prediction);
        }
      },
    );
  }
}

Future<Prediction> showGooglePlacesAutocomplete(
    {@required BuildContext context,
    @required String apiKey,
    String hint = "Search",
    num offset,
    Location location,
    num radius,
    String language,
    List<String> types,
    List<Component> components,
    bool strictbounds,
    ValueChanged<PlacesAutocompleteResponse> onError}) {
  final builder = (BuildContext ctx) => GooglePlacesAutocompleteWidget(
        apiKey: apiKey,
        language: language,
        components: components,
        types: types,
        location: location,
        radius: radius,
        strictbounds: strictbounds,
        offset: offset,
        hint: hint,
        onError: onError,
      );

  return showDialog(context: context, builder: builder);
}

abstract class GooglePlacesAutocompleteState
    extends State<GooglePlacesAutocompleteWidget> {
  TextEditingController query;
  PlacesAutocompleteResponse response;
  GoogleMapsPlaces _places;
  bool searching;

  @override
  void initState() {
    super.initState();
    query = TextEditingController(text: "");
    _places = GoogleMapsPlaces(apiKey: widget.apiKey);
    searching = false;
  }

  Future<Null> doSearch(String value) async {
    if (mounted && value.isNotEmpty) {
      setState(() {
        searching = true;
      });

      try {
        final res = await _places.autocomplete(value,
            offset: widget.offset,
            location: widget.location,
            radius: widget.radius,
            language: widget.language,
            types: widget.types,
            components: widget.components,
            strictbounds: widget.strictbounds);

        if (res.errorMessage?.isNotEmpty == true ||
            res.status == "REQUEST_DENIED") {
          onResponseError(res);
        } else {
          onResponse(res);
        }
      } on SocketException catch (_) {
        onResponse(null);
      }
    } else {
      onResponse(null);
    }
  }

  Timer _timer;

  Future<Null> search(String value) async {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () {
      _timer.cancel();
      doSearch(value);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _places.dispose();
    super.dispose();
  }

  @mustCallSuper
  void onResponseError(PlacesAutocompleteResponse res) {
    if (mounted) {
      if (widget.onError != null) {
        widget.onError(res);
      }
      setState(() {
        response = null;
        searching = false;
      });
    }
  }

  @mustCallSuper
  void onResponse(PlacesAutocompleteResponse res) {
    if (mounted) {
      setState(() {
        response = res;
        searching = false;
      });
    }
  }
}
