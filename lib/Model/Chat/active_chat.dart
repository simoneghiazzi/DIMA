import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';

/// Active chat of an expert with a base user.
///
/// The peer collection of an [ActiveChat] is the base user [ExpertChat].
class ActiveChat extends Chat {
  static const COLLECTION = "activeChats";
  static const PEER_COLLECTION = ExpertChat.COLLECTION;

  /// Active chat of an expert with a base user.
  ///
  /// The peer collection of an [ActiveChat] is the base user [ExpertChat].
  ActiveChat({BaseUser? peerUser, String lastMessage = "", DateTime? lastMessageDateTime, int notReadMessages = 0})
      : super(
          COLLECTION,
          PEER_COLLECTION,
          peerUser: peerUser,
          lastMessage: lastMessage,
          lastMessageDateTime: lastMessageDateTime,
          notReadMessages: notReadMessages,
        );

  /// Create an instance of [ActiveChat] form the [doc] fields retrieved from the FireBase DB.
  factory ActiveChat.fromDocument(DocumentSnapshot doc) {
    int milli = doc.get("lastMessageTimestamp");
    return ActiveChat(
        lastMessage: doc.get("lastMessage"),
        lastMessageDateTime: DateTime.fromMillisecondsSinceEpoch(milli),
        notReadMessages: doc.get("notReadMessages"),
        peerUser: BaseUser(id: doc.id));
  }
}
