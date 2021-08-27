import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
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
    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Button accept
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    await widget.chatViewModel.acceptPendingChat();
                    widget.chatViewModel.conversation.senderUserChat =
                        ActiveChat();
                    widget.chatViewModel.conversation.peerUserChat =
                        ActiveChat();
                    Navigator.pop(context);
                  },
                  color: Colors.green,
                ),
              ),
              color: Colors.white,
            ),
            // Button deny
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () async {
                    await widget.chatViewModel.deleteChat();
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                ),
              ),
              color: Colors.white,
            ),
          ],
        ),
        width: double.infinity,
        height: 50.0,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: lightGreyColor, width: 0.5)),
            color: Colors.white),
      )
    ]);
  }
}
