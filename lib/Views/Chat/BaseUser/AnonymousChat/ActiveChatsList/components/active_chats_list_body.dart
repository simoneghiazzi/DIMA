import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/request.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/PendingChatsList/pending_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveChatsListBody extends StatefulWidget {
  @override
  _ActiveChatsListBodyState createState() => _ActiveChatsListBodyState();
}

class _ActiveChatsListBodyState extends State<ActiveChatsListBody> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  StreamSubscription<bool> subscriberNewRandomUser;
  StreamSubscription subscriberNewChatMessage;
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    initActiveChats();
    subscriberNewRandomUser = subscribeToNewRandomUser();
    subscriberNewChatMessage = subscribeToNewChatMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder(
                future: chatViewModel.hasPendingChats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data) {
                      return TopBar(
                        text: 'Anonymous',
                        button: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 8, right: 8, top: 2, bottom: 2),
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kPrimaryLightColor,
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.notification_add,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "Requests",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            routerDelegate.pushPage(
                                name: PendingChatsListScreen.route);
                          },
                        ),
                      );
                    } else {
                      return TopBar(text: 'Anonymous');
                    }
                  }
                  return Container();
                },
              ),
              ChatsListConstructor(
                createUserCallback: createUserCallback,
              ),
            ],
          ),
        ),
        Align(
          alignment:
              Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1),
          child: FloatingActionButton(
            onPressed: () {
              LoadingDialog.show(context, _keyLoader,
                  text: 'Looking for new random user...');
              chatViewModel.getNewRandomUser();
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: kPrimaryColor,
            child: const Icon(
              Icons.add,
              size: 40.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ));
  }

  BaseUser createUserCallback(DocumentSnapshot doc) {
    BaseUser user = BaseUser();
    user.setFromDocument(doc);
    return user;
  }

  void initActiveChats() {
    chatViewModel.conversation.senderUserChat = ActiveChat();
    chatViewModel.conversation.peerUserChat = ActiveChat();
  }

  void initNewRandomChats() {
    chatViewModel.conversation.senderUserChat = Request();
    chatViewModel.conversation.peerUserChat = PendingChat();
  }

  StreamSubscription subscribeToNewChatMessage() {
    return chatViewModel.newChat.listen((event) {
      chatViewModel.loadChats();
    });
  }

  StreamSubscription<bool> subscribeToNewRandomUser() {
    return chatViewModel.isNewRandomUser.listen((isNewRandomUser) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (isNewRandomUser) {
        initNewRandomChats();
        routerDelegate.pushPage(name: ChatPageScreen.route);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('No match found.'),
          duration: const Duration(seconds: 5),
        ));
      }
    });
  }

  @override
  void dispose() {
    subscriberNewRandomUser.cancel();
    subscriberNewChatMessage.cancel();
    super.dispose();
  }
}
