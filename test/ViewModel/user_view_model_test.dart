import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Views/Signup/BaseUser/components/form/base_user_signup_form.dart';
import '../service.mocks.dart';

void main() async {
  /// Mock Services
  final mockUserService = MockUserService();

  var loggedUser = BaseUser(
    id: Utils.randomId(),
    name: "Luca",
    surname: "Colombo",
    email: "luca.colombo@prova.it",
    birthDate: DateTime(1997, 10, 19),
  );

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => loggedUser);

  var getIt = GetIt.I;
  getIt.registerSingleton<UserService>(mockUserService);

  final userViewModel = UserViewModel();

  group("UserViewModel interaction with services:", () {
    group("Load logged user:", () {
      test("Check that load logged user calls the load logged user method of the user service", () {
        userViewModel.loadLoggedUser();

        verify(mockUserService.loadLoggedUser()).called(1);
      });
    });

    group("Create user:", () {
      test("Create user should call the create user from sign up form method of the user service", () {
        var baseUserSignUpForm = BaseUserSignUpForm();
        userViewModel.createUser(baseUserSignUpForm);

        verify(mockUserService.createUserFromSignUpForm(baseUserSignUpForm)).called(1);
      });
    });
  });
}
