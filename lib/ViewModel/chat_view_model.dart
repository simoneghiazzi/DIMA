import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/random_id.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class ChatViewModel {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  // Text Controllers
  final TextEditingController contentTextCtrl = TextEditingController();

  // Stream Controllers
  var _newRandomUserCtrl = StreamController<bool>.broadcast();

  Chat chat;

  /// Update the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> updateChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(_userService.loggedUser, "chattingWith", chat.peerUser.id);
  }

  /// Reset the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> resetChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(_userService.loggedUser, "chattingWith", null);
  }

  /// Send a message to the [peerUser]
  void sendMessage() {
    _firestoreService.addMessageIntoDB(
      _userService.loggedUser,
      chat,
      Message(
        idFrom: _userService.loggedUser.id,
        idTo: chat.peerUser.id,
        timestamp: DateTime.now(),
        content: contentTextCtrl.text,
      ),
    );
    contentTextCtrl.clear();
  }

  /// Get the stream of messages between the 2 users.
  Stream<QuerySnapshot> loadMessages() {
    try {
      return _firestoreService.getStreamMessagesFromDB(Utils.pairChatId(_userService.loggedUser.id, chat.peerUser.id));
    } catch (e) {
      print("Failed to get the stream of messages: $e");
      return null;
    }
  }

  /// Return the stream of pending chats.
  Stream<QuerySnapshot> hasPendingChats() {
    try {
      return _firestoreService.getChatsFromDB(_userService.loggedUser, PendingChat.COLLECTION);
    } catch (e) {
      print("Failed to get the stream of pending chats: $e");
      return null;
    }
  }

  /// Look for a new random anonymous user into the DB.
  Future<void> getNewRandomUser() {
    return _firestoreService.getRandomUserFromDB(_userService.loggedUser, Utils.randomId()).then((doc) {
      if (doc != null) {
        // Create the random user and update the chat
        var randomUser = BaseUser();
        randomUser.setFromDocument(doc);
        chat = Request(peerUser: randomUser);
        // Add the "true" value to the new random user stream controller
        _newRandomUserCtrl.add(true);
      } else {
        // Add the "false" value to the new random user stream controller
        _newRandomUserCtrl.add(false);
      }
    });
  }

  /// Load the chat list of the [senderUser] based on the [chat].
  Stream<QuerySnapshot> loadChats() {
    try {
      return _firestoreService.getChatsFromDB(_userService.loggedUser, chat.collection);
    } catch (e) {
      print("Failed to get the stream of ${chat.collection} chats: $e");
      return null;
    }
  }

  Future<QuerySnapshot> getUser(String collection, String id) {
    return _firestoreService.getUserByIdFromDB(collection, id);
  }

  /// Accept a new pending chat request.
  void acceptPendingChat() {
    _firestoreService.upgradePendingToActiveChatIntoDB(_userService.loggedUser, chat.peerUser);
    chat = AnonymousChat(peerUser: chat.peerUser);
  }

  /// Deny a pending chat.
  ///
  /// It deletes the chat between the 2 users and all the messages.
  void denyPendingChat() {
    _firestoreService.removeChatFromDB(_userService.loggedUser, chat);
    _firestoreService.removeMessagesFromDB(Utils.pairChatId(_userService.loggedUser.id, chat.peerUser.id));
  }

  /// Stream of the new random user controller.
  Stream<bool> get newRandomUser => _newRandomUserCtrl.stream;
}
