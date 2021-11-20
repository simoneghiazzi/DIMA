import 'package:dima_colombo_ghiazzi/Model/Chat/message.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/message_list_item.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesListConstructor extends StatefulWidget {
  @override
  _MessagesListConstructorState createState() =>
      _MessagesListConstructorState();
}

class _MessagesListConstructorState extends State<MessagesListConstructor> {
  final ScrollController listScrollController = ScrollController();
  int _limitIncrement = 20;
  ChatViewModel chatViewModel;

  @override
  void initState() {
    listScrollController.addListener(scrollListener);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: StreamBuilder(
      stream: chatViewModel.loadMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              Message messageItem = Message();
              messageItem.setFromDocument(snapshot.data.docs[index]);
              return MessageListItem(messageItem: messageItem, index: index);
            },
            itemCount: snapshot.data.docs.length,
            controller: listScrollController,
            reverse: true,
          );
        }
        return LoadingDialog().widget(context);
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
}
