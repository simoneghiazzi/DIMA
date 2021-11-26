import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chat_list_item.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsListConstructor extends StatefulWidget {
  final Function createUserCallback;
  final Collection collection;

  ChatsListConstructor({
    Key key,
    @required this.createUserCallback,
    @required this.collection,
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
                if (snapshot.connectionState == ConnectionState.active) {
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: chatViewModel.getUser(widget.collection, snapshot.data.docs[index].id),
                        builder: (context, result) {
                          if (result.connectionState == ConnectionState.done) {
                            if (result.hasData) {
                              return ChatListItem(userItem: widget.createUserCallback(result.data.docs[0]));
                            } else {
                              return Container();
                            }
                          } else {
                            return LoadingDialog().widget(context);
                          }
                        },
                      );
                    },
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    reverse: true,
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
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limitIncrement += _limitIncrement;
      });
    }
  }
}
