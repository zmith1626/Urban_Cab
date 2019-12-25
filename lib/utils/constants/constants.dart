enum userType { DRIVER, PASSENGER }

const String statusBooked = "BOOKED";
const String statusPicked = "PICKED";
const String statusDroped = "DROPED";
const String statusCancelled = "CANCELLED";
const String privateVehicle = "PRIVATE";
const String publicVehicle = "PUBLIC";
const String pick = "Pick Loction";
const String drop = "Drop Location";

String get getCurrentDate {
  DateTime date = DateTime.now();
  String currentDate = (date.day.toString() +
      '-' +
      date.month.toString() +
      '-' +
      date.year.toString());
  return currentDate;
}
