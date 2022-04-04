import 'package:flutter/material.dart';
import 'package:video_stream/src/Flutter_rtmp.dart';
import 'package:wakelock/wakelock.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RtmpManager? _manager;
  bool isStreaming = false;
  String? streamUrl;

  @override
  void initState() {
    super.initState();
    _manager = RtmpManager();
    streamUrl = "rtmp://qa-livecommerce.cliqx.com.br:1935/live/00d235c4ccb54d38b2d365a6e35a5b9e";
    Wakelock.enable();
  }

  @override
  void dispose() {
    super.dispose();
    _manager!.dispose();
    setState(() {
      isStreaming = false;
    });
    Wakelock.disable();
  }



  startVideoStream() async {
    print('startVideoStream');
    await _manager!.startLive(streamUrl!);
    setState(() {
      isStreaming = true;
    });
  }

  // 停止直播
  stopVideoStream() async {
    print('stopVideoStream');
    await _manager!.stopLive();
    setState(() {
      isStreaming = false;
    });
  }

  switchVideoCamera() async {
    print('switchVideoCamera');
    await _manager!.switchCamera();
  }

  mute() async {
    print('mute');
    await _manager!.mute();
  }

  @override
  Widget build(Object context) {
    // TODO: implement build
    return Scaffold(
        body: Center(
      child: SafeArea(
        child: Stack(
          // fit: StackFit.expand,
          children: <Widget>[
            RtmpView(
              manager: _manager!,
            ),
            this.buttonArea()
          ],
        ),
      ),
    ));
  }

  Widget buttonArea() {
    return Container(
      // alignment: Alignment(0, 0),
      child: Wrap(
        spacing: 20,
        // runSpacing: 20,
        children: <Widget>[
          this.switchCameraWidget(),
        ],
      ),
    );
  }

  Widget switchCameraWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: (80),
          right: (35),
          left: (40)),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        // verticalDirection: VerticalDirection.up,
        children: <Widget>[
          Container(
            child: GestureDetector(
              child: Icon(Icons.stop_rounded, size: 60,),
              onTap: () => {stopVideoStream()},
            ),
            width: (60),
          ),
          Container(
            child: GestureDetector(
              child: Icon(Icons.not_started, size: 60,),
              onTap: () => {startVideoStream()},
            ),
            width: (60),
          ),
          Container(
            child: GestureDetector(
              child: Icon(Icons.camera, size: 60,),
              onTap: () => {switchVideoCamera()},
            ),
            width: (60),
            // on
          ),
          Container(
            child: GestureDetector(
              child: Icon(Icons.mic, size: 60,),
              onTap: () => {mute()},
            ),
            width: (60),
          ),
        ],
      ),
    );
  }

}
