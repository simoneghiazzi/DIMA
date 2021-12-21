import 'package:flutter/material.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';

/// Page of the chat with another User.
///
/// The chat contained into the chat page is the one setted as [currentChat] into the [ChatViewModel].
class ChatPageScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/chatPageScreen";

  /// Page of the chat with another User.
  ///
  /// The chat contained into the chat page is the one setted as [currentChat] into the [ChatViewModel].
  const ChatPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatPageBody(),
    );
  }
}
