

import 'package:flutter/material.dart';

import 'qrcode.dart';
import 'camera.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch( settings.name ){
      case "/" :
        return MaterialPageRoute(
          builder: (_) {
            return CameraScreen();
          }
        );
      case "/qrcode" :
        return MaterialPageRoute(
          builder: (_) => QRcodeScreen(),
        );
      case "/camera" :
        return MaterialPageRoute(
          builder: (_) => CameraScreen(),
        );
      default:
        return _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(title: Text("Tela não encontrada!"),),
          body: Center(
            child: Text("Tela não encontrada!"),
          ),
        );
      }
    );
  }

}