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
  ExpertChat({Expert peerUser}) : super(COLLECTION, PEER_COLLECTION, peerUser: peerUser);

  /// Factory that returns the instance of the [ExpertChat] with the correct [peerUser] instance.
  factory ExpertChat.fromId(String id) {
    return ExpertChat(peerUser: Expert(id: id));
  }
}
