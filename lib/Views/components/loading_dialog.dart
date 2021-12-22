import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

/// It is used during loading and it shows and hide a dialog with a circular progress indicator and
/// a [text] if it is provided.
class LoadingDialog {
  /// Shows a dialog with a circular progress indicator and a [text].
  static Future<void> show(BuildContext context, {String text = "Loading..."}) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
              backgroundColor: Colors.white,
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                        width: 20,
                      ),
                      Text(
                        text,
                        style: TextStyle(color: kPrimaryColor),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  /// Hide the previously opened loading dialog.
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
