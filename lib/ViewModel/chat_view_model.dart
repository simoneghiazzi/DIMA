import 'dart:async';
import 'dart:collection';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class ChatViewModel extends ChangeNotifier {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  // Text Controllers
  final TextEditingController contentTextCtrl = TextEditingController();

  // Stream Controllers
  var _newRandomUserCtrl = StreamController<bool>.broadcast();

  Chat? _currentChat;
  LinkedHashMap<String, Chat?> _anonymousChats = LinkedHashMap();
  LinkedHashMap<String, Chat?> _pendingChats = LinkedHashMap();

  /// Update the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> updateChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(_userService.loggedUser!, "chattingWith", _currentChat!.peerUser!.id);
  }

  /// Reset the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> resetChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(_userService.loggedUser!, "chattingWith", null);
  }

  /// Send a message to the [peerUser]
  void sendMessage() {
    _currentChat!.lastMessage = contentTextCtrl.text;
    _currentChat!.lastMessageDateTime = DateTime.now();
    _firestoreService.addMessageIntoDB(
      _userService.loggedUser!,
      _currentChat!,
      Message(
        idFrom: _userService.loggedUser!.id,
        idTo: _currentChat!.peerUser!.id,
        timestamp: _currentChat!.lastMessageDateTime!,
        content: contentTextCtrl.text,
      ),
    );
    contentTextCtrl.clear();
  }

  Future<void> setMessagesHasRead() {
    _currentChat!.notReadMessages = 0;
    return _firestoreService.setMessagesHasRead(_userService.loggedUser!, _currentChat!);
  }

  /// Get the stream of messages between the 2 users.
  Stream<QuerySnapshot>? loadMessages() {
    try {
      return _firestoreService.getStreamMessagesFromDB(Utils.pairChatId(_userService.loggedUser!.id, _currentChat!.peerUser!.id));
    } catch (e) {
      print("Failed to get the stream of messages: $e");
      return null;
    }
  }

  /// Load the anonymous chat list of the [senderUser].
  void loadAnonymousChats() async {
    _firestoreService.getChatsFromDB(_userService.loggedUser!, AnonymousChat.COLLECTION).listen(
      (snapshot) async {
        for (var docChange in snapshot.docChanges) {
          var chat = AnonymousChat.fromDocument(docChange.doc);
          // If oldIndex == -1, the document is added, so its new
          if (docChange.oldIndex == -1) {
            getPeerUserDoc(chat.peerUser!.collection, chat.peerUser!.id).then((value) {
              chat.peerUser!.setFromDocument(value.docs[0]);
              _anonymousChats[docChange.doc.id] = chat;
              notifyListeners();
            });
          } else {
            chat.peerUser = _anonymousChats.remove(docChange.doc.id)!.peerUser;
            _anonymousChats[docChange.doc.id] = chat;
            notifyListeners();
          }
        }
      },
      onError: (error) => print("Failed to get the stream of anonymous chats: $error"),
    );
  }

  /// Load the anonymous chat list of the [senderUser].
  void loadPendingChats() async {
    _firestoreService.getChatsFromDB(_userService.loggedUser!, PendingChat.COLLECTION).listen(
      (snapshot) async {
        for (var docChange in snapshot.docChanges) {
          // If oldIndex == -1, the document is added, so its new
          if (docChange.oldIndex == -1) {
            var chat = PendingChat.fromDocument(docChange.doc);
            getPeerUserDoc(chat.peerUser!.collection, chat.peerUser!.id).then((value) {
              chat.peerUser!.setFromDocument(value.docs[0]);
              _pendingChats[docChange.doc.id] = chat;
            });
          } else {
            _pendingChats[docChange.doc.id] = _pendingChats.remove(docChange.doc.id);
          }
          notifyListeners();
        }
      },
      onError: (error) => print("Failed to get the stream of pending chats: $error"),
    );
  }

  /// Return the doc of the peer user with all the info based on the [id]
  /// and the [collection].
  Future<QuerySnapshot> getPeerUserDoc(String collection, String id) {
    return _firestoreService.getUserByIdFromDB(collection, id);
  }

  /// Accept a new pending chat request.
  void acceptPendingChat() {
    _firestoreService.upgradePendingToActiveChatIntoDB(_userService.loggedUser!, _currentChat!);
    setCurrentChat(AnonymousChat(peerUser: _currentChat!.peerUser as BaseUser));
  }

  /// Return the stream of pending chats.
  Stream<QuerySnapshot>? hasPendingChats() {
    try {
      return _firestoreService.getChatsFromDB(_userService.loggedUser!, PendingChat.COLLECTION);
    } catch (e) {
      print("Failed to get the stream of pending chats: $e");
      return null;
    }
  }

  /// Look for a new random anonymous user into the DB.
  Future<void> getNewRandomUser() {
    return _firestoreService.getRandomUserFromDB(_userService.loggedUser as BaseUser, Utils.randomId()).then((doc) {
      if (doc != null) {
        // Create the random user and update the chat
        var randomUser = BaseUser.fromDocument(doc);
        setCurrentChat(Request(peerUser: randomUser));
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
    _firestoreService.removeChatFromDB(_userService.loggedUser!, _currentChat!);
    _firestoreService.removeMessagesFromDB(Utils.pairChatId(_userService.loggedUser!.id, _currentChat!.peerUser!.id));
    resetCurrentChat();
  }

  /// Set the [chat] as the [_currentChat].
  void setCurrentChat(Chat? chat) {
    _currentChat = chat;
    print("Current chat setted");
    notifyListeners();
  }

  /// Reset the [_currentChat].
  ///
  /// It must be called after all the other reset methods.
  void resetCurrentChat() {
    _currentChat = null;
    print("Current chat resetted");
    notifyListeners();
  }

  /// Get the [_currentChat] instance.
  Chat? get currentChat => _currentChat;

  /// Get the [_anonymousChats] list instance.
  LinkedHashMap get anonymousChats => _anonymousChats;

  /// Get the [_pendingChats] list instance.
  LinkedHashMap get pendingChats => _pendingChats;

  /// Stream of the new random user controller.
  Stream<bool> get newRandomUser => _newRandomUserCtrl.stream;
}
