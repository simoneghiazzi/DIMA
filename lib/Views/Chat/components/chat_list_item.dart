import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Model/user.dart';
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
  final String userId;
  final Function createUserCallback;

  ChatListItem({Key key, @required this.userId, @required this.createUserCallback}) : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> with AutomaticKeepAliveClientMixin {
  UserViewModel userViewModel;
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;
  Size size;

  User userItem;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    super.build(context);
    if (userItem == null) {
      return FutureBuilder(
          future: chatViewModel.getPeerUserDoc(chatViewModel.chat.peerUser.collection, widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                userItem = widget.createUserCallback(snapshot.data.docs[0]);
                return listItem();
              } else {
                return Container();
              }
            } else {
              return buildListItemShimmer();
            }
          });
    } else {
      return listItem();
    }
  }

  Widget listItem() {
    return Container(
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            userItem is BaseUser
                ? CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 25.0,
                    child: Image.asset(
                      "assets/icons/logo.png",
                      height: size.height * 0.05,
                    ),
                  )
                : NetworkAvatar(
                    img: userItem.data['profilePhoto'],
                    radius: 25.0,
                  ),
            SizedBox(
              width: 15,
            ),
            // Profile info
            Flexible(
              child: userItem is BaseUser
                  ? Text(
                      userItem.name + (userViewModel.loggedUser is Expert ? " " + userItem.surname : ""),
                      maxLines: 1,
                      style: TextStyle(color: kPrimaryColor, fontSize: 18),
                    )
                  : Text(
                      userItem.name + " " + userItem.surname,
                      maxLines: 1,
                      style: TextStyle(color: kPrimaryColor, fontSize: 18),
                    ),
            ),
          ],
        ),
        onPressed: () {
          chatViewModel.chatWithUser(userItem);
          routerDelegate.pushPage(name: ChatPageScreen.route);
        },
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
