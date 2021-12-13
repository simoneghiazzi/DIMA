import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/random_id.dart';
import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/conversation.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class ChatViewModel {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();

  // Text Controllers
  final TextEditingController contentTextCtrl = TextEditingController();

  // Stream Controllers
  var _newRandomUserCtrl = StreamController<bool>.broadcast();

  final Conversation conversation = Conversation();

  /// Update the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> updateChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(conversation.senderUser, "chattingWith", conversation.peerUser.id);
  }

  /// Reset the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> resetChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(conversation.senderUser, "chattingWith", null);
  }

  /// Send a message to the [peerUser]
  void sendMessage() {
    _firestoreService.addMessageIntoDB(
      conversation,
      Message(
        idFrom: conversation.senderUser.id,
        idTo: conversation.peerUser.id,
        timestamp: DateTime.now(),
        content: contentTextCtrl.text,
      ),
    );
    contentTextCtrl.clear();
  }

  /// Get the stream of messages between the 2 users.
  Stream<QuerySnapshot> loadMessages() {
    try {
      return _firestoreService.getStreamMessagesFromDB(conversation.pairChatId);
    } catch (e) {
      print("Failed to get the stream of messages: $e");
      return null;
    }
  }

  /// Return the stream of pending chats.
  Stream<QuerySnapshot> hasPendingChats() {
    try {
      return _firestoreService.getChatsFromDB(conversation.senderUser, PendingChat());
    } catch (e) {
      print("Failed to get the stream of pending chats: $e");
      return null;
    }
  }

  /// It sets the [user] as the peer user of the conversation and compute the pair chat id.
  void chatWithUser(User user) {
    conversation.peerUser = user;
    conversation.computePairChatId();
  }

  /// Look for a new random anonymous user into the DB.
  Future<void> getNewRandomUser() {
    return _firestoreService.getRandomUserFromDB(conversation.senderUser, RandomId.generate()).then((doc) {
      if (doc != null) {
        // Create the random user and add it into the conversation
        var randomUser = BaseUser();
        randomUser.setFromDocument(doc);
        conversation.peerUser = randomUser;
        conversation.computePairChatId();
        // Add the "true" value to the new random user stream controller
        _newRandomUserCtrl.add(true);
      } else {
        // Add the "false" value to the new random user stream controller
        _newRandomUserCtrl.add(false);
      }
    });
  }

  /// Load the chat list of the [senderUser] based on the [senderUserChat] in the [conversation].
  Stream<QuerySnapshot> loadChats() {
    try {
      return _firestoreService.getChatsFromDB(conversation.senderUser, conversation.senderUserChat);
    } catch (e) {
      print("Failed to get the stream of ${conversation.senderUserChat.toString()} chats: $e");
      return null;
    }
  }

  Future<QuerySnapshot> getUser(String collection, String id) {
    return _firestoreService.getUserByIdFromDB(collection, id);
  }

  /// Accept a new pendig chat request.
  void acceptPendingChat() {
    _firestoreService.upgradePendingToActiveChatIntoDB(conversation);
    conversation.senderUserChat = ActiveChat();
    conversation.peerUserChat = ActiveChat();
  }

  /// Delete or deny a chat between the 2 users and all the messages.
  void deleteChat() {
    _firestoreService.removeChatFromDB(conversation);
    _firestoreService.removeMessagesFromDB(conversation.pairChatId);
  }

  /// Stream of the new random user controller.
  Stream<bool> get newRandomUser => _newRandomUserCtrl.stream;
}
