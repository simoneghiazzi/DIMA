import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DbItem {
  /// Collection of the DBItem.
  String collection;
  String id;

  /// It represents an item into the DB [collection] defined by its [id].
  DbItem(this.collection, {this.id});

  /// Set the fields of the DBItem from the [doc].
  void setFromDocument(DocumentSnapshot doc);

  /// Get the data of the DBItem as a key-value map.
  Map<String, Object> get data;
}
