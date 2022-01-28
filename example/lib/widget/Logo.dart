import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double size;

  const Logo({this.size: 100.0}) ;

  // Logo({this.size: 100.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo_light.png', width: size);
  }
}
