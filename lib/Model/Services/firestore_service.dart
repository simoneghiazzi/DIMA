import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';

class FirestoreService {
  // The collection of users in the firestore DB
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  // The collection of experts in the firestore DB
  CollectionReference experts =
      FirebaseFirestore.instance.collection('experts');

  int _limit = 20;

  // Add a user into the firestore DB
  Future<void> addUserIntoDB(
      String id, String name, String surname, String birthDate) async {
    await users.doc(id).set({
      'uid': id,
      'name': name,
      'surname': surname,
      'birthDate': birthDate
    }).catchError((error) => print("Failed to add user: $error"));
    await _incrementUsersCountIntoDB();
  }

  //Add an expert into the firestore DB
  Future<void> addExpertIntoDB(
      String id,
      String name,
      String surname,
      DateTime birthDate,
      num lat,
      num lng,
      String phoneNumber,
      String email) async {
    await experts
        .add({
          'eid': id,
          'name': name,
          'surname': surname,
          'birthDate': birthDate,
          'lat': lat,
          'lng': lng,
          'phoneNumber': phoneNumber,
          'email': email
        })
        .then((value) => print("Expert added"))
        .catchError((error) => print("Failed to add expert: $error"));
  }

  // Delete a user from the firestore DB
  Future<void> deleteUserFromDB(String id) async {
    await users
        .doc(id)
        .delete()
        .catchError((error) => print("Failed to delete user: $error"));
    await _decrementUsersCountIntoDB();
  }

  // Increment the count of the instances of users into the DB
  Future<void> _incrementUsersCountIntoDB() async {
    var data = (await users.doc('utils').get()).data() as Map<String, dynamic>;
    if (data == null) {
      await users.doc('utils').set({'count': 1}).catchError(
          (error) => print("Failed to update user count: $error"));
    } else {
      await users.doc('utils').update({'count': data['count'] + 1}).catchError(
          (error) => print("Failed to update user count: $error"));
    }
  }

  // Decrement the count of the instances of users into the DB
  Future<void> _decrementUsersCountIntoDB() async {
    var data = (await users.doc('utils').get()).data() as Map<String, dynamic>;
    await users.doc('utils').update({'count': data['count'] - 1}).catchError(
        (error) => print("Failed to update user count: $error"));
  }

  // Get the count of the intances of users from the DB
  Future<int> getUsersCountFromDB() async {
    var data = (await users.doc('utils').get()).data() as Map<String, dynamic>;
    return data['count'];
  }

  //Query the firestore DB in order to retrieve the user's info
  Future<LoggedUser> getUserFromDB(String id) async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await users.where('uid', isEqualTo: id).get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;
    for (var doc in docs) {
      if (doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        LoggedUser loggedUser = new LoggedUser(
            name: data['name'].toString(),
            surname: data['surname'].toString(),
            uid: id,
            dateOfBirth: data['birthDate'].toString());
        return loggedUser;
      }
    }
    return null;
  }

  // Get random user from DB
  Future<Map> getRandomUserFromDB(String senderId, String randomId) async {
    if (await getUsersCountFromDB() - 1 >
        await _getActiveChatsCountFromDB(senderId)) {
      List<String> ids = await _getActiveChatIds(senderId);
      var snapshot = await users
          .where('uid', isLessThanOrEqualTo: randomId)
          .orderBy('uid', descending: true)
          .limit(_limit)
          .get();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (senderId != data['uid'].toString() && !ids.contains(data['uid'])) {
          return data;
        }
      }
      snapshot = await users
          .where('uid', isGreaterThan: randomId)
          .orderBy('uid')
          .limit(_limit)
          .get();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (senderId != data['uid'].toString() && !ids.contains(data['uid'])) {
          return data;
        }
      }
    }
    return null;
  }

  // Add a new message into the DB
  Future<void> addMessageIntoDB(
      String groupChatId, String senderId, String peerId, content) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var documentReference = FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(timestamp.toString());
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          'idFrom': senderId,
          'idTo': peerId,
          'timestamp': timestamp,
          'content': content,
        },
      );
    });
    await users
        .doc(senderId)
        .collection('activeChats')
        .doc(peerId)
        .update({'lastMessage': timestamp});
    await users
        .doc(peerId)
        .collection('activeChats')
        .doc(senderId)
        .update({'lastMessage': timestamp});
  }

  // Get all the messages of a specific pair of users from the DB
  Stream<QuerySnapshot> getMessagesFromDB(String groupChatId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(_limit)
        .snapshots();
  }

  // Add a new chat to the list of active chats of the sender user
  Future<void> addChatIntoDB(String senderId, String senderName, String peerId,
      String peerName) async {
    await users
        .doc(senderId)
        .collection('activeChats')
        .doc(peerId)
        .set({'name': peerName});
    await _incrementActiveChatsCountIntoDB(senderId);
    await users
        .doc(peerId)
        .collection('activeChats')
        .doc(senderId)
        .set({'name': senderName});
    await _incrementActiveChatsCountIntoDB(peerId);
  }

  // Remove a chat to the list of active chats of the sender user
  Future<void> removeChatFromDB(String senderId, String peerId) async {
    await users.doc(senderId).collection('activeChats').doc(peerId).delete();
    await _decrementActiveChatsCountIntoDB(senderId);
    await users.doc(peerId).collection('activeChats').doc(senderId).delete();
    await _decrementActiveChatsCountIntoDB(peerId);
  }

  Future<List> _getActiveChatIds(String senderId) async {
    var snap = await users
        .doc(senderId)
        .collection('activeChats')
        .orderBy('lastMessage')
        .limit(_limit)
        .get();
    List<String> ids = new List.from([]);
    for (var doc in snap.docs) {
      ids.add(doc.id);
    }
    return ids;
  }

  // Get all the active user chats for a specific user from the DB
  Stream<QuerySnapshot> getActiveChatsFromDB(String senderId) {
    return users
        .doc(senderId)
        .collection('activeChats')
        .orderBy('lastMessage', descending: true)
        .limit(_limit)
        .snapshots();
  }

  // Increment the count of the instances of users into the DB
  Future<void> _incrementActiveChatsCountIntoDB(String id) async {
    var data =
        (await users.doc(id).collection('activeChats').doc('utils').get())
            .data();
    if (data == null) {
      await users
          .doc(id)
          .collection('activeChats')
          .doc('utils')
          .set({'count': 1}).catchError(
              (error) => print("Failed to update user count: $error"));
    } else {
      await users
          .doc(id)
          .collection('activeChats')
          .doc('utils')
          .update({'count': data['count'] + 1}).catchError(
              (error) => print("Failed to update user count: $error"));
    }
  }

  // Decrement the count of the instances of users into the DB
  Future<void> _decrementActiveChatsCountIntoDB(String id) async {
    var data =
        (await users.doc(id).collection('activeChats').doc('utils').get())
            .data();
    await users
        .doc(id)
        .collection('activeChats')
        .doc('utils')
        .update({'count': data['count'] - 1}).catchError(
            (error) => print("Failed to update user count: $error"));
  }

  // Get the count of the intances of users from the DB
  Future<int> _getActiveChatsCountFromDB(String id) async {
    var data =
        (await users.doc(id).collection('activeChats').doc('utils').get())
            .data();
    if (data == null) {
      return 0;
    }
    return data['count'];
  }

  // Update a field of a specific user into DB
  Future<void> updateUserFieldIntoDB(
      String id, String fieldName, String field) async {
    await users.doc(id).update({fieldName: field});
  }
}
