import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -50,
            left: -50,
            child: Image.asset(
              "assets/images/main_top.png",
              width: size.width * 0.3,
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.2,
              child: Container(
                padding: EdgeInsets.only(top: 10),
                child: Image.asset(
                  "assets/icons/logo.png",
                  width: size.height * 0.06,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/images/home_bottom.png",
                width: size.width * 0.4,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
