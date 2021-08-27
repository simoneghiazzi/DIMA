import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_list_item.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';

class ChatsListConstructor extends StatefulWidget {
  final ChatViewModel chatViewModel;
  final User userItem;

  ChatsListConstructor({Key key, @required this.chatViewModel, this.userItem})
      : super(key: key);

  @override
  _ChatsListConstructorState createState() => _ChatsListConstructorState();
}

class _ChatsListConstructorState extends State<ChatsListConstructor> {
  final ScrollController listScrollController = ScrollController();
  int _limitIncrement = 20;

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          // List
          Container(
            child: FutureBuilder(
              future: widget.chatViewModel.loadChats(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      widget.userItem.setFromDocument(snapshot.data[index]);
                      return ChatListItem(
                        chatViewModel: widget.chatViewModel,
                        userItem: widget.userItem,
                        callback: () {
                          setState(() {});
                        },
                      );
                    },
                    itemCount: snapshot.data.length,
                    controller: listScrollController,
                    shrinkWrap: true,
                  );
                } else {
                  // LoadingDialog.show(context, text: 'Loading chats...');
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
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
