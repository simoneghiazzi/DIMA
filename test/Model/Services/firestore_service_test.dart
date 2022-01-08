import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:get_it/get_it.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
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

  DiaryPage diaryPage = DiaryPage(
    id: Utils.randomId(),
    title: "Diary page title",
    content: "Diary page content",
    dateTime: DateTime(2021, 10, 19),
    favourite: true,
  );

  DiaryPage diaryPage2 = DiaryPage(
    id: Utils.randomId(),
    title: "Diary page second title",
    content: "Diary page second content",
    dateTime: DateTime(2021, 3, 19),
    favourite: true,
  );

  group("Firestore user methods:", () {
    group("Add a new base user:", () {
      setUp(() async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
      });
      test("Check that the DB contains the document with the base user information", () async {
        await firestoreService.addUserIntoDB(baseUser);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).get();
        var data = res.data();

        expect(data!["uid"], baseUser.id);
        expect(data["name"], baseUser.name);
        expect(data["surname"], baseUser.surname);
        expect(data["email"], baseUser.email);
        expect(data["birthDate"].toDate(), baseUser.birthDate);
      });

      test("Check that the base user counter is incremented", () async {
        await firestoreService.addUserIntoDB(baseUser);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        var data = res.data();

        expect(data!["userCounter"], 1);

        /// Try to add another user
        await firestoreService.addUserIntoDB(baseUser2);

        /// Get the data from the fakeFirebase
        res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        data = res.data();

        expect(data!["userCounter"], 2);
      });
    });

    group("Add a new expert:", () {
      setUp(() async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
      });

      test("Check that the DB contains the document with the expert information", () async {
        await firestoreService.addUserIntoDB(expert);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Expert.COLLECTION).doc(expert.id).get();
        var data = res.data();

        expect(data!["eid"], expert.id);
        expect(data["name"], expert.name);
        expect(data["surname"], expert.surname);
        expect(data["email"], expert.email);
        expect(data["birthDate"].toDate(), expert.birthDate);
        expect(data["address"], expert.address);
        expect(data["lat"], expert.latitude);
        expect(data["lng"], expert.longitude);
        expect(data["phoneNumber"], expert.phoneNumber);
        expect(data["profilePhoto"], expert.profilePhoto);
      });

      test("Check that the base user counter is not incremented when inserting an expert", () async {
        await firestoreService.addUserIntoDB(expert);

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
      setUp(() async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
      });

      test("Check that the DB does not contain the document anymore after removing the user", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.removeUserFromDB(baseUser);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).get();

        expect(res.exists, false);
      });

      test("Check that the base user counter is decremented when removing a base user", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.removeUserFromDB(baseUser);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        var data = res.data();

        expect(data!["userCounter"], 0);
      });
    });

    group("Remove an expert:", () {
      test("Check that the DB does not contain the document anymore after removing the expert", () async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);

        await firestoreService.addUserIntoDB(expert);
        await firestoreService.removeUserFromDB(expert);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Expert.COLLECTION).doc(expert.id).get();

        expect(res.exists, false);
      });
    });

    group("Update user field:", () {
      test("Check that the DB contains the document with the updated fields", () async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
        var updatedName = "UpdatedName";
        var newField = "newField";

        await firestoreService.addUserIntoDB(baseUser);
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
      setUp(() async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
      });

      test("Check that getExpertCollection returns the query snapshot of the searched collection", () async {
        await firestoreService.addUserIntoDB(expert);
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
        var snapshot = await firestoreService.getExpertCollectionFromDB();

        expect(snapshot.docs.length, 2);
      });
    });

    group("Get user by ID:", () {
      setUp(() async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
      });

      test("Check that getUserById returns the correct document of the base user", () async {
        await firestoreService.addUserIntoDB(baseUser);
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
      setUp(() async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
      });

      test("Check that getRandomUser returns the document of a new user", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(baseUser2);

        var snapshot = await firestoreService.getRandomUserFromDB(baseUser, Utils.randomId());

        expect(snapshot!.exists, true);
        expect(snapshot.id, baseUser2.id);
      });

      test("Check that getRandomUser returns null if the number of anonymous chats of the user is not grater than the user counter + 1", () async {
        /// Only one user into the DB
        await firestoreService.addUserIntoDB(baseUser);
        var snapshot = await firestoreService.getRandomUserFromDB(baseUser, Utils.randomId());

        expect(snapshot, null);

        /// Two users but that already have a chat between them
        AnonymousChat anonymousChat = AnonymousChat(
          lastMessage: "Message content",
          lastMessageDateTime: DateTime(2021, 10, 19, 21, 10, 50),
          notReadMessages: 1,
          peerUser: baseUser2,
        );

        Message message = Message(
          idFrom: baseUser.id,
          idTo: baseUser2.id,
          timestamp: DateTime(2021, 10, 19, 21, 10, 50),
          content: "Message content",
        );

        await firestoreService.addUserIntoDB(baseUser2);
        await firestoreService.addMessageIntoDB(baseUser, anonymousChat, message);

        snapshot = await firestoreService.getRandomUserFromDB(baseUser, Utils.randomId());

        expect(snapshot, null);
      });
    });

    group("Find user type:", () {
      setUp(() async {
        /// Fake Firebase
        fakeFirebase = FakeFirebaseFirestore();
        firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
      });

      test("Check that findUserType returns the correct instance of the user", () async {
        await firestoreService.addUserIntoDB(baseUser);
        await firestoreService.addUserIntoDB(expert);

        var resultBaseUser = await firestoreService.findUserType(baseUser.id);
        var resultExpert = await firestoreService.findUserType(expert.id);

        expect(resultBaseUser, isA<BaseUser>());
        expect(resultExpert, isA<Expert>());
      });

      test("Check that findUserType returns null user is not present into the DB", () async {
        var resultBaseUser = await firestoreService.findUserType(baseUser.id);
        var resultExpert = await firestoreService.findUserType(expert.id);

        expect(resultBaseUser, null);
        expect(resultExpert, null);
      });
    });
  });

  group("Firestore message methods:", () {});
}
