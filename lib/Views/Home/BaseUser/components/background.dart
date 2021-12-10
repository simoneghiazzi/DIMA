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
            child: Image.asset(
              "assets/images/main_top.png",
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
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/images/home_bottom.png",
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
