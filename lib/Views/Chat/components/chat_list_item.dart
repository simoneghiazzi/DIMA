import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListItem extends StatefulWidget {
  final User userItem;
  final bool isExpert;

  ChatListItem({Key key, @required this.userItem, this.isExpert = false})
      : super(key: key);

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
                  : CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.network(
                          widget.userItem.getData()['profilePhoto'],
                          fit: BoxFit.cover,
                          width: 50.0,
                          height: 50.0,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                                value: loadingProgress.expectedTotalBytes !=
                                            null &&
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: Text(
                                  "${widget.userItem.name[0]}",
                                  style: TextStyle(
                                      color: kPrimaryColor, fontSize: 30),
                                ));
                          },
                        ),
                      ),
                    ),
              SizedBox(
                width: 15,
              ),
              // Profile info
              Flexible(
                child: widget.userItem.collection == Collection.EXPERTS
                    ? Text(
                        widget.userItem.name + ' ' + widget.userItem.surname,
                        maxLines: 1,
                        style: TextStyle(color: kPrimaryColor, fontSize: 18),
                      )
                    : widget.isExpert
                        ? Text(
                            widget.userItem.name +
                                ' ' +
                                widget.userItem.surname,
                            maxLines: 1,
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 18),
                          )
                        : Text(
                            widget.userItem.name,
                            maxLines: 1,
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 18),
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
