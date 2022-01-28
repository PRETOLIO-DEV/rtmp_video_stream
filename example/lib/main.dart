import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_stream/camera.dart';
import 'dart:async';
//
// import 'package:flutter_rtmp/flutter_rtmp.dart';

import '_main.dart';
import 'home.dart';
import 'utils/PhonePermissionUtils.dart';
List<CameraDescription> cameras = [];
void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

Future<void> main() async {
  // if (Platform.isAndroid) {
  //   SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent, //设置为透明
  //   );
  //   SystemChrome.setSyst emUIOverlayStyle(systemUiOverlayStyle);
  if(Platform.isAndroid){
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }


  runApp(Platform.isAndroid ? CameraApp() : MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // PhonePermissionUtils.checkPermission;
    PhonePermissionUtils.checkPermission().then((onValue) {});
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
