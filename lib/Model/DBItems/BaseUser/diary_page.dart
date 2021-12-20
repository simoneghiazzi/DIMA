import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/db_item.dart';

class DiaryPage extends DbItem {
  static const COLLECTION = "diary";

  String title;
  String content;
  DateTime? dateTime;
  bool favourite;

  DiaryPage({String id = "", this.title = "", this.content = "", this.dateTime, this.favourite = false}) : super(COLLECTION, id: id) {
    this.dateTime = dateTime ?? DateTime.now();
  }

  /// Create an instance of the [DiaryPage] form the [doc] fields retrieved from the FireBase DB.
  factory DiaryPage.fromDocument(DocumentSnapshot doc) {
    return DiaryPage(
      id: doc.id,
      title: doc.get("title"),
      content: doc.get("content"),
      dateTime: doc.get("dateTime").toDate(),
      favourite: doc.get("favourite"),
    );
  }

  @override
  Map<String, Object> get data {
    return {
      "id": id,
      "title": title,
      "content": content,
      "dateTime": dateTime!,
      "favourite": favourite,
    };
  }
}
