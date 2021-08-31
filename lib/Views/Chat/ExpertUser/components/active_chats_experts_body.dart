import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/expert_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/request.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/PendingChatsList/pending_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar_experts.dart';
import 'package:dima_colombo_ghiazzi/Views/Settings/user_profile_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveChatsExpertsBody extends StatefulWidget {
  @override
  _ActiveChatsExpertsBodyState createState() => _ActiveChatsExpertsBodyState();
}

class _ActiveChatsExpertsBodyState extends State<ActiveChatsExpertsBody> {
  bool newPendingChats;
  ChatViewModel chatViewModel;
  ExpertViewModel expertViewModel;
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    super.initState();
    expertViewModel = Provider.of<ExpertViewModel>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    authViewModel.setNotification(expertViewModel.loggedUser);
    initActiveChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder(
                future: chatViewModel.loadChats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TopBarExperts(
                      text: 'Chats',
                      button: InkWell(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.network(
                                expertViewModel.loggedUser
                                    .getData()['profilePhoto'],
                                fit: BoxFit.cover,
                                width: 60.0,
                                height: 60.0,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    width: 57.0,
                                    height: 57.0,
                                    child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                      value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null &&
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, object, stackTrace) {
                                  return CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        "${expertViewModel.loggedUser.name[0]}",
                                        style: TextStyle(
                                            color: kPrimaryColor, fontSize: 30),
                                      ));
                                },
                              ),
                            ),
                          ),
                          onTap: () {
                            routerDelegate.pushPage(
                                name: UserProfileScreen.route,
                                arguments: expertViewModel.loggedUser);
                          }),
                    );
                  }
                  return Container();
                },
              ),
              ChatsListConstructor(
                isExpert: true,
                createUserCallback: createUserCallback,
              ),
            ],
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
    chatViewModel.conversation.peerUserChat = ExpertChat();
  }
}
