import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';

/// It shows an info dialog of type [infoType] with a [title], a [content] and a button
/// of type [buttonType].
/// The [body] is an additional widget that can be displayed under the content.
///
/// The [closeButton] flag indicates if another button should be added for closing the dialog.
class InfoDialog {
  /// It shows an info dialog of type [infoType] with a [title], a [content] and a button
  /// of type [buttonType].
  /// The [body] is an additional widget that can be displayed under the content.
  ///
  /// The [closeButton] flag indicates if another button should be added for closing the dialog.
  static Future<void> show(
    BuildContext context, {
    required InfoDialogType infoType,
    String? title,
    required String content,
    required ButtonType buttonType,
    Function? onTap,
    bool closeButton = false,
    Widget? body,
  }) async {
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    routerDelegate.hasDialog = true;
    var backButtonInterceptor = (stopDefaultButtonEvent, info) => true;
    BackButtonInterceptor.add(backButtonInterceptor);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (infoType == InfoDialogType.success) ...[
                      Text("Success", style: TextStyle(color: Colors.green, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      SizedBox(width: 2.w),
                      Icon(Icons.verified, color: Colors.green, size: 30),
                    ] else if (infoType == InfoDialogType.error) ...[
                      Text("Error", style: TextStyle(color: Colors.red, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      SizedBox(width: 2.w),
                      Icon(Icons.error, color: Colors.red, size: 30),
                    ] else if (infoType == InfoDialogType.warning) ...[
                      Text("Warning", style: TextStyle(color: Colors.orange, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      SizedBox(width: 2.w),
                      Icon(Icons.warning, color: Colors.orange, size: 30),
                    ],
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null) ...[
                        Row(
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: kPrimaryColor),
                            ),
                            SizedBox(height: 3.h),
                          ],
                        ),
                      ],
                      Padding(
                        padding: EdgeInsets.only(top: 5, bottom: body == null ? 25 : 5),
                        child: Row(
                          children: [
                            Flexible(child: Text(content, maxLines: 3, textAlign: TextAlign.start, style: TextStyle(fontSize: 13.sp))),
                          ],
                        ),
                      ),
                      if (body != null) ...[
                        Padding(padding: EdgeInsets.only(bottom: 30), child: body),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (closeButton) ...[
                            InkWell(
                              child: InkResponse(
                                  onTap: () {
                                    routerDelegate.hasDialog = false;
                                    Navigator.of(context, rootNavigator: true).pop();
                                    BackButtonInterceptor.remove(backButtonInterceptor);
                                  },
                                  child: Text("Cancel", style: TextStyle(color: kPrimaryMediumColor, fontSize: 14.sp, fontWeight: FontWeight.bold))),
                            ),
                            SizedBox(width: 10.w)
                          ],
                          InkWell(
                            child: InkResponse(
                                onTap: () {
                                  routerDelegate.hasDialog = false;
                                  if (onTap != null) {
                                    onTap();
                                  }
                                  Navigator.of(context, rootNavigator: true).pop();
                                  BackButtonInterceptor.remove(backButtonInterceptor);
                                },
                                child: buttonType == ButtonType.ok
                                    ? Text("OK", style: TextStyle(color: kPrimaryMediumColor, fontSize: 14.sp, fontWeight: FontWeight.bold))
                                    : Text("Confirm", style: TextStyle(color: kPrimaryMediumColor, fontSize: 14.sp, fontWeight: FontWeight.bold))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

enum InfoDialogType { success, error, warning }

enum ButtonType { ok, confirm }
