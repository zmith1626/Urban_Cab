import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class CancelDialog extends StatelessWidget {
  final Function cancelFunction;

  CancelDialog(this.cancelFunction);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(left: 16.0, right: 8.0),
      children: <Widget>[
        SizedBox(height: 20.0),
        Wrap(
          spacing: 10.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Icon(Icons.warning),
            Text('Please Confirm', style: smallBoldTextStyle())
          ],
        ),
        Divider(indent: 20.0),
        SizedBox(height: 10.0),
        Text(
          'Are you sure, you want to cancel booking ? Cancelling will incur 30% of actual fare.',
          style: labelTextStyle(),
        ),
        ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text('Cancel', style: smallBoldTextStyle()),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              child: Text('Continue', style: smallBoldWhiteTextStyle()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              onPressed: () => cancelFunction(),
            ),
          ],
        )
      ],
    );
  }
}
