import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/collections.dart';

abstract class DbItem {
  String id;

  /// It represents an item on the DB defined by its [id]
  DbItem({this.id});

  /// Set the fields of the DBItem from the [doc]
  void setFromDocument(DocumentSnapshot doc);

  /// Get the data of the DBItem as a key-value map
  Map<String, Object> get data;

  /// Collection of the DBItem
  Collection get collection;
}
