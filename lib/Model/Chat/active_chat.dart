import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/chat.dart';

class ActiveChat extends Chat {
  ActiveChat()
      : super(
            targetCollection: Collection.USERS,
            chatCollection: Collection.ACTIVE_CHATS);
}
