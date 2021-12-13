import 'package:sApport/Model/Chat/chat.dart';

class Request extends Chat {
  static const COLLECTION = "anonymousRequestChats";

  /// New request of chat sent by the user.
  Request() : super(collection: COLLECTION);
}
