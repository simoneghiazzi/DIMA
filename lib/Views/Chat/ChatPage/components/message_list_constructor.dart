import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/components/date_item.dart';
import 'package:sApport/Views/Chat/ChatPage/components/message_list_item.dart';
import 'package:sApport/Views/Chat/ChatPage/components/new_messages_item.dart';

/// Constructor of the message list of a chat between 2 users.
///
/// It takes the [scrollController] of the list that it uses for scrolling to the [NewMessagesItem]
/// if it is present.
///
/// It uses a [ValueListenableBuilder] for listening to the messages of the chat
/// and for updating the ListView of [MessageListItem].
/// Based on the sequence of messages, it draws the [DateTime] and the [NewMessagesItem].
class MessageListConstructor extends StatefulWidget {
  final ScrollController scrollController;

  /// Constructor of the message list of a chat between 2 users.
  ///
  /// It takes the [scrollController] of the list that it uses for scrolling to the [NewMessagesItem]
  /// if it is present.
  ///
  /// It uses a [ValueListenableBuilder] for listening to the messages of the chat
  /// and for updating the ListView of [MessageListItem].
  /// Based on the sequence of messages, it draws the [DateTime] and the [NewMessagesItem].
  const MessageListConstructor({Key? key, required this.scrollController}) : super(key: key);

  @override
  _MessageListConstructorState createState() => _MessageListConstructorState();
}

class _MessageListConstructorState extends State<MessageListConstructor> {
  // View Models
  late UserViewModel userViewModel;
  late ChatViewModel chatViewModel;

  // Scroll Controllers
  var _scrollToNewMessage = true;
  var _first = true;
  late var _maxIndex;

  // Global key used for scrolling to the NewMessageItem
  final dataKey = new GlobalKey();
  var _datakeyUsed = false;

  var _lastMessageListLength;
  var _notReadMessages;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    _notReadMessages = chatViewModel.currentChat.value!.notReadMessages;
    _lastMessageListLength = chatViewModel.currentChat.value!.messages.value.length;
    chatViewModel.setMessagesHasRead();

    // Add the initial scroller to the NewMessageItem
    scrollHandler();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: chatViewModel.currentChat.value!.messages,
          builder: (context, List<Message> messages, child) {
            if (messages.length != 0) {
              if (!_scrollToNewMessage) {
                // If the new message is from the logged user, reset the _notReadMessages
                if (messages[messages.length - 1].idFrom == userViewModel.loggedUser!.id) {
                  _notReadMessages = 0;
                } else if (_notReadMessages > 0) {
                  // If the new message is from the peer user, increment the _notReadMessages
                  _notReadMessages += messages.length - _lastMessageListLength;
                  _lastMessageListLength = messages.length;
                }
              }
              return ListView.builder(
                controller: widget.scrollController,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) {
                  _maxIndex = index;
                  Message _messageItem = messages[messages.length - 1 - index];
                  if (index == messages.length - 1) {
                    // First message: it has the DateTime, the optional NewMessageItem and the MessageListItem
                    return Column(
                      children: [
                        DateItem(date: _messageItem.timestamp),
                        // If it is the index of _notReadMessages, show the NewMessageItem
                        if (index == _notReadMessages - 1) ...[
                          NewMessagesItem(counter: _notReadMessages, key: !_datakeyUsed ? dataKey : GlobalKey()),
                        ],
                        MessageListItem(messageItem: _messageItem),
                      ],
                    );
                  } else {
                    var previousDate = messages[messages.length - 2 - index].timestamp;
                    return Column(
                      children: [
                        // If previuous date is different from the current message, show the DateItem
                        if (previousDate.day != _messageItem.timestamp.day) ...[
                          DateItem(date: _messageItem.timestamp),
                        ],
                        // If it is the index of _notReadMessages, show the NewMessageItem
                        if (index == _notReadMessages - 1) ...[
                          NewMessagesItem(counter: _notReadMessages, key: !_datakeyUsed ? dataKey : GlobalKey()),
                        ],
                        MessageListItem(
                            messageItem: _messageItem, sameNextIdFrom: messages[messages.length - 2 - index].idFrom == _messageItem.idFrom)
                      ],
                    );
                  }
                },
                itemCount: messages.length,
                reverse: true,
              );
            } else {
              return Container();
            }
          },
        ),
        // Button for scrolling down
        if (widget.scrollController.hasClients && widget.scrollController.offset >= 200.h) ...[
          Align(
            alignment: Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1)!,
            child: FloatingActionButton.small(
              onPressed: () => widget.scrollController.animateTo(
                widget.scrollController.position.minScrollExtent,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.fastOutSlowIn,
              ),
              backgroundColor: kPrimaryDarkColorTrasparent.withOpacity(0.8),
              child: Transform.rotate(angle: 90 * math.pi / 180, child: Icon(Icons.double_arrow_rounded, size: 20.0, color: Colors.white)),
            ),
          ),
        ],
      ],
    );
  }

  /// Initial scroll to the NewMessageListItem and add the listener for
  /// showing the "scroll down" button when a certain threshold is passed.
  void scrollHandler() {
    if (_scrollToNewMessage) {
      _scrollToNewMessage = false;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (_notReadMessages != 0) {
          // If maxIndex is <= _notReadMessages, jump with an offset to the NewMessagesListItem in order
          // to build it, then add the callback for scrolling
          if (_maxIndex <= _notReadMessages) {
            var jumpValue = _notReadMessages * 40.0;
            var maxValue = widget.scrollController.position.maxScrollExtent;
            widget.scrollController.jumpTo(jumpValue < maxValue ? jumpValue : maxValue);
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              // Method used for scrolling to the NewMessagesListItem (thanks to the global key)
              Scrollable.ensureVisible(dataKey.currentContext!, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
              _datakeyUsed = true;
              if (widget.scrollController.position.pixels + 33.h <= maxValue) {
                widget.scrollController.jumpTo(widget.scrollController.position.pixels - 33.h);
              }
            });
          } else {
            // IOtherwise, scroll directly to NewMessagesListItem
            Scrollable.ensureVisible(dataKey.currentContext!, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
            _datakeyUsed = true;
            if (widget.scrollController.position.pixels != 0) {
              widget.scrollController.jumpTo(widget.scrollController.position.pixels + 33.h);
            }
          }
        }
        // Add a listener to the scroll controller for showing the 'Go Down' button when a
        // threshold is reached.
        // _first is used to call setState only one time when the scroller is above the threshold
        // and one time when it is below
        if (widget.scrollController.hasClients) {
          widget.scrollController.position.addListener(() {
            if (widget.scrollController.offset >= 200.h) {
              if (_first) {
                setState(() {});
                _first = false;
              }
            } else if (!_first) {
              setState(() {});
              _first = true;
            }
          });
        }
      });
    }
  }
}
