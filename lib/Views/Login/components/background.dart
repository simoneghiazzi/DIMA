import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/login_body.dart';

/// Background of the [LoginBody].
///
/// It takes the [child] that is shown above the background.
class Background extends StatelessWidget {
  final Widget child;

  /// Background of the [LoginBody].
  ///
  /// It takes the [child] that is shown above the background.
  const Background({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Top Left Image
          Positioned(top: 0, left: 0, child: Image.asset("assets/images/main_top.png", scale: 2)),
          // Bottom Right Image
          Positioned(bottom: 0, right: 0, child: Image.asset("assets/images/login_bottom.png", scale: 2.5)),
          child,
        ],
      ),
    );
  }
}
