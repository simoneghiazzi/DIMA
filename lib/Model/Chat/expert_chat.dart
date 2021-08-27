import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/chat.dart';

class ExpertChat extends Chat {
  ExpertChat()
      : super(
            targetCollection: Collection.EXPERTS,
            chatCollection: Collection.EXPERT_CHATS);
}
