import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatTextInput extends StatefulWidget {
  @override
  _ChatTextInputState createState() => _ChatTextInputState();
}

class _ChatTextInputState extends State<ChatTextInput> with WidgetsBindingObserver {
  final ScrollController listScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
          border: Border.all(color: kPrimaryDarkColor.withOpacity(0.2)),
        ),
        child: Row(
          children: <Widget>[
            // Edit text
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (value) {
                  listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                },
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontFamily: "UbuntuCondensed"),
                controller: chatViewModel.contentTextCtrl,
                decoration: InputDecoration(
                  fillColor: kPrimaryColor,
                  border: InputBorder.none,
                  hintText: 'Type your message...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (chatViewModel.contentTextCtrl.text.trim() != '') {
                        chatViewModel.sendMessage();
                      }
                    },
                    color: kPrimaryColor,
                  ),
                  isCollapsed: true,
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
