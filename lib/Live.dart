
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_stream/src/camera.dart';
import 'package:video_stream/src/flutter_rtmp.dart';
export 'src/camera.dart' show CameraDescription, ResolutionPreset, CameraException;



class LiveControler {

  LiveControler({LiveConfig? config}){
    if(config != null){
      if(_isAndroid){
        controllerAndroid = config.ConfigAndroid();
      }else{
        controllerIos = config.ConfigIos();
      }
    }
  }

  final bool _isAndroid = Platform.isAndroid;
  static RtmpManager? controllerIos;
  static CameraController? controllerAndroid;

  static bool isStream = false;
  static bool isInitialize = false;
  static bool isMute = false;


  static Future<List<CameraDescription>?> getCamerasAndroid() async => await availableCameras();


  Future<void> initialize() async {
    if(_isAndroid){
      await controllerAndroid!.initialize();
    }else{
      await controllerIos!.initConfig();
    }
    isInitialize = true;
  }

  Future<void> start(String url) async {
    if(_isAndroid){
      await controllerAndroid!.startVideoStreaming(url);
    }else{
      await controllerIos!.startLive(url);
    }
    isStream = true;
  }

  Future<void> alterResolution(LiveConfig config) async {
    bool _isInitialize = isInitialize;
    if(_isAndroid){
      await controllerAndroid!.dispose();
      controllerAndroid = config.ConfigAndroid();
      if(_isInitialize){
        await controllerAndroid!.initialize();
      }
    }else{
      await controllerIos!.dispose();
      controllerIos = config.ConfigIos();
      if (_isInitialize) {
        await controllerIos!.initConfig();
      }
    }
    isStream = false;
    isMute = false;
    isInitialize = _isInitialize;
  }

  listenerAndroid(VoidCallback listener) {
    if(_isAndroid){
      controllerAndroid!.addListener(listener);
    }
  }

  CameraValue? get getAndroidValues {
    if(_isAndroid){
      return  controllerAndroid!.value;
    }
  }

  Future<void> stop() async {
    if(_isAndroid){
      await controllerAndroid!.stopVideoStreaming();
    }else{
      await controllerIos!.stopLive();
    }
    isStream = false;
  }

  Future<void> pause() async {
    if(_isAndroid){
      await controllerAndroid!.pauseVideoStreaming();
    }else{
      await controllerIos!.pauseLive();
    }
  }

  Future<void> resume() async {
    if(_isAndroid){
      await controllerAndroid!.resumeVideoStreaming();
      if(!isMute) await mute(true);
    }else{
      await controllerIos!.resumeLive();
    }
  }

  Future<void> mute(bool isAudio) async {
    isMute = !isAudio;
    if(_isAndroid){
      await controllerAndroid!.audio(isAudio);
    }else{
      await controllerIos!.mute();
    }
  }

  Future<void> switchCamera() async {
    if(_isAndroid){
      await controllerAndroid!.switchCamera();
    }else{
      await controllerIos!.switchCamera();
    }
  }

  Future<void> dispose() async {
    if(_isAndroid){
      await controllerAndroid!.dispose();
    }else{
      await controllerIos!.dispose();
    }
    isStream = false;
    isInitialize = false;
  }

  Widget screem(){
    if(_isAndroid){
      return AspectRatio(
        aspectRatio: controllerAndroid!.value.aspectRatio,
        child: CameraPreview(controllerAndroid!),
      );
    }else{
      return Stack(
        children: [
          RtmpView(manager: controllerIos!),
        ],
      );
    }
  }

}

class LiveConfig {
  ResolutionPreset resolutionPreset = ResolutionPreset.medium;
  CameraDescription? cameras;

  LiveConfig({
    required this.resolutionPreset,
    this.cameras
  });

  CameraController ConfigAndroid(){
    return  CameraController(this.cameras!, this.resolutionPreset, androidUseOpenGL: true);
  }

  RtmpManager ConfigIos(){
    return RtmpManager();
    return RtmpManager(config: RtmpConfig(
        videoConfig: RtmpVideoConfig(
            autoRotate: false,
            quality: presetInt(this.resolutionPreset),
            orientation: Orientation.portrait
        ),
        audioConfig: RtmpAudioConfig()
    ));
  }


  int presetInt(ResolutionPreset resolutionPreset){
    switch (resolutionPreset) {
      case ResolutionPreset.low:
        return 0;
      case ResolutionPreset.medium:
        return 1;
      case ResolutionPreset.high:
        return 2;
      case ResolutionPreset.veryHigh:
        return 3;
      case ResolutionPreset.ultraHigh:
        return 4;
      case ResolutionPreset.max:
        return 5;
    }
  }
}