import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  static Future<void> show(BuildContext context, GlobalKey key,
      {String text}) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 20,
                          width: 20,
                        ),
                        Text(
                          text ?? "Loading....",
                          style: TextStyle(color: kPrimaryColor),
                        )
                      ]),
                    )
                  ]));
        });
  }
}
