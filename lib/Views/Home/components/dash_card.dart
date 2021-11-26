import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';

class DashCard extends StatelessWidget {
  final String imagePath;
  final String text;
  final Function press;

  const DashCard({Key key, this.imagePath, this.text, this.press}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      splashColor: kPrimaryColor.withAlpha(100),
      highlightColor: Colors.transparent,
      onTap: press,
      child: Card(
        elevation: 2,
        shadowColor: kPrimaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(height: size.height * 0.04),
              Image.asset(
                imagePath,
                height: size.height * 0.15,
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                text,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
