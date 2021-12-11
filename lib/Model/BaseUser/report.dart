import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/db_item.dart';

class Report extends DbItem {
  String category;
  String description;
  DateTime date;

  Report({String id, this.category, this.description, this.date}) : super(id: id);

  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
    } catch (e) {}
    try {
      category = doc.get('category');
    } catch (e) {}
    try {
      description = doc.get('description');
    } catch (e) {}
    try {
      date = doc.get('date').toDate();
    } catch (e) {}
  }

  getData() {
    return {'id': id, 'category': category, 'description': description, 'date': date};
  }

  Collection get collection => Collection.REPORTS;
}
