import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sApport/Model/Map/place.dart';
import 'package:sApport/Model/Services/map_service.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class MapViewModel {
  /// Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final MapService mapService = GetIt.I<MapService>();

  // Text Controllers
  final TextEditingController searchTextCtrl = TextEditingController();

  // Stream Controllers
  var _autocompletedPlacesCtrl = StreamController<List<Place>?>.broadcast();
  var _selectedPlaceCtrl = StreamController<Place?>.broadcast();

  late PermissionStatus positionPermission;

  MapViewModel() {
    // Set the position permission status on the location of the device
    Permission.location.status.then((status) {
      positionPermission = status;
    }).catchError((error) {
      print("Error in getting the position permission status: $error");
    });
  }

  /// Request the user for access to the location [Permission].
  ///
  /// It returns `true` if the permission is granted, `false` otherwise.
  Future<bool> askPermission() async {
    positionPermission = await Permission.location.request();
    if (positionPermission.isGranted) {
      return true;
    }
    return false;
  }

  /// Autocomplete the input of the user with the most probable places.
  ///
  /// It adds the list of [Place] to the [autocompletedPlaces] stream.
  Future<void> autocompleteSearchedPlace() async {
    return mapService.autocomplete(searchTextCtrl.text).then((places) {
      _autocompletedPlacesCtrl.add(places);
    });
  }

  /// Returns the first most probable place based on the input of the user.
  Future<Place> firstSimilarPlace(String input) async {
    return (await mapService.autocomplete(input))[0];
  }

  /// Search a place based on the [placeId].
  ///
  /// It adds the [Place] to the [selectedPlace] stream.
  Future<void> searchPlace(String placeId) async {
    _autocompletedPlacesCtrl.add(null);
    return mapService.searchPlace(placeId).then((place) {
      searchTextCtrl.text = place.address!;
      _selectedPlaceCtrl.add(place);
    });
  }

  /// Returns the current position of the user device.
  Future<Position> loadCurrentPosition() {
    return mapService.getCurrentPosition().catchError((e) {
      print("Error in getting the current position: $e");
    });
  }

  /// Return the list of experts.
  Future<QuerySnapshot?> loadExperts() async {
    try {
      return _firestoreService.getBaseCollectionFromDB(Expert.COLLECTION);
    } catch (e) {
      print("Failed to get the list of experts: $e");
      return null;
    }
  }

  /// Clear all the text and stream controllers.
  void clearControllers() {
    searchTextCtrl.clear();
    _selectedPlaceCtrl.add(null);
    _autocompletedPlacesCtrl.add(null);
  }

  /// Stream of the selected palce controller
  Stream<Place?> get selectedPlace => _selectedPlaceCtrl.stream;

  /// Stream of the autocompleted places controller
  Stream<List<Place>?> get autocompletedPlaces => _autocompletedPlacesCtrl.stream;
}
