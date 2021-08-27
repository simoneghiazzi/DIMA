import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/request.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:flutter/material.dart';

import '../../../../../../constants.dart';

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
    initChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: kPrimaryColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      "Requests",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            ChatsListConstructor(
                chatViewModel: widget.chatViewModel,
                createUserCallback: createUserCallback),
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

  void initChats() {
    widget.chatViewModel.conversation.senderUserChat = PendingChat();
    widget.chatViewModel.conversation.peerUserChat = Request();
  }
}
