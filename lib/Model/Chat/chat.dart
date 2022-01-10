import 'dart:async';
import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

/// Chat between the logged user and the [peerUser].
///
/// Every type of chat has an associated type of peer chat.
/// - [collection] : name of the chat collection of the sender user saved into the DB.
/// - [peerCollection] :   name of the peer chat collection saved into the DB.
abstract class Chat extends ChangeNotifier {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  // Name of the chat collection saved into the DB.
  final String collection;
  // Name of the peer chat collection saved into the DB.
  final String peerCollection;
  // Peer user of the chat.
  User? peerUser;

  // Last message received or sent by the logged user.
  String lastMessage;

  // Date time of the Last message received or sent by the logged user.
  DateTime? lastMessageDateTime;

  // If the Last message received by the logged user is read.
  int notReadMessages;

  // List of messages of the chat
  ValueNotifier<List<Message>> _messages = ValueNotifier<List<Message>>([]);

  // Stream Subscriptions
  StreamSubscription? _messagesSubscriber;

  /// Chat between the logged user and the [peerUser].
  ///
  /// Every type of chat has an associated type of peer chat.
  /// - [collection] : name of the chat collection of the sender user saved into the DB.
  /// - [peerCollection] :   name of the peer chat collection saved into the DB.
  Chat(this.collection, this.peerCollection, {this.peerUser, required this.lastMessage, this.lastMessageDateTime, required this.notReadMessages});

  /// Subscribe to the messages stream of the [loggedUser] from the Firebase DB and
  /// update the [_messages] list.
  ///
  /// Then it calls the [notifyListeners] on the [_messages] value notifier to notify the changes
  /// to all the listeners.
  Future<void> loadMessages() async {
    _messagesSubscriber = _firestoreService.getMessagesStreamFromDB(Utils.pairChatId(_userService.loggedUser!.id, peerUser!.id)).listen(
      (snapshot) async {
        for (var docChange in snapshot.docChanges.reversed) {
          var message = Message.fromDocument(docChange.doc);
          // If oldIndex == -1, the document is added, so its new and it has to be added to the list
          if (docChange.oldIndex == -1) {
            _messages.value.add(message);
            _messages.notifyListeners();
          }
        }
      },
      onError: (error) => log("Failed to get the stream of messages: $error"),
      cancelOnError: true,
    );
  }

  /// Cancel all the value listeners and clear their contents.
  void closeListeners() {
    _messagesSubscriber?.cancel();
    _messages.value.clear();
  }

  /// Get the [_messages] value notifier.
  ValueNotifier<List<Message>> get messages => _messages;

  /// Get the [_messagesSubscriber].
  StreamSubscription? get messagesSubscriber => _messagesSubscriber;
}
