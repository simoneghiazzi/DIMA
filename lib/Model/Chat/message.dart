import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/db_item.dart';

class Message implements DbItem {
  String idFrom;
  String idTo;
  DateTime timestamp;
  String content;

  Message({this.idFrom, this.idTo, this.timestamp, this.content});

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      idFrom = doc.get('idFrom');
    } catch (e) {}
    try {
      idTo = doc.get('idTo');
    } catch (e) {}
    try {
      int milli = doc.get('timestamp');
      timestamp =
          DateTime.fromMillisecondsSinceEpoch(milli);
    } catch (e) {}
    try {
      content = doc.get('content');
    } catch (e) {}
  }

  @override
  getData() {
    return {
      'idFrom': idFrom,
      'idTo': idTo,
      'timestamp': timestamp,
      'content': content,
    };
  }

  @override
  Collection get collection => Collection.MESSAGES;
}
