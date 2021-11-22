import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class DashCard extends StatelessWidget {
  final String imagePath;
  final String text;
  final Function press;

  const DashCard({Key key, this.imagePath, this.text, this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: press,
      child: Card(
        elevation: 2,
        shadowColor: Colors.indigo[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
