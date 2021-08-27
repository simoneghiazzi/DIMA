import 'package:dima_colombo_ghiazzi/Model/Chat/chat.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';

class Conversation {
  User senderUser, peerUser;
  Chat senderUserChat, peerUserChat;
  String pairChatId;

  Conversation(
      {this.senderUser, this.senderUserChat, this.peerUser, this.peerUserChat});

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
