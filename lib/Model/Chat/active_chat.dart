import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';

class ActiveChat extends Chat {
  static const COLLECTION = "activeChats";
  static const PEER_COLLECTION = ExpertChat.COLLECTION;

  /// Active chat of an expert with a base user.
  ///
  /// The peer collection of an [ActiveChat] is the base user [ExpertChat].
  ActiveChat(BaseUser peerUser) : super(COLLECTION, PEER_COLLECTION, peerUser: peerUser);
}
