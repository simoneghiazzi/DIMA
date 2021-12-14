import 'package:intl/intl.dart' as Date;
import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageListItem extends StatefulWidget {
  final Message messageItem;
  final int index;

  MessageListItem({Key key, @required this.messageItem, @required this.index}) : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> {
  ChatViewModel chatViewModel;
  UserViewModel userViewModel;

  double _containerWidth;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _containerWidth = calcTextSize(widget.messageItem.data['content'], TextStyle(fontFamily: "UbuntuCondensed")).width + size.width / 5;
    if (widget.messageItem != null) {
      if (widget.messageItem.data['idFrom'] == userViewModel.loggedUser.id) {
        // Right (my message)
        return Row(
          children: [
            Container(
              width: _containerWidth < size.width / 1.5 ? _containerWidth : size.width / 1.5,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: Text(
                      widget.messageItem.data['content'],
                      style: TextStyle(fontFamily: "UbuntuCondensed", color: kPrimaryColor),
                    ),
                  ),
                ),
                // Time
                Container(
                  padding: EdgeInsets.only(right: 8, bottom: 5),
                  child: Text(
                    Date.DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(widget.messageItem.data['timestamp'])),
                    style: TextStyle(color: greyColor, fontSize: 10.0, fontStyle: FontStyle.italic),
                  ),
                )
              ]),
              decoration: BoxDecoration(color: kPrimaryLightColor, borderRadius: BorderRadius.circular(15.0)),
              margin: EdgeInsets.only(bottom: 10.0),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Row(
          children: [
            Container(
              width: _containerWidth < size.width / 1.5 ? _containerWidth : size.width / 1.5,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: Text(
                      widget.messageItem.data['content'],
                      style: TextStyle(fontFamily: "UbuntuCondensed", color: Colors.white),
                    ),
                  ),
                ),
                // Time
                Container(
                  padding: EdgeInsets.only(right: 8, bottom: 5),
                  child: Text(
                    Date.DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(widget.messageItem.data['timestamp'])),
                    style: TextStyle(color: greyColor, fontSize: 10.0, fontStyle: FontStyle.italic),
                  ),
                )
              ]),
              decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(15.0)),
              margin: EdgeInsets.only(bottom: 10.0),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        );
      }
    } else {
      return SizedBox.shrink();
    }
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
