import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Map/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/map_view_model.dart';

class MapScreen extends StatelessWidget {
  final MapViewModel mapViewModel = MapViewModel();
  final ChatViewModel chatViewModel;

  MapScreen({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        mapViewModel: mapViewModel,
        chatViewModel: chatViewModel,
      ),
    );
  }
}
