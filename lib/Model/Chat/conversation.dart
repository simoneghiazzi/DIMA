import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Chat/chat.dart';

class Conversation {
  // Users
  User senderUser;
  User peerUser;

  // Chats
  Chat senderUserChat;
  Chat peerUserChat;

  // It represents the composed id of the 2 users
  String pairChatId;

  /// It represents the conversation between a [senderUser] and a [peerUser].
  ///
  /// It receives also the type of chat of the sender user as the [senderUserChat]
  /// and the type of chat of the peer user as the [peerUserChat].
  Conversation({this.senderUser, this.senderUserChat, this.peerUser, this.peerUserChat});

  /// Compute the pair chat id of the 2 users involved in the conversation
  void computePairChatId() {
    if (senderUser.id.hashCode <= peerUser.id.hashCode) {
      pairChatId = "${senderUser.id}-${peerUser.id}";
    } else {
      pairChatId = "${peerUser.id}-${senderUser.id}";
    }
  }
}
