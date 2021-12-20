/// It represents an item into the DB [collection] defined by its [id].
abstract class DbItem {
  /// Collection of the DBItem.
  String collection;
  String id;

  /// It represents an item into the DB [collection] defined by its [id].
  DbItem(this.collection, {required this.id});

  /// Get the data of the DBItem as a key-value map.
  Map<String, Object> get data;
}
