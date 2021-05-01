import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';

class Map extends StatefulWidget {
  @override
  MapState createState() => MapState();
}

class MapState extends State<Map> {
  Geolocator geolocator = Geolocator();
  Position userLocation;

  @override
  void initState() {
    super.initState();
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: userLocation == null
          ? Center(
              child: ElevatedButton(
                  onPressed: () {
                    _getLocation().then((value) {
                      setState(() {
                        userLocation = value;
                      });
                    });
                  },
                  child: Text('Position')),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(userLocation.latitude, userLocation.longitude),
                zoom: 16,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
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
}
