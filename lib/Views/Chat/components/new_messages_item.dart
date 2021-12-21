import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Chat/components/message_list_constructor.dart';

/// New messages item of the [MessageListConstructor].
///
/// It takes the [counter] from the ListView builder that represents the number of new messages.
class NewMessagesItem extends StatelessWidget {
  final int counter;

  /// New messages item of the [MessageListConstructor].
  ///
  /// It takes the [counter] from the ListView builder that represents the number of new messages.
  const NewMessagesItem({Key? key, required this.counter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10.0, top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_drop_down, color: Colors.white),
              SizedBox(width: 3.w),
              Text(
                "$counter NEW MESSAGES",
                style: TextStyle(color: Colors.white, fontSize: 13.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 3.w),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [BoxShadow(color: Colors.green.shade100, blurRadius: 4, offset: Offset(1, 3))],
          ),
        ),
      ],
    );
  }
}
