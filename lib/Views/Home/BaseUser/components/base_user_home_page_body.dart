import 'background.dart';
import 'home_page_grid.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';

/// Body of the [BaseUserHomePageScreen].
///
/// It contains the [Header] and the [HomePageGrid].
class BaseUserHomePageBody extends StatelessWidget {
  /// Body of the [BaseUserHomePageScreen].
  ///
  /// It contains the [Header] and the [HomePageGrid].
  const BaseUserHomePageBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Header(),
          Expanded(
            child: Background(
              child: Column(
                children: [Spacer(), HomePageGrid(), Spacer()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
