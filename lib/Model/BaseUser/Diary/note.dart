import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/db_item.dart';

class Note implements DbItem {
  String id;
  String title;
  String content;
  DateTime date;

  Note({this.id, this.title, this.content, this.date});

  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
    } catch (e) {}
    try {
      title = doc.get('title');
    } catch (e) {}
    try {
      content = doc.get('content');
    } catch (e) {}
    try {
      date = doc.get('date').toDate();
    } catch (e) {}
  }

  getData() {
    return {'id': id, 'title': title, 'content': content, 'date': date};
  }

  Collection get collection => Collection.DIARY;
}
