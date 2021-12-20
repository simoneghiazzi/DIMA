import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/db_item.dart';

class Message extends DbItem {
  static const COLLECTION = "messages";

  String idFrom;
  String idTo;
  DateTime timestamp;
  String content;

  Message({String id = "", required this.idFrom, required this.idTo, required this.timestamp, required this.content}) : super(COLLECTION, id: id);

  /// Create an instance of the [Message] form the [doc] fields retrieved from the FireBase DB.
  factory Message.fromDocument(DocumentSnapshot doc) {
    int milli = doc.get("timestamp");
    return Message(
      id: doc.id,
      idFrom: doc.get("idFrom"),
      idTo: doc.get("idTo"),
      timestamp: DateTime.fromMillisecondsSinceEpoch(milli),
      content: doc.get("content"),
    );
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
