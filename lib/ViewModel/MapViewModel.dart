import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapViewModel {
  var _position = StreamController<Position>.broadcast();
  Completer<GoogleMapController> mapController = Completer();

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

  Stream<Position> get position => _position.stream;
}
