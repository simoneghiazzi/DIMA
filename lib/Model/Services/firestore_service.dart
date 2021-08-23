import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';

class FirestoreService {
  // The collection of users in the firestore DB
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  // The collection of experts in the firestore DB
  CollectionReference experts =
      FirebaseFirestore.instance.collection('experts');
  //The collection of users in the firestore DB
  final CollectionReference reports =
      FirebaseFirestore.instance.collection('reports');

  String activeChatCollection = 'anonymousActiveChats';
  String pendingChatCollection = 'anonymousPendingChats';
  String expertChatCollection = 'expertChats';

  int _limit = 30;

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
        .doc(id)
        .set({
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
        await _getChatsCountFromDB(senderId)) {
      List<String> activeIds =
          await _getChatIds(senderId, activeChatCollection);
      List<String> pendingIds =
          await _getChatIds(senderId, pendingChatCollection);
      var snapshot = await users
          .where('uid', isLessThanOrEqualTo: randomId)
          .orderBy('uid', descending: true)
          .limit(_limit)
          .get();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (senderId != data['uid'].toString() &&
            !activeIds.contains(data['uid']) &&
            !pendingIds.contains(data['uid'])) {
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
        if (senderId != data['uid'].toString() &&
            !activeIds.contains(data['uid']) &&
            !pendingIds.contains(data['uid'])) {
          return data;
        }
      }
    }
    return null;
  }

  // Add a new message to an expert user into the DB
  Future<void> addMessageToExpertIntoDB(
      String groupChatId, String senderId, String peerId, content) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    _addMessageIntoDB(groupChatId, senderId, peerId, content, timestamp);
    await users
        .doc(senderId)
        .collection(expertChatCollection)
        .doc(peerId)
        .update({'lastMessage': timestamp});
    await experts
        .doc(peerId)
        .collection('chats')
        .doc(senderId)
        .update({'lastMessage': timestamp});
  }

  // Add a new response message of an expert to the user into the DB
  Future<void> addExpertResponseIntoDB(
      String groupChatId, String senderId, String peerId, content) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    _addMessageIntoDB(groupChatId, senderId, peerId, content, timestamp);
    await experts
        .doc(senderId)
        .collection('chats')
        .doc(peerId)
        .update({'lastMessage': timestamp});
    await users
        .doc(peerId)
        .collection(expertChatCollection)
        .doc(senderId)
        .update({'lastMessage': timestamp});
  }

  // Add a new message to an anonymous user into the DB
  Future<void> addMessageToUserIntoDB(
      String groupChatId, String senderId, String peerId, content) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    _addMessageIntoDB(groupChatId, senderId, peerId, content, timestamp);
    await users
        .doc(senderId)
        .collection(activeChatCollection)
        .doc(peerId)
        .update({'lastMessage': timestamp});
    if ((await users
            .doc(peerId)
            .collection(activeChatCollection)
            .doc(senderId)
            .get())
        .exists)
      await users
          .doc(peerId)
          .collection(activeChatCollection)
          .doc(senderId)
          .update({'lastMessage': timestamp});
    else
      await users
          .doc(peerId)
          .collection(pendingChatCollection)
          .doc(senderId)
          .update({'lastMessage': timestamp});
  }

  // Add a new message into the DB
  Future<void> _addMessageIntoDB(String groupChatId, String senderId,
      String peerId, content, int timestamp) async {
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
    await users
        .doc(senderId)
        .collection(activeChatCollection)
        .doc(peerId)
        .set({});
    await _incrementChatsCountIntoDB(senderId);
    await addPendingChatIntoDB(senderId, peerId);
  }

  Future<void> addPendingChatIntoDB(String senderId, String peerId) async {
    await users
        .doc(peerId)
        .collection(pendingChatCollection)
        .doc(senderId)
        .set({});
    await _incrementChatsCountIntoDB(peerId);
  }

  Future<void> upgradePendingToActiveChatIntoDB(
      String senderId, String peerId) async {
    var pendingChat = await users
        .doc(senderId)
        .collection(pendingChatCollection)
        .doc(peerId)
        .get();
    await users
        .doc(senderId)
        .collection(pendingChatCollection)
        .doc(peerId)
        .delete();
    await users.doc(senderId).collection(activeChatCollection).doc(peerId).set({
      'name': pendingChat.data()['name'],
      'lastMessage': pendingChat.data()['lastMessage']
    });
  }

  // Remove the messages between 2 users from the DB
  Future<void> removeMessagesFromDB(String groupChatId) async {
    var messages = await FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .get();
    messages.docs.forEach((doc) async {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(doc.id)
          .delete();
    });
  }

  // Remove a chat to the list of active chats of the sender user
  Future<void> removeActiveChatFromDB(String senderId, String peerId) async {
    await users
        .doc(senderId)
        .collection(activeChatCollection)
        .doc(peerId)
        .delete();
    await _decrementChatsCountIntoDB(senderId);
    await users
        .doc(peerId)
        .collection(pendingChatCollection)
        .doc(senderId)
        .delete();
    await _decrementChatsCountIntoDB(peerId);
  }

  // Remove a chat to the list of active chats of the sender user
  Future<void> removePendingChatFromDB(String senderId, String peerId) async {
    await users
        .doc(senderId)
        .collection(pendingChatCollection)
        .doc(peerId)
        .delete();
    await _decrementChatsCountIntoDB(senderId);
    await users
        .doc(peerId)
        .collection(activeChatCollection)
        .doc(senderId)
        .delete();
    await _decrementChatsCountIntoDB(peerId);
  }

  // Get the list of ids of active or pending chats of a user
  Future<List> _getChatIds(String senderId, String collection) async {
    List<String> ids = new List.from([]);
    var snap = await users
        .doc(senderId)
        .collection(collection)
        .orderBy('lastMessage')
        .limit(_limit)
        .get();
    for (var doc in snap.docs) {
      ids.add(doc.id);
    }
    return ids;
  }

  // Get the active user chats or the pending user chats for a specific user from the DB
  Future<List> getChatsFromDB(String senderId, String collection) async {
    var ids = await _getChatIds(senderId, collection);
    List<List<String>> subList = [];
    List activeChats = [];
    for (var i = 0; i < ids.length; i += 10) {
      subList.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    await Future.forEach(subList, (elem) async {
      activeChats.addAll((await users.where('uid', whereIn: elem).get()).docs);
    });
    activeChats.sort((a, b) => ids.indexOf(b.id).compareTo(ids.indexOf(a.id)));
    return activeChats;
  }

  // Increment the count of the instances of users into the DB
  Future<void> _incrementChatsCountIntoDB(String id) async {
    var data =
        (await users.doc(id).collection('utils').doc('utils').get()).data();
    if (data == null) {
      await users
          .doc(id)
          .collection('utils')
          .doc('utils')
          .set({'count': 1}).catchError(
              (error) => print("Failed to update user count: $error"));
    } else {
      await users
          .doc(id)
          .collection('utils')
          .doc('utils')
          .update({'count': data['count'] + 1}).catchError(
              (error) => print("Failed to update user count: $error"));
    }
  }

  // Decrement the count of the instances of users into the DB
  Future<void> _decrementChatsCountIntoDB(String id) async {
    var data =
        (await users.doc(id).collection('utils').doc('utils').get()).data();
    await users
        .doc(id)
        .collection('utils')
        .doc('utils')
        .update({'count': data['count'] - 1}).catchError(
            (error) => print("Failed to update user count: $error"));
  }

  // Get the count of the intances of users from the DB
  Future<int> _getChatsCountFromDB(String id) async {
    var data =
        (await users.doc(id).collection('utils').doc('utils').get()).data();
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

  // Add a new report into the DB
  Future<void> addReportIntoDB(
      String id, String category, String description) async {
    await reports.doc(id).collection('reportsList').doc().set({
      'uid': id,
      'category': category,
      'description': description,
      'date': DateTime.now().toString()
    });
  }

  // Get all the reports of a user from the DB
  Stream<QuerySnapshot> getReportsFromDB(String id) {
    return reports
        .doc(id)
        .collection('reportsList')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
