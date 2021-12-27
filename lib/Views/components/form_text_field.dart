import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Views/Utils/constants.dart';

/// Text field used inside the forms.
///
/// It takes the [textFieldBloc] that controls the [TextFieldBlocBuilder],
/// the [prefixIconData] that is drawn before the text.
class FormTextField extends StatelessWidget {
  final TextFieldBloc textFieldBloc;
  final String hintText;
  final IconData prefixIconData;
  final SuffixButton? suffixButton;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  /// Text field used inside the forms.
  ///
  /// It takes the [textFieldBloc] that controls the [TextFieldBlocBuilder],
  /// the [prefixIconData] that is drawn before the text.
  const FormTextField({
    Key? key,
    required this.textFieldBloc,
    required this.hintText,
    required this.prefixIconData,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.sentences,
    this.suffixButton,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFieldBlocBuilder(
        textFieldBloc: textFieldBloc,
        suffixButton: suffixButton,
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        onChanged: onChanged,
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
