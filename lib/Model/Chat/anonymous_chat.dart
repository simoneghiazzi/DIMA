import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';

/// Anonymous chat of the base user with another base user.
///
/// The peer collection of an [AnonymousChat] is another [AnonymousChat].
class AnonymousChat extends Chat {
  static const COLLECTION = "anonymousChats";
  static const PEER_COLLECTION = AnonymousChat.COLLECTION;

  /// Anonymous chat of the base user with another base user.
  ///
  /// The peer collection of an [AnonymousChat] is another [AnonymousChat].
  AnonymousChat({BaseUser? peerUser, String lastMessage = "", DateTime? lastMessageDateTime, int notReadMessages = 0})
      : super(
          COLLECTION,
          PEER_COLLECTION,
          peerUser: peerUser,
          lastMessage: lastMessage,
          lastMessageDateTime: lastMessageDateTime,
          notReadMessages: notReadMessages,
        );

  /// Create an instance of [AnonymousChat] form the [doc] fields retrieved from the FireBase DB.
  factory AnonymousChat.fromDocument(DocumentSnapshot doc) {
    int milli = doc.get("lastMessageTimestamp");
    return AnonymousChat(
        lastMessage: doc.get("lastMessage"),
        lastMessageDateTime: DateTime.fromMillisecondsSinceEpoch(milli),
        notReadMessages: doc.get("notReadMessages"),
        peerUser: BaseUser(id: doc.id));
  }
}
