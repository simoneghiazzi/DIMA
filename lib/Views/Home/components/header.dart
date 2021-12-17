import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: kPrimaryColor,
      child: SafeArea(
        child: Container(
          color: kPrimaryColor,
          height: size.height / 10,
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
