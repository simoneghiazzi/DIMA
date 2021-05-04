import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Map/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/MapViewModel.dart';

class MapScreen extends StatelessWidget {
  final MapViewModel mapViewModel = MapViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(mapViewModel: mapViewModel),
    );
  }
}
