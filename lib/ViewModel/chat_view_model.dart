import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/random_id.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/conversation.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:flutter/material.dart';

class ChatViewModel {
  FirestoreService firestoreService = FirestoreService();
  Conversation conversation = Conversation();
  List<QueryDocumentSnapshot> _listMessages = new List.from([]);
  TextEditingController textEditingController = TextEditingController();
  var isNewRandomUserController = StreamController<bool>.broadcast();

  /// Update the ChattingWith field of the [senderUserChat] inside the DB
  /// It is used in order to show or not the notification on new messages
  Future<void> updateChattingWith() async {
    await firestoreService.updateUserFieldIntoDB(
        conversation.senderUser, 'chattingWith', conversation.peerUser.id);
  }

  /// Reset the ChattingWith field of the [senderUserChat] inside the DB
  /// It is used in order to show or not the notification on new messages
  void resetChattingWith() async {
    try {
      await firestoreService.updateUserFieldIntoDB(
          conversation.senderUser, 'chattingWith', null);
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Send a message to the [peerUserChat]
  void sendMessage() async {
    String content = textEditingController.text;
    textEditingController.clear();
    await firestoreService.addMessageIntoDB(conversation, content);
  }

  //DA RIVEDERE
  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            _listMessages[index - 1].get('idFrom') ==
                conversation.senderUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  //DA RIVEDERE
  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            _listMessages[index - 1].get('idFrom') ==
                conversation.peerUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  /// Get the stream of messages between the 2 users
  Stream<QuerySnapshot> loadMessages() {
    try {
      var snapshots =
          firestoreService.getStreamMessagesFromDB(conversation.pairChatId);
      _listMessages.clear();
      snapshots.forEach((element) {
        _listMessages.addAll(element.docs);
      });
      return snapshots;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> hasMessages() async {
    return await firestoreService.hasMessages(conversation.pairChatId);
  }

  Future<bool> hasPendingChats() async {
    return await firestoreService.hasPendingChats(conversation.senderUser);
  }

  /// Chat with a [user]
  Future<void> chatWithUser(User user) async {
    conversation.peerUser = user;
    conversation.computePairChatId();
  }

  /// Look for a new random anonymous user
  Future<void> getNewRandomUser() async {
    var randomUser = await firestoreService.getRandomUserFromDB(
        conversation.senderUser, RandomId.generate());
    if (randomUser == null) isNewRandomUserController.add(false);
    conversation.peerUser = randomUser;
    conversation.computePairChatId();
    isNewRandomUserController.add(true);
  }

  /// Load the chat list starting from the [conversation.senderUser] and the
  /// [conversation.senderUserChat]
  Future<List> loadChats() async {
    try {
      return await firestoreService.getChatsFromDB(
          conversation.senderUser, conversation.senderUserChat);
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Accept a new pendig chat request
  Future<void> acceptPendingChat() async {
    await firestoreService.upgradePendingToActiveChatIntoDB(conversation);
    conversation.senderUserChat = ActiveChat();
    conversation.peerUserChat = ActiveChat();
  }

  /// Delete or deny a chat between the 2 users and all the messages
  Future<void> deleteChat() async {
    await firestoreService.removeChatFromDB(conversation);
    await firestoreService.removeMessagesFromDB(conversation.pairChatId);
  }

  TextEditingController get textController => textEditingController;
  Stream<bool> get isNewRandomUser => isNewRandomUserController.stream;
}
