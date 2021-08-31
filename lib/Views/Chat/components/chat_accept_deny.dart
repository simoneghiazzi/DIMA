import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/active_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatAcceptDenyInput extends StatefulWidget {
  @override
  _ChatAcceptDenyInputState createState() => _ChatAcceptDenyInputState();
}

class _ChatAcceptDenyInputState extends State<ChatAcceptDenyInput> {
  @override
  Widget build(BuildContext context) {
    var chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    AppRouterDelegate routerDelegate =
        Provider.of<AppRouterDelegate>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      InkWell(
        child: Container(
          width: size.width * 0.3,
          padding: EdgeInsets.only(top: 2, bottom: 2),
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.green,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check,
                color: Colors.white,
                size: 25,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Accept",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        onTap: () async {
          await chatViewModel.acceptPendingChat();
          chatViewModel.conversation.senderUserChat = ActiveChat();
          chatViewModel.conversation.peerUserChat = ActiveChat();
          routerDelegate.replaceAllButNumber(2, [
            RouteSettings(name: ActiveChatsListScreen.route),
            RouteSettings(name: ChatPageScreen.route)
          ]);
        },
      ),
      SizedBox(
        width: size.width * 0.1,
      ),
      InkWell(
        child: Container(
          width: size.width * 0.3,
          padding: EdgeInsets.only(top: 2, bottom: 2),
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.red,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
                size: 25,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Refuse",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        onTap: () async {
          await chatViewModel.deleteChat();
          routerDelegate.replaceAllButNumber(2, [
            RouteSettings(name: ActiveChatsListScreen.route),
          ]);
        },
      )
    ]);
  }
}
