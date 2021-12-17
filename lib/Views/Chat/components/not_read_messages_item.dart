import 'package:flutter/material.dart';

class NotReadMessagesItem extends StatelessWidget {
  final int counter;

  const NotReadMessagesItem({Key key, this.counter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size.width * 0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_drop_down, color: Colors.white),
              SizedBox(width: size.width * 0.03),
              Text(
                "$counter NEW MESSAGES",
                style: TextStyle(color: Colors.white, fontSize: 13.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: size.width * 0.03),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade100,
                blurRadius: 4,
                offset: Offset(1, 3), // Shadow position
              ),
            ],
          ),
          margin: EdgeInsets.only(bottom: 10.0, top: 20.0),
        ),
      ],
    );
  }
}
