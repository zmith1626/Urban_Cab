import 'package:expange/colors.dart';
import 'package:expange/pages/driver.dart';
import 'package:expange/pages/driverrate.dart';
import 'package:expange/pages/home.dart';
import 'package:expange/pages/login.dart';
import 'package:expange/pages/passengerlist.dart';
import 'package:expange/pages/privatedriver.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scoped_model/scoped_model.dart';

class Expange extends StatefulWidget {
  @override
  _Expange createState() => _Expange();
}

class _Expange extends State<Expange> {
  final MainModel _model = MainModel();
  final FirebaseMessaging _messaging = FirebaseMessaging();

  @override
  void initState() {
    _model.checkUserAuthDetails();
    _model.fetchApiKey();
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _model.setMessages(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        _model.setMessages(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _model.setMessages(message);
      },
    );
    super.initState();
  }

  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        title: 'Expange',
        theme: _cAppTheme,
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
          child: ScopedModelDescendant(
            builder: (BuildContext context, Widget child, MainModel model) {
              return model.isUserAuthenticated
                  ? (model.isPassenger
                      ? HomePage(model)
                      : (model.isPrivateVehicle)
                          ? PrivateDriver(model)
                          : DriverPage(model))
                  : Login(model);
            },
          ),
          onWillPop: () {
            dispose();
            return Future.value(true);
          },
        ),
        routes: {
          '/home': (context) => HomePage(_model),
          '/privateDriver': (context) => PrivateDriver(_model),
          '/passengerList': (context) =>
              PassengerList(model: _model, privateMode: false),
          '/rateDriver': (context) => DriverRate(_model),
        },
        onGenerateRoute: _getRoute,
      ),
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }
    return CustomRoute<void>(
      settings: settings,
      builder: (BuildContext context) => Login(_model),
    );
  }
}

final ThemeData _cAppTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    brightness: Brightness.dark,
    accentColor: kDarkBlackColor,
    primaryColor: kDarkRedColor,
    buttonTheme: base.buttonTheme.copyWith(
        buttonColor: kDarkRedColor, textTheme: ButtonTextTheme.normal),
    scaffoldBackgroundColor: kBackgroundColor,
    cardColor: kSurfaceColor,
    textSelectionColor: kBlackColor,
    errorColor: kErrorColor,
  );
}
