import 'package:sApport/Model/Chat/chat.dart';

class ExpertChat extends Chat {
  static const COLLECTION = "expertChats";

  /// Chat of the base user with an expert.
  ExpertChat() : super(collection: COLLECTION);
}
