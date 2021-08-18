import 'package:dima_colombo_ghiazzi/Model/Map/place.dart';
import 'package:dima_colombo_ghiazzi/Model/Map/place_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'auth_view_model.dart';
import 'map_view_model.dart';

class InfoExpertsViewModel extends FormBloc<String, String> {
  final AuthViewModel authViewModel;
  final BuildContext context;
  final MapViewModel mapViewModel = MapViewModel();
  String infoAddress;
  Place expertAddress;

  final nameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final surnameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final birthDate = InputFieldBloc<DateTime, Object>(
      validators: [
        FieldBlocValidators.required,
        FieldBlocValidators.checkAdultUser,
      ],
      initialValue: new DateTime(
          DateTime.now().year - 18, DateTime.now().month, DateTime.now().day));

  final countryText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final cityText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final streetText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final addressNumberText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final phoneNumberText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.phoneCorrect,
  ]);

  InfoExpertsViewModel({@required this.authViewModel, @required this.context}) {
    addFieldBlocs(fieldBlocs: [
      nameText,
      surnameText,
      birthDate,
      countryText,
      cityText,
      streetText,
      addressNumberText,
      phoneNumberText
    ]);
  }

  @override
  void onSubmitting() async {
    List<PlaceSearch> address = await mapViewModel.searchPlaceSubscription(
        countryText.value +
            " " +
            cityText.value +
            " " +
            streetText.value +
            " " +
            addressNumberText.value);
    if (address.isNotEmpty) {
      infoAddress = address.first.description;
      expertAddress =
          await mapViewModel.getExpertLocation(address.first.placeId);
      emitSuccess();
    } else {
      emitFailure();
    }
  }
}
