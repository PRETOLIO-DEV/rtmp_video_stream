import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_stream/Live.dart';
import 'dart:async';

import '_main.dart';
import 'home.dart';
import 'utils/PhonePermissionUtils.dart';
List<CameraDescription>? cameras = [];
void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

Future<void> main() async {
  // if (Platform.isAndroid) {
  //   SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent, //设置为透明
  //   );
  //   SystemChrome.setSyst emUIOverlayStyle(systemUiOverlayStyle);
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await LiveControler().getCamerasAndroid();
  } on Exception catch(e) {
    logError(e.toString(), e.toString());
  }



  runApp(CameraApp());
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
