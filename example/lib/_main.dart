import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_stream/camera.dart';
import 'package:wakelock/wakelock.dart';

import 'main.dart';

class CameraExampleHome extends StatefulWidget {
  const CameraExampleHome({Key? key}) : super(key: key);

  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller =
      CameraController(cameras.last, ResolutionPreset.high,androidUseOpenGL: true);
  CameraController? controllerBack =
    CameraController(cameras.first, ResolutionPreset.high,androidUseOpenGL: true);

  String? imagePath;
  String? videoPath;
  String? url;

  bool enableAudio = true;
  bool useOpenGL = true;
  String streamURL = 'rtmp://qa-livecommerce.cliqx.com.br:1935/live/00d235c4ccb54d38b2d365a6e35a5b9e';
  bool streaming = false;
  String? cameraDirection;

  Timer? _timer;

  @override
  void initState() {
    _initialize();
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> _initialize() async {
    streaming = false;
    cameraDirection = 'front';
    // controller = CameraController(cameras[1], Resolution.high);

    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        print('Camera error ${controller!.value.errorDescription}');
        showInSnackBar('Camera error ${controller!.value.errorDescription}');
        if (_timer != null) {
          _timer!.cancel();
          _timer = null;
        }
        Wakelock.disable();
      }
    });

    controllerBack!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        print('Camera error ${controller!.value.errorDescription}');
        showInSnackBar('Camera error ${controller!.value.errorDescription}');
        if (_timer != null) {
          _timer!.cancel();
          _timer = null;
        }
        Wakelock.disable();
      }
    });

    try{
      await controller!.initialize();
      //await controllerBack!.initialize();
    }catch(e){
      print(e);
    }


    if (!mounted) {
      return;
    }
    setState(() {});
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Container(
                color: Colors.black,
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  title: streaming
                      ? ElevatedButton(
                          onPressed: () => onStopButtonPressed(),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.videocam_off),
                              SizedBox(width: 10),
                              Text(
                                'End Stream',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => onVideoStreamingButtonPressed(),
                          style: ButtonStyle( backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.videocam),
                              SizedBox(width: 10),
                              Text(
                                'Start Stream',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: IconButton(
                        color: Theme.of(context).primaryColor,
                        icon: const Icon(Icons.mic),
                        tooltip: 'Mute',
                        onPressed: () async {
                          await mute();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: IconButton(
                        color: Theme.of(context).primaryColor,
                        icon: const Icon(Icons.switch_video),
                        tooltip: 'Switch Camera',
                        onPressed: () async {
                          await toggleCameraDirection();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if(cameraDirection == 'front' ){
      if (controller == null || !controller!.value.isInitialized) {
        return const Text(
          'Tap a camera',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        );
      } else {
        return AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: CameraPreview(controller!),
        );
      }
    }else{
      if (controllerBack == null || !controllerBack!.value.isInitialized) {
        return const Text(
          'Tap a camera',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        );
      } else {
        return AspectRatio(
          aspectRatio: controllerBack!.value.aspectRatio,
          child: CameraPreview(controllerBack!),
        );
      }
    }

  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  mute() async {
    enableAudio = !enableAudio;
    cameraDirection == 'front'  ? await controller!.audio(enableAudio) : await controllerBack!.audio(enableAudio);
    print('mute');
  }
  toggleCameraDirection() async {
/*    if(cameraDirection == 'front'){
      cameraDirection = 'back';
      if(streaming && !controller!.value.isStreamingVideoRtmp) onVideoStreamingButtonPressed();
    } else{
      cameraDirection = 'front';
      if(streaming && !controllerBack!.value.isStreamingVideoRtmp) onVideoStreamingButtonPressed();
    }*/
     await controller!.switchCamera();
  }

  onNewCameraSelected(CameraDescription? cameraDescription) async {
    if (controller != null) {
      //if(streaming) controller!.pauseVideoStreaming();
      await controller!.dispose();
    }
    if (cameraDescription == null) {
      print('cameraDescription is null');
    }
    controller = CameraController(
      cameraDescription ?? cameras.first,
      ResolutionPreset.high,
      enableAudio: enableAudio,
      androidUseOpenGL: useOpenGL,
    );

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        print('Camera error ${controller!.value.errorDescription}');
        showInSnackBar('Camera error ${controller!.value.errorDescription}');
        if (_timer != null) {
          _timer!.cancel();
          _timer = null;
        }
        Wakelock.disable();
      }
    });

    try {
      await controller!.initialize();

      if(streaming) onVideoStreamingButtonPressed();
      //if(streaming) await controller!.resumeVideoStreaming();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onVideoStreamingButtonPressed() {
    startVideoStreaming().then((url) {
      if (mounted) {
        setState(() {
          streaming = true;
        });
      }
      if (url?.isNotEmpty ?? false) showInSnackBar('Streaming video to $url');
      Wakelock.enable();
    });
  }

  void onStopButtonPressed() {
    stopVideoStreaming().then((_) {
      if (mounted) {
        setState(() {
          streaming = false;
        });
      }
      showInSnackBar('Streaming to: $url');
    });
    Wakelock.disable();
  }

  void onPauseStreamingButtonPressed() {
    pauseVideoStreaming().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Streaming paused');
    });
  }

  void onResumeStreamingButtonPressed() {
    resumeVideoStreaming().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Streaming resumed');
    });
  }

  Future<String?> startVideoStreaming() async {
    if (!controller!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    // Open up a dialog for the url
    String myUrl = streamURL;

    try {
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
      url = myUrl;
      cameraDirection == 'front'  ? await controller!.startVideoStreaming(url!, androidUseOpenGL: true) :
        await controllerBack!.startVideoStreaming(url!, androidUseOpenGL: true);
      // _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      //   var stats = await controller!.getStreamStatistics();
      //   print(stats);
      // });
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return url;
  }

  Future<void> stopVideoStreaming() async {
    try {
      //if(controller!.value.isStreamingVideoRtmp){
        await controller!.stopVideoStreaming();
        if (_timer != null) {
          _timer!.cancel();
          _timer = null;
        }
      //}
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<void> pauseVideoStreaming() async {
    if (!controller!.value.isStreamingVideoRtmp) {
      return;
    }

    try {
      await controller!.pauseVideoStreaming();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoStreaming() async {
    try {
      await controller!.resumeVideoStreaming();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class CameraApp extends StatelessWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraExampleHome(),
    );
  }
}
