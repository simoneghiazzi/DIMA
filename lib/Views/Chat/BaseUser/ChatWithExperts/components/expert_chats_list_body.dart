import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/expert_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Map/map_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class ExpertChatsListBody extends StatefulWidget {
  final ChatViewModel chatViewModel;

  ExpertChatsListBody({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  _ExpertChatsListBodyState createState() => _ExpertChatsListBodyState();
}

class _ExpertChatsListBodyState extends State<ExpertChatsListBody> {
  @override
  void initState() {
    initChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(
      children: <Widget>[
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(right: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(
                          Icons.arrow_back,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        "Experts",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              ChatsListConstructor(
                chatViewModel: widget.chatViewModel,
                createUserCallback: createUserCallback,
              ),
            ],
          ),
        ),
        Align(
          alignment:
              Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1),
          child: FloatingActionButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return MapScreen(
                      chatViewModel: widget.chatViewModel,
                    );
                  },
                ),
              ).then((value) {
                initChats();
                setState(() {});
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.lightBlue[200],
            child: const Icon(
              Icons.add,
              size: 40.0,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    ));
  }

  Expert createUserCallback(DocumentSnapshot doc) {
    Expert user = Expert();
    user.setFromDocument(doc);
    return user;
  }

  void initChats() {
    widget.chatViewModel.conversation.senderUserChat = ExpertChat();
    widget.chatViewModel.conversation.peerUserChat = ActiveChat();
  }
}
