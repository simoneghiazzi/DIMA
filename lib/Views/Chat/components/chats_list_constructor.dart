import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_list_item.dart';
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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    var chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    return Container(
      child: Stack(
        children: <Widget>[
          // List
          Container(
            child: FutureBuilder(
              future: chatViewModel.loadChats(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      User user =
                          widget.createUserCallback(snapshot.data[index]);
                      return ChatListItem(
                        isExpert: widget.isExpert,
                        userItem: user,
                        setStateCallback: () {
                          setState(() {});
                        },
                      );
                    },
                    itemCount: snapshot.data.length,
                    controller: listScrollController,
                    shrinkWrap: true,
                  );
                } else {
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
