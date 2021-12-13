import 'package:sApport/Model/Chat/chat.dart';

class PendingChat extends Chat {
  static const COLLECTION = "anonymousPendingChats";

  /// New chat received by the user that needs to be confirmed or denied.
  PendingChat() : super(collection: COLLECTION);
}
