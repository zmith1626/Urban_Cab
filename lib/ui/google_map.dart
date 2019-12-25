import 'dart:async';
import 'package:expange/model/bookedPassenger.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapDisplay extends StatefulWidget {
  final List<LatLng> positions;
  final List<BookedPassenger> passengerList;
  final BitmapDescriptor descriptor;
  final bool isFetchingDisplay;

  MapDisplay(
      {this.positions,
      this.passengerList,
      @required this.isFetchingDisplay,
      this.descriptor});

  @override
  _MapDisplay createState() => _MapDisplay();
}

class _MapDisplay extends State<MapDisplay> {
  StreamSubscription locationSubscription;
  LatLng userPosition;
  LatLng cameraTarget = LatLng(27.4728, 94.9120);
  bool _enableCompass = false;
  GoogleMapController _mapController;
  final Location location = Location();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Timer timer;

  @override
  void initState() {
    super.initState();
    if (widget.isFetchingDisplay) {
      _setSingleMarker();
    } else if (widget.positions != null && widget.positions.length > 0) {
      if (widget.positions.length == 1) {
        _setMarker();
      } else
        _setMarkers();
    } else if (widget.passengerList != null &&
        widget.passengerList.length > 0) {
      _setAllUserMarker();
    }
  }

  @override
  void didUpdateWidget(MapDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.positions != null) {
      if (widget.positions.length == 2) _setMarkers();
    }
  }

  @override
  void deactivate() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  void _setSingleMarker() {
    Marker singleMarker = Marker(
        markerId: MarkerId('singleMarker'),
        position: widget.positions[0],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        draggable: true);
    _markers.putIfAbsent(MarkerId('other'), () => singleMarker);
  }

  void _setMarker() async {
    _fetchUserLocation(userPos: widget.positions[0]);
    Marker otherMarker = Marker(
      markerId: MarkerId('other'),
      position: widget.positions[0],
      icon: BitmapDescriptor.defaultMarker,
      draggable: false,
    );

    _markers.putIfAbsent(MarkerId('other'), () => otherMarker);
  }

  void _setMarkers() {
    if (widget.positions.length == 2) {
      Marker initMarker = Marker(
        markerId: MarkerId('1'),
        position: widget.positions[0],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        draggable: false,
      );

      Marker lastMarker = Marker(
        markerId: MarkerId('2'),
        position: widget.positions[1],
        icon: widget.descriptor,
        draggable: false,
      );

      setState(() {
        _markers = <MarkerId, Marker>{};
        this.cameraTarget = widget.positions[0];
        if (_markers.containsKey('1')) {
          _markers.remove('1');
        }
        if (_markers.containsKey('2')) {
          _markers.remove('2');
        }
        _markers.putIfAbsent(MarkerId('1'), () => initMarker);
        _markers.putIfAbsent(MarkerId('2'), () => lastMarker);
      });
    }
    _animateCamera(widget.positions[0], widget.positions[1]);
  }

  void _fetchUserLocation({LatLng userPos}) async {
    var position = await location.getLocation();
    if (position != null) {
      setState(() {
        this.userPosition = LatLng(position.latitude, position.longitude);
        this._enableCompass = true;
        this.cameraTarget = this.userPosition;
      });
      if (userPos != null) {
        _animateCamera(userPosition, userPos);
      }
    }
    locationSubscription = location.onLocationChanged().listen(
      (LocationData position) {
        if (position != null) {
          setState(() {
            this.userPosition = LatLng(position.latitude, position.longitude);
            this.cameraTarget = this.userPosition;
          });
          if (userPos != null) {
            _animateCamera(userPosition, userPos);
          }
        }
      },
    );
  }

  void _setAllUserMarker() {
    _fetchUserLocation();
    for (int i = 0; i < widget.passengerList.length; i++) {
      Marker userPickMarker = Marker(
        markerId: MarkerId(i.toString() + 'Pick'),
        position:
            LatLng(widget.passengerList[i].pLat, widget.passengerList[i].pLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow:
            InfoWindow(title: widget.passengerList[i].name, snippet: 'Pickup'),
        draggable: true,
      );

      Marker userDropMarker = Marker(
        markerId: MarkerId(i.toString() + 'Drop'),
        position:
            LatLng(widget.passengerList[i].dLat, widget.passengerList[i].dLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: widget.passengerList[i].name, snippet: 'Drop'),
        draggable: true,
      );

      setState(() {
        if (_markers.containsKey(i.toString() + 'Pick')) {
          _markers.remove(i.toString() + 'Pick');
        }
        if (_markers.containsKey(i.toString() + 'Drop')) {
          _markers.remove(i.toString() + 'Drop');
        }
        _markers.putIfAbsent(
            MarkerId(i.toString() + 'Pick'), () => userPickMarker);
        _markers.putIfAbsent(
            MarkerId(i.toString() + 'Drop'), () => userDropMarker);
      });
    }
  }

  void _animate(LatLng first, LatLng second) {
    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
                first.latitude <= second.latitude
                    ? first.latitude
                    : second.latitude,
                first.longitude <= second.longitude
                    ? first.longitude
                    : second.longitude),
            northeast: LatLng(
                first.latitude <= second.latitude
                    ? second.latitude
                    : first.latitude,
                first.longitude <= second.longitude
                    ? second.longitude
                    : first.longitude),
          ),
          30.0,
        ),
      );
    }
  }

  void _animateCamera(LatLng first, LatLng second) {
    timer = Timer(
      Duration(seconds: 5),
      () => _animate(first, second),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        onMapCreated: _onMapCreate,
        initialCameraPosition:
            CameraPosition(target: this.cameraTarget, zoom: 16.0),
        compassEnabled: true,
        markers: Set<Marker>.of(_markers.values),
        mapType: MapType.normal,
        myLocationEnabled: _enableCompass,
      ),
    );
  }

  void _onMapCreate(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }
}
