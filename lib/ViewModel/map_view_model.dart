import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Map/place.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Map/place_search.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Map/place_service.dart';

class MapViewModel {
  var _position = StreamController<Position>.broadcast();
  Completer<GoogleMapController> mapController = Completer();
  FirestoreService _firestoreService = FirestoreService();

  var _placesSearch = StreamController<List<PlaceSearch>>.broadcast();
  final placesSearch = PlaceService();

  var _selectedLocation = StreamController<Place>.broadcast();

  var _searchedPlaceString = StreamController<String>.broadcast();

  Place searchedPlace;

  MapViewModel() {
    _getLocation().then((userLocation) {
      _position.add(userLocation);
    });
  }

  void uploadPosition() {
    _getLocation().then((userLocation) {
      _position.add(userLocation);
    });
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  searchPlaces(String searchTerm) async {
    placesSearch.getAutocomplete(searchTerm).then((places) {
      _placesSearch.add(places);
    });
  }

  Future<List<PlaceSearch>> searchPlaceSubscription(String searchTerm) async {
    return await placesSearch.getAutocomplete(searchTerm);
  }

  setSelectedLocation(String place) async {
    placesSearch.getPlace(place).then((location) {
      _selectedLocation.add(location);
      searchedPlace = location;

      _searchedPlaceString.add(place);
    });
  }

  Future<Place> getExpertLocation(String place) async {
    return await placesSearch.getPlace(place);
  }

  //Create all the experts' markers
  Future<List> getMarkers() async {
    try {
      var docs =
          (await _firestoreService.getBaseCollectionFromDB(Collection.EXPERTS))
              .docs;
      List list = [];
      for (var doc in docs) {
        if (doc.id != 'utils') list.add(doc);
      }
      return list;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<Position> get position => _position.stream;
  Stream<List<PlaceSearch>> get places => _placesSearch.stream;
  Stream<Place> get location => _selectedLocation.stream;
  Stream<String> get searched => _searchedPlaceString.stream;
}
