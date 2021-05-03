import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:email_validator/email_validator.dart';

abstract class AuthFormInterface{
  Sink get emailText;
  Sink get passwordText;
  Stream<bool> get emailController;
  Stream<bool> get passwordController;
  Stream<bool> get isButtonEnabled;
  Stream<String> get errorEmailText;
  Stream<String> get errorPasswordText;

  void dispose();
}

class LoginForm  implements AuthFormInterface{
  var _emailStream = StreamController<String>.broadcast();
  var _passwordStream = StreamController<String>.broadcast();

  @override
  Sink get emailText => _emailStream;

  @override
  Sink get passwordText => _passwordStream;

  @override
  Stream<bool> get emailController => _emailStream.stream.map((email) => EmailValidator.validate(email));

  @override
  Stream<bool> get passwordController => _passwordStream.stream.map((password) => password.isNotEmpty);

  @override
  Stream<bool> get isButtonEnabled => Rx.combineLatest2(emailController, passwordController, (a, b) => a && b);

  @override
  Stream<String> get errorEmailText => emailController.map((isCorrect) => isCorrect ? false : "Invalid email");

  @override
  Stream<String> get errorPasswordText => passwordController.map((isEmpty) => isEmpty ? false : "Invalid password");

  @override
  void dispose() {
    _emailStream.close();
    _passwordStream.close();
  }
}