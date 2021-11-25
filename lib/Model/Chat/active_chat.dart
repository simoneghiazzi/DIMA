import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/Chat/chat.dart';

class ActiveChat extends Chat {
  ActiveChat()
      : super(
            targetCollection: Collection.BASE_USERS,
            chatCollection: Collection.ACTIVE_CHATS);
}
