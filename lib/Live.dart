
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_stream/src/camera.dart';
import 'package:video_stream/src/flutter_rtmp.dart';
export 'src/camera.dart' show CameraDescription, ResolutionPreset, CameraException;



class LiveControler {
  LiveControler({LiveConfig? config}){
    if(config != null){
      if(_isAndroid){
        _controllerAndroid = config.ConfigAndroid();
      }else{
        _controllerIos = config.ConfigIos();
      }
    }
  }

  final bool _isAndroid = Platform.isAndroid;
  RtmpManager? _controllerIos;
  CameraController? _controllerAndroid;

  bool isStream = false;
  bool isInitialize = false;
  bool isMute = false;


  Future<List<CameraDescription>?> getCamerasAndroid() async {
    if(_isAndroid){
      return await availableCameras();
    }
  }

  Future<void> initialize() async {
    if(_isAndroid){
      await _controllerAndroid!.initialize();
    }else{
      await _controllerIos!.initConfig();
    }
    isInitialize = true;
  }

  start(String url) async {
    if(_isAndroid){
      await _controllerAndroid!.startVideoStreaming(url);
    }else{
      await _controllerIos!.startLive(url);
    }
    isStream = true;
  }

  alterResolution(LiveConfig config) async {
    if(_isAndroid){
      await _controllerAndroid!.dispose();
      _controllerAndroid = config.ConfigAndroid();
      await _controllerAndroid!.initialize();
    }else{
      await _controllerIos!.dispose();
      _controllerIos = config.ConfigIos();
      await _controllerIos!.initConfig();
    }
    isStream = false;
    isMute = false;
    isInitialize = true;
  }

  listenerAndroid(VoidCallback listener) {
    if(_isAndroid){
      _controllerAndroid!.addListener(listener);
    }
  }

  CameraValue? get getAndroidValues {
    if(_isAndroid){
      return  _controllerAndroid!.value;
    }
  }

  stop() async {
    if(_isAndroid){
      await _controllerAndroid!.stopVideoStreaming();
    }else{
      await _controllerIos!.stopLive();
    }
    isStream = false;
  }

  pause() async {
    if(_isAndroid){
      await _controllerAndroid!.pauseVideoStreaming();
    }else{
      await _controllerIos!.pauseLive();
    }
  }

  resume() async {
    if(_isAndroid){
      await _controllerAndroid!.resumeVideoStreaming();
    }else{
      await _controllerIos!.resumeLive();
    }
  }

  mute(bool isAudio) async {
    isMute = !isAudio;
    if(_isAndroid){
      await _controllerAndroid!.audio(isAudio);
    }else{
      await _controllerIos!.mute();
    }
  }

  switchCamera() async {
    if(_isAndroid){
      await _controllerAndroid!.switchCamera();
    }else{
      await _controllerIos!.switchCamera();
    }
  }

  Future<void> dispose() async {
    if(_isAndroid){
      await _controllerAndroid!.dispose();
    }else{
      await _controllerIos!.dispose();
    }
    isStream = false;
    isInitialize = false;
  }

  Widget screem(){
    if(_isAndroid){
      return AspectRatio(
        aspectRatio: _controllerAndroid!.value.aspectRatio,
        child: CameraPreview(_controllerAndroid!),
      );
    }else{
      return Stack(
        children: [
          RtmpView(manager: _controllerIos!),
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
        return 1;
      case ResolutionPreset.medium:
        return 3;
      case ResolutionPreset.high:
        return 5;
      case ResolutionPreset.veryHigh:
        return 6;
      case ResolutionPreset.ultraHigh:
        return 8;
      case ResolutionPreset.max:
        return 8;
    }
  }
}