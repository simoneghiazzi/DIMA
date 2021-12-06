import 'package:flutter/material.dart';
import 'package:sApport/Views/components/top_bar.dart';

class EmptyPagePortrait extends StatelessWidget {
  static const route = '/emptyPagePortrait';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TopBar(
            text: "",
            isPortrait: true,
          ),
          Expanded(child: Container()),
          Image.asset(
            "assets/icons/logo.png",
            height: size.height / 5,
          ),
          Expanded(child: Container())
        ],
      )),
    );
  }
}
