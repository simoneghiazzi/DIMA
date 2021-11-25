import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/Chat/chat.dart';

class PendingChat extends Chat {
  PendingChat()
      : super(
            targetCollection: Collection.BASE_USERS,
            chatCollection: Collection.PENDING_CHATS);
}
