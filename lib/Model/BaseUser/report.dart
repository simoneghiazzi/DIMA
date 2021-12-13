import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/db_item.dart';

class Report extends DbItem {
  static const COLLECTION = "reports";

  String category;
  String description;
  DateTime dateTime;

  Report({String id, this.category, this.description, this.dateTime}) : super(COLLECTION, id: id);

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
      category = doc.get("category");
      description = doc.get("description");
      dateTime = doc.get("dateTime").toDate();
    } catch (e) {
      print("Error in setting the report from the document snapshot: $e");
    }
  }

  @override
  Map<String, Object> get data {
    return {
      "id": id,
      "category": category,
      "description": description,
      "dateTime": dateTime,
    };
  }
}
