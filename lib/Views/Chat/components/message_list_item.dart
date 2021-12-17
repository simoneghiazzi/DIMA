import 'package:intl/intl.dart' as Date;
import 'dart:math' as math;
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageListItem extends StatefulWidget {
  final Message messageItem;
  final bool sameNextIdFrom;

  MessageListItem({Key key, @required this.messageItem, this.sameNextIdFrom}) : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> {
  ChatViewModel chatViewModel;
  UserViewModel userViewModel;

  Size size;
  double _containerWidth;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    _containerWidth = calcTextSize(widget.messageItem.data["content"], TextStyle(fontFamily: "UbuntuCondensed")).width;
    _containerWidth += MediaQuery.of(context).orientation == Orientation.portrait ? size.width / 5 : size.width / 10;
    if (widget.messageItem != null) {
      if (widget.messageItem.data["idFrom"] == userViewModel.loggedUser.id) {
        // Right (my message)
        return Row(
          children: [
            buildMessageBubble(false),
            if (!(widget.sameNextIdFrom ?? false))
              Container(
                // Same top as the message bubble margin
                margin: EdgeInsets.only(top: 20.0),
                child: CustomPaint(painter: Clip(kPrimaryLightColor)),
              ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
        );
      } else {
        // Left (peer message)
        return Row(
          children: [
            if (!(widget.sameNextIdFrom ?? false))
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Container(
                  // Same top as the message bubble margin
                  margin: EdgeInsets.only(top: 20.0),
                  child: CustomPaint(painter: Clip(kPrimaryColor)),
                ),
              ),
            buildMessageBubble(true)
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildMessageBubble(bool peerMessage) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).orientation == Orientation.portrait ? size.width / 1.5 : size.width / 2.5),
      width: _containerWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              child: Text(
                widget.messageItem.data["content"],
                style: TextStyle(fontFamily: "UbuntuCondensed", color: peerMessage ? Colors.white : kPrimaryColor),
              ),
            ),
          ),
          // Time
          Container(
            padding: EdgeInsets.only(right: 8, bottom: 5),
            child: Text(
              Date.DateFormat("kk:mm").format(widget.messageItem.timestamp),
              style: TextStyle(color: kPrimaryGreyColor, fontSize: 10.5, fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: peerMessage ? kPrimaryColor : kPrimaryLightColor,
        borderRadius: widget.sameNextIdFrom ?? false
            ? BorderRadius.circular(12.5)
            : BorderRadius.only(
                topLeft: Radius.circular(peerMessage ? 0 : 12.5),
                topRight: Radius.circular(!peerMessage ? 0 : 12.5),
                bottomLeft: Radius.circular(12.5),
                bottomRight: Radius.circular(12.5),
              ),
      ),
      // Same top as the Clip margin
      margin: EdgeInsets.only(top: widget.sameNextIdFrom ?? false ? 2.0 : 20.0),
    );
  }

  Size calcTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textScaleFactor: WidgetsBinding.instance.window.textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }
}

class Clip extends CustomPainter {
  final Color bgColor;

  Clip(this.bgColor);

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
