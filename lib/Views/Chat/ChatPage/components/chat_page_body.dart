import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/active_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_text_input.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/messages_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      child: Padding(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
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
                            widget.chatViewModel.conversation.peerUser
                                        .collection ==
                                    Collection.EXPERTS
                                ? Row(children: <Widget>[
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      child: ClipOval(
                                        child: Image.network(
                                          widget.chatViewModel.conversation
                                              .peerUser
                                              .getData()['profilePhoto'],
                                          fit: BoxFit.cover,
                                          width: 60.0,
                                          height: 60.0,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
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
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, object, stackTrace) {
                                            return CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.white,
                                                child: Text(
                                                  "${widget.chatViewModel.conversation.peerUser.name[0]}",
                                                  style: TextStyle(
                                                      color: kPrimaryColor,
                                                      fontSize: 30),
                                                ));
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    Text(
                                      widget.chatViewModel.conversation.peerUser
                                              .getData()['name'] +
                                          " " +
                                          widget.chatViewModel.conversation
                                              .peerUser
                                              .getData()['surname'],
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor),
                                    )
                                  ])
                                : Row(children: <Widget>[
                                    Icon(
                                      Icons.account_circle,
                                      size: 50,
                                      color: kPrimaryColor,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.03,
                                    ),
                                    Text(
                                      widget.chatViewModel.conversation.peerUser
                                          .getData()['name'],
                                      style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor),
                                    )
                                  ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // List of messages
                MessagesListConstructor(chatViewModel: widget.chatViewModel),
                // Input content
                widget.chatViewModel.conversation.senderUserChat
                            .chatCollection ==
                        PendingChat().chatCollection
                    ? InkWell(
                        child: Container(
                          width: size.width * 0.4,
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: kPrimaryLightColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.arrow_upward,
                                color: kPrimaryColor,
                                size: 20,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "Handle",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          _onHandleChat(context);
                        },
                      )
                    : ChatTextInput(chatViewModel: widget.chatViewModel),
              ],
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: 10, left: 5, right: 5),
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

  _onHandleChat(context) {
    Alert(
      context: context,
      title: "ACCEPT CHAT FROM " +
          widget.chatViewModel.conversation.peerUser
              .getData()['name']
              .toString()
              .toUpperCase() +
          "?",
      image: Image.asset("assets/icons/small_logo.png"),
      closeIcon: Icon(
        Icons.close,
        color: kPrimaryColor,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "ACCEPT",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            await widget.chatViewModel.acceptPendingChat();
            widget.chatViewModel.conversation.senderUserChat = ActiveChat();
            widget.chatViewModel.conversation.peerUserChat = ActiveChat();
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return ActiveChatsListScreen(
                    chatViewModel: widget.chatViewModel);
              },
            )).then((value) {
              Navigator.pop(context);
            });
          },
          color: kPrimaryColor,
        ),
        DialogButton(
          child: Text(
            "REFUSE",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            await widget.chatViewModel.deleteChat();
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return ActiveChatsListScreen(
                    chatViewModel: widget.chatViewModel);
              },
            )).then((value) {
              Navigator.pop(context);
            });
          },
          color: Colors.red,
        )
      ],
    ).show();
  }
}
