import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() async {
  final fakeFirebase = FakeFirebaseFirestore();
  FirestoreService _firestoreService = FirestoreService(fakeFirebase);
  var id = "";
  var name = "Luca";
  var surname = "Colombo";
  var email = "luca.colombo@prova.it";
  var birthDate = DateTime(1997, 10, 19);

  BaseUser baseUser = BaseUser(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
  );

//     var expectedDumpAfterset = '''{
//   "users": {
//     "$id": {
//       "uid": "$id",
//       "name": "$name",
//       "surname": "$surname",
//       "birthDate": "${DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(birthDate)}",
//       "email": "$email"
//     },
//     "utils": {
//       "userCounter": 1
//     }
//   }
// }''';

//     test("Sets data of a base user from the DB collection", () async {
//       await _firestoreService.addUserIntoDB(baseUser);
//       expect(fakeFirebase.dump(), expectedDumpAfterset);
//     });

  test("Set base user from document", () async {
    await _firestoreService.addUserIntoDB(baseUser);
    var result = (await _firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, id));
    var retrievedUser = BaseUser();
    retrievedUser.setFromDocument(result.docs[0]);
    expect(retrievedUser.id, id);
    expect(retrievedUser.name, name);
    expect(retrievedUser.surname, surname);
    expect(retrievedUser.birthDate, birthDate);
    expect(retrievedUser.email, email);
  });

  test("Base user get data", () async {
    expect(baseUser.data, {
      "uid": id,
      "name": name,
      "surname": surname,
      "birthDate": birthDate,
      "email": email,
    });
  });

  test("Base user collection", () async {
    //expect(baseUser.collection, equals(Collection.BASE_USERS));
  });
}
