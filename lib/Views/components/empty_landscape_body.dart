import 'package:flutter/material.dart';
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';

/// Background body that is used in the rigth hand side of the [VerticalSplitView] when no item is selected.
class EmptyLandscapeBody extends StatelessWidget {
  /// Background body that is used in the rigth hand side of the [VerticalSplitView] when no item is selected.
  const EmptyLandscapeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: kPrimaryColor,
          child: SafeArea(
            child: Container(color: kPrimaryColor, height: 10.h),
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
