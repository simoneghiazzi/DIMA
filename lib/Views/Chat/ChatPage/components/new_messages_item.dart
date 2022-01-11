import 'package:flutter/material.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/Chat/ChatPage/components/message_list_constructor.dart';

/// New messages item of the [MessageListConstructor].
///
/// It takes the [counter] from the ListView builder that represents the number of new messages.
class NewMessagesItem extends StatelessWidget {
  final int counter;
  final bool sameNextIdFrom;

  /// New messages item of the [MessageListConstructor].
  ///
  /// It takes the [counter] from the ListView builder that represents the number of new messages.
  const NewMessagesItem({Key? key, required this.counter, required this.sameNextIdFrom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: sameNextIdFrom ? 20.0 : 5.0, top: 20.0),
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_drop_down, color: Colors.white),
              SizedBox(width: 3.w),
              Text(
                "$counter  NEW MESSAGE${counter > 1 ? "S" : ""} ",
                style: TextStyle(color: Colors.white, fontSize: 11.sp, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 3.w),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
          decoration: BoxDecoration(
            color: kPrimaryDarkColorTrasparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ],
    );
  }
}
