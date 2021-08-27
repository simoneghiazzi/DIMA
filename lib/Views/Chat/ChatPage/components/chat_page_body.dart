import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_accept_deny.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_text_input.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/messages_list_constructor.dart';
import 'package:flutter/material.dart';

class ChatPageBody extends StatefulWidget {
  final ChatViewModel chatViewModel;

  ChatPageBody({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  _ChatPageBodyState createState() => _ChatPageBodyState();
}

class _ChatPageBodyState extends State<ChatPageBody>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.chatViewModel.updateChattingWith();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              MessagesListConstructor(chatViewModel: widget.chatViewModel),
              // Input content
              widget.chatViewModel.conversation.senderUserChat.chatCollection ==
                      PendingChat().chatCollection
                  ? ChatAcceptDenyInput(chatViewModel: widget.chatViewModel)
                  : ChatTextInput(chatViewModel: widget.chatViewModel),
            ],
          ),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Future<bool> onBackPress() async {
    widget.chatViewModel.resetChattingWith();
    if (!await widget.chatViewModel.hasMessages())
      await widget.chatViewModel.deleteChat();
    Navigator.pop(context);
    return Future.value(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      widget.chatViewModel.updateChattingWith();
    } else {
      widget.chatViewModel.resetChattingWith();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
