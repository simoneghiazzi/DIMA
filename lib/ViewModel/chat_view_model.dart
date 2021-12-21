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
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class ChatViewModel extends ChangeNotifier {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  // Text Controllers
  final TextEditingController contentTextCtrl = TextEditingController();

  // Stream Controllers
  var _newRandomUserCtrl = StreamController<bool>.broadcast();

  // Stream Subscriptions
  late StreamSubscription _anonymousChatsSubscriber;
  late StreamSubscription _pendingChatsSubscriber;

  ValueNotifier<Chat?> _currentChat = ValueNotifier(null);
  ValueNotifier<LinkedHashMap<String, Chat>> _anonymousChats = ValueNotifier<LinkedHashMap<String, Chat>>(LinkedHashMap<String, Chat>());
  ValueNotifier<LinkedHashMap<String, Chat>> _pendingChats = ValueNotifier<LinkedHashMap<String, Chat>>(LinkedHashMap<String, Chat>());
  ValueNotifier<LinkedHashMap<String, Chat>> _expertChats = ValueNotifier<LinkedHashMap<String, Chat>>(LinkedHashMap<String, Chat>());

  /// Update the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> updateChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(_userService.loggedUser!, "chattingWith", _currentChat.value?.peerUser?.id);
  }

  /// Reset the ChattingWith field of the [senderUser] inside the DB.
  ///
  /// It is used in order to show or not the notification on new messages.
  Future<void> resetChattingWith() {
    return _firestoreService.updateUserFieldIntoDB(_userService.loggedUser!, "chattingWith", null);
  }

  /// Send a message to the [peerUser]
  void sendMessage() {
    _currentChat.value!.lastMessage = contentTextCtrl.text;
    _currentChat.value!.lastMessageDateTime = DateTime.now();
    _firestoreService.addMessageIntoDB(
      _userService.loggedUser!,
      _currentChat.value!,
      Message(
        idFrom: _userService.loggedUser!.id,
        idTo: _currentChat.value!.peerUser!.id,
        timestamp: _currentChat.value!.lastMessageDateTime!,
        content: contentTextCtrl.text,
      ),
    );
    contentTextCtrl.clear();
  }

  Future<void> setMessagesHasRead() {
    _currentChat.value!.notReadMessages = 0;
    return _firestoreService.setMessagesHasRead(_userService.loggedUser!, _currentChat.value!);
  }

  /// Get the stream of messages between the 2 users.
  Stream<QuerySnapshot>? loadMessages() {
    try {
      return _firestoreService.getStreamMessagesFromDB(Utils.pairChatId(_userService.loggedUser!.id, _currentChat.value!.peerUser!.id));
    } catch (e) {
      print("Failed to get the stream of messages: $e");
      return null;
    }
  }

  /// Load the anonymous chat list of the [senderUser].
  void loadAnonymousChats() async {
    _anonymousChatsSubscriber = _firestoreService.getChatsFromDB(_userService.loggedUser!, AnonymousChat.COLLECTION).listen(
      (snapshot) async {
        for (var docChange in snapshot.docChanges) {
          var chat = AnonymousChat.fromDocument(docChange.doc);
          // If oldIndex == -1, the document is added, so its new
          if (docChange.oldIndex == -1) {
            getPeerUserDoc(chat.peerUser!.collection, chat.peerUser!.id).then((value) {
              chat.peerUser!.setFromDocument(value.docs[0]);
              _anonymousChats.value[docChange.doc.id] = chat;
              _anonymousChats.notifyListeners();
            });
          } else {
            chat.peerUser = _anonymousChats.value.remove(docChange.doc.id)!.peerUser;
            _anonymousChats.value[docChange.doc.id] = chat;
            _anonymousChats.notifyListeners();
          }
        }
      },
      onError: (error) => print("Failed to get the stream of anonymous chats: $error"),
    );
  }

  /// Load the anonymous chat list of the [senderUser].
  void loadPendingChats() async {
    _pendingChatsSubscriber = _firestoreService.getChatsFromDB(_userService.loggedUser!, PendingChat.COLLECTION).listen(
      (snapshot) async {
        for (var docChange in snapshot.docChanges) {
          // If oldIndex == -1, the document is added, so its new
          if (docChange.oldIndex == -1) {
            var chat = PendingChat.fromDocument(docChange.doc);
            getPeerUserDoc(chat.peerUser!.collection, chat.peerUser!.id).then((value) {
              chat.peerUser!.setFromDocument(value.docs[0]);
              _pendingChats.value[docChange.doc.id] = chat;
              _pendingChats.notifyListeners();
            });
          }
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

  /// Accept a new pending chat request.
  void acceptPendingChat() {
    _pendingChats.value.remove(_currentChat.value!.peerUser!.id);
    _firestoreService.upgradePendingToActiveChatIntoDB(_userService.loggedUser!, _currentChat.value!);
    setCurrentChat(AnonymousChat(peerUser: _currentChat.value!.peerUser as BaseUser));
    _pendingChats.notifyListeners();
  }

  /// Deny a pending chat.
  ///
  /// It deletes the chat between the 2 users and all the messages.
  void denyPendingChat() {
    _pendingChats.value.remove(_currentChat.value!.peerUser!.id);
    _firestoreService.removeChatFromDB(_userService.loggedUser!, _currentChat.value!);
    _firestoreService.removeMessagesFromDB(Utils.pairChatId(_userService.loggedUser!.id, _currentChat.value!.peerUser!.id));
    resetCurrentChat();
    _pendingChats.notifyListeners();
  }

  /// Set the [chat] as the [_currentChat].
  void setCurrentChat(Chat? chat) {
    _currentChat.value = chat;
    print("Current chat setted");
  }

  /// Reset the [_currentChat].
  ///
  /// It must be called after all the other reset methods.
  void resetCurrentChat() {
    _currentChat.value = null;
    print("Current chat resetted");
  }

  void reset() {
    _anonymousChatsSubscriber.cancel();
    _pendingChatsSubscriber.cancel();
    _currentChat = ValueNotifier(null);
    _anonymousChats = ValueNotifier<LinkedHashMap<String, Chat>>(LinkedHashMap<String, Chat>());
    _pendingChats = ValueNotifier<LinkedHashMap<String, Chat>>(LinkedHashMap<String, Chat>());
    _expertChats = ValueNotifier<LinkedHashMap<String, Chat>>(LinkedHashMap<String, Chat>());
  }

  /// Get the [_currentChat] instance.
  ValueNotifier<Chat?> get currentChat => _currentChat;

  /// Get the [_currentChat] instance.
  ValueNotifier<LinkedHashMap<String, Chat>> get anonymousChats => _anonymousChats;

  /// Get the [_currentChat] instance.
  ValueNotifier<LinkedHashMap<String, Chat>> get pendingChats => _pendingChats;

  /// Get the [_currentChat] instance.
  ValueNotifier<LinkedHashMap<String, Chat>> get expertChats => _expertChats;

  /// Stream of the new random user controller.
  Stream<bool> get newRandomUser => _newRandomUserCtrl.stream;
}
