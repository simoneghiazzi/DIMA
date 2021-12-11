import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/db_item.dart';

class Message extends DbItem {
  String idFrom;
  String idTo;
  DateTime timestamp;
  String content;

  Message({this.idFrom, this.idTo, this.timestamp, this.content});

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      idFrom = doc.get("idFrom");
      idTo = doc.get("idTo");
      int milli = doc.get("timestamp");
      timestamp = DateTime.fromMillisecondsSinceEpoch(milli);
      content = doc.get("content");
    } catch (e) {
      print("Error in setting the message from the document snapshot: $e");
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

  @override
  Collection get collection => Collection.MESSAGES;
}
