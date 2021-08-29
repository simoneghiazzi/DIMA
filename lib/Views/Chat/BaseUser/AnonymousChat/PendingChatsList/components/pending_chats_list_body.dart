import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/request.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar.dart';
import 'package:flutter/material.dart';

class PendingChatsListBody extends StatefulWidget {
  final ChatViewModel chatViewModel;

  PendingChatsListBody({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  _PendingChatsListBodyState createState() => _PendingChatsListBodyState();
}

class _PendingChatsListBodyState extends State<PendingChatsListBody> {
  @override
  void initState() {
    initPendingChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopBar(text: 'Requests'),
            ChatsListConstructor(
              chatViewModel: widget.chatViewModel,
              createUserCallback: createUserCallback,
            ),
          ],
        ),
      ),
    );
  }

  BaseUser createUserCallback(DocumentSnapshot doc) {
    BaseUser user = BaseUser();
    user.setFromDocument(doc);
    return user;
  }

  void initPendingChats() {
    widget.chatViewModel.conversation.senderUserChat = PendingChat();
    widget.chatViewModel.conversation.peerUserChat = Request();
  }
}
