import 'package:intl/intl.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ChatListItem extends StatefulWidget {
  final Chat chatItem;
  final bool isSelected;
  final Function selectedItemCallback;

  ChatListItem({Key key, @required this.chatItem, @required this.isSelected, @required this.selectedItemCallback}) : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> with AutomaticKeepAliveClientMixin {
  UserViewModel userViewModel;
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;
  Size size;

  var _getPeerUserDocFuture;
  Chat _chatItem;
  User _peerUserItem;
  bool _isLoaded = false;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    _getPeerUserDocFuture = chatViewModel.getPeerUserDoc(widget.chatItem.peerUser.collection, widget.chatItem.peerUser.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    super.build(context);
    if (!_isLoaded) {
      return FutureBuilder(
        future: _getPeerUserDocFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              _isLoaded = true;
              _chatItem = widget.chatItem;
              widget.chatItem.peerUser.setFromDocument(snapshot.data.docs[0]);
              _peerUserItem = widget.chatItem.peerUser;
              return listItem();
            } else {
              return Container();
            }
          } else {
            return buildListItemShimmer();
          }
        },
      );
    } else {
      _chatItem = widget.chatItem;
      _chatItem.peerUser = _peerUserItem;
      // Check if there are not read messages and the chat is not the current chat
      if (_chatItem.notReadMessages > 0 && _chatItem.peerUser == chatViewModel.currentChat?.peerUser) {
        _chatItem.notReadMessages = 0;
        chatViewModel.setMessagesHasRead();
      }
      return listItem();
    }
  }

  Widget listItem() {
    return Container(
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  // Avatar
                  _peerUserItem is BaseUser
                      ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 25.0,
                          child: Image.asset(
                            "assets/icons/logo.png",
                            height: size.height * 0.05,
                          ),
                        )
                      : NetworkAvatar(
                          img: _peerUserItem.data['profilePhoto'],
                          radius: 25.0,
                        ),
                  SizedBox(
                    width: 15,
                  ),
                  // Profile info and lastMessage
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _peerUserItem is BaseUser
                            ? Text(
                                _peerUserItem.name + (userViewModel.loggedUser is Expert ? " " + _peerUserItem.surname : ""),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: TextStyle(color: kPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                              )
                            : Text(
                                _peerUserItem.name + " " + _peerUserItem.surname,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: TextStyle(color: kPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                        SizedBox(
                          height: size.height * 0.005,
                        ),
                        Text(
                          _chatItem.lastMessage,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: TextStyle(color: kPrimaryDarkColorTrasparent, fontSize: 12.0, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Time and lastMessageDatetime
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    Utils.isToday(_chatItem.lastMessageDateTime)
                        ? DateFormat("kk:mm").format(_chatItem.lastMessageDateTime)
                        : DateFormat("MM/dd/yyyy").format(_chatItem.lastMessageDateTime),
                    style: TextStyle(color: kPrimaryDarkColorTrasparent, fontSize: 12.0, fontStyle: FontStyle.italic),
                  ),
                  // Check if there are not read messages
                  if (_chatItem.notReadMessages > 0) ...[
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.red[600]),
                      child: Center(child: Text(_chatItem.notReadMessages.toString(), style: TextStyle(fontSize: 10.0, color: Colors.white))),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        onPressed: () {
          if (chatViewModel.currentChat?.peerUser?.id != _chatItem.peerUser.id) {
            chatViewModel.setCurrentChat(_chatItem);
            widget.selectedItemCallback();
            if (MediaQuery.of(context).orientation == Orientation.portrait) {
              routerDelegate.pushPage(name: ChatPageScreen.route);
            }
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              widget.isSelected && MediaQuery.of(context).orientation == Orientation.landscape ? kPrimaryButtonColor : kPrimaryLightColor),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
          ),
        ),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }

  Widget buildListItemShimmer() {
    return Shimmer.fromColors(
        baseColor: kPrimaryLightColor,
        highlightColor: Colors.grey[100],
        period: Duration(seconds: 1),
        child: Container(
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 25.0,
                  child: Image.asset(
                    "assets/icons/logo.png",
                    height: size.height * 0.05,
                  ),
                ),
              ],
            ),
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(kPrimaryLightColor),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
