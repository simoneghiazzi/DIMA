import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatTextInput extends StatefulWidget {
  final ChatViewModel chatViewModel;

  ChatTextInput({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  _ChatTextInputState createState() => _ChatTextInputState();
}

class _ChatTextInputState extends State<ChatTextInput>
    with WidgetsBindingObserver {
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ]),
        child: Row(
          children: <Widget>[
            // Edit text
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: TextField(
                onSubmitted: (value) {
                  listScrollController.animateTo(0.0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                },
                textAlignVertical: TextAlignVertical.center,
                style: GoogleFonts.ubuntuCondensed(color: kPrimaryColor),
                controller: widget.chatViewModel.textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  fillColor: kPrimaryColor,
                  border: InputBorder.none,
                  hintText: 'Type your message...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (widget.chatViewModel.textController.text.trim() !=
                          '') {
                        widget.chatViewModel.sendMessage();
                        focusNode.requestFocus();
                      }
                    },
                    color: kPrimaryColor,
                  ),
                  isCollapsed: true,
                ),
              ),
            ))
          ],
        ),
      )
    ]);
  }
}
