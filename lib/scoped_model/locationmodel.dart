import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expange/model/location.dart';
import 'package:expange/model/privateVehicle.dart';
import 'package:expange/model/ticket.dart';
import 'package:expange/scoped_model/commonmodel.dart';
import 'package:expange/utils/constants/constants.dart';
import 'package:expange/utils/constants/resources.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

mixin LocationModel on CommonModel {
  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;
  StreamSubscription documentSubs;
  PrivateVehicle pvtVehicle;

  List<LatLng> stepPoints = [];

  bool _isFetching = false;
  String apiKey = "";

  bool get isFetching {
    return _isFetching;
  }

  //@API function to get the API KEY for the google services used within the application.
  void fetchApiKey() async {
    final Map<String, dynamic> data = {"API_KEY": "API_KEY"};
    try {
      final http.Response response = await http.post(
        ResourcesUri().getApiKeyUri,
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        this.apiKey = decodedResponse['API_KEY']['apiKey'];
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Fetch Api Key", "error": e.toString()});
    }
  }

  void initializeJourneyPoints() {
    pickupLocation = null;
    dropLocation = null;
    stepPoints = [];
  }

  //This function is called to save the dues when a ticket is cancelled.
  void saveDues(double totalFare) async {
    double savedDues = 0;
    final double currentDues = 0.3 * totalFare;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    double dues = preferences.getDouble('dues');
    if (dues != null) {
      savedDues = dues;
    }
    final double dueAmount = savedDues + currentDues;
    preferences.setDouble('dues', dueAmount);
  }

  //This function is called to clear the active dues of a user.
  void clearDues() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('dues')) {
      preferences.remove('dues');
    }
    return;
  }

  //This function is called to get the pickup location details of a user based on the places Id obtained through google places API.
  void getPickLocationDetails(String placeId) async {
    final String url = ResourcesUri().getPlacesApiLink(placeId) + this.apiKey;
    final http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      var address = decodedResponse['results'][0]['formatted_address'];
      var lat = decodedResponse['results'][0]['geometry']['location']['lat'];
      var lng = decodedResponse['results'][0]['geometry']['location']['lng'];
      if (pickupLocation == null) {
        pickupLocation = Location(
          address: address,
          location: geo.point(latitude: lat, longitude: lng),
        );
      } else {
        dropLocation = Location(
          address: address,
          location: geo.point(latitude: lat, longitude: lng),
        );
      }
    } else {
      return;
    }
    if (pickupLocation != null && dropLocation != null) {
      getListLatLng();
    } else {
      return;
    }
  }

  //This function is called to retrieve the detailed address of a user based the geo-coordinates.
  Future<void> getAddressDetails(double lat, double lng) async {
    final String url =
        ResourcesUri().getLatLngApiLink(lat.toString(), lng.toString()) +
            this.apiKey;
    try {
      final http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        var address = decodedResponse['results'][0]['formatted_address'];
        var lat = decodedResponse['results'][0]['geometry']['location']['lat'];
        var lng = decodedResponse['results'][0]['geometry']['location']['lng'];

        pickupLocation = Location(
          address: address,
          location: geo.point(latitude: lat, longitude: lng),
        );
      } else {
        return;
      }
    } on SocketException catch (_) {
      return;
    }
  }

  //This function is called to get the distance and LatLng points between two given coordinates.
  void getListLatLng() async {
    _isFetching = true;
    this.stepPoints = [];
    notifyListeners();
    final url = "https://maps.googleapis.com/maps/api/directions/json?" +
        "origin=" +
        pickupLocation.location.latitude.toString() +
        "," +
        pickupLocation.location.longitude.toString() +
        "&destination=" +
        dropLocation.location.latitude.toString() +
        "," +
        dropLocation.location.longitude.toString() +
        "&key=${this.apiKey}";
    final http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);

      travelInfo.distance =
          decodedResponse['routes'][0]['legs'][0]['distance']['text'];
      travelInfo.time =
          decodedResponse['routes'][0]['legs'][0]['duration']['text'];
      travelInfo.noSeats = 1;

      List<dynamic> points = decodedResponse['routes'][0]['legs'][0]['steps'];
      for (final point in points) {
        PolylinePoints points = PolylinePoints();
        List<PointLatLng> latLngPoints =
            points.decodePolyline(point['polyline']['points']);
        for (int i = 0; i < latLngPoints.length; i++) {
          LatLng latLng =
              LatLng(latLngPoints[i].latitude, latLngPoints[i].longitude);
          stepPoints.add(latLng);
        }
      }
    } else {
      _isFetching = false;
      notifyListeners();
      return;
    }
    _isFetching = false;
    notifyListeners();
  }

  //This function is called by a passenger to cancel booking.
  Future<Map<String, dynamic>> cancelPublicBooking(String vehicleId) async {
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Booking Cancelled"
    };

    final userID = passenger.id;
    final Map<String, dynamic> cancMap = {"vehicle": vehicleId};

    try {
      final http.Response response = await http.put(
        ResourcesUri().getPublicCancelBookingUri,
        body: json.encode(cancMap),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );

      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      } else {
        travelInfo.bookStatus = statusCancelled;
      }
      _isFetching = false;
      notifyListeners();
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Cancel Public Booking", "error": e.toString()});
      _isFetching = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong"};
    }
    return result;
  }

  //@Function -- to fetch all the nearby vehicles and book ticket based on the nearest location.
  void processPrivateBooking(String vModel) async {
    travelInfo.bookStatus = null;
    ticket = null;
    message = null;
    _isFetching = true;
    notifyListeners();
    var phone = passenger.phone;
    phone = phone.substring(3, 13);
    travelInfo.travelFare = travelFare(vModel, travelInfo.distance);

    final String userID = passenger.id;
    final Map<String, dynamic> bookingData = {
      "name": passenger.username,
      "phone": phone,
      "photo": passenger.image,
      "price": travelInfo.travelFare,
      "compPrice": passenger.duesAmount,
      "pickPosition": {
        "address": pickupLocation.address,
        "latitude": pickupLocation.location.latitude,
        "longitude": pickupLocation.location.longitude
      },
      "dropPosition": {
        "address": dropLocation.address,
        "latitude": dropLocation.location.latitude,
        "longitude": dropLocation.location.longitude
      }
    };

    var reference = _firestore.collection('PrivateVehicles');
    GeoFirePoint center = geo.point(
      latitude: pickupLocation.location.latitude,
      longitude: pickupLocation.location.longitude,
    );

    final List<PrivateVehicle> vehicleList = [];
    Stream<List<DocumentSnapshot>> documentStream =
        geo.collection(collectionRef: reference).within(
              center: center,
              radius: 5.0,
              field: 'Position',
            );
    documentSubs = documentStream.listen(
      (List<DocumentSnapshot> data) async {
        data.forEach((doc) {
          String model = doc.data['Model'];
          double distance = doc.data['distance'];
          String status = doc.data['status'];
          String id = doc.documentID;
          pvtVehicle = PrivateVehicle(id: id, model: model, distance: distance);
          if (vModel == model && status == "AVAILABLE") {
            vehicleList.add(pvtVehicle);
          }
        });
        if (vehicleList.length > 1) {
          vehicleList.sort((a, b) => a.distance.compareTo(b.distance));
        }

        bookingData.putIfAbsent('date', () => getCurrentDate);
        if (vehicleList.length > 0) {
          if (vehicleList.length == 1) {
            bookingData.putIfAbsent('vehicle1', () => vehicleList[0].id);
            bookingData.putIfAbsent('vehicle2', () => "NA");
            bookingData.putIfAbsent('vehicle3', () => "NA");
          } else if (vehicleList.length == 2) {
            bookingData.putIfAbsent('vehicle1', () => vehicleList[0].id);
            bookingData.putIfAbsent('vehicle2', () => vehicleList[1].id);
            bookingData.putIfAbsent('vehicle3', () => "NA");
          } else {
            bookingData.putIfAbsent('vehicle1', () => vehicleList[0].id);
            bookingData.putIfAbsent('vehicle2', () => vehicleList[1].id);
            bookingData.putIfAbsent('vehicle3', () => vehicleList[2].id);
          }
          try {
            final http.Response response = await http.post(
              ResourcesUri().getPrivateBookingUri,
              body: json.encode(bookingData),
              headers: {
                'Content-Type': 'application/json',
                HttpHeaders.authorizationHeader: 'Bearer $userID'
              },
            );

            if (response.statusCode == 200) {
              travelInfo.bookStatus = "Finding Cab For You, Please Wait";
              _cancelSubscription();
            } else {
              travelInfo.bookStatus =
                  "Oops! Request Timed Out, Please try again.";
            }
          } catch (e) {
            _firestore.collection('Errors').add(
                {"function": "Process Private Booking", "error": e.toString()});
          }
          _isFetching = false;
          notifyListeners();
        } else {
          travelInfo.bookStatus = "Oops! No Available Vehicles";
          _isFetching = false;
          notifyListeners();
        }
      },
    );
  }

  void _cancelSubscription() {
    documentSubs.cancel();
  }

  //@Function -- to save the ticket data to permanent storage.
  void saveTicketData(String travelMode) async {
    if (ticket == null) {
      return;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String, dynamic> ticketData = {
      "otp": ticket.otp,
      "id": ticket.ticketId,
      "driverId": ticket.driverId,
      "driverName": ticket.driverName,
      "driverEmail": ticket.driverEmail,
      "driverImage": ticket.driverImage,
      "driverPhone": ticket.driverPhone,
      "driverLicense": ticket.driverLicense,
      "driverRating": ticket.driverRating,
      "driverVehicle": ticket.vehicleReg,
      "vehicleModel": ticket.vehicleModel,
      "vehicleLat": ticket.vehiclePos.latitude,
      "vehicleLng": ticket.vehiclePos.longitude,
      "vehicleTime": ticket.vehicleTime,
      "userAddress": ticket.pickup,
      "dropAddress": ticket.drop,
      "userLat": ticket.userPos.latitude,
      "userLng": ticket.userPos.longitude,
      "travelFare": ticket.travelFare,
      "travelDistance": ticket.travelDistance,
      "pCount": ticket.passCount,
      "pendingDues": ticket.pendingDues,
    };
    String ticketJSON = json.encode(ticketData).toString();
    preferences.setString('ticket', ticketJSON);
    preferences.setString('travelMode', travelMode);
  }

  //@Function -- to retrive the ticket data from permanent storage to temporary storage.
  void fetchTicketData() async {
    _isFetching = true;
    notifyListeners();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String ticketString = preferences.getString('ticket');
    var decodedTicket = json.decode(ticketString);
    ticket = Ticket(
      otp: decodedTicket['otp'],
      ticketId: decodedTicket['id'],
      driverId: decodedTicket['driverId'],
      driverName: decodedTicket['driverName'],
      driverImage: decodedTicket['driverImage'],
      driverEmail: decodedTicket['driverEmail'],
      driverPhone: decodedTicket['driverPhone'],
      driverLicense: decodedTicket['driverLicense'],
      driverRating: decodedTicket['driverRating'],
      vehicleReg: decodedTicket['driverVehicle'],
      vehicleModel: decodedTicket['vehicleModel'],
      vehicleTime: decodedTicket['vehicleTime'],
      travelDistance: decodedTicket['travelDistance'],
      travelFare: decodedTicket['travelFare'],
      passCount: decodedTicket['pCount'],
      pendingDues: decodedTicket['pendingDues'],
      vehiclePos:
          LatLng(decodedTicket['vehicleLat'], decodedTicket['vehicleLng']),
      pickup: decodedTicket['userAddress'],
      drop: decodedTicket['dropAddress'],
      userPos: LatLng(decodedTicket['userLat'], decodedTicket['userLng']),
    );
    _isFetching = false;
    notifyListeners();
  }

  //@Function -- to check if user has any active rides/undergoing rides.
  void checkActiveRides() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('ticket')) {
      hasActiveRides = true;
    }

    if (privateVehicle == preferences.getString('travelMode'))
      travelInfo.travelMode = privateVehicle;
    else
      travelInfo.travelMode = publicVehicle;
    notifyListeners();
  }
}
