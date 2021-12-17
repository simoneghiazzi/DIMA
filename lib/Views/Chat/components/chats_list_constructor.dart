import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chat_list_item.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsListConstructor extends StatefulWidget {
  final Function createChatCallback;

  ChatsListConstructor({Key key, @required this.createChatCallback}) : super(key: key);

  @override
  _ChatsListConstructorState createState() => _ChatsListConstructorState();
}

class _ChatsListConstructorState extends State<ChatsListConstructor> {
  ChatViewModel chatViewModel;

  var _loadChatsStream;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    _loadChatsStream = chatViewModel.loadChats(widget.createChatCallback(""));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: StreamBuilder(
        stream: _loadChatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return ListView.custom(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(10.0),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
                  Chat _chatItem = widget.createChatCallback(snapshot.data.docs[index].id);
                  _chatItem.setFromDocument(snapshot.data.docs[index]);
                  return ChatListItem(chatItem: _chatItem, key: ValueKey(snapshot.data.docs[index].id));
                },
                childCount: snapshot.data.docs.length,
                findChildIndexCallback: (Key key) {
                  final ValueKey valueKey = key;
                  for (int index = 0; index < snapshot.data.docs.length; index++) {
                    if (snapshot.data.docs[index].id == valueKey.value) {
                      return index;
                    }
                  }
                  return 0;
                },
              ),
            );
          } else {
            return LoadingDialog().widget(context);
          }
        },
      ),
    );
  }
}
