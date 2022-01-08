import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import '../../service.mocks.dart';

void main() async {
  /// Fake Firebase
  var fakeFirebase = FakeFirebaseFirestore();
  var fakeFirebaseStorage = MockFirebaseStorage();

  var firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(fakeFirebase));
  getIt.registerSingleton<UserService>(MockUserService());

  /// Test DB Items
  var baseUser = BaseUser(
    id: Utils.randomId(),
    name: "Luca",
    surname: "Colombo",
    email: "luca.colombo@prova.it",
    birthDate: DateTime(1997, 10, 19),
  );

  var baseUser2 = BaseUser(
    id: Utils.randomId(),
    name: "Simone",
    surname: "Ghiazzi",
    email: "simone.ghiazzi@prova.it",
    birthDate: DateTime(1997, 02, 26),
  );

  var baseUser3 = BaseUser(
    id: Utils.randomId(),
    name: "Pippo",
    surname: "Pluto",
    email: "pippo.pluto@prova.it",
    birthDate: DateTime(1980, 12, 5),
  );

  var baseUser4 = BaseUser(
    id: Utils.randomId(),
    name: "Sofia",
    surname: "Verdi",
    email: "sofia.verdi@prova.it",
    birthDate: DateTime(1985, 5, 15),
  );

  var expert = Expert(
    id: Utils.randomId(),
    name: "Mattia",
    surname: "Rossi",
    email: "mattia.rossi@prova.it",
    birthDate: DateTime(1995, 5, 12),
    address: "Piazza Leonardo da Vinci, Milano, Italia",
    latitude: 45.478195,
    longitude: 9.2256787,
    phoneNumber: "331331331",
    profilePhoto: "image.png",
  );

  var expert2 = Expert(
    id: Utils.randomId(),
    name: "Sara",
    surname: "Bianchi",
    email: "sara.bianchi@prova.it",
    birthDate: DateTime(1997, 8, 1),
    address: "Piazza Leonardo da Vinci, Milano, Italia",
    latitude: 45.478195,
    longitude: 9.2256787,
    phoneNumber: "331331331",
    profilePhoto: "image.png",
  );

  var anonymousChat = AnonymousChat(
    lastMessage: "Message content to the user",
    lastMessageDateTime: DateTime(2021, 10, 19, 21, 10, 50),
    peerUser: baseUser2,
  );

  var anonymousChat2 = AnonymousChat(
    lastMessage: "Message content to the user 2",
    lastMessageDateTime: DateTime(2022, 1, 8, 13, 10, 50),
    peerUser: baseUser3,
  );

  var anonymousChat3 = AnonymousChat(
    lastMessage: "Message content to the user 3",
    lastMessageDateTime: DateTime(2022, 1, 8, 13, 11, 20),
    peerUser: baseUser4,
  );

  var expertChat = ExpertChat(
    lastMessage: "Message content to the expert",
    lastMessageDateTime: DateTime(2021, 10, 19, 21, 10, 50),
    peerUser: expert,
  );

  var request = Request(
    lastMessage: "Message content of a new request by baseUser",
    lastMessageDateTime: DateTime(2021, 10, 19, 21, 10, 50),
    peerUser: baseUser2,
  );

  var pendingChat = PendingChat(
    lastMessage: "Message content of a new request by baseUser",
    lastMessageDateTime: DateTime(2021, 10, 19, 21, 10, 50),
    peerUser: baseUser,
  );

  var message = Message(
    idFrom: baseUser.id,
    idTo: baseUser2.id,
    timestamp: DateTime(2021, 10, 19, 21, 10, 50),
    content: "Message content",
  );

  var message2 = Message(
    idFrom: baseUser.id,
    idTo: baseUser2.id,
    timestamp: DateTime(2021, 12, 19, 12, 42, 22),
    content: "Message content 2",
  );

  var message3 = Message(
    idFrom: baseUser.id,
    idTo: baseUser2.id,
    timestamp: DateTime(2021, 12, 19, 13, 00, 25),
    content: "Message content 3",
  );

  var report = Report(
    id: DateTime(2021, 8, 5, 13, 00, 25).millisecondsSinceEpoch.toString(),
    category: "Report category",
    description: "Report description",
    dateTime: DateTime(2021, 8, 5, 13, 00, 25),
  );

  var report2 = Report(
    id: DateTime(2021, 10, 5, 13, 00, 25).millisecondsSinceEpoch.toString(),
    category: "Report category 2",
    description: "Report description 2",
    dateTime: DateTime(2021, 10, 5, 13, 00, 25),
  );

  var report3 = Report(
    id: DateTime(2022, 1, 5, 13, 00, 25).millisecondsSinceEpoch.toString(),
    category: "Report category 3",
    description: "Report description 3",
    dateTime: DateTime(2022, 1, 5, 13, 00, 25),
  );

  var diaryPage = DiaryPage(
    id: DateTime(2021, 3, 19).millisecondsSinceEpoch.toString(),
    title: "Diary page title",
    content: "Diary page content",
    dateTime: DateTime(2021, 3, 19),
  );

  var diaryPage2 = DiaryPage(
    id: DateTime(2021, 3, 30).millisecondsSinceEpoch.toString(),
    title: "Diary page second title",
    content: "Diary page second content",
    dateTime: DateTime(2021, 3, 30),
  );

  var diaryPage3 = DiaryPage(
    id: DateTime(2022, 1, 5).millisecondsSinceEpoch.toString(),
    title: "Diary page third title",
    content: "Diary page third content",
    dateTime: DateTime(2022, 1, 5),
  );

  /***************************************** USERS *****************************************/

  group("Firestore user methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Add a new base user:", () {
      test("Check that the DB contains the document with the base user information", () async {
        await firestoreService.addUserIntoDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).get();
        BaseUser retrievedUser = BaseUser.fromDocument(res);

        expect(retrievedUser.id, baseUser.id);
        expect(retrievedUser.name, baseUser.name);
        expect(retrievedUser.surname, baseUser.surname);
        expect(retrievedUser.email, baseUser.email);
        expect(retrievedUser.birthDate, baseUser.birthDate);
      });

      test("Check that the base user counter is incremented", () async {
        await firestoreService.addUserIntoDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        var data = res.data();

        expect(data!["userCounter"], 1);

        /// Try to add another user
        await firestoreService.addUserIntoDB(baseUser2);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        data = res.data();

        expect(data!["userCounter"], 2);
      });
    });

    group("Add a new expert:", () {
      test("Check that the DB contains the document with the expert information", () async {
        await firestoreService.addUserIntoDB(expert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Expert.COLLECTION).doc(expert.id).get();
        Expert rerievedExpert = Expert.fromDocument(res);

        expect(rerievedExpert.id, expert.id);
        expect(rerievedExpert.name, expert.name);
        expect(rerievedExpert.surname, expert.surname);
        expect(rerievedExpert.email, expert.email);
        expect(rerievedExpert.birthDate, expert.birthDate);
        expect(rerievedExpert.address, expert.address);
        expect(rerievedExpert.latitude, expert.latitude);
        expect(rerievedExpert.longitude, expert.longitude);
        expect(rerievedExpert.phoneNumber, expert.phoneNumber);
        expect(rerievedExpert.profilePhoto, expert.profilePhoto);
      });

      test("Check that the base user counter is not incremented when inserting an expert", () async {
        await firestoreService.addUserIntoDB(expert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();

        expect(res.exists, false);
      });

      test("Add a new expert should upload the profile photo into the firesbase storage", () async {
        await firestoreService.addUserIntoDB(expert);

        expect(fakeFirebaseStorage.storedFilesMap["/${expert.id}/profilePhoto"]!.path, expert.profilePhoto);
      });
    });

    group("Remove a base user:", () {
      test("Check that the DB does not contain the document anymore after removing the user", () async {
        await firestoreService.addUserIntoDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.removeUserFromDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).get();

        expect(res.exists, false);
      });

      test("Check that the base user counter is decremented when removing a base user", () async {
        await firestoreService.addUserIntoDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.removeUserFromDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        var data = res.data();

        expect(data!["userCounter"], 0);
      });
    });

    group("Remove an expert:", () {
      test("Check that the DB does not contain the document anymore after removing the expert", () async {
        await firestoreService.addUserIntoDB(expert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.removeUserFromDB(expert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Expert.COLLECTION).doc(expert.id).get();

        expect(res.exists, false);
      });
    });

    group("Update user field:", () {
      test("Check that the DB contains the document with the updated fields", () async {
        var updatedName = "UpdatedName";
        var newField = "newField";

        await firestoreService.addUserIntoDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.updateUserFieldIntoDB(baseUser, "name", updatedName);
        await firestoreService.updateUserFieldIntoDB(baseUser, "newField", newField);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).get();
        var data = res.data()!;

        expect(data["name"], updatedName);
        expect(data["newField"], newField);
      });
    });

    group("Get expert collection:", () {
      test("Check that getExpertCollection returns the query snapshot of the searched collection", () async {
        await firestoreService.addUserIntoDB(expert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var snapshot = await firestoreService.getExpertCollectionFromDB();

        /// Create the BaseUser instance
        Expert retrievedExpert;
        if (snapshot.docs.first.id != "utils") {
          retrievedExpert = Expert.fromDocument(snapshot.docs.first);
        } else {
          retrievedExpert = Expert.fromDocument(snapshot.docs.last);
        }

        expect(retrievedExpert.id, expert.id);
        expect(retrievedExpert.name, expert.name);
        expect(retrievedExpert.surname, expert.surname);
        expect(retrievedExpert.email, expert.email);
        expect(retrievedExpert.birthDate, expert.birthDate);
        expect(retrievedExpert.address, expert.address);
        expect(retrievedExpert.latitude, expert.latitude);
        expect(retrievedExpert.longitude, expert.longitude);
        expect(retrievedExpert.phoneNumber, expert.phoneNumber);
        expect(retrievedExpert.profilePhoto, expert.profilePhoto);
      });

      test("Check that getBaseCollection returns the correct number of documents of the searched collection", () async {
        await firestoreService.addUserIntoDB(expert);
        await firestoreService.addUserIntoDB(expert2);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var snapshot = await firestoreService.getExpertCollectionFromDB();

        expect(snapshot.docs.length, 2);
      });
    });

    group("Get user by ID:", () {
      test("Check that getUserById returns the correct document of the base user", () async {
        await firestoreService.addUserIntoDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var snapshot = await firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, baseUser.id);
        BaseUser retrievedUser = BaseUser.fromDocument(snapshot.docs[0]);

        expect(retrievedUser.id, baseUser.id);
        expect(retrievedUser.name, baseUser.name);
        expect(retrievedUser.surname, baseUser.surname);
        expect(retrievedUser.email, baseUser.email);
        expect(retrievedUser.birthDate, baseUser.birthDate);
      });

      test("Check that if the id of the user doesn not exit into the DB it returns an empty snapshot", () async {
        var snapshot = await firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, baseUser.id);

        expect(snapshot.docs.isEmpty, true);
      });
    });

    group("Get random user:", () {
      test("Check that getRandomUser returns the document of a new user", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var snapshot = await firestoreService.getRandomUserFromDB(baseUser, Utils.randomId());

        expect(snapshot!.exists, true);
        expect(snapshot.id, baseUser2.id);
      });

      test("Check that getRandomUser returns null if the number of anonymous chats of the user is not grater than the user counter + 1", () async {
        /// Only one user into the DB
        await firestoreService.addUserIntoDB(baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var snapshot = await firestoreService.getRandomUserFromDB(baseUser, Utils.randomId());

        expect(snapshot, null);

        /// Two users but that already have a chat between them
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);

        snapshot = await firestoreService.getRandomUserFromDB(baseUser, Utils.randomId());

        expect(snapshot, null);
      });
    });

    group("Find user type:", () {
      test("Check that findUserType returns the correct instance of the user", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(expert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var resultBaseUser = await firestoreService.findUserType(baseUser.id);
        var resultExpert = await firestoreService.findUserType(expert.id);

        expect(resultBaseUser, isA<BaseUser>());
        expect(resultExpert, isA<Expert>());
      });

      test("Check that findUserType returns null if the user is not present into the DB", () async {
        var resultBaseUser = await firestoreService.findUserType(baseUser.id);
        var resultExpert = await firestoreService.findUserType(expert.id);

        expect(resultBaseUser, null);
        expect(resultExpert, null);
      });
    });
  });

  /***************************************** MESSAGES *****************************************/

  group("Firestore message methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Add message:", () {
      test("Check that the DB contains the document with the message information", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var pairChatId = Utils.pairChatId(baseUser.id, baseUser2.id);
        var res = await fakeFirebase.collection(Message.COLLECTION).doc(pairChatId).collection(pairChatId).get();

        Message retrievedMessage = Message.fromDocument(res.docs.first);

        expect(retrievedMessage.id, message.timestamp.millisecondsSinceEpoch.toString());
        expect(retrievedMessage.idFrom, message.idFrom);
        expect(retrievedMessage.idTo, message.idTo);
        expect(retrievedMessage.timestamp, message.timestamp);
        expect(retrievedMessage.content, message.content);
      });

      test("Check that addMessage with anonymousChat updates the chat info of both the users in the correct collection", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resAnonymousChatUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection(AnonymousChat.COLLECTION).get();
        var resAnonymousChatUser2 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection(AnonymousChat.COLLECTION).get();
        var retrievedChatUser = AnonymousChat.fromDocument(resAnonymousChatUser.docs.first);
        var retrievedChatUser2 = AnonymousChat.fromDocument(resAnonymousChatUser2.docs.first);

        /// The id of the document in the collection of base user should be the id of base user 2
        expect(resAnonymousChatUser.docs.first.id, baseUser2.id);
        expect(retrievedChatUser.lastMessage, anonymousChat.lastMessage);
        expect(retrievedChatUser.lastMessageDateTime, anonymousChat.lastMessageDateTime);

        /// The notReadMessages of the sender user should be setted to 0
        expect(retrievedChatUser.notReadMessages, 0);

        /// The id of the document in the collection of base user 2 should be the id of base user
        expect(resAnonymousChatUser2.docs.first.id, baseUser.id);
        expect(retrievedChatUser2.lastMessage, anonymousChat.lastMessage);
        expect(retrievedChatUser2.lastMessageDateTime, anonymousChat.lastMessageDateTime);
        expect(retrievedChatUser2.notReadMessages, 1);
      });

      test("Check that addMessage with request updates the chat info of both the users in the correct collection", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addMessageIntoDB(baseUser, request, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resRequest = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection(Request.COLLECTION).get();
        var resPendingChat = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection(PendingChat.COLLECTION).get();
        var retrievedRequest = Request.fromDocument(resRequest.docs.first);
        var retrievedPendingChat = PendingChat.fromDocument(resPendingChat.docs.first);

        /// The id of the document in the collection of base user should be the id of base user 2
        expect(resRequest.docs.first.id, baseUser2.id);
        expect(retrievedRequest.lastMessage, request.lastMessage);
        expect(retrievedRequest.lastMessageDateTime, request.lastMessageDateTime);

        /// The notReadMessages of the sender user should be setted to 0
        expect(retrievedRequest.notReadMessages, 0);

        /// The id of the document in the collection of base user 2 should be the id of base user
        expect(resPendingChat.docs.first.id, baseUser.id);
        expect(retrievedPendingChat.lastMessage, request.lastMessage);
        expect(retrievedPendingChat.lastMessageDateTime, request.lastMessageDateTime);
        expect(retrievedPendingChat.notReadMessages, 1);
      });

      test("Check that addMessage with expertChat updates the chat info of both the users in the correct collection", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(expert);

        Message messageToExpert = Message(
          idFrom: baseUser.id,
          idTo: expert.id,
          timestamp: DateTime(2021, 10, 19, 21, 10, 50),
          content: "Message content",
        );

        await firestoreService.addMessageIntoDB(baseUser, expertChat, messageToExpert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resExpertChat = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection(ExpertChat.COLLECTION).get();
        var resActiveChat = await fakeFirebase.collection(Expert.COLLECTION).doc(expert.id).collection(ActiveChat.COLLECTION).get();
        var retrievedExpertChat = ExpertChat.fromDocument(resExpertChat.docs.first);
        var retrievedActiveChat = ActiveChat.fromDocument(resActiveChat.docs.first);

        /// The id of the document in the collection of base user should be the id of base user 2
        expect(resExpertChat.docs.first.id, expert.id);
        expect(retrievedExpertChat.lastMessage, expertChat.lastMessage);
        expect(retrievedExpertChat.lastMessageDateTime, expertChat.lastMessageDateTime);

        /// The notReadMessages of the sender user should be setted to 0
        expect(retrievedExpertChat.notReadMessages, 0);

        /// The id of the document in the collection of base user 2 should be the id of base user
        expect(resActiveChat.docs.first.id, baseUser.id);
        expect(retrievedActiveChat.lastMessage, expertChat.lastMessage);
        expect(retrievedActiveChat.lastMessageDateTime, expertChat.lastMessageDateTime);
        expect(retrievedActiveChat.notReadMessages, 1);
      });

      test("Add message should increment the anonymousChatCounter if the chat of the sender user is a Request and it is the first message", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addMessageIntoDB(baseUser, request, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection("utils").doc("utils").get();
        var resUtilsUser2 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection("utils").doc("utils").get();
        var dataUser = resUtilsUser.data()!;
        var dataUser2 = resUtilsUser2.data()!;

        expect(dataUser["anonymousChatCounter"], 1);
        expect(dataUser2["anonymousChatCounter"], 1);

        /// Try to add another message
        await firestoreService.addMessageIntoDB(baseUser, request, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection("utils").doc("utils").get();
        resUtilsUser2 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection("utils").doc("utils").get();
        dataUser = resUtilsUser.data()!;
        dataUser2 = resUtilsUser2.data()!;

        /// Add another message should not incremente the counter
        expect(dataUser["anonymousChatCounter"], 1);
        expect(dataUser2["anonymousChatCounter"], 1);
      });

      test("Add message should not increment the anonymousChatCounter if the chat of the sender user is not a Request", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addUserIntoDB(expert);

        /// Initially set the counter to 1
        await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection("utils").doc("utils").set({"anonymousChatCounter": 1});
        await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection("utils").doc("utils").set({"anonymousChatCounter": 1});

        /// Send a message to another anonymous user
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection("utils").doc("utils").get();
        var resUtilsUser2 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection("utils").doc("utils").get();
        var dataUser = resUtilsUser.data()!;
        var dataUser2 = resUtilsUser2.data()!;

        expect(dataUser["anonymousChatCounter"], 1);
        expect(dataUser2["anonymousChatCounter"], 1);

        /// Send a message to an expert
        await firestoreService.addMessageIntoDB(baseUser, expertChat, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection("utils").doc("utils").get();
        dataUser = resUtilsUser.data()!;

        expect(dataUser["anonymousChatCounter"], 1);
      });
    });

    group("Get messages stream:", () {
      test("Check that getMessagesStreamFromDB returns the correct stream of messages in descending order", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        var messages = [message, message2, message3];

        /// Send some messages to another anonymous user
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message2);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message3);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var stream = firestoreService.getMessagesStreamFromDB(Utils.pairChatId(baseUser.id, baseUser2.id));
        expect(stream, emits(isA<QuerySnapshot>()));

        var res = await stream.first;

        for (int i = 0; i < messages.length; i++) {
          Message m = Message.fromDocument(res.docs[i]);
          expect(m.timestamp, messages[messages.length - 1 - i].timestamp);
        }
      });
    });

    group("Remove messages:", () {
      test("Check that removeMessagesFromDB deletes all the messages between 2 users", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);

        /// Send some messages to another anonymous user
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message2);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message3);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var pairChatId = Utils.pairChatId(baseUser.id, baseUser2.id);
        await firestoreService.removeMessagesFromDB(pairChatId);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Message.COLLECTION).doc(pairChatId).collection(pairChatId).get();
        expect(res.docs, isEmpty);
      });
    });

    group("Set messages has read:", () {
      test("Check that setMessagesHasRead sets the notReadMessages of the chat with a peer user to 0", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection(AnonymousChat.COLLECTION).get();

        /// The notReadMessages of the peer user initially is 1
        expect(res.docs.first.data()["notReadMessages"], 1);

        AnonymousChat anonymousChatPeerUser = anonymousChat;

        anonymousChatPeerUser.peerUser = baseUser;
        await firestoreService.setMessagesHasRead(baseUser2, anonymousChatPeerUser);

        /// Get the data from the fakeFirebase
        res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection(AnonymousChat.COLLECTION).get();

        expect(res.docs.first.data()["notReadMessages"], 0);
      });
    });
  });

  /***************************************** CHATS *****************************************/

  group("Firestore chat methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Upgrade pending to active chat:", () {
      test("Check that upgradePendingToActiveChatIntoDB remove the chat from the request and the pending list and add them to the anonymous lists",
          () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addMessageIntoDB(baseUser, request, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.upgradePendingToActiveChatIntoDB(baseUser2, pendingChat);

        /// Get the data from the fakeFirebase
        var resRequest = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection(Request.COLLECTION).get();
        var resPending = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection(PendingChat.COLLECTION).get();

        expect(resRequest.docs, isEmpty);
        expect(resPending.docs, isEmpty);

        /// Get the data from the fakeFirebase
        var resAnonymousChatUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection(AnonymousChat.COLLECTION).get();
        var resAnonymousChatUser2 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection(AnonymousChat.COLLECTION).get();
        var retrievedChatUser = AnonymousChat.fromDocument(resAnonymousChatUser.docs.first);
        var retrievedChatUser2 = AnonymousChat.fromDocument(resAnonymousChatUser2.docs.first);

        /// The id of the document in the collection of base user should be the id of base user 2
        expect(resAnonymousChatUser.docs.first.id, baseUser2.id);
        expect(retrievedChatUser.lastMessage, request.lastMessage);
        expect(retrievedChatUser.lastMessageDateTime, request.lastMessageDateTime);
        expect(retrievedChatUser.notReadMessages, 0);

        /// The id of the document in the collection of base user 2 should be the id of base user
        expect(resAnonymousChatUser2.docs.first.id, baseUser.id);
        expect(retrievedChatUser2.lastMessage, request.lastMessage);
        expect(retrievedChatUser2.lastMessageDateTime, request.lastMessageDateTime);
        expect(retrievedChatUser2.notReadMessages, 0);
      });

      test("Check that upgradePendingToActiveChatIntoDB does not increment the anonymousChatCounter", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);

        await firestoreService.addMessageIntoDB(baseUser, request, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.upgradePendingToActiveChatIntoDB(baseUser2, pendingChat);

        /// Get the data from the fakeFirebase
        var resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection("utils").doc("utils").get();
        var resUtilsUser2 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection("utils").doc("utils").get();
        var dataUser = resUtilsUser.data()!;
        var dataUser2 = resUtilsUser2.data()!;

        expect(dataUser["anonymousChatCounter"], 1);
        expect(dataUser2["anonymousChatCounter"], 1);
      });
    });

    group("Remove chat:", () {
      test("Check that removeChatFromDB deletes the chat for both the users", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);

        await firestoreService.addMessageIntoDB(baseUser, request, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.removeChatFromDB(baseUser2, pendingChat);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resRequest = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection(Request.COLLECTION).get();
        var resPendingChat = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection(PendingChat.COLLECTION).get();

        expect(resRequest.docs, isEmpty);
        expect(resPendingChat.docs, isEmpty);
      });

      test("Check that removeChatFromDB decrements the anonymousChatCounter for both the users", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);

        await firestoreService.addMessageIntoDB(baseUser, request, message);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.removeChatFromDB(baseUser2, pendingChat);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).collection("utils").doc("utils").get();
        var resUtilsUser2 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).collection("utils").doc("utils").get();
        var dataUser = resUtilsUser.data()!;
        var dataUser2 = resUtilsUser2.data()!;

        expect(dataUser["anonymousChatCounter"], 0);
        expect(dataUser2["anonymousChatCounter"], 0);
      });
    });

    group("Get chats stream:", () {
      test("Check that getChatsStreamFromDB returns the correct stream of chats ordered by lastMessageDateTime", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addUserIntoDB(baseUser3);
        var chats = [anonymousChat, anonymousChat2, anonymousChat3];

        /// Add the chats into the fakeFirebase
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat2, message2);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat3, message3);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var stream = firestoreService.getChatsStreamFromDB(baseUser, AnonymousChat.COLLECTION);
        expect(stream, emits(isA<QuerySnapshot>()));

        var res = await stream.first;

        for (int i = 0; i < chats.length; i++) {
          AnonymousChat c = AnonymousChat.fromDocument(res.docs[i]);
          expect(c.peerUser!.id, chats[i].peerUser!.id);
        }
      });
    });
  });

  /***************************************** REPORTS *****************************************/

  group("Firestore report methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Add new report:", () {
      test("Check that the DB contains the document with the report information", () async {
        await firestoreService.addReportIntoDB(baseUser.id, report);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Report.COLLECTION).doc(baseUser.id).collection("reportList").doc(report.id).get();
        Report retrievedReport = Report.fromDocument(res);

        expect(res.id, report.id);
        expect(retrievedReport.category, report.category);
        expect(retrievedReport.description, report.description);
        expect(retrievedReport.dateTime, report.dateTime);
      });
    });

    group("Get reports:", () {
      test("Check that getReportsFromDB returns the correct future of reports ordered by documentId", () async {
        var reports = [report, report2, report3];

        /// Add the reports into the fakeFirebase
        await firestoreService.addReportIntoDB(baseUser.id, report);
        await firestoreService.addReportIntoDB(baseUser.id, report2);
        await firestoreService.addReportIntoDB(baseUser.id, report3);

        var res = await firestoreService.getReportsFromDB(baseUser.id);
        expect(res, isA<QuerySnapshot>());

        for (int i = 0; i < reports.length; i++) {
          Report r = Report.fromDocument(res.docs[i]);
          expect(r.id, reports[i].id);
        }
      });
    });
  });

  /***************************************** DIARY *****************************************/

  group("Firestore diary methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Add new diary page:", () {
      test("Check that the DB contains the document with the diary page information", () async {
        await firestoreService.addDiaryPageIntoDB(baseUser.id, diaryPage);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(DiaryPage.COLLECTION).doc(baseUser.id).collection("diaryPages").doc(diaryPage.id).get();
        DiaryPage retrieveDiaryPage = DiaryPage.fromDocument(res);

        expect(res.id, diaryPage.id);
        expect(retrieveDiaryPage.title, diaryPage.title);
        expect(retrieveDiaryPage.content, diaryPage.content);
        expect(retrieveDiaryPage.dateTime, diaryPage.dateTime);
        expect(retrieveDiaryPage.favourite, diaryPage.favourite);
      });
    });

    group("Update diary page:", () {
      test("Check that the DB contains the document with the updated information of the diary page", () async {
        await firestoreService.addDiaryPageIntoDB(baseUser.id, diaryPage);

        diaryPage.title = "Title updated";
        diaryPage.content = "Content updated";
        diaryPage.dateTime = DateTime(2022, 1, 8);

        await firestoreService.updateDiaryPageIntoDB(baseUser.id, diaryPage);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(DiaryPage.COLLECTION).doc(baseUser.id).collection("diaryPages").doc(diaryPage.id).get();
        DiaryPage retrieveDiaryPage = DiaryPage.fromDocument(res);

        expect(res.id, diaryPage.id);
        expect(retrieveDiaryPage.title, diaryPage.title);
        expect(retrieveDiaryPage.content, diaryPage.content);
        expect(retrieveDiaryPage.dateTime, diaryPage.dateTime);
        expect(retrieveDiaryPage.favourite, diaryPage.favourite);
      });
    });

    group("Set diary page as favourite:", () {
      test("Check that the DB contains the document with the updated information of the diary page", () async {
        await firestoreService.addDiaryPageIntoDB(baseUser.id, diaryPage);

        diaryPage.favourite = !diaryPage.favourite;

        await firestoreService.setDiaryPageAsFavouriteIntoDB(baseUser.id, diaryPage);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(DiaryPage.COLLECTION).doc(baseUser.id).collection("diaryPages").doc(diaryPage.id).get();
        DiaryPage retrieveDiaryPage = DiaryPage.fromDocument(res);

        expect(res.id, diaryPage.id);
        expect(retrieveDiaryPage.favourite, diaryPage.favourite);
      });
    });

    group("Get diary pages:", () {
      test("Check that getDiaryPagesStreamFromDB returns the correct stream of diaryPages ordered by documentId", () async {
        var diaryPages = [diaryPage, diaryPage2, diaryPage3];

        /// Add the diary pages into the fakeFirebase
        await firestoreService.addDiaryPageIntoDB(baseUser.id, diaryPage);
        await firestoreService.addDiaryPageIntoDB(baseUser.id, diaryPage2);
        await firestoreService.addDiaryPageIntoDB(baseUser.id, diaryPage3);

        var stream = firestoreService.getDiaryPagesStreamFromDB(baseUser.id);
        expect(stream, emits(isA<QuerySnapshot>()));

        var res = await stream.first;

        for (int i = 0; i < diaryPages.length; i++) {
          DiaryPage d = DiaryPage.fromDocument(res.docs[i]);
          expect(d.id, diaryPages[i].id);
        }
      });
    });
  });
}
