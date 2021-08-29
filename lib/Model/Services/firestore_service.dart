import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/conversation.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/request.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/report.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Service used by the view models to interact with the Firestore DB
class FirestoreService {
  // Firestore instance
  final _firestore = FirebaseFirestore.instance;
  // Limit of returned instances from the DB by the queries
  int _limit = 30;

  /***************************************** USERS *****************************************/

  /// Add a user into the firestore DB.
  /// It takes the [user] and based on the type it adds him/her to the list of experts or to the list
  /// of users and it increments the collection counter.
  Future<void> addUserIntoDB(User user) async {
    await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .set(user.getData())
        .then((value) => print('User added'))
        .catchError((error) => print("Failed to add user: $error"));
    await _incrementBaseCollectionCounter(user.collection, 1);
  }

  /// Delete a user from the firestore DB.
  /// It takes the [user] and based on the type it deletes him/her from the list of experts or from the list
  /// of users and it decrements the collection counter.
  Future<void> removeUserFromDB(User user) async {
    await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .delete()
        .catchError((error) => print("Failed to delete user: $error"));
    await _incrementBaseCollectionCounter(user.collection, -1);
  }

  /// It takes a [user] and updates the specified [field] with the [newValue] into the DB
  Future<void> updateUserFieldIntoDB(User user, String field, newValue) async {
    await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .update({field: newValue});
  }

  /// Get the list of all the doc in [collection] from the DB
  Future<QuerySnapshot> getBaseCollectionFromDB(Collection collection) async {
    return await _firestore.collection(collection.value).get();
  }

  /// It takes the [id] and the [collection] and returns a doc instance with
  /// all the information of the retrieved user
  Future<DocumentSnapshot> getUserByIdFromDB(
      Collection collection, String id) async {
    var snap = await _firestore
        .collection(collection.value)
        .where(FieldPath.documentId, isEqualTo: id)
        .get();
    if (snap.docs.isNotEmpty) return snap.docs[0];
    return null;
  }

  /// It takes the [list] of ids and the [collection] (users/experts)
  /// and returns a list of docs with all the information of the retrieved users
  Future<List> _getUsersByList(Collection collection, List list) async {
    var snap = await _firestore
        .collection(collection.value)
        .where(FieldPath.documentId, whereIn: list)
        .get();
    return List.from(snap.docs);
  }

  /// Increment the count of the instances of [collection] into the DB
  Future<void> _incrementBaseCollectionCounter(
      Collection collection, int increment) async {
    var utils = await _firestore
        .collection(collection.value)
        .doc(Collection.UTILS.value)
        .get();
    int counter;
    utils.data() != null ? counter = utils.get('userCounter') : counter = 0;
    await _firestore
        .collection(collection.value)
        .doc(Collection.UTILS.value)
        .set({'userCounter': counter + increment}).catchError(
            (error) => print("Failed to update the counter: $error"));
  }

  /// Get the counter of the intances of [collection] from the DB
  Future<int> _getBaseCollectionCounter(Collection collection) async {
    var utils = await _firestore
        .collection(collection.value)
        .doc(Collection.UTILS.value)
        .get();
    return utils.get('userCounter');
  }

  /// Get random user from the DB. It takes the [user] and the auto-generated [randomId] and it returns a Future BaseUser instance
  // 1. Check if the number of chats of the user is less than the total number of users, if not return null
  // 2. Get all the active and pending chat users id
  // 3. Take the ordered list of users with the id <= randomId and take the first
  // user id that is not the sender him/herself or that is not in the list of active/pending chat ids
  // 4. If no user is returned, repeat the search with the ids > randomId
  Future<BaseUser> getRandomUserFromDB(BaseUser user, String randomId) async {
    if (await _getBaseCollectionCounter(Collection.BASE_USERS) - 1 >
        await _getChatsCounterFromDB(user)) {
      List<String> activeIds = await _getChatIds(user, ActiveChat());
      List<String> pendingIds = await _getChatIds(user, PendingChat());
      List<String> requests = await _getChatIds(user, Request());
      var snapshot = await _firestore
          .collection(user.collection.value)
          .where('uid', isLessThanOrEqualTo: randomId)
          .orderBy('uid', descending: true)
          .limit(_limit)
          .get();
      while (true) {
        for (var doc in snapshot.docs) {
          if (user.id != doc.get('uid') &&
              !activeIds.contains(doc.get('uid')) &&
              !pendingIds.contains(doc.get('uid')) &&
              !requests.contains(doc.get('uid'))) {
            var user = BaseUser();
            user.setFromDocument(doc);
            return user;
          }
        }
        snapshot = await _firestore
            .collection(user.collection.value)
            .where('uid', isGreaterThan: randomId)
            .orderBy('uid', descending: true)
            .limit(_limit)
            .get();
      }
    }
    return null;
  }

  /// Find the collection of the user [id] inside the base collections of the DB
  Future<Collection> findUserInCollections(String id) async {
    var baseCollections = [Collection.BASE_USERS, Collection.EXPERTS];
    for (var collection in baseCollections) {
      try {
        var snap = await _firestore
            .collection(collection.value)
            .where(FieldPath.documentId, isEqualTo: id)
            .get();
        if (snap.docs.isNotEmpty) return collection;
      } catch (e) {}
    }
    return null;
  }

  Future<void> uploadProfilePhoto(User user, File profilePhoto) async {
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child(user.id + '/profilePhoto');
    UploadTask uploadTask = firebaseStorageRef.putFile(profilePhoto);
    uploadTask.whenComplete(() async {
      updateUserFieldIntoDB(
          user, 'profilePhoto', await firebaseStorageRef.getDownloadURL());
    }).catchError((err) {
      print(err);
    });
  }

  /***************************************** MESSAGES *****************************************/

  /// It updates the field of the lastMessage of the sender and peer Users. If the chat is new, it
  /// adds it to the list of chats of the 2 users in the collection specified
  /// into the [conversation] field and updates the chat counters,
  Future<void> _updateChatInfo(Conversation conversation, timestamp) async {
    await _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(conversation.senderUserChat.chatCollection.value)
        .doc(conversation.peerUser.id)
        .set({'lastMessage': timestamp});
    await _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(conversation.peerUserChat.chatCollection.value)
        .doc(conversation.senderUser.id)
        .set({'lastMessage': timestamp});
    // Increments the counter only if the sender and the peer users are base users and if
    // this is their first message
    if (conversation.senderUser.collection == Collection.BASE_USERS &&
        conversation.peerUser.collection == Collection.BASE_USERS &&
        !await hasMessages(conversation.pairChatId)) {
      _incrementChatsCounter(conversation.senderUser, 1);
      _incrementChatsCounter(conversation.peerUser, 1);
    }
  }

  /// It takes the [pairChatId] that is the composite id of the 2 users, the [senderUserChat],
  /// the [peerUserChat] and the [content] of message and adds a new message into the messages collection of the DB.
  /// Then it calls the updateChatInfo method
  Future<void> addMessageIntoDB(Conversation conversation, content) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var documentReference = _firestore
        .collection(Collection.MESSAGES.value)
        .doc(conversation.pairChatId)
        .collection(conversation.pairChatId)
        .doc(timestamp.toString());
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          'idFrom': conversation.senderUser.id,
          'idTo': conversation.peerUser.id,
          'timestamp': timestamp,
          'content': content,
        },
      );
    });
    _updateChatInfo(conversation, timestamp);
  }

  /// It takes the [pairChatId] that is the composite id of the 2 users and
  /// returns the stream of all the messages between the pair of users from the DB
  Stream<QuerySnapshot> getStreamMessagesFromDB(String pairChatId) {
    return _firestore
        .collection(Collection.MESSAGES.value)
        .doc(pairChatId)
        .collection(pairChatId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// It takes the [pairChatId] that is the composite id of the 2 users and returns true
  /// if there is at least 1 between the pair of users from the DB, false otherwise
  Future<bool> hasMessages(String pairChatId) async {
    var snap = await _firestore
        .collection(Collection.MESSAGES.value)
        .doc(pairChatId)
        .collection(pairChatId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) return true;
    return false;
  }

  /// It takes the [pairChatId] and removes the messages between the 2 users from the DB
  Future<void> removeMessagesFromDB(String pairChatId) async {
    var messages = await _firestore
        .collection(Collection.MESSAGES.value)
        .doc(pairChatId)
        .collection(pairChatId)
        .get();
    messages.docs.forEach((doc) async {
      await _firestore
          .collection(Collection.MESSAGES.value)
          .doc(pairChatId)
          .collection(pairChatId)
          .doc(doc.id)
          .delete();
    });
  }

  /***************************************** CHATS *****************************************/

  /// Upgrade a [pendingUserChat] with a [peerUser] to an active chat for both the users.
  Future<void> upgradePendingToActiveChatIntoDB(
      Conversation conversation) async {
    if (conversation.senderUserChat.chatCollection ==
        Collection.PENDING_CHATS) {
      // Pending chat of the sender user is moved into active chats
      var pendingChat = await _firestore
          .collection(conversation.senderUser.collection.value)
          .doc(conversation.senderUser.id)
          .collection(conversation.senderUserChat.chatCollection.value)
          .doc(conversation.peerUser.id)
          .get();
      await _firestore
          .collection(conversation.senderUser.collection.value)
          .doc(conversation.senderUser.id)
          .collection(conversation.senderUserChat.chatCollection.value)
          .doc(conversation.peerUser.id)
          .delete();
      await _firestore
          .collection(conversation.senderUser.collection.value)
          .doc(conversation.senderUser.id)
          .collection(Collection.ACTIVE_CHATS.value)
          .doc(conversation.peerUser.id)
          .set({'lastMessage': pendingChat.get('lastMessage')});
      // Request chat of the peer user is moved into active chats
      var request = await _firestore
          .collection(conversation.peerUser.collection.value)
          .doc(conversation.peerUser.id)
          .collection(conversation.peerUserChat.chatCollection.value)
          .doc(conversation.senderUser.id)
          .get();
      await _firestore
          .collection(conversation.peerUser.collection.value)
          .doc(conversation.peerUser.id)
          .collection(conversation.peerUserChat.chatCollection.value)
          .doc(conversation.senderUser.id)
          .delete();
      await _firestore
          .collection(conversation.peerUser.collection.value)
          .doc(conversation.peerUser.id)
          .collection(Collection.ACTIVE_CHATS.value)
          .doc(conversation.senderUser.id)
          .set({'lastMessage': request.get('lastMessage')});
    }
  }

  /// Remove the [conversation] between the [peerUser] and the [senderUser] list
  Future<void> removeChatFromDB(Conversation conversation) async {
    await _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(conversation.senderUserChat.chatCollection.value)
        .doc(conversation.peerUser.id)
        .delete();
    await _incrementChatsCounter(conversation.senderUser, -1);
    await _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(conversation.peerUserChat.chatCollection.value)
        .doc(conversation.senderUser.id)
        .delete();
    await _incrementChatsCounter(conversation.peerUser, -1);
  }

  /// It takes the [user] and returns the list of all the [chat] of the
  /// user based on the [chatCollection] field of the Chat.
  Future<List> getChatsFromDB(User user, Chat chat) async {
    var ids = await _getChatIds(user, chat);
    List<List<String>> subList = [];
    List chats = [];
    for (var i = 0; i < ids.length; i += 10) {
      subList.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    await Future.forEach(subList, (list) async {
      chats.addAll(await _getUsersByList(chat.targetCollection, list));
    });
    chats.sort((a, b) => ids.indexOf(b.id).compareTo(ids.indexOf(a.id)));
    return chats;
  }

  /// It takes the [user] and returns the list of ids of all the [chat] of the
  /// user based on the [chatCollection] field of the Chat.
  Future<List> _getChatIds(User user, Chat chat) async {
    List<String> ids = new List.from([]);
    var snap = await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(chat.chatCollection.value)
        .orderBy('lastMessage')
        .limit(_limit)
        .get();
    for (var doc in snap.docs) {
      ids.add(doc.id);
    }
    return ids;
  }

  Future<bool> hasPendingChats(User user) async {
    var snap = await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(Collection.PENDING_CHATS.value)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return false;
    return true;
  }

  /// It takes the [user] and the [increment] amount and increments the anonymous chat's counter of the user into the DB
  Future<void> _incrementChatsCounter(User user, int increment) async {
    var utils = await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(Collection.UTILS.value)
        .doc(Collection.UTILS.value)
        .get();
    int oldCounter;
    utils.data() != null
        ? oldCounter = utils.get('anonymousChatCounter')
        : oldCounter = 0;
    int newCounter = oldCounter + increment;
    await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(Collection.UTILS.value)
        .doc(Collection.UTILS.value)
        .set({
      'anonymousChatCounter': newCounter < 0 ? 0 : newCounter
    }).catchError((error) => print("Failed to update the counter: $error"));
  }

  /// It takes the [user] and returns the anonymous chat's counter from the DB
  Future<int> _getChatsCounterFromDB(User user) async {
    var utils = await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(Collection.UTILS.value)
        .doc(Collection.UTILS.value)
        .get();
    if (utils.data() != null)
      return utils.get('anonymousChatCounter');
    else
      return 0;
  }

  /***************************************** REPORTS *****************************************/

  /// It takes the [id] of an user and the [report]
  /// and adds it into the list of reports of the user into the DB
  Future<void> addReportIntoDB(String id, Report report) async {
    await _firestore
        .collection(report.collection.value)
        .doc(id)
        .collection('reportsList')
        .doc(report.id)
        .set(report.getData());
  }

  /// It takes the [id] of an user and return the stream of all the reports of the user from the DB
  Stream<QuerySnapshot> getReportsFromDB(String id) {
    return _firestore
        .collection(Collection.REPORTS.value)
        .doc(id)
        .collection('reportsList')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
