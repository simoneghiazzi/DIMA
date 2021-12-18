import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/date_item.dart';
import 'package:sApport/Views/Chat/components/message_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Chat/components/not_read_messages_item.dart';
import 'package:sApport/constants.dart';

class MessagesListConstructor extends StatefulWidget {
  final ScrollController scrollController;

  const MessagesListConstructor({Key key, this.scrollController}) : super(key: key);

  @override
  _MessagesListConstructorState createState() => _MessagesListConstructorState();
}

class _MessagesListConstructorState extends State<MessagesListConstructor> {
  ChatViewModel chatViewModel;
  final dataKey = new GlobalKey();
  Size size;

  var _loadMessagesStream;
  var _notReadMessages;
  var _first = true;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    _loadMessagesStream = chatViewModel.loadMessages();
    _notReadMessages = chatViewModel.currentChat.notReadMessages;
    chatViewModel.setMessagesHasRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Stack(
      children: [
        StreamBuilder(
          stream: _loadMessagesStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_notReadMessages != 0) {
                  Scrollable.ensureVisible(dataKey.currentContext, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
                }
                widget.scrollController.position.addListener(() {
                  if (widget.scrollController.hasClients && widget.scrollController.offset >= 2 * size.height) {
                    if (_first) {
                      setState(() {});
                      _first = false;
                    }
                  } else if (!_first) {
                    setState(() {});
                    _first = true;
                  }
                });
              });
              return ListView.custom(
                controller: widget.scrollController,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10.0),
                childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    Message messageItem = Message.fromDocument(snapshot.data.docs[index]);
                    if (index == snapshot.data.docs.length - 1) {
                      return Column(
                        children: [
                          DateItem(date: messageItem.timestamp),
                          MessageListItem(messageItem: messageItem, key: ValueKey(messageItem.timestamp.millisecondsSinceEpoch)),
                        ],
                      );
                    } else {
                      var previousDate = DateTime.fromMillisecondsSinceEpoch(snapshot.data.docs[index + 1].get("timestamp"));
                      return Column(
                        children: [
                          if (previousDate.day != messageItem.timestamp.day) ...[
                            DateItem(date: messageItem.timestamp),
                          ],
                          if (index == _notReadMessages - 1) ...[
                            NotReadMessagesItem(counter: _notReadMessages, key: dataKey),
                          ],
                          MessageListItem(
                            messageItem: messageItem,
                            sameNextIdFrom: snapshot.data.docs[index + 1].get("idFrom") == messageItem.idFrom,
                            key: ValueKey(messageItem.timestamp.millisecondsSinceEpoch),
                          )
                        ],
                      );
                    }
                  },
                  childCount: snapshot.data.docs.length,
                  findChildIndexCallback: (Key key) {
                    final ValueKey valueKey = key;
                    for (int index = 0; index < snapshot.data.docs.length; index++) {
                      if (snapshot.data.docs[index].get("timestamp") == valueKey.value) {
                        return index;
                      }
                    }
                    return 0;
                  },
                ),
                reverse: true,
              );
            } else {
              return Container();
            }
          },
        ),
        buildGoDownButton(),
      ],
    );
  }

  Widget buildGoDownButton() {
    if (widget.scrollController.hasClients && widget.scrollController.offset >= 2 * size.height) {
      return Align(
        alignment: Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1),
        child: FloatingActionButton.small(
          onPressed: () {
            widget.scrollController.animateTo(widget.scrollController.position.minScrollExtent,
                duration: const Duration(milliseconds: 1000), curve: Curves.fastOutSlowIn);
          },
          backgroundColor: kColorTransparent,
          child: const Icon(
            Icons.arrow_drop_down,
            size: 40,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
