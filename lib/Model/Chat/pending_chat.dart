import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';

/// New request of chat received from another base user awaiting confirmation or rejection.
///
/// The peer collection of an [PendingChat] is the expert [Request].
class PendingChat extends Chat {
  static const COLLECTION = "anonymousPendingChats";
  static const PEER_COLLECTION = Request.COLLECTION;

  /// New request of chat received from another base user awaiting confirmation or rejection.
  ///
  /// The peer collection of an [PendingChat] is the expert [Request].
  PendingChat({BaseUser? peerUser, String lastMessage = "", DateTime? lastMessageDateTime, int notReadMessages = 0})
      : super(
          COLLECTION,
          PEER_COLLECTION,
          peerUser: peerUser,
          lastMessage: lastMessage,
          lastMessageDateTime: lastMessageDateTime,
          notReadMessages: notReadMessages,
        );

  /// Create an instance of [PendingChat] form the [doc] fields retrieved from the FireBase DB.
  factory PendingChat.fromDocument(DocumentSnapshot doc) {
    int milli = doc.get("lastMessageTimestamp");
    return PendingChat(
        lastMessage: doc.get("lastMessage"),
        lastMessageDateTime: DateTime.fromMillisecondsSinceEpoch(milli),
        notReadMessages: doc.get("notReadMessages"),
        peerUser: BaseUser(id: doc.id));
  }
}
