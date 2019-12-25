class ResourcesUri {
  String get getSignInUri {
    return "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAESsHAClRR9XMkpjvxIaRZFSpPHGbkuk4";
  }

  String get getPwdRsetLink {
    return "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getOobConfirmationCode?key=AIzaSyAESsHAClRR9XMkpjvxIaRZFSpPHGbkuk4";
  }

  String get pwdRsetLink {
    return "https://expange.com/driver/resetPassword";
  }

  String get getDriverDetails {
    return "https://expange.com/driverDetails";
  }

  String get getUserDetails {
    return "https://expange.com/userDetails";
  }

  String getPlacesApiLink(String placesId) {
    return "https://maps.googleapis.com/maps/api/geocode/json?place_id=$placesId&key=";
  }

  String get getVehiclesUri {
    return "https://expange.com/getVehicles";
  }

  String get getTicketsUri {
    return "https://expange.com/public/ticketDetails";
  }

  String getLatLngApiLink(String lat, String lng) {
    return "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=";
  }

  String get getDefaultImageUri {
    return "https://firebasestorage.googleapis.com/v0/b/expange-f8d9d.appspot.com/o/assets%2Fuserlogo.png?alt=media&token=06b65e2b-1963-487d-80e5-6d6a87b8d4cb";
  }

  String get getBookSeatUri {
    return "https://expange.com/public/bookTicket";
  }

  String get getPublicCancelBookingUri {
    return "https://expange.com/public/cancelBooking";
  }

  String get getPrivateBookingUri {
    return "https://expange.com/private/bookTicket";
  }

  String get getPrivateStatusUpdateUri {
    return "https://expange.com/private/updateBookStatus";
  }

  String get getPassengersUri {
    return "https://expange.com/getPassengers";
  }

  String get getPrivateVehicleUri {
    return "https://expange.com/private/ticketDetails";
  }

  String get confirmPublicPickupUri {
    return "https://expange.com/public/confirmPickup";
  }

  String get confirmPrivatePickupUri {
    return "https://expange.com/private/confirmPickup";
  }

  String get refreshSeatUri {
    return "https://expange.com/refreshSeat";
  }

  String get privateVehicleStatusUpdate {
    return "https://expange.com/private/updateVehicleStatus";
  }

  String get publicVehicleStatusUpdate {
    return "https://expange.com/updateStatus";
  }

  String get publicVehicleTimerUri {
    return "https://expange.com/setTime";
  }

  String get publicVehicleResetUri {
    return "https://expange.com/reset";
  }

  String get userProfileUpdateUri {
    return "https://expange.com/update/userProfile";
  }

  String get driverProfileUpdateUri {
    return "https://expange.com/update/driverProfile";
  }

  String get uploadImageUri {
    return "https://us-central1-expange-f8d9d.cloudfunctions.net/storeImage";
  }

  String get cancelPrivateBookingUri {
    return "https://expange.com/private/cancelBooking";
  }

  String get refreshPrivateVehicleUri {
    return "https://expange.com/private/refreshStatus";
  }

  String get getUserRidesUri {
    return "https://expange.com/user/rides";
  }

  String get getDriverRidesUri {
    return "https://expange.com/driver/rides";
  }

  String get getVerifyEmailUri {
    return "https://expange.com/verifyEmail";
  }

  String get getApiKeyUri {
    return "https://expange.com/getApiKey";
  }

  String get startJourneyUri {
    return "https://expange.com/update/VehicleStatus";
  }

  String get rateDriverRouteUri {
    return "https://expange.com/driver/rate";
  }
}
