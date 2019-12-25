//@Travel Info --> Contains all the data associated to a journey.
class TravelInfo {
  int otp;
  int noSeats;
  String time;
  String distance;
  String travelMode;
  String bookStatus;
  double travelFare;

  TravelInfo({
    this.otp,
    this.noSeats,
    this.time,
    this.distance,
    this.travelMode,
    this.bookStatus,
    this.travelFare,
  });
}
