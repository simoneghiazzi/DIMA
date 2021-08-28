import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dash_card.dart';

class ExpertGrid extends StatefulWidget {
  final ExpertViewModel expertViewModel;

  ExpertGrid({Key key, @required this.expertViewModel}) : super(key: key);

  @override
  _ExpertGridState createState() =>
      _ExpertGridState(expertViewModel: expertViewModel);
}

class _ExpertGridState extends State<ExpertGrid> {
  final ExpertViewModel expertViewModel;
  ChatViewModel chatViewModel;

  _ExpertGridState({@required this.expertViewModel});

  @override
  void initState() {
    super.initState();
    chatViewModel = ChatViewModel(expertViewModel.loggedUser);
    chatViewModel.conversation.senderUserChat = ActiveChat();
    chatViewModel.conversation.peerUserChat = ActiveChat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            defaultColumnWidth: FlexColumnWidth(15.0),
            children: <TableRow>[
              TableRow(children: <Widget>[
                DashCard(
                  imagePath: "assets/icons/psychologist.png",
                  text: "Chats",
                  press: () {},
                ),
              ]),
            ],
          )),
    );
  }
}
