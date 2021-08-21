import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';

class FirestoreService {
  // The collection of users in the firestore DB
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  int _limit = 20;

  // Add a user to the firestore DB
  Future<void> addUserIntoDB(String id, String name, String surname, String birthDate) async {
    await users
        .doc(id)
        .set({
          'uid': id,
          'name': name,
          'surname': surname,
          'birthDate': birthDate
        })
        .catchError((error) => print("Failed to add user: $error"));
    await incrementUsersCountIntoDB();
  }

  // Delete a user from the firestore DB
  Future<void> deleteUserFromDB (String id) async {
    await users.doc(id).delete().catchError((error) => print("Failed to delete user: $error"));
    await decrementUsersCountIntoDB();
  }

  // Increment the count of the instances of users into the DB
  Future<void> incrementUsersCountIntoDB() async {
    var data = (await users.doc('utils').get()).data() as Map<String, dynamic>;
    if(data == null){
      await users.doc('utils').set({'count': 1})
      .catchError((error) => print("Failed to update user count: $error"));
    } else {
      await users.doc('utils').update({'count': data['count'] + 1})
      .catchError((error) => print("Failed to update user count: $error"));
    }
  }

  // Decrement the count of the instances of users into the DB
  Future<void> decrementUsersCountIntoDB() async {
    var data = (await users.doc('utils').get()).data() as Map<String, dynamic>;
    await users.doc('utils').update({'count': data['count'] - 1})
    .catchError((error) => print("Failed to update user count: $error"));
  }

  // Get the count of the intances of users from the DB
  Future<int> getUsersCountFromDB() async {
    var data = (await users.doc('utils').get()).data() as Map<String, dynamic>;
    return data['count'];
  }

  //Query the firestore DB in order to retrieve the user's info
  Future<LoggedUser> getUserFromDB(String id) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await users.where('uid', isEqualTo: id).get();
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
  Future<String> getRandomUserFromDB(String senderId, String randomId) async {
    if(await getUsersCountFromDB() - 1 > await getActiveChatsCountFromDB(senderId)) {
      var snapshot = await users.where('uid', isLessThanOrEqualTo: randomId).orderBy('uid', descending: true).limit(1).get();
      if(snapshot.docs.length == 0) {
        snapshot = await users.where('uid', isGreaterThanOrEqualTo: randomId).orderBy('uid').limit(1).get();
      }
      var docs = snapshot.docs;
      for (var doc in docs) {
        var data = doc.data() as Map<String, dynamic>;
        return data['uid'].toString();        
      }
    }
    return null;
  }

  // Add a new message into the DB
  Future<void> addMessageIntoDB(String groupChatId, String senderId, String peerId, content) async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    var documentReference = FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(timestamp);

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
  Future<void> addChatIntoDB(String senderId, String peerId) async {
    await users.doc(senderId).collection('activeChats').doc(peerId).set({});
    await incrementActiveChatsCountCountIntoDB(senderId);
    await users.doc(peerId).collection('activeChats').doc(senderId).set({});
    await incrementActiveChatsCountCountIntoDB(peerId);
  }

  Future<List> getActiveChatIds(String senderId) async {
    var snap = await users
        .doc(senderId)
        .collection('activeChats')
        .limit(_limit)
        .get();
    List<String> ids = new List.from([]);
    for (var doc in snap.docs) {
      if(doc.id != 'utils')
        ids.add(doc.id);
    }
    return ids;
  }

  // Get all the active user chats for a specific user from the DB
  Future<QuerySnapshot> getActiveChatUsers(String senderId) async {
    return users.where(FieldPath.documentId, whereIn: await getActiveChatIds(senderId)).get();
  }

  // Increment the count of the instances of users into the DB
  Future<void> incrementActiveChatsCountCountIntoDB(String id) async {
    var data = (await users.doc(id).collection('activeChats').doc('utils').get()).data();
    if(data == null){ 
      await users.doc(id).collection('activeChats').doc('utils').set({'count': 1})
      .catchError((error) => print("Failed to update user count: $error"));
    } else {
      await users.doc(id).collection('activeChats').doc('utils').update({'count': data['count'] + 1})
      .catchError((error) => print("Failed to update user count: $error"));
    }
  }
    
  // Get the count of the intances of users from the DB
  Future<int> getActiveChatsCountFromDB(String id) async {
    var data = (await users.doc(id).collection('activeChats').doc('utils').get()).data();
    if(data == null) {
      return 0;
    }
    return data['count'];
  }

  // Update a field of a specific user into DB
  Future<void> updateUserFieldIntoDB(String id, String fieldName, String field) async { 
    await users.doc(id).update({fieldName: field});
  }

}
