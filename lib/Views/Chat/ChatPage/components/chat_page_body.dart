import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_accept_deny.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chat_text_input.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/messages_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar_chats.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPageBody extends StatefulWidget {
  final bool isExpert;

  ChatPageBody({Key key, this.isExpert = false}) : super(key: key);

  @override
  _ChatPageBodyState createState() => _ChatPageBodyState();
}

class _ChatPageBodyState extends State<ChatPageBody>
    with WidgetsBindingObserver {
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;
  User peerUser;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    peerUser = chatViewModel.conversation.peerUser;
    chatViewModel.updateChattingWith();
    BackButtonInterceptor.add(myInterceptor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              peerUser.collection == Collection.EXPERTS
                  ? TopBarChats(
                      peerExpert: true,
                      circleAvatar: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.network(
                            chatViewModel.conversation.peerUser
                                .getData()['profilePhoto'],
                            fit: BoxFit.cover,
                            width: 40.0,
                            height: 40.0,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: 40.0,
                                height: 40.0,
                                child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    "${chatViewModel.conversation.peerUser.name[0]}",
                                    style: TextStyle(
                                        color: kPrimaryColor, fontSize: 30),
                                  ));
                            },
                          ),
                        ),
                      ),
                      text: peerUser.getData()['name'] +
                          " " +
                          peerUser.getData()['surname'],
                    )
                  : widget.isExpert
                      ? TopBarChats(
                          peerExpert: false,
                          circleAvatar: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.account_circle,
                              size: 40,
                              color: kPrimaryColor,
                            ),
                          ),
                          text: peerUser.getData()['name'] +
                              " " +
                              peerUser.getData()['surname'],
                        )
                      : TopBarChats(
                          peerExpert: false,
                          circleAvatar: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.account_circle,
                              size: 40,
                              color: kPrimaryColor,
                            ),
                          ),
                          text: peerUser.getData()['name'],
                        ),
              // List of messages
              MessagesListConstructor(),
              // Input content
              chatViewModel.conversation.senderUserChat.runtimeType ==
                      PendingChat
                  ? ChatAcceptDenyInput()
                  : ChatTextInput(),
            ],
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 10, left: 5, right: 5),
    );
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    chatViewModel.resetChattingWith();
    routerDelegate.pop();
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      chatViewModel.updateChattingWith();
    } else {
      chatViewModel.resetChattingWith();
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
