import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/ChatList/components/chat_list_item.dart';

/// Constructor of the user chat list.
///
/// It takes the [valueNotifier] of the linked hash map of chats that it has to construct.
///
/// It uses a [ValueListenableBuilder] for listening to the user chats and for updating the ListView
/// of [ChatListItem].
class ChatListConstructor extends StatefulWidget {
  /// Notifier of the linked hash map of the user chat list.
  final ValueNotifier<LinkedHashMap<String, Chat>> valueNotifier;

  /// Constructor of the user chat list.
  ///
  /// It takes the [valueNotifier] of the linked hash map of chats that it has to construct.
  ///
  /// It uses a [ValueListenableBuilder] for listening to the user chats and for updating the ListView
  /// of [ChatListItem].
  const ChatListConstructor({Key? key, required this.valueNotifier}) : super(key: key);

  @override
  _ChatListConstructorState createState() => _ChatListConstructorState();
}

class _ChatListConstructorState extends State<ChatListConstructor> {
  // View Models
  late ChatViewModel chatViewModel;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ValueListenableBuilder(
        valueListenable: widget.valueNotifier,
        builder: (context, LinkedHashMap<String, Chat> chatList, child) {
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              // The index for the linked hash map runs from chats.length - 1 to 0 because the hash map
              // is ordered by the time of insertion, so the last inserted element (the newer chat) is the first element
              // to show in the list.
              return ChatListItem(
                chatItem: chatList.values.elementAt(chatList.length - 1 - index),
                selectedItemCallback: () => setState(() {}),
              );
            },
            itemCount: chatList.length,
          );
        },
      ),
    );
  }
}
