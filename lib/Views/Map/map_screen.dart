import 'package:flutter/material.dart';
import 'package:sApport/Views/Map/components/map_body.dart';

class MapScreen extends StatelessWidget {
  static const route = '/mapScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapBody(),
    );
  }
}
