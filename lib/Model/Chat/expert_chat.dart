import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';

/// Chat of the base user with an expert.
///
/// The peer collection of an [ExpertChat] is the expert [ActiveChat].
class ExpertChat extends Chat {
  static const COLLECTION = "expertChats";
  static const PEER_COLLECTION = ActiveChat.COLLECTION;

  /// Chat of the base user with an expert.
  ///
  /// The peer collection of an [ExpertChat] is the expert [ActiveChat].
  ExpertChat({Expert? peerUser, String lastMessage = "", DateTime? lastMessageDateTime, int notReadMessages = 0})
      : super(
          COLLECTION,
          PEER_COLLECTION,
          peerUser: peerUser,
          lastMessage: lastMessage,
          lastMessageDateTime: lastMessageDateTime,
          notReadMessages: notReadMessages,
        );

  /// Create an instance of [ExpertChat] form the [doc] fields retrieved from the FireBase DB.
  factory ExpertChat.fromDocument(DocumentSnapshot doc) {
    int milli = doc.get("lastMessageTimestamp");
    return ExpertChat(
        lastMessage: doc.get("lastMessage"),
        lastMessageDateTime: DateTime.fromMillisecondsSinceEpoch(milli),
        notReadMessages: doc.get("notReadMessages"),
        peerUser: Expert(id: doc.id));
  }
}
