import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/Chat/chat.dart';

class Request extends Chat {
  Request()
      : super(
            targetCollection: Collection.BASE_USERS,
            chatCollection: Collection.REQUESTS_CHATS);
}