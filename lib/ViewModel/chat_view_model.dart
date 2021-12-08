import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/random_id.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/conversation.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/user.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatViewModel {
  FirestoreService firestoreService = GetIt.I<FirestoreService>();
  Conversation conversation = Conversation();
  TextEditingController textEditingController = TextEditingController();
  var _isNewRandomUserController = StreamController<bool>.broadcast();

  /// Update the ChattingWith field of the [senderUserChat] inside the DB
  /// It is used in order to show or not the notification on new messages
  Future<void> updateChattingWith() {
    return firestoreService.updateUserFieldIntoDB(conversation.senderUser, 'chattingWith', conversation.peerUser.id);
  }

  /// Reset the ChattingWith field of the [senderUserChat] inside the DB
  /// It is used in order to show or not the notification on new messages
  Future<void> resetChattingWith() {
    return firestoreService.updateUserFieldIntoDB(conversation.senderUser, 'chattingWith', null);
  }

  /// Send a message to the [peerUserChat]
  void sendMessage() {
    Message message = Message(
      idFrom: conversation.senderUser.id,
      idTo: conversation.peerUser.id,
      timestamp: DateTime.now(),
      content: textEditingController.text,
    );
    firestoreService.addMessageIntoDB(conversation, message);
    textEditingController.clear();
  }

  /// Get the stream of messages between the 2 users
  Stream<QuerySnapshot> loadMessages() {
    try {
      return firestoreService.getStreamMessagesFromDB(conversation.pairChatId);
    } catch (e) {
      print("Failed to get the stream of messages: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> hasPendingChats() {
    try {
      return firestoreService.hasPendingChats(conversation.senderUser);
    } catch (e) {
      print("Failed to get the stream of pending chats: $e");
      return null;
    }
  }

  /// Chat with a [user]
  void chatWithUser(User user) {
    conversation.peerUser = user;
    conversation.computePairChatId();
  }

  /// Look for a new random anonymous user
  Future<void> getNewRandomUser() async {
    var randomUser = await firestoreService.getRandomUserFromDB(conversation.senderUser, RandomId.generate());
    if (randomUser != null) {
      conversation.peerUser = randomUser;
      conversation.computePairChatId();
      _isNewRandomUserController.add(true);
    } else {
      _isNewRandomUserController.add(false);
    }
  }

  /// Load the chat list starting from the [conversation.senderUser] and the
  /// [conversation.senderUserChat]
  Stream<QuerySnapshot> loadChats() {
    try {
      return firestoreService.getChatsFromDB(conversation.senderUser, conversation.senderUserChat);
    } catch (e) {
      print("Failed to get the stream of active chats: $e");
      return null;
    }
  }

  Future<QuerySnapshot> getUser(Collection collection, String id) {
    return firestoreService.getUserByIdFromDB(collection, id);
  }

  /// Accept a new pendig chat request
  void acceptPendingChat() {
    firestoreService.upgradePendingToActiveChatIntoDB(conversation);
    conversation.senderUserChat = ActiveChat();
    conversation.peerUserChat = ActiveChat();
  }

  /// Delete or deny a chat between the 2 users and all the messages
  void deleteChat() {
    firestoreService.removeChatFromDB(conversation);
    firestoreService.removeMessagesFromDB(conversation.pairChatId);
  }

  TextEditingController get textController => textEditingController;
  Stream<bool> get isNewRandomUser => _isNewRandomUserController.stream;
}
