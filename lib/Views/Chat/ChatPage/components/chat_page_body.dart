import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_accept_deny.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_text_input.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/messages_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar_chats.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class ChatPageBody extends StatefulWidget {
  final ChatViewModel chatViewModel;

  ChatPageBody({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  _ChatPageBodyState createState() => _ChatPageBodyState();
}

class _ChatPageBodyState extends State<ChatPageBody>
    with WidgetsBindingObserver {
  User peerUser;
  @override
  void initState() {
    super.initState();
    peerUser = widget.chatViewModel.conversation.peerUser;
    WidgetsBinding.instance.addObserver(this);
    widget.chatViewModel.updateChattingWith();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Padding(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                peerUser.collection == Collection.EXPERTS
                    ? TopBarChats(
                        circleAvatar: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.network(
                              widget.chatViewModel.conversation.peerUser
                                  .getData()['profilePhoto'],
                              fit: BoxFit.cover,
                              width: 40.0,
                              height: 40.0,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 40.0,
                                  height: 40.0,
                                  child: CircularProgressIndicator(
                                    color: kPrimaryColor,
                                    value: loadingProgress.expectedTotalBytes !=
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
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      "${widget.chatViewModel.conversation.peerUser.name[0]}",
                                      style: TextStyle(
                                          color: kPrimaryColor, fontSize: 30),
                                    ));
                              },
                            ),
                          ),
                        ),
                        text: peerUser.getData()['name'] +
                            " " +
                            peerUser.getData()['surname'])
                    : TopBarChats(text: peerUser.getData()['name']),
                // List of messages
                MessagesListConstructor(chatViewModel: widget.chatViewModel),
                // Input content
                widget.chatViewModel.conversation.senderUserChat.runtimeType ==
                        PendingChat
                    ? ChatAcceptDenyInput(chatViewModel: widget.chatViewModel)
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
}
