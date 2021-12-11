import 'dart:io';
import 'dart:math';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/Model/BaseUser/report.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/conversation.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/BaseUser/Diary/diary_page.dart';

class FirestoreService {
  // Firestore instance
  final FirebaseFirestore _firestore;
  // Max number of returned instances from the DB by the queries
  int _limit = 30;

  /// Service used by the view models to interact with the Firestore DB
  FirestoreService(this._firestore);

  /***************************************** USERS *****************************************/

  /// Add a user into the firestore DB.
  ///
  /// It takes the [user] and based on the type it adds him/her to the list of experts or to the list
  /// of users and it increments the collection counter.
  Future<void> addUserIntoDB(User user) {
    var userReference = _firestore.collection(user.collection.value).doc(user.id);

    // If the user is a base user, increment the base user counter
    if (user.collection == Collection.BASE_USERS) {
      _incrementBaseUsersCounter(1);
    }
    return userReference.set(user.data).then((value) => print("User added")).catchError((error) => print("Failed to add user: $error"));
  }

  /// Delete a user from the firestore DB.
  ///
  /// It takes the [user] and based on the type it deletes him/her from the list of experts or from the list
  /// of users and it decrements the collection counter.
  Future<void> removeUserFromDB(User user) {
    var userReference = _firestore.collection(user.collection.value).doc(user.id);

    // If the user is a base user, decrement the base user counter
    if (user.collection == Collection.BASE_USERS) {
      _incrementBaseUsersCounter(-1);
    }
    return userReference.delete().then((value) => print("User deleted")).catchError((error) => print("Failed to delete user: $error"));
  }

  /// It takes a [user] and updates the specified [field] with the [newValue] into the DB
  Future<void> updateUserFieldIntoDB(User user, String field, newValue) {
    return _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .update({field: newValue})
        .then((value) => print("User updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  /// Get the list of all the docs in the [collection] from the DB
  Future<QuerySnapshot> getBaseCollectionFromDB(Collection collection) {
    return _firestore.collection(collection.value).get();
  }

  /// It takes the [id] and the [collection] and returns a doc instance with
  /// all the information of the retrieved user
  Future<QuerySnapshot> getUserByIdFromDB(Collection collection, String id) {
    return _firestore.collection(collection.value).where(FieldPath.documentId, isEqualTo: id).get();
  }

  /// Get random user from the DB. It takes the [user] and the auto-generated [randomId] and it returns a Future BaseUser instance
  ///
  /// 1. Check if the number of chats of the user is less than the total number of users, if not return null
  /// 2. Get all the active, pending and request chat ids set
  /// 3. Take the list of the first _limit users with the id <= randomId and id > randomId and sample a random
  /// user id that is not the sender him/herself or that is not in the list of active/pending chat ids
  Future<QueryDocumentSnapshot> getRandomUserFromDB(BaseUser user, String randomId) async {
    var baseUserCounter = (await _getBaseUsersCounter()).get("userCounter");
    var res = (await _getChatsCounterFromDB(user));
    var chatsCounter = res.exists ? res.get("anonymousChatCounter") : 0;

    // Check if there is at least 1 user that is not already present in the user chats
    if (baseUserCounter - 1 > chatsCounter) {
      // Get the hash set of the active, pending and request chats
      HashSet<String> activeIds = await _getChatIdsSet(user, ActiveChat());
      HashSet<String> pendingIds = await _getChatIdsSet(user, PendingChat());
      HashSet<String> requests = await _getChatIdsSet(user, Request());

      // Get the ids less than or equal to the random id
      var snapshotLess =
          await _firestore.collection(user.collection.value).where("uid", isLessThanOrEqualTo: randomId).orderBy("uid").limit(_limit).get();

      // Get the ids grater than the random id
      var snapshotGreater =
          await _firestore.collection(user.collection.value).where("uid", isGreaterThan: randomId).orderBy("uid").limit(_limit).get();

      // Union of the retrieved ids to the same list
      List randomUsers = new List.from(snapshotLess.docs);
      randomUsers.addAll(snapshotGreater.docs);

      while (randomUsers.length != 0) {
        var doc = randomUsers.removeAt(Random().nextInt(randomUsers.length));
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
  Future<Collection> findUserCollection(String id) async {
    for (var collection in [Collection.BASE_USERS, Collection.EXPERTS]) {
      try {
        var snap = await _firestore.collection(collection.value).doc(id).get();
        if (snap.exists) {
          return collection;
        }
      } catch (e) {}
    }
    return null;
  }

  /// Upload the [profilePhoto] of the [user] into FirebaseStorage and add the url into the user doc in the DB
  void uploadProfilePhoto(User user, File profilePhoto) {
    var firebaseStorageRef = FirebaseStorage.instance.ref().child(user.id + "/profilePhoto");
    UploadTask uploadTask = firebaseStorageRef.putFile(profilePhoto);
    uploadTask.whenComplete(() async {
      updateUserFieldIntoDB(user, "profilePhoto", await firebaseStorageRef.getDownloadURL());
    });
  }

  /// It takes the [increment] amount and increments the user's counter into the DB
  Future<void> _incrementBaseUsersCounter(int increment) async {
    var utilsReference = _firestore.collection(Collection.BASE_USERS.value).doc(Collection.UTILS.value);
    await _firestore
        .runTransaction((transaction) async {
          var utils = await transaction.get(utilsReference);
          int counter;
          utils.data() != null ? counter = utils.get("userCounter") : counter = 0;
          transaction.set(utilsReference, {"userCounter": counter + increment});
        })
        .then((value) => print("Base user counter incremented"))
        .catchError((error) => print("Failed to increment the base user counter: $error"));
  }

  /// Get the counter of the intances of base users from the DB
  Future<DocumentSnapshot> _getBaseUsersCounter() {
    return _firestore.collection(Collection.BASE_USERS.value).doc(Collection.UTILS.value).get();
  }

  /***************************************** MESSAGES *****************************************/

  /// It takes the [conversation] between the 2 users and the [message] and adds it into the messages collection of the DB.
  ///
  /// Then it calls the updateChatInfo method.
  void addMessageIntoDB(Conversation conversation, Message message) {
    _firestore
        .collection(Collection.MESSAGES.value)
        .doc(conversation.pairChatId)
        .collection(conversation.pairChatId)
        .doc(message.timestamp.millisecondsSinceEpoch.toString())
        .set(message.data);
    _updateChatInfo(conversation, message.timestamp.millisecondsSinceEpoch);
  }

  /// It takes the [pairChatId] that is the composite id of the 2 users and returns
  /// the stream of all the messages between the 2 users oredered by timestamp from the DB.
  Stream<QuerySnapshot> getStreamMessagesFromDB(String pairChatId) {
    return _firestore.collection(Collection.MESSAGES.value).doc(pairChatId).collection(pairChatId).orderBy("timestamp", descending: true).snapshots();
  }

  /// It takes the [pairChatId] and removes the messages between the 2 users from the DB.
  void removeMessagesFromDB(String pairChatId) {
    var messages = _firestore.collection(Collection.MESSAGES.value).doc(pairChatId).collection(pairChatId).get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    messages.then((documentSnapshot) {
      documentSnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
      batch.commit().then((value) => print("Messages removed")).catchError((error) => print("Failed to remove the messages: $error"));
    });
  }

  /// It updatesthe field of the lastMessage of the sender and peer Users.
  ///
  /// If the chat is new, it adds it to the list of chats of the 2 users in the collection specified
  /// into the [conversation] field and updates the chat counters
  void _updateChatInfo(Conversation conversation, int timestamp) async {
    DocumentReference senderUserRef = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(conversation.senderUserChat.chatCollection.value)
        .doc(conversation.peerUser.id);
    DocumentReference peerUserRef = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(conversation.peerUserChat.chatCollection.value)
        .doc(conversation.senderUser.id);

    // Increments the counter only if the sender and the peer users are base users and if this is their first message
    if (conversation.senderUser.collection == Collection.BASE_USERS &&
        conversation.peerUser.collection == Collection.BASE_USERS &&
        !(await senderUserRef.get()).exists) {
      _incrementConversationCounter(conversation, 1);
    }
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.set(senderUserRef, {"lastMessage": timestamp});
    batch.set(peerUserRef, {"lastMessage": timestamp});
    batch.commit().then((value) => print("Chat info updated")).catchError((error) => print("Failed to update the chat info: $error"));
  }

  /***************************************** CHATS *****************************************/

  /// Upgrade a [pendingChat] and a [requestChat] between 2 users to an [activeChat] for both the users
  void upgradePendingToActiveChatIntoDB(Conversation conversation) {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    if (conversation.senderUserChat.chatCollection == Collection.PENDING_CHATS) {
      var pendingChatsReference = _firestore
          .collection(conversation.senderUser.collection.value)
          .doc(conversation.senderUser.id)
          .collection(Collection.PENDING_CHATS.value)
          .doc(conversation.peerUser.id);
      var senderActiveChatsReference = _firestore
          .collection(conversation.senderUser.collection.value)
          .doc(conversation.senderUser.id)
          .collection(Collection.ACTIVE_CHATS.value)
          .doc(conversation.peerUser.id);
      var requestsReference = _firestore
          .collection(conversation.peerUser.collection.value)
          .doc(conversation.peerUser.id)
          .collection(Collection.REQUESTS_CHATS.value)
          .doc(conversation.senderUser.id);
      var peerActiveChatsReference = _firestore
          .collection(conversation.peerUser.collection.value)
          .doc(conversation.peerUser.id)
          .collection(Collection.ACTIVE_CHATS.value)
          .doc(conversation.senderUser.id);

      WriteBatch batch = FirebaseFirestore.instance.batch();
      // Pending chat of the sender user is moved into active chats
      batch.delete(pendingChatsReference);
      batch.set(senderActiveChatsReference, {"lastMessage": timestamp});
      // Request chat of the peer user is moved into active chats
      batch.delete(requestsReference);
      batch.set(peerActiveChatsReference, {"lastMessage": timestamp});

      batch.commit().then((value) => print("Chats upgraded")).catchError((error) => print("Failed to upgrade the chats: $error"));
    }
  }

  /// Remove the [conversation] between the [peerUser] and the [senderUser]
  void removeChatFromDB(Conversation conversation) {
    var senderUserReference = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(conversation.senderUserChat.chatCollection.value)
        .doc(conversation.peerUser.id);
    var peerUserReference = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(conversation.peerUserChat.chatCollection.value)
        .doc(conversation.senderUser.id);

    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.delete(senderUserReference);
    batch.delete(peerUserReference);
    batch.commit().then((value) => print("Chat removed")).catchError((error) => print("Failed to remove the chat: $error"));
    _incrementConversationCounter(conversation, -1);
  }

  /// It takes the [user] and returns the list of all the [chat] of the
  /// user based on the [chatCollection] field of the [chat] ordered by lastMessage.
  Stream<QuerySnapshot> getChatsFromDB(User user, Chat chat) {
    return _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(chat.chatCollection.value)
        .orderBy("lastMessage", descending: true)
        .limit(_limit)
        .snapshots();
  }

  /// It takes the [user] and returns the hash set of ids of all the [chat]
  /// of the user based on the [chatCollection] field of the Chat.
  Future<HashSet> _getChatIdsSet(User user, Chat chat) async {
    HashSet<String> ids = new HashSet();
    var snap = await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(chat.chatCollection.value)
        .orderBy("lastMessage")
        .limit(_limit)
        .get();
    for (var doc in snap.docs) {
      ids.add(doc.id);
    }
    return ids;
  }

  /// It takes the [conversation] and the [increment] amount and increments the anonymous chat's counter of the users
  /// into the DB within the [transaction]
  void _incrementConversationCounter(Conversation conversation, int increment) {
    var utilsSenderReference = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(Collection.UTILS.value)
        .doc(Collection.UTILS.value);
    var utilsPeerReference = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(Collection.UTILS.value)
        .doc(Collection.UTILS.value);

    _firestore
        .runTransaction((transaction) async {
          var utilsSender = await transaction.get(utilsSenderReference);
          var utilsPeer = await transaction.get(utilsPeerReference);
          int oldCounterSender, oldCounterPeer;
          utilsSender.data() != null ? oldCounterSender = utilsSender.get("anonymousChatCounter") : oldCounterSender = 0;
          utilsPeer.data() != null ? oldCounterPeer = utilsPeer.get("anonymousChatCounter") : oldCounterPeer = 0;
          int newCounterSender = oldCounterSender + increment;
          int newCounterPeer = oldCounterPeer + increment;
          transaction.set(utilsSenderReference, {"anonymousChatCounter": newCounterSender < 0 ? 0 : newCounterSender});
          transaction.set(utilsPeerReference, {"anonymousChatCounter": newCounterPeer < 0 ? 0 : newCounterPeer});
        })
        .then((value) => print("Conversation counters incremented"))
        .catchError((error) => print("Failed to increment the conversation counters: $error"));
  }

  /// It takes the [user] and returns the anonymous chat's counter from the DB
  Future<DocumentSnapshot> _getChatsCounterFromDB(User user) async {
    return _firestore.collection(Collection.BASE_USERS.value).doc(user.id).collection(Collection.UTILS.value).doc(Collection.UTILS.value).get();
  }

  /***************************************** REPORTS *****************************************/

  /// It takes the [id] of an user and the [report] and
  /// adds it into the list of reports of the user into the DB
  Future<void> addReportIntoDB(String id, Report report) async {
    _firestore
        .collection(report.collection.value)
        .doc(id)
        .collection("reportsList")
        .doc(report.id)
        .set(report.data)
        .then((value) => print("Report added"))
        .catchError((error) => print("Failed to add the report: $error"));
  }

  /// It takes the [id] of an user and return the stream of all the
  /// reports of the user oredered in descending by date from the DB
  Stream<QuerySnapshot> getReportsFromDB(String id) {
    return _firestore.collection(Collection.REPORTS.value).doc(id).collection("reportsList").orderBy("id", descending: true).snapshots();
  }

  /**************************************** DIARY ********************************************/

  /// It takes the [id] of an user and the [diaryPage]
  /// and adds it into the list of diaryPages of the user into the DB
  Future<void> addDiaryPageIntoDB(String id, DiaryPage diaryPage) {
    return _firestore
        .collection(diaryPage.collection.value)
        .doc(id)
        .collection("diaryPages")
        .doc(diaryPage.id)
        .set(diaryPage.data)
        .then((value) => print("Diary page added"))
        .catchError((error) => print("Failed to add the diary note: $error"));
  }

  /// It takes the [id] of an user and the new [diaryPage]
  /// and updates the title and content fields into the DB
  Future<void> updateDiaryPageIntoDB(String id, DiaryPage diaryPage) {
    return _firestore
        .collection(diaryPage.collection.value)
        .doc(id)
        .collection("diaryPages")
        .doc(diaryPage.id)
        .update({
          "title": diaryPage.data["title"],
          "content": diaryPage.data["content"],
          "date": diaryPage.data["date"],
        })
        .then((value) => print("Diary page updated"))
        .catchError((error) => print("Failed to update the diary note: $error"));
  }

  /// It takes the [id] of an user and the [diaryPage] and set it as favourite or not
  Future<void> setFavouriteDiaryNotesIntoDB(String id, DiaryPage diaryPage) {
    return _firestore
        .collection(diaryPage.collection.value)
        .doc(id)
        .collection("diaryPages")
        .doc(diaryPage.id)
        .update({
          "favourite": diaryPage.data["favourite"],
        })
        .then((value) => print("Favourite note updated"))
        .catchError((error) => print("Failed to update the favourite note: $error"));
  }

  /// It takes the [id] of an user and return the stream of
  /// all the diaryPages of the user oredered by date from the DB
  Stream<QuerySnapshot> getDiaryPagesStreamFromDB(String id) {
    return _firestore.collection(Collection.DIARY.value).doc(id).collection("diaryPages").orderBy("id", descending: true).snapshots();
  }
}
