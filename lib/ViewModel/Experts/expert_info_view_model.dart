import 'package:dima_colombo_ghiazzi/Model/BaseUser/Map/place.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Map/place_search.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/map_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ExpertInfoViewModel extends BaseUserInfoViewModel {
  final MapViewModel mapViewModel = MapViewModel();
  String infoAddress;
  Place expertAddress;

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

  ExpertInfoViewModel() {
    addFieldBlocs(fieldBlocs: [
      nameText,
      surnameText,
      birthDateTime,
      countryText,
      cityText,
      streetText,
      addressNumberText,
      phoneNumberText
    ]);
  }

  @override
  Map get values {
    return {
      'name': nameText.value,
      'surname': surnameText.value,
      'birthDate': birthDateTime.value,
      'lat': expertAddress.geometry.location.lat,
      'lng': expertAddress.geometry.location.lng,
      'phoneNumber': phoneNumberText.value,
    };
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
