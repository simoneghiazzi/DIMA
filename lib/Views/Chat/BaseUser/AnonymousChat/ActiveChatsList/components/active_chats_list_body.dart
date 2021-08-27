import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/PendingChatsList/pending_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';

class ActiveChatsListBody extends StatefulWidget {
  final ChatViewModel chatViewModel;

  ActiveChatsListBody({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  _ActiveChatsListBodyState createState() => _ActiveChatsListBodyState();
}

class _ActiveChatsListBodyState extends State<ActiveChatsListBody> {
  @override
  void initState() {
    initChats();
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
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Anon",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 2),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.lightBlue[200],
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.archive,
                              color: Colors.indigo[500],
                              size: 20,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Requests",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PendingChatsListScreen(
                                  chatViewModel: widget.chatViewModel)),
                        ).then((value) {
                          initChats();
                          setState(() {});
                        });
                      },
                    ),
                    InkWell(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.lightBlue[200],
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.indigo[500],
                                size: 20,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "Add New",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          LoadingDialog.show(context,
                              text: 'Looking for new random user...');
                          widget.chatViewModel.newRandomChat().then((value) {
                            LoadingDialog.hide(context);
                            if (value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPageScreen(
                                    chatViewModel: widget.chatViewModel,
                                  ),
                                ),
                              ).then((value) {
                                initChats();
                                setState(() {});
                              });
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text('No more users.'),
                                duration: const Duration(seconds: 5),
                              ));
                            }
                          });
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Row(children: <Widget>[
                    IconButton(
                      splashColor: Colors.grey,
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ])),
            ),
            ChatsListConstructor(
                chatViewModel: widget.chatViewModel, userItem: BaseUser()),
          ],
        ),
      ),
    );
  }

  void initChats() {
    widget.chatViewModel.conversation.senderUserChat = ActiveChat();
    widget.chatViewModel.conversation.peerUserChat = ActiveChat();
  }
}
