import 'package:sApport/Model/Services/collections.dart';

abstract class Chat {
  Collection targetCollection;
  Collection chatCollection;

  Chat({this.targetCollection, this.chatCollection});
}
