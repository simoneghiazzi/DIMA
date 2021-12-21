import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chat_list_item.dart';

/// Constructor of the anonymous chats list.
///
/// It uses a [StreamBuilder] for listening to the [anonymousChats] linked hash map of the user and updating the ListView.
class AnonymousChatsListConstructor extends StatefulWidget {
  /// Constructor of the anonymous chats list.
  ///
  /// It uses a [StreamBuilder] for listening to the [anonymousChats] linked hash map of the user and updating the ListView.
  const AnonymousChatsListConstructor({Key? key}) : super(key: key);

  @override
  _AnonymousChatsListConstructorState createState() => _AnonymousChatsListConstructorState();
}

class _AnonymousChatsListConstructorState extends State<AnonymousChatsListConstructor> {
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
        valueListenable: chatViewModel.anonymousChats,
        builder: (context, LinkedHashMap<String, Chat> anonymousChats, child) {
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              // The index for the linked hash map runs from anonymousChats.length - 1 to 0 because the hash map
              // is ordered by the time of insertion, so the last inserted element (the newer chat) is the first element
              // to show in the list.
              Chat _chatItem = anonymousChats.values.elementAt(anonymousChats.length - 1 - index);
              return ChatListItem(
                  chatItem: _chatItem,
                  selectedItemCallback: () => setState(() {}),
                  isSelected: chatViewModel.currentChat.value?.peerUser?.id == _chatItem.peerUser!.id);
            },
            itemCount: anonymousChats.length,
          );
        },
      ),
    );
  }
}
