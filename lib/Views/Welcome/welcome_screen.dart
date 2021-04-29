import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/components/body.dart';

class WelcomeScreen extends StatelessWidget {

  final AuthViewModel authViewModel = AuthViewModel();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(authViewModel: authViewModel,),
    );
  }
}
