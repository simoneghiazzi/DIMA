import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/Map/place.dart';
import 'package:dima_colombo_ghiazzi/Model/Map/place_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/places_service.dart';

class MapViewModel {
  var _position = StreamController<Position>.broadcast();
  Completer<GoogleMapController> mapController = Completer();

  var _placesSearch = StreamController<List<PlaceSearch>>.broadcast();
  final placesSearch = PlacesService();

  var _selectedLocation = StreamController<Place>.broadcast();

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

  setSelectedLocation(String place) async {
    placesSearch.getPlace(place).then((location) {
      _selectedLocation.add(location);
    });
  }

  Stream<Position> get position => _position.stream;
  Stream<List<PlaceSearch>> get places => _placesSearch.stream;
  Stream<Place> get location => _selectedLocation.stream;
}
