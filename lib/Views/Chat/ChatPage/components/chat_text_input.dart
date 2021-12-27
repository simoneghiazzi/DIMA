import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/components/message_list_constructor.dart';

/// It is used into the [ChatPageScreen] for sending new messages.
/// It contains the text input field and the send message button.
///
/// It takes the [scrollController] of the [MessageListConstructor] in order to scroll down the list
/// when a new message is sent.
class ChatTextInput extends StatelessWidget {
  final ScrollController scrollController;

  /// It is used into the [ChatPageScreen] for sending new messages.
  /// It contains the text input field and the send message button.
  ///
  /// It takes the [scrollController] of the [MessageListConstructor] in order to scroll down the list
  /// when a new message is sent.
  const ChatTextInput({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // View Models
    ChatViewModel chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    return Container(
      color: Colors.transparent,
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
              padding: EdgeInsets.only(left: 20, right: 10),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                textAlignVertical: TextAlignVertical.top,
                maxLines: 5,
                minLines: 1,
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
          Container(
            width: 50,
            height: 50,
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                  shadowColor: MaterialStateProperty.all<Color>(kPrimaryLightColor)),
              onPressed: () {
                // Send message and scroll down the message list view
                chatViewModel.sendMessage();
                if (scrollController.hasClients) {
                  scrollController.jumpTo(scrollController.position.minScrollExtent);
                }
              },
              child: Icon(Icons.send, size: 22.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
