
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:video_stream/Live.dart';
import 'package:provider/provider.dart';

import 'controllers/livecam.dart';
import 'route_generator.dart';
import '../utils/PhonePermissionUtils.dart';

List<CameraDescription>? cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PhonePermissionUtils.checkPermission();
  cameras = await LiveControler.getCamerasAndroid();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).
  then((_) {
    runApp(MultiProvider(providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_)=> LiveCam(),
        ),
      ], child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Calibri'),
      title: 'Live Commerce',
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}


// rtmp://qa-livecommerce.cliqx.com.br:1935/live/a3f73259f6ab43cea627e6e1cd24769e
// https://qa-livecommerce.cliqx.com.br:19588/hls/a3f73259f6ab43cea627e6e1cd24769e.m3u8