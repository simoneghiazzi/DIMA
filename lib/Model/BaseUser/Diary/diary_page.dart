import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/db_item.dart';

class DiaryPage implements DbItem {
  String id;
  String title;
  String content;
  DateTime date;
  bool favourite;

  DiaryPage({this.id, this.title, this.content, this.date, this.favourite});

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
    try {
      favourite = doc.get('favourite');
    } catch (e) {}
  }

  getData() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'favourite': favourite
    };
  }

  Collection get collection => Collection.DIARY;
}
