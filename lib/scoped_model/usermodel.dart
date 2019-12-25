import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expange/model/bookedPassenger.dart';
import 'package:expange/model/driver.dart';
import 'package:expange/model/passenger.dart';
import 'package:expange/model/savedTicket.dart';
import 'package:expange/model/ticket.dart';
import 'package:expange/scoped_model/commonmodel.dart';
import 'package:expange/utils/constants/constants.dart';
import 'package:expange/utils/constants/resources.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

mixin UserModel on CommonModel {
  //@Package imports --
  final FirebaseMessaging _messaging = FirebaseMessaging();
  final Firestore _firestore = Firestore.instance;
  final Location _location = new Location();
  final Geoflutterfire _geoFire = Geoflutterfire();
  //@Locally defined variables --
  List<BookedPassenger> _passengerList = [];
  List<SavedTicket> _allTrips = [];
  bool _userAuthenticated = false;
  bool _isPassenger = false;
  bool _isPrivateVehicle = false;
  bool _isLoading = false;
  bool viewFullDetails = true;

  LatLng _vehicleLatLng;
  Timer _locationService;
  StreamSubscription _locationSubscription;

  bool get isUserAuthenticated {
    return _userAuthenticated;
  }

  bool get isPassenger {
    return _isPassenger;
  }

  bool get isPrivateVehicle {
    return _isPrivateVehicle;
  }

  List<BookedPassenger> get passengerList {
    return List.from(_passengerList);
  }

  List<SavedTicket> get getRides {
    return List.from(_allTrips);
  }

  void setPrivateVehicle() {
    _isPrivateVehicle = true;
    notifyListeners();
  }

  bool get isLoading {
    return _isLoading;
  }

  bool get isAvailable {
    if (driver.status == "UNAVAILABLE") {
      return false;
    }
    return true;
  }

  void removeBoundCustomer(String id) {
    this.boundCustomer = null;
    if (id != null) {
      _passengerList.removeWhere((passenger) => passenger.id == id);
    }
    notifyListeners();
  }

  //This route is called to update the location of the vehicle in real time.
  void updateLocation() async {
    var position = await _location.getLocation();
    this._vehicleLatLng = LatLng(position.latitude, position.longitude);
    _locationSubscription =
        _location.onLocationChanged().listen((LocationData position) {
      this._vehicleLatLng = LatLng(position.latitude, position.longitude);
    });
    _locationService = new Timer.periodic(
      Duration(seconds: 30),
      (Timer timer) async {
        GeoFirePoint location = _geoFire.point(
            latitude: _vehicleLatLng.latitude,
            longitude: _vehicleLatLng.longitude);
        if (isPrivateVehicle) {
          _firestore
              .collection('PrivateVehicles')
              .document(driver.vehicleNo)
              .updateData({"Position": location.data});
        } else {
          _firestore
              .collection('Vehicles')
              .document(driver.vehicleNo)
              .updateData({"Position": location.data});
        }
      },
    );
  }

  void stopLocationUpdate() {
    if (_locationService != null) {
      _locationService.cancel();
    }

    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
  }

  //@Function to check the authentication of current user
  dynamic checkUserAuthDetails() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString('userId') != null &&
        (preferences.getString('idToken') != null ||
            preferences.getString('phone') != null)) {
      _userAuthenticated = true;
      if (preferences.containsKey('phone')) {
        _isPassenger = true;
      }
      if (preferences.getString('vehicleType') == 'PRIVATE') {
        _isPrivateVehicle = true;
      }
      notifyListeners();
    }
  }

  //@Function -- Clears auth data stored locally and signs out a user.
  void signOutUser() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('phone')) {
      preferences.remove('userId');
      preferences.remove('phone');
      FirebaseAuth.instance.signOut();
    } else {
      preferences.remove('idToken');
      preferences.remove('userId');
      preferences.remove('refreshToken');
    }

    _userAuthenticated = false;
    notifyListeners();
  }

  //@Function to Log In a user using Email and Password.
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      String email, String password, String apiKey) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> result;
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final String url = ResourcesUri().getSignInUri;
    final http.Response response = await http.post(
      url,
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},
    );
    var decodedResponse = json.decode(response.body);
    if (decodedResponse.containsKey('error')) {
      var errorMessage = decodedResponse['error']['message'];
      result = {"status": "ERROR", "message": errorMessage};
    } else {
      result = {"status": "OK", "message": "Success"};
      //@Function -- saves user data to the internal phone memory.
      _saveUserData(
        decodedResponse['localId'],
        decodedResponse['idToken'],
        decodedResponse['refreshToken'],
      );
    }
    _isLoading = false;
    notifyListeners();
    return result;
  }

  //@Function to send Password reset link to a registered email address.
  Future<Map<String, dynamic>> sendPasswordResetLink(
      String email, String apiKey) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> result = {
      'status': "OK",
      "message": "Success! Reset Link Sent."
    };
    final Map<String, dynamic> resetDetails = {
      'requestType': 'PASSWORD_RESET',
      'email': email
    };

    final String url = ResourcesUri().getPwdRsetLink;
    final http.Response response = await http.post(
      url,
      body: json.encode(resetDetails),
      headers: {'Content-Type': 'application/json'},
    );
    var decodedResponse = json.decode(response.body);
    _isLoading = false;
    notifyListeners();
    if (decodedResponse.containsKey('error')) {
      result = {
        "status": "ERROR",
        "message": decodedResponse['error']['message']
      };
    }

    return result;
  }

  //@Function -- to save the auth data of currently logged in user in phone memory.
  void savePassengerData(String userId, String phone) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('userId', userId);
    preferences.setString('phone', phone);
  }

  //@Function -- to save the user data of currently logged in-user in phone memory.
  void _saveUserData(String userId, String idToken, String refreshToken) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('userId', userId);
    preferences.setString('idToken', idToken);
    preferences.setString('refreshToken', refreshToken);
  }

  //This function is called to save the fcm token data of the currently used device
  void _saveFcmToken(String id) {
    _messaging.getToken().then(
      (String token) {
        _firestore
            .collection('fcmTokens')
            .document(id)
            .setData({"fcmToken": token});
      },
    );
  }

  //@Function -- to get the rides of currently signed in user.
  void userRides() async {
    _allTrips = [];
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> postData = {"RIDE_USER": "RIDE_USER"};
    final http.Response response = await http.post(
      ResourcesUri().getUserRidesUri,
      body: json.encode(postData),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${passenger.id}',
        'Content-Type': 'application/json'
      },
    );
    _isLoading = false;
    notifyListeners();
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      var tripData = decodedResponse['tripData'];
      for (final trip in tripData) {
        if (trip['data']['assignedVehicle'] != null) {
          try {
            SavedTicket ticket = SavedTicket(
              id: trip['id'],
              pickAddress: trip['data']['pickup']['address'],
              dropAddress: trip['data']['drop']['address'],
              passengerId: trip['data']['passengerId'],
              passengerName: trip['data']['passengerName'],
              vehicleModel: trip['data']['assignedVehicle']['model'],
              vehicleReg: trip['data']['assignedVehicle']['registration'],
              driverId: trip['data']['assignedVehicle']['driver'],
              compPrice: trip['data']['compPrice'].toDouble(),
              price: trip['data']['price'].toDouble(),
              status: trip['data']['status'],
              date: trip['data']['date'],
            );
            _allTrips.add(ticket);
          } catch (e) {
            _firestore
                .collection('Errors')
                .add({"function": "Get User Rides", "error": e.toString()});
          }
        }
      }

      if (_allTrips.length > 1) {
        _allTrips.sort((a, b) => a.date.compareTo(b.date));
      }
    }
  }

  //@Function -- to retrieve the rides of a currently logged in user.
  void driverRides() async {
    _allTrips = [];
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> postData = {"RIDE_DRIVER": "RIDE_DRIVER"};
    final http.Response response = await http.post(
      ResourcesUri().getDriverRidesUri,
      body: json.encode(postData),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${driver.id}',
        'Content-Type': 'application/json'
      },
    );
    _isLoading = false;
    notifyListeners();
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      var tripData = decodedResponse['tripData'];
      for (final trip in tripData) {
        try {
          SavedTicket savedTicket = SavedTicket(
            id: trip['id'],
            pickAddress: trip['data']['pickup']['address'],
            dropAddress: trip['data']['drop']['address'],
            passengerId: trip['data']['passengerId'],
            passengerName: trip['data']['passengerName'],
            vehicleModel: trip['data']['assignedVehicle']['model'],
            vehicleReg: trip['data']['assignedVehicle']['registration'],
            driverId: trip['data']['assignedVehicle']['driver'],
            compPrice: trip['data']['compPrice'].toDouble(),
            price: trip['data']['price'].toDouble(),
            status: trip['data']['status'],
            date: trip['data']['date'],
          );
          _allTrips.add(savedTicket);
        } catch (e) {
          _firestore
              .collection('Errors')
              .add({"function": "Get Driver Rides", "error": e.toString()});
        }
      }

      if (_allTrips.length > 1) {
        _allTrips.sort((a, b) => a.date.compareTo(b.date));
      }
    }
  }

  //@function to retrieve the profile data of currently logged in user.
  void fetchUserDetails({bool initLoad}) async {
    double duesAmount = 0;
    if (initLoad) {
      _isLoading = true;
      notifyListeners();
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    double dues = preferences.getDouble('dues');
    if (dues != null) {
      duesAmount = dues;
    }
    var id = preferences.getString('userId');
    if (initLoad) {
      _saveFcmToken(id);
    }

    try {
      final http.Response response = await http.get(
        ResourcesUri().getUserDetails,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $id'},
      );
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        String unformattedName = decodedResponse['data']['displayName'];
        String email = decodedResponse['data']['email'];
        String phone = decodedResponse['data']['phoneNumber'];
        String image = decodedResponse['data']['photoURL'];
        String username = (unformattedName.contains('Bearer '))
            ? unformattedName.split('Bearer ')[0]
            : unformattedName;
        String imagePath = (unformattedName.contains('Bearer '))
            ? unformattedName.split('Bearer ')[1]
            : null;
        passenger = Passenger(
          id: id,
          email: email,
          phone: phone,
          username: username,
          image: image != null ? image : ResourcesUri().getDefaultImageUri,
          isemailVerified: decodedResponse['data']['emailVerified'],
          imagePath: imagePath,
          duesAmount: duesAmount,
        );
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } on SocketException catch (_) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  //@function to retrieve the driver profile of currently logged In driver.
  void fetchDriverDetails({bool initLoad}) async {
    if (initLoad) {
      _isLoading = true;
      notifyListeners();
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String driverDetailsUrl = ResourcesUri().getDriverDetails +
        (_isPrivateVehicle ? "/PRIVATE" : "/PUBLIC");
    var id = preferences.getString('userId');

    try {
      final http.Response response = await http.get(
        driverDetailsUrl,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $id'},
      );
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        String username = decodedResponse['data']['firstName'] +
            ' ' +
            decodedResponse['data']['lastName'];
        String email = decodedResponse['data']['email'];
        String phone = decodedResponse['data']['phone'];
        String image = decodedResponse['data']['photo'];
        String license = decodedResponse['data']['license'];
        String vehicle = decodedResponse['data']['vehicle'];
        String imagePath = decodedResponse['data']['imagePath'];
        double rating = decodedResponse['data']['rating'].toDouble();
        int votes = decodedResponse['data']['votes'];
        String status = decodedResponse['status'][0].toString();
        driver = Driver(
          id: id,
          username: username,
          email: email,
          phone: phone,
          image: image != null ? image : ResourcesUri().getDefaultImageUri,
          licenseNo: license,
          vehicleNo: vehicle,
          imagePath: imagePath,
          status: status,
          rating: rating,
          votes: votes,
        );

        if (initLoad) {
          _saveFcmToken(driver.vehicleNo);
          fetchPassengerList(driver.vehicleNo);
        } else {
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } on SocketException catch (_) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  //This function is called to set the messages received through push notification.
  void setMessages(Map<String, dynamic> message) async {
    if (message['data']['title'] == "NEW_RIDE_REQUEST") {
      _setBoundCustomer(message);
    } else if (message['data']['title'] == "RIDE_REQUEST_STATUS") {
      _setAssignedTicket(message);
    } else if (message['data']['data'] == "NEW_BOOKING") {
      fetchPassengerList(this.driver.vehicleNo);
    } else if (message['data']['title'] == "RIDE_CANCELLED") {
      _removeAssignedItems(false);
    } else if (message['data']['title'] == "RIDE_COMPLETED") {
      _removeAssignedItems(true);
    } else if (message['data']['title'] == "PICKUP_CONFIRMED") {
      viewFullDetails = false;
    }

    notifyListeners();
  }

  //Sets the customer for a currently logged in driver.
  void _setBoundCustomer(Map<String, dynamic> message) {
    boundCustomer = BookedPassenger(
      id: message['data']['userId'],
      name: message['data']['user'],
      image: message['data']['photo'],
      phone: message['data']['contact'],
      travelFare: double.parse(message['data']['price']),
      compFare: double.parse(message['data']['compPrice']),
      pCount: 1,
      pLat: double.parse(message['data']['pickLat']),
      pLng: double.parse(message['data']['pickLng']),
      pAddress: message['data']['pick'],
      dLat: double.parse(message['data']['dropLat']),
      dLng: double.parse(message['data']['dropLng']),
      dAddress: message['data']['drop'],
      ticketId: message['data']['orderId'],
      status: statusBooked,
    );
    notifyListeners();
  }

  //Sets the ticket for a currently booked Cab.
  void _setAssignedTicket(Map<String, dynamic> message) {
    ticket = null;
    if (message['data']['message'] != null) {
      this.message = message;
    } else {
      clearDues();
      ticket = Ticket(
        otp: int.parse(message['data']['otp']),
        ticketId: message['data']['ticketID'],
        driverId: message['data']['driverId'],
        driverName: message['data']['driverFname'] +
            ' ' +
            message['data']['driverLname'],
        driverImage: message['data']['photo'] == null
            ? ResourcesUri().getDefaultImageUri
            : message['data']['photo'],
        driverEmail: message['data']['email'],
        driverPhone: message['data']['phone'],
        driverRating: message['data']['driverRating'],
        driverLicense: message['data']['license'],
        vehicleReg: message['data']['registration'],
        vehicleModel: message['data']['model'],
        vehicleTime: 'NA',
        travelDistance: travelInfo.distance,
        travelFare: travelInfo.travelFare,
        pendingDues: passenger.duesAmount,
        pickup: pickupLocation.address,
        drop: dropLocation.address,
        passCount: 1,
        vehiclePos: LatLng(double.parse(message['data']['latitude']),
            double.parse(message['data']['longitude'])),
        userPos: LatLng(pickupLocation.location.latitude,
            pickupLocation.location.longitude),
      );
      travelInfo.bookStatus = statusBooked;
    }
    notifyListeners();
  }

  //Remove the ticket details when journey is completed.
  void _removeAssignedItems(bool rideCompleted) {
    travelInfo.bookStatus = statusCancelled;
    if (rideCompleted) {
      travelInfo.bookStatus = statusDroped;
    }
    boundCustomer = null;
    if (passenger != null) {
      removeTicket();
    }
    notifyListeners();
  }

  //This function clears any previously saved dues.
  void clearDues() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('dues')) {
      preferences.remove('dues');
    }
    return;
  }

  //This function is called to retrieve the list of passengers for a currently logged in driver.
  Future<void> fetchPassengerList(String idVehicle) async {
    _passengerList = [];
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> vehicleData = {"vehicle": this.driver.vehicleNo};

    return http.post(ResourcesUri().getPassengersUri,
        body: json.encode(vehicleData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${this.driver.id}'
        }).then((http.Response response) {
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        var passengers = decodedResponse['data'];
        if (passengers == null) {
          _isLoading = false;
          notifyListeners();
          return;
        }
        passengers.forEach((passenger) {
          if (passenger is Map<String, dynamic>) {
            try {
              final BookedPassenger _passenger = BookedPassenger(
                id: passenger['passengerID'],
                name: passenger['passengerName'],
                image: passenger['photo'],
                phone: passenger['contact'],
                travelFare: passenger['price'].toDouble(),
                compFare: passenger['compPrice'].toDouble(),
                pAddress: passenger['pickup']['address'],
                pLat: passenger['pickup']['latitude'],
                pLng: passenger['pickup']['longitude'],
                dAddress: passenger['drop']['address'],
                dLat: passenger['drop']['latitude'],
                dLng: passenger['drop']['longitude'],
                status: statusBooked,
                pCount: 0,
                otp: passenger['OTP'],
              );

              if (_passengerList.length > 0) {
                int objCount = 0;
                for (int i = 0; i < _passengerList.length; i++) {
                  if (_passengerList[i].id == _passenger.id) {
                    _passengerList[i].pCount = _passengerList[i].pCount + 1;
                    objCount = objCount + 1;
                  }
                }
                if (objCount == 0) {
                  _passengerList.add(_passenger);
                }
              } else {
                _passengerList.add(_passenger);
              }
            } catch (e) {
              _firestore.collection('Errors').add(
                  {"function": "Fetch Passenger List", "error": e.toString()});
            }
          }
        });
        _isLoading = false;
        notifyListeners();
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  //This function is called to enter the OTP of a selected passenger.
  Future<Map<String, dynamic>> confirmPublicPickup(
      Map<String, dynamic> otpData, String userID) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Pickup Confirmed."
    };
    try {
      final http.Response response = await http.put(
          ResourcesUri().confirmPublicPickupUri,
          body: json.encode(otpData),
          headers: {
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $userID'
          });
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      } else {
        int index = _passengerList.indexWhere(
            (passenger) => (passenger.otp == int.parse(otpData['OTP'])));
        _passengerList[index].status = statusPicked;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Public Pickup Function", "error": e.toString()});
      _isLoading = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function is called to enter the OTP of a passenger in private vehicle mode.
  Future<Map<String, dynamic>> confirmPrivatePickup(
      Map<String, dynamic> otpData, String userID) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Pickup Confirmed"
    };
    try {
      final http.Response response = await http.put(
          ResourcesUri().confirmPrivatePickupUri,
          body: json.encode(otpData),
          headers: {
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $userID'
          });
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      } else {
        this.boundCustomer.status = statusPicked;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Confirm Private Pickup", "error": e.toString()});
      _isLoading = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function is called to refresh the status of the seat when a passenger is dropped.
  Future<Map<String, dynamic>> refreshSeat(
      Map<String, dynamic> userData, String userID) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Seat Refreshed"
    };
    try {
      final http.Response response = await http.put(
        ResourcesUri().refreshSeatUri,
        body: json.encode(userData),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userID'
        },
      );
      _isLoading = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      } else {
        int index = _passengerList
            .indexWhere((passenger) => passenger.id == userData['passengerID']);
        result = {"status": "OK", "id": index};
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Refresh Seat Status", "error": e.toString()});
      _isLoading = false;
      notifyListeners();
      print(e);
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function id called to cancel the booking of a cab in private mode.
  Future<Map<String, dynamic>> cancelPrivateBooking(
      Map<String, dynamic> cancelMap, String userID) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Booking Cancelled. "
    };

    try {
      final http.Response response = await http.put(
        ResourcesUri().cancelPrivateBookingUri,
        body: json.encode(cancelMap),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $userID',
          'Content-Type': 'application/json'
        },
      );
      _isLoading = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      } else {
        travelInfo.bookStatus = statusCancelled;
      }
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Cancel Private Booking", "error": e.toString()});
      _isLoading = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //This function is called to refresh the status of the vehicle when ride is completed in private mode.
  Future<Map<String, dynamic>> dropPassenger(
      Map<String, dynamic> data, String userID) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> result = {
      "status": "OK",
      "message": "Success! Drop Confirmed"
    };
    try {
      final http.Response response = await http.put(
        ResourcesUri().refreshPrivateVehicleUri,
        body: json.encode(data),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $userID',
          'Content-Type': 'application/json',
        },
      );
      _isLoading = false;
      notifyListeners();
      if (response.statusCode != 200) {
        var decodedResponse = json.decode(response.body);
        result = {"status": "ERROR", "message": decodedResponse['message']};
      }
    } catch (e) {
      _firestore.collection('Errors').add({
        "function": "Refresh Private vehicle status",
        "error": e.toString()
      });
      _isLoading = false;
      notifyListeners();
      result = {"status": "ERROR", "message": "Oops! Something went wrong."};
    }

    return result;
  }

  //@Function is called to rate driver after completion of the ride
  void rateDriver(int expRate, int bevRate, int timeRate) async {
    try {
      final Map<String, dynamic> rateModel = {
        "driverID": ticket.driverId,
        "ride": expRate + 1,
        "behaviour": bevRate + 1,
        "time": timeRate + 1
      };
      ticket = null;
      notifyListeners();

      final http.Response response = await http.post(
        ResourcesUri().rateDriverRouteUri,
        body: json.encode(rateModel),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${passenger.id}',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        return;
      }
      return;
    } catch (e) {
      _firestore
          .collection('Errors')
          .add({"function": "Rate Driver", "error": e.toString()});
    }
  }
}
