import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/chat.dart';

class PendingChat extends Chat {
  PendingChat()
      : super(
            targetCollection: Collection.BASE_USERS,
            chatCollection: Collection.PENDING_CHATS);
}
