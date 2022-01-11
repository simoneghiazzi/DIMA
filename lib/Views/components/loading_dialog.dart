import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Router/app_router_delegate.dart';

/// It is used during loading and it shows and hide a dialog with a circular progress indicator and
/// a [text] if it is provided.
class LoadingDialog {
  /// Shows a dialog with a circular progress indicator and a [text].
  static Future<void> show(BuildContext context, {String text = "Loading..."}) async {
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    routerDelegate.hasDialog = true;
    BackButtonInterceptor.add(backButtonInterceptor);
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Colors.white,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 3.h),
                      Text(
                        text,
                        style: TextStyle(color: kPrimaryColor, fontSize: 13.5.sp),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  static var backButtonInterceptor = (stopDefaultButtonEvent, info) => true;

  /// Hide the previously opened loading dialog.
  static void hide(BuildContext context) {
    BackButtonInterceptor.remove(backButtonInterceptor);
    Navigator.of(context, rootNavigator: true).pop();
  }
}
