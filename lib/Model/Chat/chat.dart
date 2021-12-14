import 'package:sApport/Model/user.dart';

/// Chat between the logged user and the [peerUser].
///
/// Every type of chat has an associated type of peer chat.
/// - [collection] : name of the chat collection of the sender user saved into the DB.
/// - [peerCollection] :   name of the peer chat collection saved into the DB.
abstract class Chat {
  // Name of the chat collection saved into the DB.
  final String collection;
  // Name of the peer chat collection saved into the DB.
  final String peerCollection;
  // Peer user of the chat.
  User peerUser;

  /// Chat between the logged user and the [peerUser].
  ///
  /// Every type of chat has an associated type of peer chat.
  /// - [collection] : name of the chat collection of the sender user saved into the DB.
  /// - [peerCollection] :   name of the peer chat collection saved into the DB.
  Chat(this.collection, this.peerCollection, {this.peerUser});
}
