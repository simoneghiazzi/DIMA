import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopBarChats extends StatelessWidget {
  final String text;
  final CircleAvatar circleAvatar;
  final NetworkAvatar networkAvatar;
  final bool isPortrait;

  TopBarChats({Key key, @required this.text, this.circleAvatar, this.networkAvatar, this.isPortrait = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    ChatViewModel chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height / 8,
      color: kPrimaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SafeArea(
            child: SizedBox(
              width: size.width,
              child: Padding(
                padding: EdgeInsets.only(right: 20, top: 8),
                child: Row(
                  children: <Widget>[
                    isPortrait
                        ? Container()
                        : IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              routerDelegate.pop();
                            },
                          ),
                    SizedBox(
                      width: size.width * 0.01,
                    ),
                    circleAvatar ?? networkAvatar ?? Container(),
                    circleAvatar != null || networkAvatar != null
                        ? SizedBox(
                            width: size.width * 0.04,
                          )
                        : Container(),
                    Flexible(
                      child: GestureDetector(
                        child: Text(
                          text,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          if (networkAvatar != null) {
                            routerDelegate.pushPage(name: ExpertProfileScreen.route, arguments: chatViewModel.conversation.peerUser as Expert);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
