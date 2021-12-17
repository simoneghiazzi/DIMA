import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatTextInput extends StatefulWidget {
  final ScrollController scrollController;

  const ChatTextInput({Key key, this.scrollController}) : super(key: key);

  @override
  _ChatTextInputState createState() => _ChatTextInputState();
}

class _ChatTextInputState extends State<ChatTextInput> with WidgetsBindingObserver {
  ChatViewModel chatViewModel;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
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
                  sendMessage();
                  if (widget.scrollController.hasClients) {
                    widget.scrollController.jumpTo(widget.scrollController.position.minScrollExtent);
                  }
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
                      sendMessage();
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

  void sendMessage() {
    if (chatViewModel.contentTextCtrl.text.trim() != '') {
      chatViewModel.sendMessage();
      if (widget.scrollController.hasClients) {
        widget.scrollController.jumpTo(widget.scrollController.position.minScrollExtent);
      }
    }
  }
}
