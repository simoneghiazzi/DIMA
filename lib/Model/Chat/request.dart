import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';

/// New request of chat sent by the base user to another base user.
///
/// The peer collection of an [Request] is the expert [PendingChat].
class Request extends Chat {
  static const COLLECTION = "anonymousRequest";
  static const PEER_COLLECTION = PendingChat.COLLECTION;

  /// New request of chat sent by the base user to another base user.
  ///
  /// The peer collection of an [Request] is the expert [PendingChat].
  Request({BaseUser? peerUser, String lastMessage = "", DateTime? lastMessageDateTime, int notReadMessages = 0})
      : super(
          COLLECTION,
          PEER_COLLECTION,
          peerUser: peerUser,
          lastMessage: lastMessage,
          lastMessageDateTime: lastMessageDateTime,
          notReadMessages: notReadMessages,
        );

  /// Create an instance of [Request] form the [doc] fields retrieved from the FireBase DB.
  factory Request.fromDocument(DocumentSnapshot doc) {
    int milli = doc.get("lastMessageTimestamp");
    return Request(
        lastMessage: doc.get("lastMessage"),
        lastMessageDateTime: DateTime.fromMillisecondsSinceEpoch(milli),
        notReadMessages: doc.get("notReadMessages"),
        peerUser: BaseUser(id: doc.id));
  }
}
