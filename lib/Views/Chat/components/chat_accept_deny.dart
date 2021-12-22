import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';

/// It is used for new [PendingChat] and it contains the accept/deny buttons.
class ChatAcceptDenyInput extends StatelessWidget {
  /// It is used for new [PendingChat] and it contains the accept/deny buttons.
  const ChatAcceptDenyInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // View Models
    ChatViewModel chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    // Router Delegate
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    return Column(
      children: [
        Divider(color: kPrimaryLightColor),
        Padding(
          padding: EdgeInsets.only(bottom: 25, top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 25.w, minHeight: 20.h),
                  padding: EdgeInsets.only(top: 2, bottom: 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.green),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.check, color: Colors.white, size: 25),
                      SizedBox(width: 5),
                      Text("Accept", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                onTap: () {
                  chatViewModel.acceptPendingChat();
                  if (MediaQuery.of(context).orientation == Orientation.portrait) {
                    // If the orientation is portrait, replace the PendingChatListScreen and the chat page with the new ChatPageScreen
                    routerDelegate.replaceAllButNumber(3, routeSettingsList: [RouteSettings(name: ChatPageScreen.route)]);
                  } else {
                    // If the orientation is landscape, replace the PendingChatListScreen and the ChatPageScreen, so it returns to the
                    // AnonymousChatListScreen
                    routerDelegate.replaceAllButNumber(3);
                  }
                },
              ),
              SizedBox(width: 10.w),
              InkWell(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 25.w, minHeight: 20.h),
                  padding: EdgeInsets.only(top: 2, bottom: 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.red),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.delete, color: Colors.white, size: 25),
                      SizedBox(width: 5),
                      Text("Refuse", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                onTap: () {
                  chatViewModel.denyPendingChat();
                  // If deny, returns to the PendingChatListScreen
                  routerDelegate.pop();
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
