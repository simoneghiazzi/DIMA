import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/db_item.dart';

class DiaryPage extends DbItem {
  static const COLLECTION = "diary";

  String title;
  String content;
  DateTime dateTime;
  bool favourite;

  DiaryPage({String id, this.title, this.content, this.dateTime, this.favourite}) : super(COLLECTION, id: id);

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
      title = doc.get("title");
      content = doc.get("content");
      dateTime = doc.get("dateTime").toDate();
      favourite = doc.get("favourite");
    } catch (e) {
      print("Error in setting the diary page from the document snapshot: $e");
    }
  }

  @override
  Map<String, Object> get data {
    return {
      "id": id,
      "title": title,
      "content": content,
      "dateTime": dateTime,
      "favourite": favourite,
    };
  }
}
