import 'package:expange/colors.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/ui/imageinput.dart';
import 'package:expange/ui/inputdialog.dart';
import 'package:expange/ui/snackbardisplay.dart';
import 'package:expange/utils/materialbutton.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';

class ProfileUpdate extends StatefulWidget {
  final bool isProfileSettings;
  final bool isPrivateVehicle;
  final MainModel model;

  ProfileUpdate({this.isProfileSettings, this.model, this.isPrivateVehicle});

  @override
  _ProfileUpdate createState() => _ProfileUpdate();
}

class _ProfileUpdate extends State<ProfileUpdate> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();

  File _selectedImage;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.model.driver == null) {
      _fnameController.text = widget.model.passenger.username.split(' ')[0];
      _lnameController.text = widget.model.passenger.username.split(' ')[1];
      _phoneController.text = widget.model.passenger.phone.substring(3, 13);
      _emailController.text = widget.model.passenger.email;
    } else {
      _fnameController.text = widget.model.driver.username.split(' ')[0];
      _lnameController.text = widget.model.driver.username.split(' ')[1];
      _phoneController.text = widget.model.driver.phone;
      _emailController.text = widget.model.driver.email;
      _isAvailable = widget.model.isAvailable;
    }
  }

  @override
  void dispose() {
    if (widget.isProfileSettings) {
      if (widget.model.driver != null) {
        widget.model.fetchDriverDetails(initLoad: false);
      } else {
        widget.model.fetchUserDetails(initLoad: false);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: (widget.isProfileSettings)
            ? Container(
                color: kSurfaceColor,
                child: Form(
                  key: _profileFormKey,
                  child: ListView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: <Widget>[
                      Wrap(
                        spacing: 10.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(Icons.person),
                          Text('My Profile', style: smallBoldTextStyle())
                        ],
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: labelTextStyle(),
                        controller: _fnameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: labelTextStyle(),
                          errorStyle: errorTextStyle(),
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'first name is required.';
                          }
                          if (!value
                              .contains(RegExp(r"^[a-zA-Z 0-9\-\_\.]*$"))) {
                            return 'Invalid first name character';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: labelTextStyle(),
                        controller: _lnameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: labelTextStyle(),
                          errorStyle: errorTextStyle(),
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'last name is required.';
                          }
                          if (!value
                              .contains(RegExp(r"^[a-zA-Z 0-9\-\_\.]*$"))) {
                            return 'Invalid last name character';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: labelTextStyle(),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Contact No',
                          labelStyle: labelTextStyle(),
                          errorStyle: errorTextStyle(),
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Contact no is required.';
                          }
                          if (!value.contains(RegExp(r'^[0-9]*$'))) {
                            return 'Invalid contact number';
                          }
                          if (value.length != 10) {
                            return 'Invalid contact no.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: labelTextStyle(),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: labelTextStyle(),
                          errorStyle: errorTextStyle(),
                          suffix: (widget.model.driver == null)
                              ? (widget.model.passenger.isemailVerified)
                                  ? SizedBox(width: 0.1)
                                  : _buildVerifyButton(context)
                              : SizedBox(width: 0.1),
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Email is required.';
                          }
                          if ((!value.contains('@') ||
                              !value.endsWith('.com'))) {
                            return 'Invalid Email Address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      ImageInput(
                          (widget.model.driver == null)
                              ? widget.model.passenger.image
                              : widget.model.driver.image,
                          _setImage),
                      SizedBox(height: 10.0),
                      ScopedModelDescendant(
                        builder: (BuildContext context, Widget child,
                            MainModel model) {
                          return model.isRequesting
                              ? CupertinoActivityIndicator(radius: 14.0)
                              : MaterialedButton(Icons.done, 'Update', () {
                                  _updateForm(model);
                                });
                        },
                      ),
                    ],
                  ),
                ),
              )
            : ScopedModelDescendant<MainModel>(
                builder: (BuildContext context, Widget child, MainModel model) {
                  return Container(
                    color: kSurfaceColor,
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Ride Settings',
                              style: smallBoldTextStyle()),
                          trailing: Icon(Icons.more_horiz),
                        ),
                        Divider(indent: 30.0, height: 2.0),
                        ListTile(
                          leading: (widget.model.isRequesting)
                              ? CupertinoActivityIndicator()
                              : _isAvailable
                                  ? Icon(Icons.notifications)
                                  : Icon(Icons.notifications_off),
                          title: Text(
                            'Currently Available',
                            style: labelTextStyle(),
                          ),
                          trailing: Switch(
                            value: _isAvailable,
                            onChanged: (bool value) =>
                                _updateAvailability(value),
                            activeColor: kGreenColor,
                            activeTrackColor: Colors.green[500],
                            inactiveThumbColor: kBlackColor,
                            inactiveTrackColor: Colors.black38,
                          ),
                        ),
                        widget.isPrivateVehicle
                            ? SizedBox(height: 0.1)
                            : ListTile(
                                leading: (widget.model.isRequesting)
                                    ? CupertinoActivityIndicator()
                                    : Icon(Icons.schedule),
                                title:
                                    Text('Set Timer', style: labelTextStyle()),
                                subtitle: Text('Set timer for next trip.',
                                    style: TextStyle(fontFamily: 'Ubuntu')),
                                trailing: Container(
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_forward_ios),
                                    onPressed: () => _setTimer(model),
                                  ),
                                ),
                              ),
                        widget.isPrivateVehicle
                            ? SizedBox(height: 0.1)
                            : ListTile(
                                leading: (widget.model.isRequesting)
                                    ? CupertinoActivityIndicator()
                                    : Icon(Icons.cached),
                                title: Text('Reset', style: labelTextStyle()),
                                subtitle: Text('Reset timer for Next Day trip',
                                    style: TextStyle(fontFamily: 'Ubuntu')),
                                trailing: Container(
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_forward_ios),
                                    onPressed: () => _reset(model),
                                  ),
                                ),
                              ),
                        ListTile(
                          leading: (widget.model.isRequesting)
                              ? CupertinoActivityIndicator()
                              : Icon(Icons.phonelink_setup),
                          title:
                              Text('Reset Password', style: labelTextStyle()),
                          trailing: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: IconButton(
                              icon: Icon(Icons.arrow_forward_ios),
                              onPressed: () => inputDialog(
                                  context, _buildPwdInputDisplay(), 260.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPwdInputField() {
    _fnameController.text = "";
    return TextFormField(
      style: labelTextStyle(),
      controller: _fnameController,
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: InputDecoration(
          hintText: 'Enter Password',
          hintStyle: labelTextStyle(),
          errorStyle: errorTextStyle()),
      validator: (String password) {
        if (password.isEmpty) {
          return '* Password is required.';
        }
        if (password.length < 8) {
          return '* Password must be 8 characters long.';
        }
        return null;
      },
    );
  }

  Widget _buildPwdConfirmField() {
    _lnameController.text = "";
    return TextFormField(
      style: labelTextStyle(),
      obscureText: true,
      keyboardType: TextInputType.text,
      controller: _lnameController,
      decoration: InputDecoration(
          hintText: 'Confirm Password',
          hintStyle: labelTextStyle(),
          errorStyle: errorTextStyle()),
      validator: (String password) {
        if (password.isEmpty) {
          return '* Password is required.';
        }
        if (_fnameController.text != password) {
          return '* Password do not match.';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return MaterialedButton(Icons.done, 'Submit', _submitResetRequest);
  }

  void _submitResetRequest() async {
    if (!_passwordFormKey.currentState.validate()) return;

    Navigator.pop(context);

    final response = await widget.model.resetPassword(_lnameController.text);
    _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
  }

  Widget _buildPwdInputDisplay() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(height: 10.0),
            Wrap(
              spacing: 10.0,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Icon(Icons.phonelink_setup),
                Text('Enter New Password', style: smallBoldTextStyle()),
              ],
            ),
            SizedBox(height: 20.0),
            _buildPwdInputField(),
            SizedBox(height: 2.0),
            _buildPwdConfirmField(),
            SizedBox(height: 10.0),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  void _updateAvailability(bool value) {
    _updateStatus(widget.model, value);
  }

  void _updateForm(MainModel model) async {
    if (!_profileFormKey.currentState.validate()) return;
    Map<String, dynamic> profileMap = {
      "fName": _fnameController.text.trimRight(),
      "lName": _lnameController.text.trimRight(),
      "email": _emailController.text.trimRight(),
      "phone": _phoneController.text.trimRight(),
    };
    Map<String, dynamic> response;
    if (model.driver == null) {
      final String userID = model.passenger.id;
      response = await model.updateProfile(_selectedImage, profileMap, userID,
          1, model.passenger.imagePath, model.passenger.image);
    } else {
      final String userID = model.driver.id;
      response = await model.updateProfile(_selectedImage, profileMap, userID,
          0, model.driver.imagePath, model.driver.image);
    }
    _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
  }

  void _setImage({File image}) {
    this._selectedImage = image;
  }

  void _setTimer(MainModel model) async {
    final Map<String, dynamic> vehicleData = {
      "vehicle": model.driver.vehicleNo
    };
    final String userID = model.driver.id;
    final Map<String, dynamic> response =
        await model.setPublicVehicleTimer(vehicleData, userID);
    _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
  }

  void _reset(MainModel model) async {
    final Map<String, dynamic> vehicleData = {
      "vehicle": model.driver.vehicleNo
    };
    final String userID = model.driver.id;
    final Map<String, dynamic> response =
        await model.resetPublicVehicle(vehicleData, userID);
    _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
  }

  void _updateStatus(MainModel model, bool value) async {
    Map<String, dynamic> response;
    final Map<String, dynamic> statusData = {
      "status": _isAvailable ? 'UNAVAILABLE' : 'AVAILABLE',
      "vehicle": model.driver.vehicleNo
    };
    final String userID = model.driver.id;
    if (widget.isPrivateVehicle) {
      response = await model.updatePrivateVehicleStatus(statusData, userID);
    } else {
      response = await model.updatePublicVehicleStatus(statusData, userID);
    }
    _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
    if (response['status'] == "OK") {
      setState(() {
        _isAvailable = value;
      });
    }
  }

  Widget _buildVerifyButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isRequesting
            ? CupertinoActivityIndicator()
            : OutlineButton(
                borderSide: BorderSide(color: kGreenColor, width: 2.0),
                child: Text('Verify', style: labelTextStyle()),
                onPressed: () => _verifyEmail(model),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              );
      },
    );
  }

  void _verifyEmail(MainModel model) async {
    final Map<String, dynamic> email = {"email": _emailController.text};
    final String userID = model.passenger.id;
    final Map<String, dynamic> response =
        await model.verifyEmail(email, userID);
    _scaffoldKey.currentState.showSnackBar(snackbarDisplay(response));
  }
}
