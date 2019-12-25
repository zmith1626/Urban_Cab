import 'package:expange/colors.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/utils/materialbutton.dart';
import 'package:expange/utils/ratebar.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class DriverRate extends StatefulWidget {
  final MainModel model;

  DriverRate(this.model);

  @override
  _DriverRate createState() => _DriverRate();
}

class _DriverRate extends State<DriverRate> {
  int rideRate = 0;
  int bevRate = 0;
  int timeRate = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: Icon(Icons.question_answer, size: 100.0)),
              SizedBox(height: 10.0),
              Text('Please Rate your experience', style: boldTextStyle()),
              SizedBox(height: 25.0),
              Text('How was your ride experience ?', style: hugeTextStyle()),
              SizedBox(height: 10.0),
              RateBar(
                rating: rideRate,
                onRatingChanged: (rideRate) =>
                    setState(() => this.rideRate = rideRate),
              ),
              SizedBox(height: 25.0),
              Text("How was your driver's behaviour ?", style: hugeTextStyle()),
              SizedBox(height: 10.0),
              RateBar(
                rating: bevRate,
                onRatingChanged: (bevRate) =>
                    setState(() => this.bevRate = bevRate),
              ),
              SizedBox(height: 25.0),
              Text('How punctual(Stringent to time) was your driver ?',
                  style: hugeTextStyle()),
              SizedBox(height: 10.0),
              RateBar(
                rating: timeRate,
                onRatingChanged: (timeRate) =>
                    setState(() => this.timeRate = timeRate),
              ),
              SizedBox(height: 50.0),
              Center(
                child: MaterialedButton(
                  Icons.done_all,
                  'Done',
                  () {
                    widget.model
                        .rateDriver(this.rideRate, this.bevRate, this.timeRate);
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
