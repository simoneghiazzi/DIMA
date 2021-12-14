import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
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

  Chat _chat;

  /// Update the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> updateChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(_userService.loggedUser, "chattingWith", _chat.peerUser.id);
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
      _chat,
      Message(
        idFrom: _userService.loggedUser.id,
        idTo: _chat.peerUser.id,
        timestamp: DateTime.now(),
        content: contentTextCtrl.text,
      ),
    );
    contentTextCtrl.clear();
  }

  /// Get the stream of messages between the 2 users.
  Stream<QuerySnapshot> loadMessages() {
    try {
      return _firestoreService.getStreamMessagesFromDB(Utils.pairChatId(_userService.loggedUser.id, _chat.peerUser.id));
    } catch (e) {
      print("Failed to get the stream of messages: $e");
      return null;
    }
  }

  /// Load the chat list of the [senderUser] based on the [_chat].
  Stream<QuerySnapshot> loadChats() {
    try {
      return _firestoreService.getChatsFromDB(_userService.loggedUser, _chat.collection);
    } catch (e) {
      print("Failed to get the stream of ${_chat.collection} chats: $e");
      return null;
    }
  }

  /// Return the doc of the peer user with all the info based on the [id]
  /// and the [collection].
  Future<QuerySnapshot> getPeerUserDoc(String collection, String id) {
    return _firestoreService.getUserByIdFromDB(collection, id);
  }

  /// Set the [user] as the peerUser of the [chat].
  void chatWithUser(User user) {
    _chat.peerUser = user;
  }

  /***************************************** CHAT METHODS FOR BASE USERS *****************************************/

  /// Set the [chat] as an [AnonymousChat].
  void setAnonymousChat({BaseUser baseUser}) {
    _chat = AnonymousChat(baseUser ?? BaseUser());
  }

  /// Set the [chat] as a [PendingChat].
  void setPendingChat({BaseUser baseUser}) {
    _chat = PendingChat(baseUser ?? BaseUser());
  }

  /// Set the [chat] as an [ExpertChat].
  void setExpertChat({Expert expert}) {
    _chat = ExpertChat(expert ?? Expert());
  }

  /// Accept a new pending chat request.
  void acceptPendingChat() {
    _firestoreService.upgradePendingToActiveChatIntoDB(_userService.loggedUser, _chat.peerUser);
    _chat = AnonymousChat(_chat.peerUser);
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
        _chat = Request(randomUser);
        // Add the "true" value to the new random user stream controller
        _newRandomUserCtrl.add(true);
      } else {
        // Add the "false" value to the new random user stream controller
        _newRandomUserCtrl.add(false);
      }
    });
  }

  /// Deny a pending chat.
  ///
  /// It deletes the chat between the 2 users and all the messages.
  void denyPendingChat() {
    _firestoreService.removeChatFromDB(_userService.loggedUser, _chat);
    _firestoreService.removeMessagesFromDB(Utils.pairChatId(_userService.loggedUser.id, _chat.peerUser.id));
  }

  /***************************************** CHAT METHODS FOR BASE EXPERTS *****************************************/

  /// Set the [chat] as an [ActiveChat].
  void setActiveChat({BaseUser baseUser}) {
    _chat = ActiveChat(baseUser ?? BaseUser());
  }

  /// Get the [chat] instance.
  Chat get chat => _chat;

  /// Stream of the new random user controller.
  Stream<bool> get newRandomUser => _newRandomUserCtrl.stream;
}
