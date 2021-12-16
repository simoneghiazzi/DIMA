import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:email_validator/email_validator.dart';

abstract class AuthFormInterface {
  /// Email sink for inserting the text stream
  Sink get email;

  /// Password sink for inserting the text stream
  Sink get psw;

  /// Repeate password sink for inserting the text stream
  Sink get repeatPsw;

  /// Enable the sign up by checking the email controller, the password controller and the repeat password controller
  Stream<bool> get isSignUpEnabled;

  /// Validate the login by checking the email controller and the password controller
  Stream<bool> get isLoginEnabled;

  /// Validate the reset password by checking the email controller
  Stream<bool> get isResetPasswordEnabled;

  /// Error message for the email input
  Stream<String> get errorEmailText;

  /// Error message for the repeat password input
  Stream<String> get errorRepeatPasswordText;

  void dispose();
}

class LoginForm implements AuthFormInterface {
  // Stream controllers
  var _emailStream = StreamController<String>.broadcast();
  var _passwordStream = StreamController<String>.broadcast();
  var _repeatPasswordStream = StreamController<String>.broadcast();

  // Variables that store the inserted password and repeated password for the check
  String _lastPsw = "";
  String _lastRepeatPsw = "";

  // Sinks
  @override
  Sink get email => _emailStream;

  @override
  Sink get psw => _passwordStream;

  @override
  Sink get repeatPsw => _repeatPasswordStream;

  /// Validate the inserted email with an EmailValidator
  Stream<bool> get _emailController => _emailStream.stream.map((email) => EmailValidator.validate(email));

  /// Validate the inserted password by checking if it is not empty and it is equal to the repeated password
  Stream<bool> get _passwordController => _passwordStream.stream.map((password) {
        _lastPsw = password;
        if (_lastRepeatPsw.isNotEmpty) {
          _repeatPasswordStream.add(_lastRepeatPsw);
        }
        return password.isNotEmpty;
      });

  /// Validate the inserted repeat password by checking if it is not empty and it is equal to the repeated password
  Stream<bool> get _repeatedPasswordController => _repeatPasswordStream.stream.map((repeatedPassword) {
        _lastRepeatPsw = repeatedPassword;
        return repeatedPassword == _lastPsw;
      });

  // Streams
  @override
  Stream<bool> get isSignUpEnabled => Rx.combineLatest3(_emailController, _passwordController, _repeatedPasswordController, (a, b, c) => a && b && c);

  @override
  Stream<bool> get isLoginEnabled => Rx.combineLatest2(_emailController, _passwordController, (a, b) => a && b);

  @override
  Stream<bool> get isResetPasswordEnabled => _emailController.map((isCorrect) => isCorrect);

  @override
  Stream<String> get errorEmailText => _emailController.map((isCorrect) => isCorrect ? false : "Invalid email");

  @override
  Stream<String> get errorRepeatPasswordText => _repeatedPasswordController.map((isCorrect) => isCorrect ? false : "Password does not match");

  /// Reset all the controllers and the variables for the password check
  void resetControllers() {
    _lastPsw = "";
    _lastRepeatPsw = "";
    email.add(null);
    psw.add(null);
    repeatPsw.add(null);
  }

  @override
  void dispose() {
    _emailStream.close();
    _passwordStream.close();
    _repeatPasswordStream.close();
  }
}
