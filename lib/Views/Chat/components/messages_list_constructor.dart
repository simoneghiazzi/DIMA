import 'package:dima_colombo_ghiazzi/Model/Chat/message.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/message_list_item.dart';
import 'package:flutter/material.dart';

class MessagesListConstructor extends StatefulWidget {
  final ChatViewModel chatViewModel;

  MessagesListConstructor({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  _MessagesListConstructorState createState() =>
      _MessagesListConstructorState();
}

class _MessagesListConstructorState extends State<MessagesListConstructor> {
  final ScrollController listScrollController = ScrollController();
  Message messageItem = Message();
  int _limitIncrement = 20;

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    //LoadingDialog.show(context, text: 'Loading chats...');
    return Flexible(
        child: StreamBuilder(
      stream: widget.chatViewModel.loadMessages(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //LoadingDialog.hide(context);
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              messageItem.setFromDocument(snapshot.data.docs[index]);
              return MessageListItem(
                  chatViewModel: widget.chatViewModel,
                  messageItem: messageItem,
                  index: index);
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
