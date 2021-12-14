import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';

class Request extends Chat {
  static const COLLECTION = "anonymousRequest";
  static const PEER_COLLECTION = PendingChat.COLLECTION;

  /// New request of chat sent by the base user to another base user.
  ///
  /// The peer collection of an [Request] is the expert [PendingChat].
  Request({BaseUser peerUser}) : super(COLLECTION, PEER_COLLECTION, peerUser: peerUser);
}
