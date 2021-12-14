import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';

/// Anonymous chat of the base user with another base user.
///
/// The peer collection of an [AnonymousChat] is another [AnonymousChat].
class AnonymousChat extends Chat {
  static const COLLECTION = "anonymousChats";
  static const PEER_COLLECTION = AnonymousChat.COLLECTION;

  /// Anonymous chat of the base user with another base user.
  ///
  /// The peer collection of an [AnonymousChat] is another [AnonymousChat].
  AnonymousChat(BaseUser peerUser) : super(COLLECTION, PEER_COLLECTION, peerUser);
}
