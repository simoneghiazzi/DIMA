import 'package:cloud_firestore/cloud_firestore.dart';

class ChatlistViewModel {
  String loggedId;
  int _limit = 20;

  ChatlistViewModel(this.loggedId);

  Stream<QuerySnapshot> loadUsers() {
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .limit(_limit)
          .snapshots();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
