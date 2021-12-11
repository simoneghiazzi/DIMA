import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/db_item.dart';

class Message extends DbItem {
  String idFrom;
  String idTo;
  DateTime dateTime;
  String content;

  Message({String id, this.idFrom, this.idTo, this.dateTime, this.content}) : super(id: id);

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
      idFrom = doc.get("idFrom");
      idTo = doc.get("idTo");
      dateTime = doc.get("dateTime");
      content = doc.get('content');
    } catch (e) {
      print("Error in setting the message from the document snapshot: $e");
    }
  }

  @override
  Map<String, Object> getData() {
    return {
      "idFrom": idFrom,
      "idTo": idTo,
      "dateTime": dateTime,
      "content": content,
    };
  }

  @override
  Collection get collection => Collection.MESSAGES;
}
