import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Chat/ChatPage/components/message_list_constructor.dart';

/// Date item of the [MessageListConstructor].
///
/// It takes the [date] from the ListView builder and builds the date item of the message list.
class DateItem extends StatelessWidget {
  final DateTime date;

  /// Date item of the [MessageListConstructor].
  ///
  /// It takes the [date] from the ListView builder and builds the date item of the message list.
  const DateItem({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 5.0, top: 25.0),
          padding: EdgeInsets.only(right: 10, bottom: 5, top: 5, left: 10),
          child: Text(
            DateFormat().add_yMMMd().format(date),
            style: TextStyle(color: Colors.white, fontSize: 10.sp, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          decoration: BoxDecoration(
            color: kPrimaryDarkColorTrasparent.withOpacity(0.65),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: kPrimaryLightColor,
                blurRadius: 4,
                offset: Offset(1, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
