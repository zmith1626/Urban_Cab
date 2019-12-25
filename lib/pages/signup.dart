import 'package:expange/colors.dart';
import 'package:expange/scoped_model/mainmodel.dart';
import 'package:expange/utils/materialbutton.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUp extends StatefulWidget {
  final String uID;

  SignUp(this.uID);

  @override
  _SignUp createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          body: _returnSignUp(context),
        );
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: labelTextStyle(),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        errorStyle: errorTextStyle(),
        labelStyle: labelTextStyle(),
        labelText: 'Email',
        prefixIcon: Icon(Icons.mail_outline),
      ),
      validator: (String email) {
        if (email.isEmpty) {
          return '* Email is required';
        }
        if (!email.contains('@') || !email.endsWith('.com')) {
          return '* Enter a valid Email';
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: labelTextStyle(),
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        errorStyle: errorTextStyle(),
        labelStyle: labelTextStyle(),
        labelText: 'Full Name',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (String name) {
        if (name.isEmpty) {
          return '* Full Name is required';
        }
        if (name.contains('<')) {
          return '* Enter valid Name Characters.';
        }
        return null;
      },
    );
  }

  Widget _returnSignUp(BuildContext context) {
    double topSpacing = MediaQuery.of(context).size.height / 5;
    return Container(
      color: kSurfaceColor,
      child: SafeArea(
        child: Form(
          key: _signUpFormKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            children: <Widget>[
              SizedBox(height: topSpacing),
              _buildNameField(),
              SizedBox(height: 10.0),
              _buildEmailField(),
              SizedBox(height: 20.0),
              _isLoading
                  ? CupertinoActivityIndicator(radius: 14.0)
                  : MaterialedButton(
                      Icons.edit,
                      'Submit',
                      () {
                        validateForm(context);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void validateForm(BuildContext context) async {
    if (!_signUpFormKey.currentState.validate()) return;
    setState(() {
      _isLoading = true;
    });
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    UserUpdateInfo userInfo = new UserUpdateInfo();
    userInfo.displayName = _nameController.text.trimRight();
    user.updateProfile(userInfo).then((value) {
      user.updateEmail(_emailController.text.trimRight()).then((onValue) {
        Navigator.of(context).pushReplacementNamed('/home');
      }).catchError((_) {});
    }).catchError((_) {});
  }
}
