import 'dart:async';
import 'dart:developer';
import 'dart:collection';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sApport/Model/Map/place.dart';
import 'package:sApport/Model/Services/map_service.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class MapViewModel with ChangeNotifier {
  /// Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final MapService _mapService = GetIt.I<MapService>();

  // Text Controllers
  final TextEditingController searchTextCtrl = TextEditingController();

  // Stream Controllers
  var _autocompletedPlacesCtrl = StreamController<List<Place>?>.broadcast();
  var _selectedPlaceCtrl = StreamController<Place?>.broadcast();

  // Current opened expert in the map
  ValueNotifier<Expert?> _currentExpert = ValueNotifier(null);

  // List of the reports of the user saved as Linked Hash Map
  LinkedHashMap<String, Expert> _experts = LinkedHashMap<String, Expert>();

  /// Autocomplete the input of the user with the most probable places.
  ///
  /// It adds the list of [Place] to the [autocompletedPlaces] stream.
  Future<void> autocompleteSearchedPlace() async {
    return _mapService.autocomplete(searchTextCtrl.text).then((places) {
      _autocompletedPlacesCtrl.add(places);
    });
  }

  /// Returns the first most probable place based on the input of the user.
  Future<Place> firstSimilarPlace(String input) async {
    return (await _mapService.autocomplete(input))[0];
  }

  /// Search a place based on the [placeId].
  ///
  /// It adds the [Place] to the [selectedPlace] stream.
  Future<void> searchPlace(String placeId) async {
    _autocompletedPlacesCtrl.add(null);
    return _mapService.searchPlace(placeId).then((place) {
      if (place != null) {
        searchTextCtrl.text = place.address!;
        _selectedPlaceCtrl.add(place);
      }
    });
  }

  /// Returns the current position of the user device.
  Future<Position?> loadCurrentPosition() {
    return _mapService.getCurrentPosition();
  }

  /// Load the list of experts.
  Future<void> loadExperts() async {
    return _firestoreService.getExpertCollectionFromDB().then((snapshot) {
      for (var doc in snapshot.docs) {
        Expert expert = Expert.fromDocument(doc);
        if (!_experts.containsKey(expert.id)) {
          _experts[expert.id] = expert;
        }
      }
    }).catchError((error) {
      log("Failed to get the list of experts: $error");
    });
  }

  /// Clear all the text and stream controllers.
  void clearControllers() {
    searchTextCtrl.clear();
    _selectedPlaceCtrl.add(null);
    _autocompletedPlacesCtrl.add(null);
  }

  /// Clear the experts values.
  void resetViewModel() {
    _experts.clear();
    log("MapViewModel resetted");
  }

  /// Stream of the selected palce controller
  Stream<Place?> get selectedPlace => _selectedPlaceCtrl.stream;

  /// Stream of the autocompleted places controller
  Stream<List<Place>?> get autocompletedPlaces => _autocompletedPlacesCtrl.stream;

  /// Set the [expert] as the [_currentExpert].
  void setCurrentExpert(Expert expert) {
    _currentExpert.value = expert;
    log("Current expert setted");
  }

  /// Reset the [_currentExpert].
  ///
  /// It must be called after all the other reset methods.
  void resetCurrentExpert() {
    _currentExpert.value = null;
    log("Current expert resetted");
  }

  /// Get the [_currentExpert] instance.
  ValueNotifier<Expert?> get currentExpert => _currentExpert;

  /// Get the [_experts] list.
  ///
  /// **The function [loadExperts] must be called before getting
  /// the [experts].**
  LinkedHashMap<String, Expert> get experts => _experts;
}
