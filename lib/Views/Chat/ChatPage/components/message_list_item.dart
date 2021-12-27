import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as Date;
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/components/message_list_constructor.dart';

/// Message list item of the [MessageListConstructor].
///
/// It takes the [messageItem] from the ListView builder that represents a message between 2 users
/// and the [sameNextIdFrom] that is used for applying the correct margin to the message.
///
/// It contains the content and the time of the message.
class MessageListItem extends StatefulWidget {
  final Message messageItem;
  final bool sameNextIdFrom;

  /// Message list item of the [MessageListConstructor].
  ///
  /// It takes the [messageItem] from the ListView builder that represents a message between 2 users
  /// and the [sameNextIdFrom] that is used for applying the correct margin to the message.
  ///
  /// It contains the content and the time of the message.
  const MessageListItem({Key? key, required this.messageItem, this.sameNextIdFrom = false}) : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> {
  // View Models
  late ChatViewModel chatViewModel;
  late UserViewModel userViewModel;

  late double _containerWidth;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the width of the container for the message
    _containerWidth = calcTextSize(widget.messageItem.content, TextStyle(fontFamily: "Lato")).width + 19.w;

    // Check if the message is sent or received by the logged user
    if (widget.messageItem.idFrom == userViewModel.loggedUser!.id) {
      // Logged user message (rigth)
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMessageBubble(false),
          if (!widget.sameNextIdFrom) ...[
            // If the next message is not from the same id, add a further margin and the CustomPaint
            Container(
              // Same top as the message bubble margin
              margin: EdgeInsets.only(top: 20.0),
              child: CustomPaint(painter: Clip(kPrimaryLightColor)),
            ),
          ]
        ],
      );
    } else {
      // Peer user message (left)
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.sameNextIdFrom) ...[
            // If the next message is not from the same id, add a further margin and the rotated CustomPaint
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Container(
                // Same top as the message bubble margin
                margin: EdgeInsets.only(top: 20.0),
                child: CustomPaint(painter: Clip(kPrimaryColor)),
              ),
            ),
          ],
          buildMessageBubble(true)
        ],
      );
    }
  }

  /// Builder of the bubble container of the message.
  ///
  /// [peerUser] is used to select the correct color and the correct non-rounded border vertex position.
  ///
  /// It also sets the container constraints based on the orientation of the device.
  Widget buildMessageBubble(bool peerMessage) {
    return Container(
      constraints: BoxConstraints(maxWidth: 70.w),
      width: _containerWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Content
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
              child: Text(
                widget.messageItem.content,
                style: TextStyle(color: peerMessage ? Colors.white : kPrimaryColor, fontSize: 12.2.sp),
              ),
            ),
          ),
          // Time
          Container(
            padding: EdgeInsets.only(right: 8, bottom: 5),
            child: Text(
              Date.DateFormat("kk:mm").format(widget.messageItem.timestamp),
              style: TextStyle(color: kPrimaryGreyColor, fontSize: 9.sp, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: peerMessage ? kPrimaryColor : kPrimaryLightColor,
        borderRadius: widget.sameNextIdFrom
            ?
            // If the next id is the same, the border radius is applied to all the vertexes
            BorderRadius.circular(12.5)
            :
            // Otherwise, the border radius is applied to all the bottom vertexes and only one of the
            // top vertixes based on the fact that it is a peer message or not
            BorderRadius.only(
                topLeft: Radius.circular(peerMessage ? 0 : 12.5),
                topRight: Radius.circular(!peerMessage ? 0 : 12.5),
                bottomLeft: Radius.circular(12.5),
                bottomRight: Radius.circular(12.5),
              ),
      ),
      // Same top as the Clip margin
      margin: EdgeInsets.only(top: widget.sameNextIdFrom ? 2.0 : 20.0),
    );
  }

  /// Calculate the width of the [text] based on the applyed [style].
  Size calcTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textScaleFactor: WidgetsBinding.instance!.window.textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }
}

/// Draw of the triangle attached to the container of the first message sent by one of the users.
class Clip extends CustomPainter {
  final Color bgColor;

  /// Draw of the triangle attached to the container of the first message sent by one of the users.
  const Clip(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;
    var path = Path();
    path.lineTo(-10, 0);
    path.lineTo(0, 10);
    path.lineTo(5.5, 3);
    path.lineTo(3, 0);

    var path2 = Path();
    path2.addArc(Rect.fromCircle(center: Offset(3.75, 2), radius: 1.6), 3 * math.pi / 2 - 0.8, math.pi);

    canvas.drawPath(path2, paint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
