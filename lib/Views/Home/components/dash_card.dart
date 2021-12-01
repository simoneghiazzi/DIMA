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
    return Padding(
      padding: EdgeInsets.only(right: 12, top: 15, bottom: 15),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        splashColor: kPrimaryColor.withAlpha(100),
        highlightColor: Colors.transparent,
        onTap: press,
        child: Container(
          height: size.height / 3.3,
          child: Card(
            elevation: 3,
            shadowColor: kPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: size.height / 25),
                    Image.asset(
                      imagePath,
                      height: size.height * 0.13,
                    ),
                    SizedBox(height: 16),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
