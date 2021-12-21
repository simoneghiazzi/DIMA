import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/components/message_list_constructor.dart';

/// It is used into the [ChatPageScreen] for sending new messages.
/// It contains the text input field and the send message button.
///
/// It takes the [scrollController] of the [MessageListConstructor] in order to scroll down the list
/// when a new message is sent.
class ChatTextInput extends StatelessWidget {
  final ScrollController? scrollController;

  /// It is used into the [ChatPageScreen] for sending new messages.
  /// It contains the text input field and the send message button.
  ///
  /// It takes the [scrollController] of the [MessageListConstructor] in order to scroll down the list
  /// when a new message is sent.
  const ChatTextInput({Key? key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // View Models
    ChatViewModel chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0, top: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.1), spreadRadius: 4, blurRadius: 6, offset: Offset(0, 3))],
                border: Border.all(color: kPrimaryDarkColor.withOpacity(0.2)),
              ),
              padding: EdgeInsets.only(left: 20),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
                style: TextStyle(fontFamily: "UbuntuCondensed"),
                controller: chatViewModel.contentTextCtrl,
                decoration: InputDecoration(
                  fillColor: kPrimaryColor,
                  border: InputBorder.none,
                  hintText: "Type your message...",
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            child: Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(bottom: 1),
              decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(40.0)),
              child: Container(
                padding: EdgeInsets.only(left: 3),
                child: Icon(Icons.send, size: 22.0, color: Colors.white),
              ),
            ),
            onTap: () {
              // Send message and scroll down the message list view
              chatViewModel.sendMessage();
              if (scrollController!.hasClients) {
                scrollController!.jumpTo(scrollController!.position.minScrollExtent);
              }
            },
          ),
        ],
      ),
    );
  }
}
