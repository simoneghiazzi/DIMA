import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:test/test.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';

import 'chat_view_model_test.mocks.dart';

@GenerateMocks([FirestoreService, UserService])
void main() async {
  final mockFirestoreService = MockFirestoreService();
  final mockUserService = MockUserService();

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => BaseUser(
        id: Utils.randomId(),
        name: "Luca",
        surname: "Colombo",
        email: "luca.colombo@prova.it",
        birthDate: DateTime(1997, 10, 19),
      ));

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(mockFirestoreService);
  getIt.registerSingleton<UserService>(mockUserService);

  final chatViewModel = ChatViewModel();

  group("ChatViewModel initialization", () {
    test("Update the chatting with field of the logged user", () async {
      await chatViewModel.updateChattingWith();
      verify(mockFirestoreService.updateUserFieldIntoDB(any, any, any)).called(1);
    });
  });
}
