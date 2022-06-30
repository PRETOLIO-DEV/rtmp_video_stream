
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:another_flushbar/flushbar.dart';


import '../config.dart';
import '../controllers/livecam.dart';



void showInSnackBar(String message, {bool isTop = false}) {
  if(LiveCam.scaffoldKeyCam.currentContext != null){
    BuildContext context = LiveCam.scaffoldKeyCam.currentContext!;
    Flushbar(
      message:  message,
      icon: Icon(Icons.warning_rounded, color: Colors.white,),
      flushbarPosition: FlushbarPosition.TOP,
      duration:  Duration(seconds: 3),
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 8, right: 8),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Config.colorSec,
    )..show(context);
  }
}