import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expange/model/bookedPassenger.dart';
import 'package:expange/model/driver.dart';
import 'package:expange/model/location.dart';
import 'package:expange/model/passenger.dart';
import 'package:expange/model/ticket.dart';
import 'package:expange/model/travelInfo.dart';
import 'package:expange/model/vehicle.dart';
import 'package:expange/utils/constants/constants.dart';
import 'package:expange/utils/constants/resources.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

mixin CommonModel on Model {
  //@Drivers --
  Driver driver;
  //@Vehicles --
  Vehicle selectedVehicle;
  //@Passengers --
  Passenger passenger;
  BookedPassenger boundCustomer;
  //@Locations --
  Location pickupLocation;
  Location dropLocation;
  //@Tickets --
  Ticket ticket;
  //@Travel -- data associated to travel
  TravelInfo travelInfo = TravelInfo();
  //@Locally defined variables --
  bool _isRequesting = false;
  bool hasActiveRides = false;
  Map<String, dynamic> message;
  List<Vehicle> _availableVehicles = [];
  //@Firestore import --
  Firestore _firestore = Firestore.instance;

  bool get isRequesting {
    return _isRequesting;
  }

  List<Vehicle> get availableVehicles {
    return List.from(_availableVehicles);
  }

  //This function is called to get the fare of the vehicle for a selected mode of travel.
  double travelFare(String vehicle, dynamic distance) {
    var formattedDistance = distance.toString().split(' ')[0];
    var eDistance = formattedDistance.split(',').join();
    if (vehicle == "PRIVATE") {
      vehicle = 'L';
    }
    double formattedPrice;
    double minFare = 60.00;
    switch (vehicle) {
      case publicVehicle:
        {
          formattedPrice = double.parse(eDistance) * 2;
          formattedPrice = num.parse(formattedPrice.toStringAsFixed(2));
          formattedPrice = formattedPrice > minFare ? formattedPrice : minFare;
        }
        break;
      case 'Auto':
        {
          formattedPrice = double.parse(eDistance) * 10;
          formattedPrice = num.parse(formattedPrice.toStringAsFixed(2));
          formattedPrice = formattedPrice > minFare ? formattedPrice : minFare;
        }
        break;
      case 'L':
        {
          formattedPrice = double.parse(eDistance) * 12;
          formattedPrice = num.parse(formattedPrice.toStringAsFixed(2));
          formattedPrice = formattedPrice > minFare ? formattedPrice : minFare;
        }
        break;
      case 'XL':
        {
          formattedPrice = double.parse(eDistance) * 15;
          formattedPrice = num.parse(formattedPrice.toStringAsFixed(2));
          formattedPrice = formattedPrice > minFare ? formattedPrice : minFare;
        }
        break;
      case 'XXL':
        {
          formattedPrice = double.parse(eDistance) * 18;
          formattedPrice = num.parse(formattedPrice.toStringAsFixed(2));
          formattedPrice = formattedPrice > minFare ? formattedPrice : minFare;
        }
        break;
    }
    return formattedPrice;
  }

  //@Function -- to get the list of available cabs between two selected location in public mode.
  void getAvailableCabs() async {
    _availableVehicles = [];
    _isRequesting = true;
    notifyListeners();
    final Map<String, dynamic> stationData = {
      "source": pickupLocation.address,
      "destination": dropLocation.address
    };
    final http.Response response = await http.post(
      ResourcesUri().getVehiclesUri,
      body: json.encode(stationData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      var vehicleList = decodedResponse['data'];
      try {
        for (final vehicle in vehicleList) {
          var stops = vehicle['vehicleData']['currentStops'];
          List<String> stopList = [];
          stops.forEach((auto) {
            stopList.add(auto.toString().toLowerCase());
          });
          final Vehicle formVehicle = Vehicle(
            id: vehicle['docID'],
            model: vehicle['vehicleData']['model'],
            currentTime: vehicle['vehicleData']['currentTime'],
            registration: vehicle['vehicleData']['registration'],
            seatCapacity: vehicle['vehicleData']['seatCapacity'].toString(),
            driverPrimary: vehicle['vehicleData']['driver'],
            stops: stopList,
            occupiedSeats: vehicle['vehicleData']['passenger'].length,
            currentStatus: vehicle['vehicleData']['currentStatus'],
            latitude: vehicle['vehicleData']['Position']['geopoint']
                ['_latitude'],
            longitude: vehicle['vehicleData']['Position']['geopoint']
                ['_longitude'],
          );
          _availableVehicles.add(formVehicle);
        }
      } catch (e) {
        _firestore
            .collection('Errors')
            .add({"function": "Get Available Vehicles", "error": e.toString()});
      }
      _isRequesting = false;
      notifyListeners();
    } else {
      _isRequesting = false;
      notifyListeners();
    }
  }

  //@Function -- to book public vehicle.
  Future<Map<String, dynamic>> bookSeat() async {
    _isRequesting = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Booking Confirmed"
    };

    var phone = passenger.phone;
    phone = phone.substring(3, 13);
    travelInfo.travelFare =
        (travelInfo.noSeats * travelFare(publicVehicle, travelInfo.distance));

    final String userID = passenger.id;
    final Map<String, dynamic> bookData = {
      "name": passenger.username,
      "phone": phone,
      "photo": passenger.image,
      "pickPosition": {
        "address": pickupLocation.address,
        "latitude": pickupLocation.location.latitude,
        "longitude": pickupLocation.location.longitude
      },
      "dropPosition": {
        "address": dropLocation.address,
        "latitude": dropLocation.location.latitude,
        "longitude": dropLocation.location.longitude
      },
      "price": travelInfo.travelFare,
      "compPrice": passenger.duesAmount,
      "vehicle": selectedVehicle.id,
      "count": travelInfo.noSeats,
    };
    bookData.putIfAbsent('date', () => getCurrentDate);

    try {
      final http.Response response = await http.post(
        ResourcesUri().getBookSeatUri,
        body: json.encode(bookData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );

      if (response.statusCode != 201) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      } else {
        travelInfo.bookStatus = statusBooked;
      }
      _isRequesting = false;
      notifyListeners();
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Book Seat", "error": e.toString()});
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
      _isRequesting = false;
      notifyListeners();
    }
    return result;
  }

  //@Function --to fetch booking details of a current Ticket in public mode.
  void fetchBookingDetails() async {
    _isRequesting = true;
    notifyListeners();
    final Map<String, dynamic> vehicleData = {"vehicle": selectedVehicle.id};
    try {
      final http.Response response = await http.post(
        ResourcesUri().getTicketsUri,
        body: json.encode(vehicleData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${passenger.id}'
        },
      );
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        travelInfo.otp = decodedResponse['ticketData']['OTP'];
        ticket = Ticket(
          otp: decodedResponse['ticketData']['OTP'],
          ticketId: 'NA',
          driverId: decodedResponse['ticketData']['driverData']['id'],
          driverName: decodedResponse['ticketData']['driverData']['fName'] +
              ' ' +
              decodedResponse['ticketData']['driverData']['lName'],
          driverImage:
              decodedResponse['ticketData']['driverData']['photo'] == ""
                  ? ResourcesUri().getDefaultImageUri
                  : decodedResponse['ticketData']['driverData']['photo'],
          driverEmail: decodedResponse['ticketData']['driverData']['email'],
          driverPhone: decodedResponse['ticketData']['driverData']['phone'],
          driverRating:
              decodedResponse['ticketData']['driverData']['rating'].toDouble(),
          driverLicense: decodedResponse['ticketData']['driverData']['license'],
          vehicleReg: decodedResponse['ticketData']['driverData']['vehicle'],
          vehicleModel: selectedVehicle.model,
          travelDistance: travelInfo.distance,
          travelFare: travelInfo.travelFare,
          pendingDues: passenger.duesAmount,
          pickup: pickupLocation.address,
          drop: dropLocation.address,
          passCount: travelInfo.noSeats,
          vehicleTime: selectedVehicle.currentTime,
          vehiclePos:
              LatLng(selectedVehicle.latitude, selectedVehicle.longitude),
          userPos: LatLng(pickupLocation.location.latitude,
              pickupLocation.location.longitude),
        );
      }
      _isRequesting = false;
      notifyListeners();
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Fetch Booking Details", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      return null;
    }
  }

  //This function is called update the driver response status when a user requests a ride.
  Future<Map<String, dynamic>> updatePrivateBookStatus(
      Map<String, dynamic> statusData, String userID) async {
    _isRequesting = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Request Accepted"
    };
    try {
      final http.Response response = await http.put(
        ResourcesUri().getPrivateStatusUpdateUri,
        body: json.encode(statusData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isRequesting = false;
      notifyListeners();
      print(response.body);
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Private Status Update", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }
    return result;
  }

  //This function is called to update the status of vehicle from "AVAILABLE" TO "STARTED".
  void startJourney() async {
    try {
      final Map<String, dynamic> statusData = {
        "vehicle": driver.vehicleNo,
        "status": "STARTED"
      };
      final http.Response response = await http.post(
          ResourcesUri().startJourneyUri,
          body: json.encode(statusData),
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ${driver.id}',
            'Content-Type': 'application/json'
          });

      if (response.statusCode == 200) {
        return;
      }

      return;
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Start Journey", "error": e.toString()});
    }
  }

  //This function is called to update the vehicle status "AVAILABILITY TO UNAVAILABILITY AND VICE VERSA".
  Future<Map<String, dynamic>> updatePublicVehicleStatus(
      Map<String, dynamic> statusData, String userID) async {
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Vehicle Status Updated."
    };
    try {
      _isRequesting = true;
      notifyListeners();
      final http.Response response = await http.put(
        ResourcesUri().publicVehicleStatusUpdate,
        body: json.encode(statusData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isRequesting = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Public Vehicle Status", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }
    return result;
  }

  //This function is called to update the availability of the vehicle.
  Future<Map<String, dynamic>> updatePrivateVehicleStatus(
      Map<String, dynamic> statusData, String userID) async {
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Vehicle Status Updated."
    };
    try {
      _isRequesting = true;
      notifyListeners();
      final http.Response response = await http.put(
        ResourcesUri().privateVehicleStatusUpdate,
        body: json.encode(statusData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isRequesting = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore.collection('Errors').add(
          {"function": "Update Private Vehicle Status", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function is called to set the next journey time and reverse the station points.
  Future<Map<String, dynamic>> setPublicVehicleTimer(
      Map<String, dynamic> vehicleData, String userID) async {
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Status Refreshed."
    };
    try {
      _isRequesting = true;
      notifyListeners();
      final http.Response response = await http.put(
        ResourcesUri().publicVehicleTimerUri,
        body: json.encode(vehicleData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isRequesting = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Set Public Vehicle Timer", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function is called to initialize the journey points and start time of a vehicle in public mode.
  Future<Map<String, dynamic>> resetPublicVehicle(
      Map<String, dynamic> vehicleData, String userID) async {
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Vehicle Status Reset."
    };
    try {
      _isRequesting = true;
      notifyListeners();
      final http.Response response = await http.put(
        ResourcesUri().publicVehicleResetUri,
        body: json.encode(vehicleData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isRequesting = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Reset Public Vehicle", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function is called to reset the password for a currently signed in driver.
  Future<Map<String, dynamic>> resetPassword(String password) async {
    _isRequesting = true;
    notifyListeners();
    final Map<String, dynamic> pwdMap = {"password": password};
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Password Reset Successful."
    };
    try {
      final http.Response response = await http.post(
        ResourcesUri().pwdRsetLink,
        body: json.encode(pwdMap),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${driver.id}',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
      _isRequesting = false;
      notifyListeners();
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Reset Password", "error": e.toString()});
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
      _isRequesting = false;
      notifyListeners();
    }

    return result;
  }

  //This function is called to update/upload a new image for a currently logged in user/driver.
  Future<Map<String, dynamic>> _uploadImage(File imageFile, String userID,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(imageFile.path).split('/');
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(ResourcesUri().uploadImageUri));
    final file = await http.MultipartFile.fromPath(
      'imageFile',
      imageFile.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    );

    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }

    imageUploadRequest.headers['Authorization'] = 'Bearer $userID';
    try {
      final http.StreamedResponse streamedResponse =
          await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      var responseData = json.decode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        return {"status": "ERROR", "message": responseData['message']};
      }
      return responseData;
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Upload Image", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      return {"status": "ERROR", "message": "Oops! Something went Wrong"};
    }
  }

  //This function updates the data in the database.
  Future<Map<String, dynamic>> updateProfile(
      File imageFile,
      Map<String, dynamic> profileData,
      String userID,
      int indicator,
      String imagePath,
      String imageUrl) async {
    _isRequesting = true;
    notifyListeners();
    String imgPath = imagePath;
    String imgUrl = imageUrl;
    if (imageFile != null) {
      final Map<String, dynamic> uploadResponse =
          await _uploadImage(imageFile, userID, imagePath: imagePath);

      if (uploadResponse != null) {
        imgPath = uploadResponse['imagePath'];
        imgUrl = uploadResponse['imageUrl'];
      }
    }

    profileData.putIfAbsent('photo', () => imgUrl);
    profileData.putIfAbsent('photoPath', () => imgPath);

    Map<String, dynamic> response;
    if (indicator == 0) {
      response = await _updateDriverProfile(profileData, userID);
    } else {
      response = await _updateUserProfile(profileData, userID);
    }
    return response;
  }

  //This function is called to save the user data in the database.
  Future<Map<String, dynamic>> _updateUserProfile(
      Map<String, dynamic> profileData, String userID) async {
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Profile Updated."
    };
    try {
      final http.Response response = await http.post(
        ResourcesUri().userProfileUpdateUri,
        body: json.encode(profileData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isRequesting = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "User Profile Update", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function is called to save the driver data in the database.
  Future<Map<String, dynamic>> _updateDriverProfile(
      Map<String, dynamic> profileData, String userID) async {
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Profile Updated."
    };
    try {
      final http.Response response = await http.post(
        ResourcesUri().driverProfileUpdateUri,
        body: json.encode(profileData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isRequesting = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Driver Profile Update", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function is called to send a email verification link to the registered users email.
  Future<Map<String, dynamic>> verifyEmail(
      Map<String, dynamic> email, String userID) async {
    _isRequesting = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Email Verification Link Sent."
    };
    try {
      final http.Response response = await http.post(
        ResourcesUri().getVerifyEmailUri,
        body: json.encode(email),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isRequesting = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Verify Email", "error": e.toString()});
      _isRequesting = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }
    return result;
  }

  //@Function -- to remove the saved ticket data from device permanent storage.
  void removeTicket() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('ticket')) {
      preferences.remove('ticket');
    }
    hasActiveRides = false;
    notifyListeners();
  }
}
