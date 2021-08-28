import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/db_item.dart';

class Report implements DbItem{
  String id;
  String category;
  String description;
  DateTime date;

  Report({this.id, this.category, this.description, this.date});

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
      date = doc.get('date');
    } catch (e) {}
  }

  getData() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'date': date
    };
  }

  Collection get collection => Collection.REPORTS;
}
