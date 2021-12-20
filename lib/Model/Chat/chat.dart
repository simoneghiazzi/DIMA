import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/user.dart';

/// Chat between the logged user and the [peerUser].
///
/// Every type of chat has an associated type of peer chat.
/// - [collection] : name of the chat collection of the sender user saved into the DB.
/// - [peerCollection] :   name of the peer chat collection saved into the DB.
abstract class Chat {
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

  /// Chat between the logged user and the [peerUser].
  ///
  /// Every type of chat has an associated type of peer chat.
  /// - [collection] : name of the chat collection of the sender user saved into the DB.
  /// - [peerCollection] :   name of the peer chat collection saved into the DB.
  Chat(this.collection, this.peerCollection, {this.peerUser, required this.lastMessage, this.lastMessageDateTime, required this.notReadMessages});

  /// Set dinamically the fields of the [User] from the [doc].
  void setFromDocument(DocumentSnapshot doc) {
    try {
      lastMessage = doc.get("lastMessage");
      int milli = doc.get("lastMessageTimestamp");
      lastMessageDateTime = DateTime.fromMillisecondsSinceEpoch(milli);
      notReadMessages = doc.get("notReadMessages");
    } catch (e) {
      print("Error in setting the chat from the document snapshot: $e");
    }
  }
}
