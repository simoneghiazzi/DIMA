import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/collections.dart';

abstract class DbItem {
  void setFromDocument(DocumentSnapshot doc);
  getData();
  Collection get collection;
}
