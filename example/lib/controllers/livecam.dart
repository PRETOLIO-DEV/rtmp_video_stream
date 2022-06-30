import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:intl/intl.dart';


import 'package:video_stream/live.dart';
import 'package:wakelock/wakelock.dart';


import '../component/custom_alert.dart';
import '../component/snakbar.dart';
import '../config.dart';
import '../main.dart';
import '../models/qrcode_model.dart';



class LiveCam extends ChangeNotifier {
  static final  LiveCam _liveManager = LiveCam._internal();
  factory LiveCam() {
    return _liveManager;
  }
  LiveCam._internal();


  //bool isResolution = false;
  final bool isAndroid = Platform.isAndroid;
  bool msgCount = true;
  static final GlobalKey<ScaffoldState> scaffoldKeyCam = GlobalKey<ScaffoldState>();

  final GlobalKey<PopupMenuButtonState<ResolutionPreset>> keyMenuResolution = GlobalKey();


  DateTime _timeDateLive = DateTime(2000);

  String _timeLive = '00:00:00';
  String get timeLive => _timeLive;
  set timeLive(String v){
    _timeLive = v;
    notifyListeners();
  }




  ResolutionPreset _resolution = ResolutionPreset.medium;
  ResolutionPreset get resolution => _resolution;
  set resolution(ResolutionPreset v ){
    _resolution = v;
    //isResolution = true;
    //alterResolution();
    notifyListeners();
  }

  static LiveControler controller = LiveControler(config: LiveConfig(
    resolutionPreset: ResolutionPreset.low, cameras: cameras?.last
  ));


  bool enableAudio = true;
  bool camFront = true;

  QRCodeModel? _qrCode;
  QRCodeModel? get qrCode => _qrCode;
  set qrCode(QRCodeModel? v){
    _qrCode = v ?? QRCodeModel(id: 1, mediaUrl: Config.urlTeste);
    if(v != null){
      initialize();
    }
  }

  bool _buttomOn = false;
  bool get buttomOn => _buttomOn;
  set buttomOn(bool v){
    _buttomOn = isAndroid ? v: false;
    notifyListeners();
  }

  bool _isDebug = false;
  bool get isDebug => _isDebug;
  set isDebug(bool v){
    _isDebug = v;
    notifyListeners();
  }

  bool _isPause = false;
  bool get isPause => _isPause;
  set isPause(bool v){
    _isPause = v;
    notifyListeners();
  }

  bool _streaming = false;
  bool get streaming => _streaming;
  set streaming(bool v){
    _streaming = v;
    notifyListeners();
  }

  bool _load = false;
  bool get load => _load;
  set load(bool v){
    _load = v;
    notifyListeners();
  }

  String cameraDirection = 'front';

  Timer? _timer;

  init(BuildContext context) async {
    qrCode = await Navigator.pushNamed(context, '/qrcode') as QRCodeModel?;
  }

  Future<void> initialize() async {
    Wakelock.enable();
    buttomOn = true;
    if(isAndroid){
      controller.listenerAndroid(_listener);
    }
    print('initialize');
    await controller.initialize();
    buttomOn = false;
    notifyListeners();
  }

  muteVideo() async {
    buttomOn = true;
    enableAudio = !enableAudio;
    if (qrCode != null) {
      await controller.mute(enableAudio);
    }
    buttomOn = false;
  }

  alterResolution(ResolutionPreset preset) async {
    buttomOn = true;
    resolution = preset;
    if(!streaming){
      await controller.alterResolution(LiveConfig(
          resolutionPreset: resolution, cameras: camFront ? cameras?.last : cameras?.first
      ));
      if(!isAndroid) camFront = true;
      if(isAndroid){
        controller.listenerAndroid(_listener);
      }
      if(qrCode != null){
        controller.initialize();
      }
    }
    notifyListeners();
    buttomOn = false;
  }

  Future<bool> pauseLive() async {
    buttomOn = true;
    if(streaming){
      try{
        await controller.pause();
        isPause = true;
        _timer!.cancel();
      }catch(e){
        debugPrint(e.toString());
      }
    }
    buttomOn = false;
    return isPause;
  }

  resumeLive() async {
    buttomOn = true;
    if(streaming){
      try{
        await controller.resume();
        _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
          _timeDateLive = _timeDateLive.add(Duration(seconds: timer.tick));
          timeLive = DateFormat('HH:mm:ss').format(_timeDateLive);
        });
        isPause = false;
      }catch(e){
        debugPrint(e.toString());
      }
    }
    buttomOn = false;
  }

  toggleCameraDirection() async {
    buttomOn = true;
    if(qrCode != null){
      await controller.switchCamera();
      camFront = !camFront;
    }
    buttomOn = false;
  }


  Future<VoidCallback?> funcStartStopLive(BuildContext context) async {
    if(streaming) {
      bool result = await onStopButtonPressed();
      if(result){
        CustomAlert(context,title: 'Parabéns!',
            subtitle: 'Sua live foi finalizada com sucesso.',
            body: 'No Live Commerce Web você poderá acompanhar os indicadores da sua live atráves do Dashboard que pode ser acessado pelo menu suspendo clicando no icone do perfil.',
            confirm: (){},
            textConfirm: 'Ok, até logo (:'
        );
      }
    }else if (qrCode != null || !isDebug) {
      if(qrCode?.endDateTime == null || (qrCode?.endDateTime?.compareTo(DateTime.now()) ?? 1) > 0 || isDebug){
        if (qrCode?.startDateTime == null || (qrCode?.startDateTime?.subtract(Duration(minutes: 5)).compareTo(DateTime.now()) ?? 1) < 0 || isDebug ) {
          await onVideoStreamingButtonPressed();
        }
      }
    }
  }


  Future<void> onVideoStreamingButtonPressed() async {
    //if (isResolution) {
      buttomOn = true;
      await startVideoStreaming().then((url) {
        if (url != null) {
          streaming = true;
        } else {
          showInSnackBar('Não foi possivel iniciar o video, tente novamente!');
        }
      });
      buttomOn = false;
/*    }else{
      showInSnackBar('Seleciona uma resolução para iniciar a live', isTop: true);
      keyMenuResolution.currentState?.showButtonMenu();
    }*/
  }

  Future<bool> onStopButtonPressed() async {
    buttomOn = true;
    bool? result = await putEndLive(qrCode?.id).catchError((onError){
      print(onError);
      showInSnackBar('Não foi possivel encerrar a live, tente novamente!');
    });

    print(result);
    if(result ?? false){
      await stopVideoStreaming();
      streaming = false;
      _timer!.cancel();
      enableAudio = true;
      return true;
    }
    buttomOn = false;
    return false;
  }

  Future<bool?> putEndLive(int? url) async {
    return true;
  }

  Future<String?> startVideoStreaming() async {
    if (isAndroid && (!(controller.getAndroidValues?.isInitialized ?? false) || (cameras?.length ?? 0) <= 0)) {
      showInSnackBar('Não foi possivel reconhecer uma camera');
      return null;
    }
    try {
      String _newurl = _qrCode?.mediaUrl ?? '';
      await controller.start(isDebug ? Config.urlTeste : _newurl);

      if (_timer != null) {
        _timer!.cancel();
      }
      _timeDateLive = DateTime(2000);
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        timeLive = "${DateFormat('HH:mm:ss').format(DateTime(2000).add(Duration(seconds: timer.tick)))}";
        _timeDateLive = _timeDateLive.add(Duration(seconds: timer.tick));
        //timeLive = DateFormat('HH:mm:ss').format(_timeDateLive);
      });
      if(!enableAudio) {
        Future.delayed(Duration(milliseconds: 500), () async {
          await controller.mute(enableAudio);
        });
      }
      if(isAndroid) Wakelock.enable();
      if (_qrCode?.durationInMinutes != null) {
        Future.delayed(Duration(minutes: _qrCode!.durationInMinutes!.toInt() - 3), () async {
          if (streaming) {
            Future.delayed(Duration(minutes: 2), () async {
              if (streaming) {
                showInSnackBar('Falta 1 minuto para encerrar a live', isTop: true);
              }
            });
            showInSnackBar('Falta 3 minutos para encerrar a live', isTop: true);
          }
        });
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    } catch (e){
      print(e);
      return null;
    }
    return _qrCode?.mediaUrl;
  }

  Future<void> stopVideoStreaming() async {
    try {
      if (streaming) {
        await controller.stop();
        if(isAndroid) Wakelock.disable();
        if (_timer != null) {
          _timer!.cancel();
        }
      }
      if (_timer != null) {
        _timer!.cancel();
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }catch (e){
      print(e);
    }
  }

  bool _conn = true;
  Future<void> _listener() async {
    if (controller.getAndroidValues!.hasError) {
      print('Camera error ${controller.getAndroidValues!.errorDescription}');
      showInSnackBar('Erro na live, inicie novamente!');

      try {
        if(controller.getAndroidValues!.isStreamingVideoRtmp){
          await controller.stop();
          Wakelock.disable();
        }
      } catch (e) {
        print(e);
      }
      if (_timer != null) {
        _timer!.cancel();
      }
      enableAudio = true;
      streaming = false;
    }
    notifyListeners();
  }

  String resolutionString(ResolutionPreset resolutionPreset){
    switch (resolutionPreset) {
      case ResolutionPreset.low:
        return "240p";
      case ResolutionPreset.medium:
        return "480p";
      case ResolutionPreset.high:
        return "720p";
      case ResolutionPreset.veryHigh:
        return "1080p";
      case ResolutionPreset.ultraHigh:
        return "2160p";
      case ResolutionPreset.max:
        return "Max";
    }
  }

  disposeCam() async {
    try {
      if(isAndroid && streaming) await controller.stop();
    } catch (e) {
      print(e);
    }
    try {
      await controller.dispose();
      streaming = false;
      if(isAndroid) Wakelock.disable();
    } catch (e) {
      print(e);
    }
  }

}


void _showCameraException(CameraException e) {
  showInSnackBar('Error: ${e.code}\n${e.description}');
}