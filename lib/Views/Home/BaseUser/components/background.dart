import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Image.asset(
              "assets/images/main_top.png",
              scale: 2,
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.2,
              child: Container(
                child: Image.asset(
                  "assets/icons/logo.png",
                  scale: 11,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/images/home_bottom.png",
                scale: 2,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
