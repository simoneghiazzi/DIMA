import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';

/// Top bar of the chat page.
///
/// It takes a [text] and one between a [circleAvatar] and a [networkAvatar].
/// If the [networkAvatar] is not null, the user is an [Expert] and so it adds a
/// [GestureDetector] in order to push the [ExpertProfileScreen] when the user taps
/// the bar.
///
/// If the orientation of the device is portrait, it also shows a back button that resets
/// the current chat and the `chatting with` field of the DB before popping the page.
class ChatTopBar extends StatelessWidget {
  final String text;
  final CircleAvatar? circleAvatar;
  final NetworkAvatar? networkAvatar;

  /// Top bar of the chat page.
  ///
  /// It takes a [circleAvatar] icon that is shown before the [text].
  ///
  /// If the orientation of the device is portrait, it also shows a back button that resets
  /// the current chat and the `chatting with` field of the DB before popping the page.
  const ChatTopBar.circleAvatar({Key? key, required this.text, required this.circleAvatar})
      : networkAvatar = null,
        super(key: key);

  /// Top bar of the chat page.
  ///
  /// It takes a [networkAvatar] image that is shown before the [text].
  ///
  /// If the orientation of the device is portrait, it also shows a back button that resets
  /// the current chat and the `chatting with` field of the DB before popping the page.
  const ChatTopBar.networkAvatar({Key? key, required this.text, required this.networkAvatar})
      : circleAvatar = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // View Models
    ChatViewModel chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    // Router Delegate
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    return Container(
      color: kPrimaryColor,
      child: SafeArea(
        child: Container(
          height: 9.5.h,
          decoration: BoxDecoration(color: kPrimaryColor),
          child: Row(
            children: <Widget>[
              // If the orientation is portrait, show the back button
              if (MediaQuery.of(context).orientation == Orientation.portrait) ...[
                Container(
                  child: InkWell(
                    child: InkResponse(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        chatViewModel.resetChattingWith();
                        chatViewModel.resetCurrentChat();
                        routerDelegate.pop();
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 2.5.w, right: 2.5.w),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 25)),
                    ),
                  ),
                ),
              ] else
                SizedBox(width: 3.w),
              Flexible(
                child: GestureDetector(
                  child: Row(
                    children: [
                      // Show the circle avatar if it is not null, else show the network avatar
                      if (circleAvatar != null) ...[
                        circleAvatar!,
                        SizedBox(width: 2.5.w),
                      ] else ...[
                        networkAvatar!,
                        SizedBox(width: 2.5.w),
                      ],
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.5.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  onTap: () {
                    // If the network avatar is not null (the user is an Expert) push the EpertProfileScreen
                    if (networkAvatar != null) {
                      routerDelegate.pushPage(name: ExpertProfileScreen.route, arguments: chatViewModel.currentChat.value!.peerUser as Expert);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
