import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class ChatTextInput extends StatefulWidget {
  final ChatViewModel chatViewModel;

  ChatTextInput({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  _ChatTextInputState createState() => _ChatTextInputState();
}

class _ChatTextInputState extends State<ChatTextInput> with WidgetsBindingObserver {
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
        child: Row(
          children: <Widget>[
            // Edit text
            Flexible(
              child: Container(
                child: TextField(
                  onSubmitted: (value) {
                    listScrollController.animateTo(0.0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  },
                  style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
                  controller: widget.chatViewModel.textController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: greyColor),
                  ),
                  focusNode: focusNode,
                ),
              ),
            ),

            // Button send message
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (widget.chatViewModel.textController.text.trim() != '') {
                      widget.chatViewModel.sendMessage();
                      focusNode.requestFocus();
                    }
                  },
                  color: kPrimaryColor,
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
