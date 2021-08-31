import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/request.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingChatsListBody extends StatefulWidget {
  @override
  _PendingChatsListBodyState createState() => _PendingChatsListBodyState();
}

class _PendingChatsListBodyState extends State<PendingChatsListBody> {
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
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
    chatViewModel.conversation.senderUserChat = PendingChat();
    chatViewModel.conversation.peerUserChat = Request();
  }
}
