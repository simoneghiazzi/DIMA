import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/constants.dart';

/// Text field used inside the forms.
///
/// It takes the [textFieldBloc] that controls the [TextFieldBlocBuilder], the [hintText],
/// the [prefixIconData] that is drawn before the text and the optional [suffixButton].
class FormTextField extends StatelessWidget {
  final TextFieldBloc textFieldBloc;
  final String hintText;
  final IconData prefixIconData;
  final SuffixButton? suffixButton;

  /// Text field used inside the forms.
  ///
  /// It takes the [textFieldBloc] that controls the [TextFieldBlocBuilder], the [hintText],
  /// the [prefixIconData] that is drawn before the text and the optional [suffixButton].
  const FormTextField({Key? key, required this.textFieldBloc, required this.hintText, required this.prefixIconData, this.suffixButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFieldBlocBuilder(
        textFieldBloc: textFieldBloc,
        suffixButton: suffixButton,
        decoration: InputDecoration(
          filled: true,
          fillColor: kPrimaryLightColor.withAlpha(100),
          labelText: hintText,
          labelStyle: TextStyle(color: kPrimaryDarkColor),
          prefixIcon: Icon(prefixIconData, color: kPrimaryColor),
        ),
      ),
    );
  }
}
