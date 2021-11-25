import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/date_item.dart';
import 'package:sApport/Views/Chat/components/message_list_item.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesListConstructor extends StatefulWidget {
  @override
  _MessagesListConstructorState createState() =>
      _MessagesListConstructorState();
}

class _MessagesListConstructorState extends State<MessagesListConstructor> {
  ChatViewModel chatViewModel;
  DateTime previousDate;

  @override
  void initState() {
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
              if (index == snapshot.data.docs.length - 1) {
                var dateToPrint = previousDate;
                previousDate = null;
                return Column(
                  children: [
                    DateItem(date: messageItem.timestamp),
                    MessageListItem(messageItem: messageItem, index: index),
                    DateItem(date: dateToPrint),
                  ],
                );
              } else if (previousDate != null &&
                  previousDate.day != messageItem.timestamp.day) {
                var dateToPrint = previousDate;
                previousDate = messageItem.timestamp;
                return Column(
                  children: [
                    MessageListItem(messageItem: messageItem, index: index),
                    DateItem(date: dateToPrint),
                  ],
                );
              } else {
                previousDate = messageItem.timestamp;
                return MessageListItem(messageItem: messageItem, index: index);
              }
            },
            itemCount: snapshot.data.docs.length,
            reverse: true,
          );
        }
        return LoadingDialog().widget(context);
      },
    ));
  }
}
