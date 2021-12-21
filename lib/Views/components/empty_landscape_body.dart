import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

class EmptyLandscapeBody extends StatelessWidget {
  const EmptyLandscapeBody({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: kPrimaryColor,
          child: SafeArea(
            child: Container(
              color: kPrimaryColor,
              height: 10.h,
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: kPrimaryLightGreyColor,
            child: Center(
              child: Image.asset(
                "assets/icons/logo.png",
                scale: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
