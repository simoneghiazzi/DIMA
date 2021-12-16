import 'package:flutter/material.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/constants.dart';

class EmptyLandscapeBody extends StatelessWidget {
  const EmptyLandscapeBody({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        TopBar(
          text: "",
          isPortrait: true,
        ),
        Expanded(
          child: Container(
            color: kPrimaryLightGreyColor,
            child: Center(
              child: Image.asset(
                "assets/icons/logo.png",
                scale: 7,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
