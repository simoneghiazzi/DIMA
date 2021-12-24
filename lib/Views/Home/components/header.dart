import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

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
          height: 10.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "sApport",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 33.sp, fontFamily: "Gabriola"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
