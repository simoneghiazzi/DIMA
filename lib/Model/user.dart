import 'package:sApport/Model/db_item.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

abstract class User extends DbItem {
  String name;
  String surname;
  DateTime birthDate;
  String email;

  User({String id, this.name, this.surname, this.birthDate, this.email}) : super(id: id);

  /// Set the fields of the User from the [baseUserSignUpForm]
  void setFromSignUpForm(BaseUserSignUpForm baseUserSignUpForm);
}
