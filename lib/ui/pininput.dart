import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class PinInput extends StatelessWidget {
  final int count;
  final Function submitFunction;
  final TextEditingController pinInputController;

  PinInput(this.count, this.submitFunction, this.pinInputController);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PinCodeTextField(
        autofocus: true,
        controller: pinInputController,
        pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
        pinBoxHeight: 50.0,
        pinBoxWidth: 32.0,
        pinTextStyle: boldTextStyle(),
        hideCharacter: false,
        maxLength: count,
        onDone: (pin) {
          pinInputController.text = pin;
          submitFunction();
        },
      ),
    );
  }
}
