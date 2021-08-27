import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatefulWidget {
  final ChatViewModel chatViewModel;
  final Function setStateCallback;
  final User userItem;

  ChatListItem({Key key, @required this.chatViewModel, @required this.userItem, @required this.setStateCallback})
      : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.userItem != null) {
      return Container(
        child: TextButton(
          child: Row(
            children: <Widget>[
              Material(
                // Profile image
                child: widget.userItem.getData()['profileImage'] == null
                    ? Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: Color(0xffaeaeae),
                      )
                    : Image.network(
                        widget.userItem.getData()['profileImage'],
                        fit: BoxFit.cover,
                        width: 50.0,
                        height: 50.0,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xff203152),
                                value: loadingProgress.expectedTotalBytes !=
                                            null &&
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return Icon(
                            Icons.account_circle,
                            size: 50.0,
                            color: Color(0xffaeaeae),
                          );
                        },
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              // Profile info
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: widget.userItem.collection == Collection.EXPERTS
                            ? Text(
                                widget.userItem.name +
                                    ' ' +
                                    widget.userItem.surname,
                                maxLines: 1,
                                style: TextStyle(color: Color(0xff203152)),
                              )
                            : Text(
                                widget.userItem.name,
                                maxLines: 1,
                                style: TextStyle(color: Color(0xff203152)),
                              ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            widget.chatViewModel.chatWithUser(widget.userItem);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatPageScreen(chatViewModel: widget.chatViewModel),
              ),
            ).then((value) {
              widget.setStateCallback();
            });
          },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xffE8E8E8)),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
