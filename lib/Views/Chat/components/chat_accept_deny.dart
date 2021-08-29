import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/active_chats_list_screen.dart';
import 'package:flutter/material.dart';

class ChatAcceptDenyInput extends StatefulWidget {
  final ChatViewModel chatViewModel;

  ChatAcceptDenyInput({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  _ChatAcceptDenyInputState createState() => _ChatAcceptDenyInputState();
}

class _ChatAcceptDenyInputState extends State<ChatAcceptDenyInput>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
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
          await widget.chatViewModel.acceptPendingChat();
          widget.chatViewModel.conversation.senderUserChat = ActiveChat();
          widget.chatViewModel.conversation.peerUserChat = ActiveChat();
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return ActiveChatsListScreen(chatViewModel: widget.chatViewModel);
            },
          )).then((value) {
            Navigator.pop(context);
          });
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
          await widget.chatViewModel.deleteChat();
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return ActiveChatsListScreen(chatViewModel: widget.chatViewModel);
            },
          )).then((value) {
            Navigator.pop(context);
          });
        },
      )
    ]);
  }
}
