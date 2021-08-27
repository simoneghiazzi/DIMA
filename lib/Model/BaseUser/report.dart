import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';

class Report {
  String id;
  String category;
  String description;
  DateTime date;

  Report({this.id, this.category, this.description, this.date});

  factory Report.fromDocument(DocumentSnapshot doc) {
    String id = "";
    String category = "";
    String description = "";
    DateTime date;
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
    return Report(
        id: id, category: category, description: description, date: date);
  }

  toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'date': date
    };
  }

  Collection get collection => Collection.REPORTS;
}
