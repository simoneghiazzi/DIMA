import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Profile/Expert/expert_profile_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopBarChats extends StatelessWidget {
  final String text;
  final CircleAvatar circleAvatar;

  TopBarChats({
    Key key,
    @required this.text,
    this.circleAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate =
        Provider.of<AppRouterDelegate>(context, listen: false);
    ChatViewModel chatViewModel =
        Provider.of<ChatViewModel>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SafeArea(
          child: SizedBox(
            width: size.width,
            child: Padding(
              padding: EdgeInsets.only(right: 30, top: 12, bottom: 7),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: kPrimaryColor,
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      routerDelegate.pop();
                    },
                  ),
                  circleAvatar ?? Container(),
                  circleAvatar != null
                      ? SizedBox(
                          width: size.width * 0.04,
                        )
                      : Container(),
                  Flexible(
                    child: GestureDetector(
                      child: Text(
                        text,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        if (circleAvatar != null) {
                          routerDelegate.pushPage(
                              name: ExpertProfileScreen.route,
                              arguments: chatViewModel.conversation.peerUser
                                  as Expert);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Color(0xFFD9D9D9),
          height: 1.5,
        ),
      ],
    );
  }
}
