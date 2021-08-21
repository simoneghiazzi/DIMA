import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Map/place.dart';
import 'package:dima_colombo_ghiazzi/Model/Map/place_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/place_service.dart';

class MapViewModel {
  var _position = StreamController<Position>.broadcast();
  Completer<GoogleMapController> mapController = Completer();

  var _placesSearch = StreamController<List<PlaceSearch>>.broadcast();
  final placesSearch = PlaceService();

  var _selectedLocation = StreamController<Place>.broadcast();

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
    });
  }

  Future<Place> getExpertLocation(String place) async {
    return await placesSearch.getPlace(place);
  }

  //Create all the experts' markers
  Future<Set<Marker>> getMarkers(BitmapDescriptor pinLocationIcon) async {
    Set<Marker> _markers = {};

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('experts').get();

    List<QueryDocumentSnapshot> docs = snapshot.docs;
    for (var doc in docs) {
      if (doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        _markers.add(Marker(
            markerId: MarkerId(data['surname'] +
                data['lat'].toString() +
                data['lng'].toString()),
            position: LatLng(data['lat'], data['lng']),
            icon: pinLocationIcon,
            infoWindow: InfoWindow(
                title: data['surname'] +
                    " " +
                    data['name'] +
                    " (" +
                    data['phoneNumber'] +
                    ")",
                snippet: data['email'])));
      }
    }
    return _markers;
  }

  Stream<Position> get position => _position.stream;
  Stream<List<PlaceSearch>> get places => _placesSearch.stream;
  Stream<Place> get location => _selectedLocation.stream;
}
