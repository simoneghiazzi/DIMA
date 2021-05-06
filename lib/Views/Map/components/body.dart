import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dima_colombo_ghiazzi/ViewModel/MapViewModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Body extends StatefulWidget {
  final MapViewModel mapViewModel;

  Body({Key key, @required this.mapViewModel}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  StreamSubscription<Position> subscriber;
  Position userLocation;

  @override
  void initState() {
    super.initState();
    subscriber = subscribeToViewModel();
    widget.mapViewModel.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: userLocation == null
          ? Container(
              child: Center(
                child: Text(
                  'loading map..',
                  style:
                      TextStyle(fontFamily: 'Roboto', color: Colors.grey[400]),
                ),
              ),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(userLocation.latitude, userLocation.longitude),
                zoom: 16,
              ),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                widget.mapViewModel.mapController.complete(controller);
              }),
    );
  }

  StreamSubscription<Position> subscribeToViewModel() {
    return widget.mapViewModel.position.listen((userPosition) {
      if (userPosition != null) {
        userLocation = userPosition;
      }
    });
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
