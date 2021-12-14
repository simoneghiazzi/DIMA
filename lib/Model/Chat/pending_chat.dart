import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';

/// New request of chat received from another base user awaiting confirmation or rejection.
///
/// The peer collection of an [PendingChat] is the expert [Request].
class PendingChat extends Chat {
  static const COLLECTION = "anonymousPendingChats";
  static const PEER_COLLECTION = Request.COLLECTION;

  /// New request of chat received from another base user awaiting confirmation or rejection.
  ///
  /// The peer collection of an [PendingChat] is the expert [Request].
  PendingChat({BaseUser peerUser}) : super(COLLECTION, PEER_COLLECTION, peerUser: peerUser);

  /// Factory that returns the instance of the [PendingChat] with the correct [peerUser] instance.
  factory PendingChat.fromId(String id) {
    return PendingChat(peerUser: BaseUser(id: id));
  }
}
