import 'package:flutter/material.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';

/// Header of the application.
///
/// It contains the top bar with the [SafeArea] and the name of the application.
class Header extends StatelessWidget {
  /// Header of the application.
  ///
  /// It contains the top bar with the [SafeArea] and the name of the application.
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: kPrimaryColor,
        child: SafeArea(
          child: Container(
            color: kPrimaryColor,
            height: 9.5.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5.0.w),
                  child: Text(
                    "sApport",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.sp, fontFamily: "Gabriola"),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
