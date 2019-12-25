import 'dart:async';

import 'package:expange/colors.dart';
import 'package:expange/pages/driver.dart';
import 'package:expange/pages/privatedriver.dart';
import 'package:expange/pages/signup.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/custom_route.dart';
import 'package:expange/ui/inputdialog.dart';
import 'package:expange/ui/pininput.dart';
import 'package:expange/ui/snackbardisplay.dart';
import 'package:expange/utils/constants/constants.dart';
import 'package:expange/utils/constants/passwordfield.dart';
import 'package:expange/utils/materialbutton.dart';
import 'package:expange/utils/outlined.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  final MainModel model;

  Login(this.model);

  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailfocusNode = FocusNode();
  final FocusNode _pwdfocusNode = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double cardHeight = 202.0;
  bool _userScreen = true;

  String phoneNo;
  String smsCode;
  String verificationId;

  Timer _timer;
  int _start = 60;
  bool _isTextVisible = false;
  bool _processing = false;
  bool _resendOTP = false;
  bool _displayPhoneOption = true;

  void _startTimer() {
    const sec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      sec,
      (Timer timer) => setState(() {
        _isTextVisible = true;
        if (_start < 1) {
          _timer.cancel();
          _isTextVisible = false;
          _resendOTP = true;
        } else {
          _start = _start - 1;
        }
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _emailfocusNode.addListener(_updateDisplay);
    _pwdfocusNode.addListener(_updateDisplay);
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    _emailfocusNode.removeListener(_updateDisplay);
    _pwdfocusNode.removeListener(_updateDisplay);
    super.dispose();
  }

  void _updateDisplay() {
    setState(() {
      if (_emailfocusNode.hasFocus || _pwdfocusNode.hasFocus) {
        _displayPhoneOption = false;
      } else {
        _displayPhoneOption = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double topSpacing = MediaQuery.of(context).size.height / 4.0;
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          key: _scaffoldKey,
          body: _buildDisplay(context, model, topSpacing),
          floatingActionButton:
              _userScreen ? _buildFAB(model) : _buildSecondFab(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildSecondFab() {
    return _displayPhoneOption
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('Login with Phone', style: hugeTextStyle()),
                  ),
                  onTap: _changeScreenDisplay),
            ],
          )
        : SizedBox(width: 0.1);
  }

  Widget _buildFAB(MainModel model) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Text('Login with E-mail', style: hugeTextStyle()),
          onTap: _changeScreenDisplay,
        ),
        SizedBox(width: MediaQuery.of(context).size.width / 3),
        _processing
            ? FloatingActionButton(
                child: CupertinoActivityIndicator(radius: 14.0),
                onPressed: null,
                backgroundColor: kBlackColor,
              )
            : FloatingActionButton(
                heroTag: 'fab',
                backgroundColor: kBlackColor,
                child: Icon(Icons.arrow_forward),
                onPressed: () {
                  this.phoneNo = _emailPhoneController.text.trimRight();
                  if (this.phoneNo.length == 10) {
                    this.phoneNo = '+91' + this.phoneNo;
                    _startTimer();
                    verifyPhone();
                  }
                },
              ),
      ],
    );
  }

  Widget _buildDisplay(
      BuildContext context, MainModel model, double topSpacing) {
    if (_userScreen) {
      return _buildUserScreen(topSpacing);
    }
    return _buildDriverScreen(context, topSpacing);
  }

  void _changeScreenDisplay() {
    setState(() {
      _userScreen = !_userScreen;
    });
  }

  Widget _buildDriverScreen(BuildContext context, double topSpacing) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        color: kSurfaceColor,
        child: SafeArea(
          child: Form(
            key: _loginFormKey,
            child: ListView(
              padding: EdgeInsets.all(10.0),
              children: <Widget>[
                SizedBox(height: topSpacing),
                _buildHeader(Icons.mail_outline, 'E-mail Login'),
                SizedBox(height: 10.0),
                _buildEmailField(),
                SizedBox(height: 10.0),
                PasswordField(_passwordController, _pwdfocusNode),
                SizedBox(height: 10.0),
                _buildButtonBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserScreen(double topSpacing) {
    return Container(
      color: kSurfaceColor,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            SizedBox(height: topSpacing),
            _buildHeader(Icons.phone, 'Phone Login'),
            SizedBox(height: 10.0),
            _buildPhoneField(),
            SizedBox(height: 10.0),
            _isTextVisible
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                        'You will recieve an SMS within $_start seconds, enter the OTP for verification.',
                        style: labelTextStyle()),
                  )
                : (_resendOTP)
                    ? GestureDetector(
                        onTap: () {
                          this.phoneNo = _emailPhoneController.text.trimRight();
                          if (this.phoneNo.length == 10) {
                            this.phoneNo = '+91' + this.phoneNo;
                            verifyPhone();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Wrap(
                            children: <Widget>[
                              Text('Did you enter correct details ?',
                                  style: labelTextStyle()),
                              Text(
                                ' Resend OTP',
                                style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    color: kGreenColor,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(height: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(IconData icon, String text) {
    return Wrap(
      spacing: 10.0,
      children: <Widget>[
        Icon(icon),
        Text(text, style: smallBoldTextStyle()),
      ],
    );
  }

  Widget _buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          child: Text('Forgot Password', style: labelTextStyle()),
          onPressed: () =>
              inputDialog(context, _buildEmailInputDisplay(), cardHeight),
        ),
        _buildSignInbutton(),
      ],
    );
  }

  Widget _buildSignInbutton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? CupertinoActivityIndicator(radius: 10.0)
            : Hero(
                tag: 'fab',
                child: RaisedButton(
                  elevation: 8.0,
                  color: kBlackColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Text('Sign In', style: smallBoldWhiteTextStyle()),
                  onPressed: () async {
                    if (!_loginFormKey.currentState.validate()) return;
                    Map<String, dynamic> response =
                        await model.signInWithEmailAndPassword(
                      _emailPhoneController.text.trimRight(),
                      _passwordController.text,
                      model.apiKey,
                    );
                    if (response['status'] == 'OK') {
                      inputDialog(
                          context, _buildVehicleTypeDisplay(), cardHeight);
                    } else {
                      _scaffoldKey.currentState.showSnackBar(
                        snackbarDisplay(response),
                      );
                    }
                  },
                ),
                transitionOnUserGestures: true,
              );
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailPhoneController,
      focusNode: _emailfocusNode,
      style: labelTextStyle(),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        errorStyle: errorTextStyle(),
        labelStyle: labelTextStyle(),
        labelText: 'Email',
        prefixIcon: Icon(Icons.mail_outline),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return '* Email is required';
        }
        if ((!value.contains('@') || !value.endsWith('.com'))) {
          return '* Enter a valid Email Address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _emailPhoneController,
      style: labelTextStyle(),
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        errorStyle: errorTextStyle(),
        labelStyle: labelTextStyle(),
        labelText: 'Phone',
        prefixIcon: Icon(Icons.phone),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return '* Contact Number is required';
        }
        if ((value.length != 10 || !value.contains(RegExp(r'^[0-9]*$')))) {
          return '* Enter a valid Contact Number';
        }
        return null;
      },
    );
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      _timer.cancel();
      setState(() {
        _isTextVisible = false;
      });
      this.verificationId = verId;
      inputDialog(context, _buildInputDisplay(), cardHeight);
    };

    final PhoneVerificationCompleted verificationComplete =
        (AuthCredential userCreds) async {
      final AuthResult result =
          await FirebaseAuth.instance.signInWithCredential(userCreds);
      if (result.user != null) {
        widget.model
            .savePassengerData(result.user.uid, result.user.phoneNumber);
        setState(() {
          _processing = false;
        });
        if (result.user.displayName == null && result.user.email == null) {
          Navigator.of(context).pushReplacement(
            CustomRoute(
              builder: (BuildContext context) {
                return SignUp(result.user.uid);
              },
            ),
          );
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    };

    final PhoneVerificationFailed verificationFail =
        (AuthException exception) {};

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: this.phoneNo,
      codeAutoRetrievalTimeout: autoRetrieve,
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verificationComplete,
      verificationFailed: verificationFail,
    );
  }

  Widget _buildVehicleTypeDisplay() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          Text('Select Vehicle Type', style: smallBoldTextStyle()),
          SizedBox(height: 20.0),
          OutlinedButton('Passenger Vehicle', Icons.local_taxi, () {
            _setVehicleType(publicVehicle);
            Navigator.of(context).pushReplacement(
              CustomRoute(
                builder: (BuildContext context) {
                  return ScopedModelDescendant<MainModel>(
                    builder:
                        (BuildContext context, Widget child, MainModel model) {
                      return DriverPage(model);
                    },
                  );
                },
              ),
            );
          }, kDarkRedColor),
          OutlinedButton('Cab/Taxi', Icons.time_to_leave, () {
            _setVehicleType(privateVehicle);
            Navigator.of(context).pushReplacement(
              CustomRoute(
                builder: (BuildContext context) {
                  return ScopedModelDescendant<MainModel>(
                    builder:
                        (BuildContext context, Widget child, MainModel model) {
                      return PrivateDriver(model);
                    },
                  );
                },
              ),
            );
          }, kBlackColor),
        ],
      ),
    );
  }

  Widget _buildEmailInputDisplay() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Enter Email', style: smallBoldTextStyle()),
            leading: Icon(Icons.mail),
          ),
          SizedBox(height: cardHeight / 24),
          _buildEmailField(),
          SizedBox(height: 10.0),
          _buildVerifyButton(),
        ],
      ),
    );
  }

  void _setVehicleType(String vehicleType) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('vehicleType', vehicleType);
  }

  Widget _buildVerifyButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return MaterialedButton(
          Icons.done_all,
          'Confirm',
          () async {
            String email = _emailPhoneController.text.trim();
            _emailPhoneController.clear();
            if (email.isEmpty ||
                !email.contains('@') ||
                !email.endsWith('.com')) return;
            Navigator.pop(context);
            Map<String, dynamic> response =
                await model.sendPasswordResetLink(email, model.apiKey);
            _scaffoldKey.currentState.showSnackBar(
              snackbarDisplay(response),
            );
          },
        );
      },
    );
  }

  Widget _buildInputDisplay() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Enter OTP', style: smallBoldTextStyle()),
            leading: Icon(Icons.textsms),
          ),
          SizedBox(height: cardHeight / 24),
          PinInput(
              6, () => manualVerifyPhone(widget.model), _passwordController),
          SizedBox(height: 10.0),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return MaterialedButton(
          Icons.done_all,
          'Confirm',
          () {
            setState(() {
              _processing = true;
            });
            Navigator.pop(context);
            manualVerifyPhone(model);
          },
        );
      },
    );
  }

  void manualVerifyPhone(MainModel model) async {
    this.smsCode = _passwordController.text;
    final AuthCredential creds = PhoneAuthProvider.getCredential(
        verificationId: this.verificationId, smsCode: this.smsCode);
    try {
      final AuthResult result =
          await FirebaseAuth.instance.signInWithCredential(creds);
      if (result.user != null) {
        model.savePassengerData(result.user.uid, result.user.phoneNumber);
        setState(() {
          _processing = false;
        });
        if (result.user.displayName == null && result.user.email == null) {
          Navigator.of(context).pushReplacement(
            CustomRoute(
              builder: (BuildContext context) {
                return SignUp(result.user.uid);
              },
            ),
          );
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (_) {
      _scaffoldKey.currentState.showSnackBar(
        snackbarDisplay({"status": "ERROR", "message": "Error! Invalid OTP."}),
      );
      setState(() {
        _processing = false;
      });
    }
  }
}
