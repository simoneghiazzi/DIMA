import 'package:dima_colombo_ghiazzi/Model/Chat/message.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/message_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesListConstructor extends StatefulWidget {
  @override
  _MessagesListConstructorState createState() =>
      _MessagesListConstructorState();
}

class _MessagesListConstructorState extends State<MessagesListConstructor> {
  final ScrollController listScrollController = ScrollController();
  ChatViewModel chatViewModel;
  Message messageItem = Message();
  int _limitIncrement = 20;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    listScrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: StreamBuilder(
      stream: chatViewModel.loadMessages(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              messageItem.setFromDocument(snapshot.data.docs[index]);
              return MessageListItem(messageItem: messageItem, index: index);
            },
            itemCount: snapshot.data.docs.length,
            reverse: true,
            controller: listScrollController,
          );
        }
        return Container();
      },
    ));
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limitIncrement += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    listScrollController.dispose();
    super.dispose();
  }
}
