import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoaderPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.grey[500],
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0))
          ],
        ),
        child: CupertinoActivityIndicator(radius: 16.0),
      ),
    );
  }
}
