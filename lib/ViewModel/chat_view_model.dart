import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatViewModel {
  String loggedId;
  String peerId;
  String peerAvatar;
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  String groupChatId = "";
  int _limit = 20;

  TextEditingController textEditingController = TextEditingController();

  ChatViewModel(
      {@required this.loggedId, @required this.peerId, this.peerAvatar});

  readLocal() async {
    if (loggedId.hashCode <= peerId.hashCode) {
      groupChatId = '$loggedId-$peerId';
    } else {
      groupChatId = '$peerId-$loggedId';
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(loggedId)
        .update({'chattingWith': peerId});
  }

  void sendMessage() {
    if (textEditingController.text.trim() != '') {

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': loggedId,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': textEditingController.text,
          },
        );
      }).then((_) => textEditingController.clear());
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') == loggedId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void resetChat() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(loggedId)
        .update({'chattingWith': null});
  }

  Stream<QuerySnapshot> loadMessages() {
    try {
      var query = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
          .limit(_limit);
      Stream<QuerySnapshot> querySnapshots = query.snapshots();
      querySnapshots.forEach((element) {
        listMessage.addAll(element.docs);
      });
      return query.snapshots();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
