import 'package:flutter/material.dart';

class LoginViewMobile extends StatefulWidget {
  const LoginViewMobile({super.key});

  @override
  State<LoginViewMobile> createState() => _LoginViewMobileState();
}

class _LoginViewMobileState extends State<LoginViewMobile> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(child: Text("Mobile View"),),
    );
  }
}