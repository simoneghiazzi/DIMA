import 'package:dima_colombo_ghiazzi/Model/Chat/message.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MessageListItem extends StatefulWidget {
  final Message messageItem;
  final int index;

  MessageListItem({Key key, @required this.messageItem, @required this.index})
      : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> {
  @override
  Widget build(BuildContext context) {
    var chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    if (widget.messageItem != null) {
      if (widget.messageItem.getData()['idFrom'] ==
          chatViewModel.conversation.senderUser.id) {
        // Right (my message)
        return Row(
          children: <Widget>[
            Container(
              child: Text(
                widget.messageItem.getData()['content'],
                style: GoogleFonts.ubuntuCondensed(color: kPrimaryColor),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(15.0)),
              margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  chatViewModel.isLastMessageLeft(widget.index)
                      ? Material(
                          child: chatViewModel.conversation.peerUser
                                      .getData()['profileImage'] !=
                                  null
                              // Profile Image
                              ? Image.network(
                                  chatViewModel.conversation.peerUser
                                      .getData()['profileImage'],
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: kPrimaryColor,
                                        value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null &&
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                      ),
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 40,
                                  color: kPrimaryColor,
                                ))
                      : Container(width: 35.0),
                  // Message content
                  Container(
                    child: Text(
                      widget.messageItem.getData()['content'],
                      style: GoogleFonts.ubuntuCondensed(color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(15.0)),
                    margin: EdgeInsets.only(left: 10.0),
                  )
                ],
              ),
              // Time
              // widget.chatViewModel.isLastMessageLeft(index)
              //     ? Container(
              //         child: Text(
              //           DateFormat('dd MMM kk:mm').format(
              //               DateTime.fromMillisecondsSinceEpoch(
              //                   int.parse(document.get('timestamp')))),
              //           style: TextStyle(
              //               color: greyColor,
              //               fontSize: 12.0,
              //               fontStyle: FontStyle.italic),
              //         ),
              //         margin:
              //             EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
              //       )
              //     : Container()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
