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
  Request({BaseUser peerUser}) : super(COLLECTION, PEER_COLLECTION, peerUser: peerUser);

  /// Factory that returns the instance of the [Request] with the correct [peerUser] instance.
  factory Request.fromId(String id) {
    return Request(peerUser: BaseUser(id: id));
  }
}
