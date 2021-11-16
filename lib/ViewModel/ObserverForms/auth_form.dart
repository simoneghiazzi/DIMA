import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:email_validator/email_validator.dart';

abstract class AuthFormInterface {
  Sink get emailText;
  Sink get passwordText;
  Sink get repeatedPasswordText;
  Stream<bool> get isSignUpEnabled;
  Stream<bool> get isLoginEnabled;
  Stream<String> get errorEmailText;
  Stream<String> get errorRepeatedPasswordText;

  void dispose();
}

class LoginForm implements AuthFormInterface {
  var _emailStream = StreamController<String>.broadcast();
  var _passwordStream = StreamController<String>.broadcast();
  var _repeatedPasswordStream = StreamController<String>.broadcast();
  String lastPassword = "";
  String lastRepeatedPassword = "";

  @override
  Sink get emailText => _emailStream;

  @override
  Sink get passwordText => _passwordStream;

  @override
  Sink get repeatedPasswordText => _repeatedPasswordStream;

  Stream<bool> get _emailController =>
      _emailStream.stream.map((email) => EmailValidator.validate(email));

  Stream<bool> get _passwordController =>
      _passwordStream.stream.map((password) {
        lastPassword = password;
        if (lastRepeatedPassword.isNotEmpty) {
          _repeatedPasswordStream.add(lastRepeatedPassword);
        }
        return password.isNotEmpty;
      });

  Stream<bool> get _repeatedPasswordController =>
      _repeatedPasswordStream.stream.map((repeatedPassword) {
        lastRepeatedPassword = repeatedPassword;
        return repeatedPassword == lastPassword;
      });

  @override
  Stream<bool> get isSignUpEnabled => Rx.combineLatest3(
      _emailController,
      _passwordController,
      _repeatedPasswordController,
      (a, b, c) => a && b && c);

  @override
  Stream<bool> get isLoginEnabled => Rx.combineLatest2(
      _emailController, _passwordController, (a, b) => a && b);

  @override
  Stream<String> get errorEmailText =>
      _emailController.map((isCorrect) => isCorrect ? false : "Invalid email");

  @override
  Stream<String> get errorRepeatedPasswordText => _repeatedPasswordController
      .map((isCorrect) => isCorrect ? false : "Password does not match");

  @override
  void dispose() {
    _emailStream.close();
    _passwordStream.close();
    _repeatedPasswordStream.close();
  }
}
