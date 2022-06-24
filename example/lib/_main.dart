import 'dart:async';

import 'package:example/widget/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:video_stream/Live.dart';
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

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  LiveControler controler = LiveControler(config: LiveConfig(
      resolutionPreset: ResolutionPreset.medium, cameras: cameras?.last));
  ResolutionPreset resolution = ResolutionPreset.medium;

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

    controler.listenerAndroid(() {
      if (mounted) setState(() {});
      if (controler.getAndroidValues?.hasError ?? false) {
        print('Camera error ${controler.getAndroidValues?.errorDescription}');
        showInSnackBar('Camera error ${controler.getAndroidValues?.errorDescription}');
        if (_timer != null) {
          _timer!.cancel();
          _timer = null;
        }
        Wakelock.disable();
      }
    });

    try{
      await controler.initialize();
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
                child: Column(
                  children: [
                    AppBar(
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
                                    'Start',
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
                            icon: const Icon(Icons.high_quality_outlined),
                            tooltip: 'Resolucao',
                            onPressed: () async {
                              await CustomBottomSheet(context,
                                  Container(
                                    height: 200,
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    child:  DropdownButton<ResolutionPreset>(
                                        value: resolution,
                                        itemHeight: 50,
                                        underline: Container(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            resolution = newValue!;
                                          });
                                        },
                                        items: ResolutionPreset.values.map((ResolutionPreset classType) {
                                          return DropdownMenuItem<ResolutionPreset>(
                                              value: classType,
                                              child: Container(
                                                padding: EdgeInsets.only(left: 20, top: 5),
                                                child: Text(classType.toString().replaceAll('ConfigBackup.', ''),
                                                  style: TextStyle(fontSize: 20, color: Colors.black,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ));
                                        }).toList()
                                    ),
                                  ), false);
                              await alterResolution();
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

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: IconButton(
                              color: Theme.of(context).primaryColor,
                              icon: const Icon(Icons.not_started_outlined),
                              tooltip: 'resume',
                              onPressed: () async {
                                await resume();
                              },

                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: IconButton(
                              color: Theme.of(context).primaryColor,
                              icon: const Icon(Icons.pause),
                              tooltip: 'pause',
                              onPressed: () async {
                                await pause();
                              },
                            ),
                          ),
                        ],
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
      if (!LiveControler.isInitialize) {
        return const Text(
          'Tap a camera',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        );
      } else {
        return controler.screem();
      }
    }else{
      if (!LiveControler.isInitialize) {
        return const Text(
          'Tap a camera',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        );
      } else {
        return controler.screem();
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
    await controler.mute(enableAudio);
  }

  alterResolution() async {
    await controler.alterResolution(LiveConfig(
        resolutionPreset: resolution, cameras: cameras?.last));
    setState(() {});
  }

  resume() async {
     await controler.resume();
  }

  pause() async {
    await controler.pause();
  }


  toggleCameraDirection() async {
    await controler.switchCamera();
  }


  onNewCameraSelected(CameraDescription? cameraDescription) async {
    await controler.dispose();
    if (cameraDescription == null) {
      print('cameraDescription is null');
    }
    controler = LiveControler(config: LiveConfig(
        resolutionPreset: ResolutionPreset.medium, cameras: cameraDescription));

    // If the controller is updated then update the UI.
    controler.listenerAndroid(() {
      if (mounted) setState(() {});
      if (controler.getAndroidValues?.hasError ?? false) {
        print('Camera error ${controler.getAndroidValues?.errorDescription}');
        showInSnackBar('Camera error ${controler.getAndroidValues?.errorDescription}');
        if (_timer != null) {
          _timer!.cancel();
          _timer = null;
        }
        Wakelock.disable();
      }
    });

    try {
      await controler.initialize();

      if(streaming) onVideoStreamingButtonPressed();
      //if(streaming) await controller!.resumeVideoStreaming();
    } on Exception catch (e) {
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
    if (!(controler.getAndroidValues?.isInitialized ?? false)) {
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
      await controler.start(url!);
      // _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      //   var stats = await controller!.getStreamStatistics();
      //   print(stats);
      // });
    } on Exception catch (e) {
      _showCameraException(e);
      return null;
    }
    return url;
  }

  Future<void> stopVideoStreaming() async {
    try {
      //if(controller!.value.isStreamingVideoRtmp){
        await controler.stop();
        if (_timer != null) {
          _timer!.cancel();
          _timer = null;
        }
      //}
    } on Exception catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<void> pauseVideoStreaming() async {
    if (!(controler.getAndroidValues?.isStreamingVideoRtmp ?? false)) {
      return;
    }

    try {
      await controler.pause();
    } on Exception catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoStreaming() async {
    try {
      await controler.resume();
    } on Exception catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(Exception e) {
    logError(e.toString(), e.toString());
    showInSnackBar('Error: ${e.toString()}\n${e.toString()}');
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
