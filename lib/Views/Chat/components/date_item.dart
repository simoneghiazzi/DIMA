import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateItem extends StatefulWidget {
  final DateTime date;

  DateItem({Key? key, required this.date}) : super(key: key);

  @override
  _DateItemState createState() => _DateItemState();
}

class _DateItemState extends State<DateItem> {
  @override
  Widget build(BuildContext context) {
    // Date
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(right: 8, bottom: 5, top: 5, left: 8),
          child: Text(
            DateFormat().add_yMMMd().format(widget.date),
            style: TextStyle(color: Colors.white, fontSize: 11.0, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          decoration: BoxDecoration(
            color: kPrimaryDarkColorTrasparent,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: kPrimaryLightColor,
                blurRadius: 4,
                offset: Offset(1, 3), // Shadow position
              ),
            ],
          ),
          margin: EdgeInsets.only(bottom: 5.0, top: 25.0),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}
