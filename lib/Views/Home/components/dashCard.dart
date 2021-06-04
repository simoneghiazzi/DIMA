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
              Image.asset(
                imagePath,
                height: size.height * 0.15,
              ),
              Text(text)
            ],
          ),
        ),
      ),
    );
  }
}
