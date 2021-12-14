import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/user.dart';

/// Active chat of an expert with a base user.
///
/// The peer collection of an [ActiveChat] is the base user [ExpertChat].
class ActiveChat extends Chat {
  static const COLLECTION = "activeChats";
  static const PEER_COLLECTION = ExpertChat.COLLECTION;

  /// Active chat of an expert with a base user.
  ///
  /// The peer collection of an [ActiveChat] is the base user [ExpertChat].
  ActiveChat({BaseUser peerUser}) : super(COLLECTION, PEER_COLLECTION, peerUser: peerUser);

  /// Factory that returns the instance of the [ActiveChat] with the correct [peerUser] instance.
  factory ActiveChat.fromId(String id) {
    return ActiveChat(peerUser: BaseUser(id: id));
  }
}
