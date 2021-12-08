import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sApport/Model/BaseUser/Map/place.dart';
import 'package:sApport/Model/BaseUser/Map/place_search.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sApport/Model/BaseUser/Map/place_service.dart';

class MapViewModel {
  FirestoreService _firestoreService = GetIt.I<FirestoreService>();

  var _placesSearch = StreamController<List<PlaceSearch>>.broadcast();
  final placesSearch = PlaceService();

  var _selectedLocation = StreamController<Place>.broadcast();

  var _searchedPlaceString = StreamController<String>.broadcast();

  var positionPermission = PermissionStatus.denied;

  Place searchedPlace;

  MapViewModel() {
    Permission.location.status.then((status) => positionPermission = status);
  }

  Future<Position> uploadPosition() {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future<bool> askPermission() async {
    positionPermission = await Permission.location.request();
    if (positionPermission.isGranted) {
      return true;
    }
    return false;
  }

  void searchPlaces(String searchTerm) async {
    placesSearch.getAutocomplete(searchTerm).then((places) {
      _placesSearch.add(places);
    });
  }

  Future<List<PlaceSearch>> searchPlaceSubscription(String searchTerm) async {
    return await placesSearch.getAutocomplete(searchTerm);
  }

  void setSelectedLocation(String place) async {
    placesSearch.getPlace(place).then((location) {
      _selectedLocation.add(location);
      searchedPlace = location;
      _searchedPlaceString.add(place);
    });
  }

  Future<Place> getExpertLocation(String place) async {
    return await placesSearch.getPlace(place);
  }

  /// Return the list of experts
  Future<QuerySnapshot> getMarkers() async {
    return _firestoreService.getBaseCollectionFromDB(Collection.EXPERTS);
  }

  Stream<List<PlaceSearch>> get places => _placesSearch.stream;
  Stream<Place> get location => _selectedLocation.stream;
  Stream<String> get searched => _searchedPlaceString.stream;
}
