import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  Widget widget(BuildContext context, {String text}) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 1.3,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

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

  static void hide(BuildContext context, GlobalKey key) {
    Navigator.of(key.currentContext, rootNavigator: true).pop();
  }
}
