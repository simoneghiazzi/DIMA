import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chat_list_item.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingChatsListConstructor extends StatefulWidget {
  const PendingChatsListConstructor({Key? key}) : super(key: key);

  @override
  _PendingChatsListConstructorState createState() => _PendingChatsListConstructorState();
}

class _PendingChatsListConstructorState extends State<PendingChatsListConstructor> with AutomaticKeepAliveClientMixin {
  late ChatViewModel chatViewModel;

  var _loadChatsStream;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    //_loadChatsStream = chatViewModel.loadChats(widget.createChatCallback(""));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Flexible(
      child: Consumer<ChatViewModel>(
        builder: (context, chatViewModel, child) {
          return ListView.custom(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(10.0),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                Chat _chatItem = chatViewModel.pendingChats.values.elementAt(index);
                return ChatListItem(
                  chatItem: _chatItem,
                  selectedItemCallback: () => setState(() {}),
                  isSelected: chatViewModel.currentChat?.peerUser?.id == _chatItem.peerUser!.id,
                  key: ValueKey(chatViewModel.pendingChats.keys.elementAt(index)),
                );
              },
              childCount: chatViewModel.pendingChats.values.length,
              findChildIndexCallback: (Key key) {
                final ValueKey valueKey = key as ValueKey<dynamic>;
                for (int index = 0; index < chatViewModel.pendingChats.keys.length; index++) {
                  if (chatViewModel.pendingChats.values.elementAt(index) == valueKey.value) {
                    return index;
                  }
                }
                return 0;
              },
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
