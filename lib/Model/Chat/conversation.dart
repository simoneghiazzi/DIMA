import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/user.dart';

class Conversation {
  User senderUser, peerUser;
  Chat senderUserChat, peerUserChat;
  String pairChatId;

  /// It represents the conversation between a [senderUser] and a [peerUser].
  /// 
  /// It receives also the type of chat of the sender user as the [senderUserChat] 
  /// and the type of chat of the peer user as the [peerUserChat].
  Conversation({this.senderUser, this.senderUserChat, this.peerUser, this.peerUserChat});

  /// Compute the pair chat id between 2 users
  void computePairChatId() {
    var senderId = senderUser.id;
    var peerId = peerUser.id;
    if (senderUser.id.hashCode <= peerUser.id.hashCode) {
      pairChatId = '$senderId-$peerId';
    } else {
      pairChatId = '$peerId-$senderId';
    }
  }
}
