import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chat_list_item.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsListConstructor extends StatefulWidget {
  final Function createUserCallback;
  final String peerCollection;

  ChatsListConstructor({Key key, @required this.createUserCallback, @required this.peerCollection}) : super(key: key);

  @override
  _ChatsListConstructorState createState() => _ChatsListConstructorState();
}

class _ChatsListConstructorState extends State<ChatsListConstructor> {
  ChatViewModel chatViewModel;
  bool loading = true;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: StreamBuilder(
        stream: chatViewModel.loadChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return ListView.custom(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(10.0),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
                  var userId = snapshot.data.docs[index].id;
                  return ChatListItem(
                      userId: userId, peerCollection: widget.peerCollection, createUserCallback: widget.createUserCallback, key: ValueKey(userId));
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
