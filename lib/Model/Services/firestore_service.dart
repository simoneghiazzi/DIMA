import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'dart:collection';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';

class FirestoreService {
  // Firestore instance
  final FirebaseFirestore _firestore;
  // Firebase storage instance
  final FirebaseStorage? firebaseStorage;
  // Max number of returned instances from the DB by the queries
  int _limit = 30;

  /// Service used by the view models to interact with the Firestore DB
  FirestoreService(this._firestore, {this.firebaseStorage});

  /***************************************** USERS *****************************************/

  /// Add a user into the firestore DB.
  ///
  /// It takes the [user] and based on the type it adds him/her to the list of experts or to the list
  /// of base users (in this case it also increments the collection counter).
  Future<void> addUserIntoDB(User user) async {
    var userReference = _firestore.collection(user.collection).doc(user.id);
    if (user is BaseUser) {
      // If the user is a base user, increment the base user counter
      _incrementBaseUsersCounter(1);
    } else {
      // Otherwise, update the profile photo into the FirebaseStorage
      await uploadProfilePhoto(user as Expert);
    }
    return userReference.set(user.data).then((_) {
      log("User added");
    }).catchError((error) {
      log("Failed to add user: $error");
    });
  }

  /// Delete a user from the firestore DB.
  ///
  /// It takes the [user] and based on the type it deletes him/her from the list of experts or from the list
  /// of base users and it decrements the collection counter.
  Future<void> removeUserFromDB(User user) {
    var userReference = _firestore.collection(user.collection).doc(user.id);
    // If the user is a base user, decrement the base user counter
    if (user is BaseUser) {
      _incrementBaseUsersCounter(-1);
    }
    return userReference.delete().then((value) => log("User deleted")).catchError((error) => log("Failed to delete user: $error"));
  }

  /// It takes a [user] and updates the specified [field] with the [newValue] into the DB
  Future<void> updateUserFieldIntoDB(User user, String field, newValue) {
    return _firestore
        .collection(user.collection)
        .doc(user.id)
        .update({field: newValue})
        .then((value) => log("User updated"))
        .catchError((error) => log("Failed to update user: $error"));
  }

  /// Get the list of all the docs in the [Expert] collection from the DB
  Future<QuerySnapshot> getExpertCollectionFromDB() {
    return _firestore.collection(Expert.COLLECTION).get();
  }

  /// It takes the [id] and the [collection] and returns a doc instance with
  /// all the information of the retrieved user
  Future<QuerySnapshot> getUserByIdFromDB(String collection, String id) {
    return _firestore.collection(collection).where(FieldPath.documentId, isEqualTo: id).limit(1).get();
  }

  /// Get random user from the DB. It takes the [user] and the auto-generated [randomId] and it returns a Future BaseUser instance
  ///
  /// 1. Check if the number of chats of the user is less than the total number of users, if not return null
  /// 2. Get all the active, pending and request chat ids set
  /// 3. Take the list of the first _limit users with the id <= randomId and id > randomId and sample a random
  /// user id that is not the sender him/herself or that is not in the list of active/pending chat ids
  Future<QueryDocumentSnapshot?> getRandomUserFromDB(BaseUser user, String randomId) async {
    var baseUserCounter = (await _getBaseUsersCounter()).get("userCounter");
    var res = (await _getChatsCounterFromDB(user));
    var chatsCounter = res.exists ? res.get("anonymousChatCounter") : 0;

    // Check if there is at least 1 user that is not already present in the user chats
    if (baseUserCounter - 1 > chatsCounter) {
      // Get the hash set of the active, pending and request chats
      HashSet<String> activeIds = await _getChatIdsSet(user, AnonymousChat.COLLECTION);
      HashSet<String> pendingIds = await _getChatIdsSet(user, PendingChat.COLLECTION);
      HashSet<String> requests = await _getChatIdsSet(user, Request.COLLECTION);

      // Get the ids less than or equal to the random id
      var snapshotLess = await _firestore.collection(user.collection).where("uid", isLessThanOrEqualTo: randomId).orderBy("uid").limit(_limit).get();

      // Get the ids grater than the random id
      var snapshotGreater = await _firestore.collection(user.collection).where("uid", isGreaterThan: randomId).orderBy("uid").limit(_limit).get();

      // Union of the retrieved ids to the same list
      List randomUsers = new List.from(snapshotLess.docs);
      randomUsers.addAll(snapshotGreater.docs);

      while (randomUsers.length != 0) {
        var doc = randomUsers.removeAt(math.Random().nextInt(randomUsers.length));
        if (doc.id == "utils") {
          continue;
        }
        // Check if the id is different from the one of the logged user and is not already present in the chat sets
        if (user.id != doc.id && !activeIds.contains(doc.id) && !pendingIds.contains(doc.id) && !requests.contains(doc.id)) {
          return doc;
        }
      }
    }
    return null;
  }

  /// Find the collection of the user [id] inside the base collections of the DB
  Future<User?> findUserType(String id) async {
    for (var user in [BaseUser(), Expert()]) {
      try {
        var snap = await _firestore.collection(user.collection).doc(id).get();
        if (snap.exists) {
          return user;
        }
      } catch (e) {
        log("User not found in collection ${user.collection}");
      }
    }
    return null;
  }

  /// Upload the [profilePhoto] of the [expert] into the FirebaseStorage and add the url into the user doc in the DB
  Future<void> uploadProfilePhoto(Expert expert) async {
    var firebaseStorageRef = (firebaseStorage ?? FirebaseStorage.instance).ref().child(expert.id + "/profilePhoto");
    UploadTask uploadTask = firebaseStorageRef.putFile(File(expert.profilePhoto));
    await uploadTask.whenComplete(() async {
      log("Profile Photo uploaded");
      expert.profilePhoto = await firebaseStorageRef.getDownloadURL();
    });
  }

  /// It takes the [increment] amount and increments the user's counter into the DB
  Future<void> _incrementBaseUsersCounter(int increment) async {
    var utilsReference = _firestore.collection(BaseUser.COLLECTION).doc("utils");
    await _firestore
        .runTransaction((transaction) async {
          var utils = await transaction.get(utilsReference);
          int? counter;
          utils.data() != null ? counter = utils.get("userCounter") : counter = 0;
          transaction.set(utilsReference, {"userCounter": counter! + increment});
        })
        .then((value) => log("Base user counter incremented"))
        .catchError((error) => log("Failed to increment the base user counter: $error"));
  }

  /// Get the counter of the intances of base users from the DB
  Future<DocumentSnapshot> _getBaseUsersCounter() {
    return _firestore.collection(BaseUser.COLLECTION).doc("utils").get();
  }

  /***************************************** MESSAGES *****************************************/

  /// It takes the [chat] between the 2 users and the [message] and adds it into the messages collection of the DB.
  ///
  /// Then it calls [_updateChatInfo].
  Future<void> addMessageIntoDB(User senderUser, Chat chat, Message message) async {
    String pairChatId = Utils.pairChatId(senderUser.id, chat.peerUser!.id);
    _firestore
        .collection(Message.COLLECTION)
        .doc(pairChatId)
        .collection(pairChatId)
        .doc(message.timestamp.millisecondsSinceEpoch.toString())
        .set(message.data);
    _updateChatInfo(senderUser, chat, message.timestamp.millisecondsSinceEpoch);
  }

  /// It takes the [pairChatId] that is the composite id of the 2 users and returns
  /// the stream of all the messages between the 2 users oredered by timestamp from the DB.
  Stream<QuerySnapshot> getMessagesStreamFromDB(String pairChatId) {
    return _firestore.collection(Message.COLLECTION).doc(pairChatId).collection(pairChatId).orderBy("timestamp", descending: true).snapshots();
  }

  /// It takes the [pairChatId] and removes the messages between the 2 users from the DB.
  Future<void> removeMessagesFromDB(String pairChatId) async {
    var messages = _firestore.collection(Message.COLLECTION).doc(pairChatId).collection(pairChatId).get();
    WriteBatch batch = _firestore.batch();
    messages.then((documentSnapshot) {
      documentSnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
      batch.commit().then((value) => log("Messages removed")).catchError((error) => log("Failed to remove the messages: $error"));
    });
  }

  /// It sets the `notReadMessages` field of the chat of the [senderUser] with the peerUser specified
  /// in the [chat] to `0`.
  Future<void> setMessagesHasRead(User senderUser, Chat chat) {
    return _firestore
        .collection(senderUser.collection)
        .doc(senderUser.id)
        .collection(chat.collection)
        .doc(chat.peerUser!.id)
        .update({"notReadMessages": 0})
        .then((value) => log("notReadMessages field setted to zero"))
        .catchError((error) => log("Failed to set the notReadMessages field: $error"));
  }

  /***************************************** CHATS *****************************************/

  /// Upgrade the [PendingChat] of the [senderUser] and the [Request] of the
  /// [peerUser] to an [AnonymousChat] for both the users.
  void upgradePendingToActiveChatIntoDB(User senderUser, Chat chat) {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var pendingChatsReference =
        _firestore.collection(senderUser.collection).doc(senderUser.id).collection(PendingChat.COLLECTION).doc(chat.peerUser!.id);
    var senderAnonymousChatsReference =
        _firestore.collection(senderUser.collection).doc(senderUser.id).collection(AnonymousChat.COLLECTION).doc(chat.peerUser!.id);
    var requestsReference = _firestore.collection(chat.peerUser!.collection).doc(chat.peerUser!.id).collection(Request.COLLECTION).doc(senderUser.id);
    var peerAnonymousChatsReference =
        _firestore.collection(chat.peerUser!.collection).doc(chat.peerUser!.id).collection(AnonymousChat.COLLECTION).doc(senderUser.id);

    WriteBatch batch = _firestore.batch();
    // Pending chat of the sender user is moved into active chats
    batch.delete(pendingChatsReference);
    batch.set(senderAnonymousChatsReference, {"lastMessageTimestamp": timestamp, "notReadMessages": 0, "lastMessage": chat.lastMessage});
    // Request chat of the peer user is moved into active chats
    batch.delete(requestsReference);
    batch.set(peerAnonymousChatsReference, {"lastMessageTimestamp": timestamp, "notReadMessages": 0, "lastMessage": chat.lastMessage});

    batch.commit().then((value) => log("Chats upgraded")).catchError((error) => log("Failed to upgrade the chats: $error"));
  }

  /// Remove the [chat] between the [senderUser] and the [peerUser] specified in the [chat].
  void removeChatFromDB(User senderUser, Chat chat) {
    var senderUserReference = _firestore.collection(senderUser.collection).doc(senderUser.id).collection(chat.collection).doc(chat.peerUser!.id);
    var peerUserReference =
        _firestore.collection(chat.peerUser!.collection).doc(chat.peerUser!.id).collection(chat.peerCollection).doc(senderUser.id);

    WriteBatch batch = _firestore.batch();
    batch.delete(senderUserReference);
    batch.delete(peerUserReference);
    batch.commit().then((value) => log("Chat removed")).catchError((error) => log("Failed to remove the chat: $error"));
    _incrementConversationCounter(senderUser, chat, -1);
  }

  /// It takes the [user] and returns the list of all the chat of the
  /// user based on the [chatCollection] ordered by lastMessageTimestamp.
  Stream<QuerySnapshot> getChatsStreamFromDB(User user, String chatCollection) {
    return _firestore.collection(user.collection).doc(user.id).collection(chatCollection).orderBy("lastMessageTimestamp").limit(_limit).snapshots();
  }

  /// It updates the `lastMessage`, `lastMessageTimestamp` and `notReadMessages` fields
  /// of the [senderUser] and peerUsers specified in the [chat].
  ///
  /// If the [chat] is a [Request], adds it to the list of chats of the 2 users
  /// in the correct collection and updates the counters.
  void _updateChatInfo(User senderUser, Chat chat, int timestamp) async {
    var senderUserRef = _firestore.collection(senderUser.collection).doc(senderUser.id).collection(chat.collection).doc(chat.peerUser!.id);
    var peerUserRef = _firestore.collection(chat.peerUser!.collection).doc(chat.peerUser!.id).collection(chat.peerCollection).doc(senderUser.id);

    var doc = await peerUserRef.get();
    int? counter;
    doc.data() != null ? counter = doc.get("notReadMessages") + 1 : counter = 1;

    // If the chat is a Request and the counter is 1 it means that it is a new chat and it is the first message,
    // so call increment conversation counter
    if (chat is Request && counter == 1) {
      _incrementConversationCounter(senderUser, chat, 1);
    }
    WriteBatch batch = _firestore.batch();
    // The notReadMessages field is setted to 0 for the sender user and to counter for the peer user
    batch.set(senderUserRef, {"lastMessageTimestamp": timestamp, "notReadMessages": 0, "lastMessage": chat.lastMessage});
    batch.set(peerUserRef, {"lastMessageTimestamp": timestamp, "notReadMessages": counter, "lastMessage": chat.lastMessage});
    batch.commit().then((value) => log("Chat info updated")).catchError((error) => log("Failed to update the chat info: $error"));
  }

  /// It takes the [user] and returns the hash set of ids of all the chat
  /// of the user based on the [chatCollection].
  Future<HashSet<String>> _getChatIdsSet(User user, String chatCollection) async {
    HashSet<String> ids = new HashSet();
    var snap =
        await _firestore.collection(user.collection).doc(user.id).collection(chatCollection).orderBy("lastMessageTimestamp").limit(_limit).get();
    for (var doc in snap.docs) {
      ids.add(doc.id);
    }
    return ids;
  }

  /// It takes the [chat] and the [increment] amount and increments the anonymous chat's counter
  /// of the [senderUser] and of the [peerUser] specified in the [chat] within a transaction.
  void _incrementConversationCounter(User senderUser, Chat chat, int increment) {
    var utilsSenderReference = _firestore.collection(senderUser.collection).doc(senderUser.id).collection("utils").doc("utils");
    var utilsPeerReference = _firestore.collection(chat.peerUser!.collection).doc(chat.peerUser!.id).collection("utils").doc("utils");

    _firestore
        .runTransaction((transaction) async {
          var utilsSender = await transaction.get(utilsSenderReference);
          var utilsPeer = await transaction.get(utilsPeerReference);
          int? oldCounterSender, oldCounterPeer;
          utilsSender.data() != null ? oldCounterSender = utilsSender.get("anonymousChatCounter") : oldCounterSender = 0;
          utilsPeer.data() != null ? oldCounterPeer = utilsPeer.get("anonymousChatCounter") : oldCounterPeer = 0;
          int newCounterSender = oldCounterSender! + increment;
          int newCounterPeer = oldCounterPeer! + increment;
          transaction.set(utilsSenderReference, {"anonymousChatCounter": newCounterSender < 0 ? 0 : newCounterSender});
          transaction.set(utilsPeerReference, {"anonymousChatCounter": newCounterPeer < 0 ? 0 : newCounterPeer});
        })
        .then((value) => log("Conversation counters incremented"))
        .catchError((error) => log("Failed to increment the conversation counters: $error"));
  }

  /// It takes the [user] and returns the anonymous chat's counter from the DB
  Future<DocumentSnapshot> _getChatsCounterFromDB(User user) async {
    return _firestore.collection(BaseUser.COLLECTION).doc(user.id).collection("utils").doc("utils").get();
  }

  /***************************************** REPORTS *****************************************/

  /// It takes the [id] of an user and the [report] and
  /// adds it into the list of reports of the user into the DB
  Future<void> addReportIntoDB(String id, Report report) async {
    _firestore
        .collection(report.collection)
        .doc(id)
        .collection("reportList")
        .doc(report.id)
        .set(report.data)
        .then((value) => log("Report added"))
        .catchError((error) => log("Failed to add the report: $error"));
  }

  /// It takes the [id] of an user and return the stream of all the
  /// reports of the user oredered in descending by date from the DB
  Future<QuerySnapshot> getReportsFromDB(String id) {
    return _firestore.collection(Report.COLLECTION).doc(id).collection("reportList").orderBy(FieldPath.documentId).get();
  }

  /**************************************** DIARY ********************************************/

  /// It takes the [id] of an user and the [diaryPage]
  /// and adds it into the list of diaryPages of the user into the DB
  Future<void> addDiaryPageIntoDB(String id, DiaryPage diaryPage) {
    return _firestore
        .collection(diaryPage.collection)
        .doc(id)
        .collection("diaryPages")
        .doc(diaryPage.id)
        .set(diaryPage.data)
        .then((value) => log("Diary page added"))
        .catchError((error) => log("Failed to add the diary note: $error"));
  }

  /// It takes the [id] of an user and the new [diaryPage]
  /// and updates the title and content fields into the DB
  Future<void> updateDiaryPageIntoDB(String id, DiaryPage diaryPage) {
    return _firestore
        .collection(diaryPage.collection)
        .doc(id)
        .collection("diaryPages")
        .doc(diaryPage.id)
        .update({
          "title": diaryPage.data["title"],
          "content": diaryPage.data["content"],
          "dateTime": diaryPage.data["dateTime"],
        })
        .then((value) => log("Diary page updated"))
        .catchError((error) => log("Failed to update the diary note: $error"));
  }

  /// It takes the [id] of an user and the [diaryPage] and set it as favourite or not
  Future<void> setFavouriteDiaryNotesIntoDB(String id, DiaryPage diaryPage) {
    return _firestore
        .collection(diaryPage.collection)
        .doc(id)
        .collection("diaryPages")
        .doc(diaryPage.id)
        .update({
          "favourite": diaryPage.data["favourite"],
        })
        .then((value) => log("Favourite note updated"))
        .catchError((error) => log("Failed to update the favourite note: $error"));
  }

  /// It takes the [id] of an user and return the stream of
  /// all the diaryPages of the user oredered by date from the DB
  Stream<QuerySnapshot> getDiaryPagesStreamFromDB(String id) {
    return _firestore.collection(DiaryPage.COLLECTION).doc(id).collection("diaryPages").orderBy(FieldPath.documentId).snapshots();
  }
}
