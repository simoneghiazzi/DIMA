import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20, right: 20, top: 110),
      title: Text(
        'Homepage',
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      trailing: CircleAvatar(
        radius: 50,
      ),
    );
  }
}
