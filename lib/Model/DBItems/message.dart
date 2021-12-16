import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/db_item.dart';

class Message extends DbItem {
  static const COLLECTION = "messages";

  String idFrom;
  String idTo;
  DateTime timestamp;
  String content;

  Message({this.idFrom, this.idTo, this.timestamp, this.content}) : super(COLLECTION);

  /// Create an instance of the [Message] form the [doc] fields retrieved from the FireBase DB.
  factory Message.fromDocument(DocumentSnapshot doc) {
    try {
      int milli = doc.get("timestamp");
      return Message(
        idFrom: doc.get("idFrom"),
        idTo: doc.get("idTo"),
        timestamp: DateTime.fromMillisecondsSinceEpoch(milli),
        content: doc.get("content"),
      );
    } catch (e) {
      print("Error in creating the message from the document snapshot: $e");
      return null;
    }
  }

  @override
  Map<String, Object> get data {
    return {
      "idFrom": idFrom,
      "idTo": idTo,
      "timestamp": timestamp.millisecondsSinceEpoch,
      "content": content,
    };
  }
}
