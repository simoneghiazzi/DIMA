import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sizer/sizer.dart';

class Header extends StatelessWidget {
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40, fontFamily: "Gabriola"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
