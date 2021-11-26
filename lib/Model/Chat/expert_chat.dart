import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/Chat/chat.dart';

class ExpertChat extends Chat {
  ExpertChat()
      : super(
            targetCollection: Collection.EXPERTS,
            chatCollection: Collection.EXPERT_CHATS);
}
