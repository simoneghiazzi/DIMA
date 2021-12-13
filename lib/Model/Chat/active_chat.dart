import 'package:sApport/Model/Chat/chat.dart';

class ActiveChat extends Chat {
  static const COLLECTION = "anonymousActiveChats";

  /// Anonymous chat of the base user and of the expert.
  ActiveChat() : super(collection: COLLECTION);
}
