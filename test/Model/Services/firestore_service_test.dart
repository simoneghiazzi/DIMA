import 'package:test/test.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

void main() {
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
  group(
    FirestoreService,
    () {
      test(
        '',
        () async {},
      );
    },
  );
}
