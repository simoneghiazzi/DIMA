import 'dart:async';
import 'package:collection/collection.dart';
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
  var _isNewRandomUserController = StreamController<bool>.broadcast();
  var _isNewMessageController = StreamController<bool>.broadcast();
  bool newCurrentUser;

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
    if (newCurrentUser) {
      _isNewMessageController.add(true);
      newCurrentUser = false;
    }
  }

  /// Return true if it is the last of a group of messages sent by the sender user
  bool isLastMessageLeft(int index) {
    if (_listMessages.isNotEmpty) {
      if (index == 0 ||
          index > 0 &&
              _listMessages[index - 1].get('idFrom') ==
                  conversation.senderUser.id) {
        return true;
      }
    }
    return false;
  }

  /// Return true if it is the last of a group of messages sent by the peer user
  bool isLastMessageRight(int index) {
    if (_listMessages.isNotEmpty) {
      if (index == 0 ||
          index > 0 &&
              _listMessages[index - 1].get('idFrom') ==
                  conversation.peerUser.id) {
        return true;
      }
    }
    return false;
  }

  /// Get the stream of messages between the 2 users
  Stream<QuerySnapshot> loadMessages() {
    try {
      var snapshots =
          firestoreService.getStreamMessagesFromDB(conversation.pairChatId);
      //_listMessages.clear();
      snapshots.forEach((element) {
        _listMessages.addAll(element.docs);
      });
      return snapshots;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> hasPendingChats() async {
    return await firestoreService.hasPendingChats(conversation.senderUser);
  }

  /// Chat with a [user]
  void chatWithUser(User user) {
    conversation.peerUser = user;
    conversation.computePairChatId();
    _isNewMessageController.add(false);
    newCurrentUser = true;
  }

  /// Look for a new random anonymous user
  Future<void> getNewRandomUser() async {
    var randomUser = await firestoreService.getRandomUserFromDB(
        conversation.senderUser, RandomId.generate());
    if (randomUser == null) {
      _isNewRandomUserController.add(false);
      return;
    }
    newCurrentUser = false;
    conversation.peerUser = randomUser;
    conversation.computePairChatId();
    _isNewRandomUserController.add(true);
  }

  /// Load the chat list starting from the [conversation.senderUser] and the
  /// [conversation.senderUserChat]
  Future<PriorityQueue> loadChats() async {
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
  Stream<bool> get isNewRandomUser => _isNewRandomUserController.stream;
  Stream<bool> get isNewMessage => _isNewMessageController.stream;
}
