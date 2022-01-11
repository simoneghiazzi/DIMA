import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/components/rounded_button.dart';
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
              RoundedButton(
                text: "Accept",
                prefixIcon: Icon(Icons.check, color: Colors.white, size: 25),
                color: Colors.green,
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
              SizedBox(width: 15.w),
              RoundedButton(
                text: "Deny",
                prefixIcon: Icon(Icons.delete, color: Colors.white, size: 25),
                color: Colors.red,
                onTap: () {
                  chatViewModel.denyPendingChat();
                  // If deny, returns to the PendingChatListScreen
                  routerDelegate.pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
