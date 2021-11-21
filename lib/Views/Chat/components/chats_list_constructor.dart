import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_list_item.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsListConstructor extends StatefulWidget {
  final Function createUserCallback;
  final bool isExpert;

  ChatsListConstructor({
    Key key,
    this.isExpert = false,
    this.createUserCallback,
  }) : super(key: key);

  @override
  _ChatsListConstructorState createState() => _ChatsListConstructorState();
}

class _ChatsListConstructorState extends State<ChatsListConstructor> {
  final ScrollController listScrollController = ScrollController();
  int _limitIncrement = 20;
  ChatViewModel chatViewModel;
  bool loading = true;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    listScrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          // List
          Container(
            child: StreamBuilder(
              stream: chatViewModel.loadChats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return ChatListItem(
                          isExpert: widget.isExpert,
                          userItem: widget
                              .createUserCallback(snapshot.data.removeFirst()));
                    },
                    itemCount: snapshot.data.length,
                    controller: listScrollController,
                    shrinkWrap: true,
                  );
                } else {
                  return LoadingDialog().widget(context);
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
}
