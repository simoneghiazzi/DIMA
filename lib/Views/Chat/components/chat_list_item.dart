import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListItem extends StatefulWidget {
  final User userItem;

  ChatListItem({Key key, @required this.userItem}) : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  @override
  Widget build(BuildContext context) {
    var chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    AppRouterDelegate routerDelegate =
        Provider.of<AppRouterDelegate>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    if (widget.userItem != null) {
      return Container(
        child: TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              widget.userItem.collection == Collection.BASE_USERS
                  ? CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 25.0,
                      child: Image.asset(
                        "assets/icons/logo.png",
                        height: size.height * 0.05,
                      ),
                    )
                  : NetworkAvatar(
                      img: widget.userItem.getData()['profilePhoto'],
                      radius: 25.0,
                    ),
              SizedBox(
                width: 15,
              ),
              // Profile info
              Flexible(
                child: widget.userItem.collection == Collection.EXPERTS
                    ? Text(
                        widget.userItem.name + " " + widget.userItem.surname,
                        maxLines: 1,
                        style: TextStyle(color: kPrimaryColor, fontSize: 18),
                      )
                    : Text(
                        widget.userItem.name +
                            (chatViewModel.conversation.senderUser.collection ==
                                    Collection.EXPERTS
                                ? " " + widget.userItem.surname
                                : ""),
                        maxLines: 1,
                        style: TextStyle(color: kPrimaryColor, fontSize: 18),
                      ),
              ),
            ],
          ),
          onPressed: () {
            chatViewModel.chatWithUser(widget.userItem);
            routerDelegate.pushPage(name: ChatPageScreen.route);
          },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(kPrimaryLightColor),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
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
