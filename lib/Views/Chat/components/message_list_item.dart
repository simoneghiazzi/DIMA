import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessageListItem extends StatefulWidget {
  final Message messageItem;
  final int index;

  MessageListItem({Key key, @required this.messageItem, @required this.index}) : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> {
  @override
  Widget build(BuildContext context) {
    var chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    if (widget.messageItem != null) {
      if (widget.messageItem.getData()['idFrom'] == chatViewModel.conversation.senderUser.id) {
        // Right (my message)
        return Row(
          children: [
            Container(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: Text(
                      widget.messageItem.getData()['content'],
                      style: GoogleFonts.ubuntuCondensed(color: kPrimaryColor),
                    ),
                  ),
                ),
                // Time
                Container(
                  padding: EdgeInsets.only(right: 8, bottom: 5),
                  child: Text(
                    DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(widget.messageItem.getData()['timestamp'])),
                    style: TextStyle(color: greyColor, fontSize: 10.0, fontStyle: FontStyle.italic),
                  ),
                )
              ]),
              width: 200.0,
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
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: Text(
                      widget.messageItem.getData()['content'],
                      style: GoogleFonts.ubuntuCondensed(color: Colors.white),
                    ),
                  ),
                ),
                // Time
                Container(
                  padding: EdgeInsets.only(right: 8, bottom: 5),
                  child: Text(
                    DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(widget.messageItem.getData()['timestamp'])),
                    style: TextStyle(color: greyColor, fontSize: 10.0, fontStyle: FontStyle.italic),
                  ),
                )
              ]),
              width: 200.0,
              decoration: BoxDecoration(color: kPrimaryDarkColor, borderRadius: BorderRadius.circular(15.0)),
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
}
