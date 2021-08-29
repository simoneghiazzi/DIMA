import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/chat.dart';

class Request extends Chat {
  Request()
      : super(
            targetCollection: Collection.BASE_USERS,
            chatCollection: Collection.REQUESTS_CHATS);
}