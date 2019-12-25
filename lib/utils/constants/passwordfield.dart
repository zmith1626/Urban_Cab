import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController _textEditingController;
  final FocusNode _focusNode;

  PasswordField(this._textEditingController, this._focusNode);

  @override
  _PasswordField createState() => _PasswordField();
}

class _PasswordField extends State<PasswordField> {
  bool _makePasswordVisible = false;

  void _obscureText() {
    setState(() {
      _makePasswordVisible = !_makePasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget._textEditingController,
      style: labelTextStyle(),
      focusNode: widget._focusNode,
      obscureText: !_makePasswordVisible,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        errorStyle: errorTextStyle(),
        labelStyle: labelTextStyle(),
        labelText: 'Password',
        prefixIcon: Icon(Icons.vpn_key),
        suffix: GestureDetector(
          onTap: _obscureText,
          child: _makePasswordVisible
              ? Icon(Icons.visibility, size: 18.0)
              : Icon(Icons.visibility_off, size: 18.0),
        ),
      ),
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
}
