import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/expert_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/request.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/PendingChatsList/pending_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar_experts.dart';
import 'package:dima_colombo_ghiazzi/Views/Settings/user_profile_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class ActiveChatsExpertsBody extends StatefulWidget {
  final AuthViewModel authViewModel;
  final UserViewModel userViewModel;

  ActiveChatsExpertsBody(
      {Key key, @required this.authViewModel, @required this.userViewModel})
      : super(key: key);

  @override
  _ActiveChatsExpertsBodyState createState() => _ActiveChatsExpertsBodyState();
}

class _ActiveChatsExpertsBodyState extends State<ActiveChatsExpertsBody> {
  bool newPendingChats;
  ChatViewModel chatViewModel;

  @override
  void initState() {
    super.initState();
    chatViewModel = ChatViewModel(widget.userViewModel.loggedUser);
    chatViewModel.conversation.senderUserChat = ActiveChat();
    chatViewModel.conversation.peerUserChat = ActiveChat();
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
                future: chatViewModel.hasPendingChats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data) {
                      return TopBarExperts(
                        text: 'Chats',
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PendingChatsListScreen(
                                      chatViewModel: chatViewModel)),
                            );
                          },
                        ),
                      );
                    } else {
                      return TopBarExperts(text: 'Chats');
                    }
                  }
                  return Container();
                },
              ),
              ChatsListConstructor(
                chatViewModel: chatViewModel,
                createUserCallback: createUserCallback,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.lerp(Alignment.topRight, Alignment.center, 0.11),
          child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                            user: widget.userViewModel.loggedUser)));
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: Colors.lightBlue[200],
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.network(
                    widget.userViewModel.loggedUser.getData()['profilePhoto'],
                    fit: BoxFit.cover,
                    width: 60.0,
                    height: 60.0,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 57.0,
                        height: 57.0,
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                          value: loadingProgress.expectedTotalBytes != null &&
                                  loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
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
                            "${widget.userViewModel.loggedUser.name[0]}",
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 30),
                          ));
                    },
                  ),
                ),
              )),
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

  void initNewRandomChats() {
    chatViewModel.conversation.senderUserChat = Request();
    chatViewModel.conversation.peerUserChat = PendingChat();
  }
}
