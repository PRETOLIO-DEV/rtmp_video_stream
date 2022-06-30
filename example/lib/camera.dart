import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_stream/live.dart';
import 'package:wakelock/wakelock.dart';

import '../config.dart';
import '../controllers/livecam.dart';
import '../models/qrcode_model.dart';
import '../component/custom_alert.dart';
import '../component/custom_button.dart';
import '../component/custom_container.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {

    Future.delayed(Duration(milliseconds: 400),(){
      context.read<LiveCam>().init(context);
    });

    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    LiveCam.controller.dispose();
    Wakelock.disable();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Consumer<LiveCam>(
        builder: (_, cam, __) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: true,
            extendBody: true,
            key: LiveCam.scaffoldKeyCam,
            body: Container(
              color: Colors.black,
              constraints: BoxConstraints.expand(),
              child: Center(
                child: _cameraPreviewWidget(cam),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(5),
              child: Menus(cam),
            ),
          );
        }
      ),
    );
  }


  Widget Menus(LiveCam cam){
    double w = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
            key: _key,
            height: 110,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: CustomContainer(
              color: Colors.white,
                ispadding: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(width: 5,),
                        CustomButton(
                            color: cam.streaming ? Colors.transparent :  Config.colorPri[50]!,
                            extend: false, ispadding: false,
                            func: cam.streaming ? null : () async {
                              cam.load = true;
                              await cam.disposeCam();
                              await Future.delayed(Duration(milliseconds: 400));
                              cam.qrCode = await Navigator.pushNamed(context, '/qrcode')  as QRCodeModel?;
                              cam.load = false;
                            },
                            child: Container(
                                width: 55,
                                height: 55,
                                child: Icon(CupertinoIcons.qrcode,
                                  size: 30,
                                  color: cam.streaming ? Config.colorBlack[600] : Config.colorPri,)
                            )
                        ),
                        CustomButton(
                            key: cam.keyMenuResolution,
                            extend: false, ispadding: false,
                            child: Container(
                                width: 55,
                                height: 55,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.settings_outlined,
                                        size: 33,
                                        color: cam.streaming ? Config.colorBlack[600] : Config.colorPri
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: CustomContainer(
                                          extend: false, ispadding: false,
                                          color: cam.streaming ? Config.colorBlack[600]! : Colors.red,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(cam.resolutionString(cam.resolution),
                                              style: TextStyle(color: Colors.white, fontSize: 10),),
                                          )
                                      ),
                                    ),
                                  ],
                                )
                            ),
                            func: cam.streaming ? null : () async => alertResolution(cam),
                            color: cam.streaming ? Colors.transparent :  Config.colorPri[50]!,
                        ),

                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                            color: cam.enableAudio ? Colors.transparent : Config.colorPri[50]!,
                            extend: false, ispadding: false,
                            func: cam.buttomOn ? null : () async => await cam.muteVideo(),
                            child:  Container(
                              width: 55,
                              height: 55,
                              child: cam.enableAudio ?
                                Icon(CupertinoIcons.mic, size: 30, color: Config.colorBlack) :
                                Icon(CupertinoIcons.mic_off, size: 30, color: Config.colorPri),
                            )
                        ),
                        CustomButton(
                            color: cam.camFront ? Config.colorPri[50]! : Colors.transparent,
                            extend: false, ispadding: false,
                            func: cam.buttomOn ? null : () async => await cam.toggleCameraDirection(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                              child: SvgPicture.asset('assets/svg/InvertCam.svg',
                                  width: 30,
                                color: cam.camFront ? Config.colorPri : Colors.black,
                              ),
                            )
                        ),
                        SizedBox(width: 5,)
                      ],
                    ),
                  ),
                ],
            )
         ),
        ),


        if(cam.streaming)
          SafeArea(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 50 + MediaQuery.of(context).padding.top),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 25,
                        width: 90,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15))
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(4),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red
                              ),
                              height: 15,
                              width: 15,
                            ),
                            SizedBox(width: 3,),
                            Text(cam.timeLive, style: TextStyle(color: Config.colorGrey),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


        /*Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: CustomButton(
            color: cam.streaming ? Colors.red : Config.colorSec,
            extend: false,
            child: Container(
              width: w / 3.7,
              child: cam.streaming ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stop, color: Colors.white,),
                    Text('Finalizar',
                    style: TextStyle(color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.bold),)
                ],) :
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_outlined, color: Colors.white,),
                    Text('Iniciar',
                      style: TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.bold),)
                ],),
            ),
            func: cam.buttomOn ? null : () => cam.funcStartStopLive(context),
          ),
        ),*/

        Container(
          width: w / 3.5,
          padding: const EdgeInsets.only(bottom: 60),
          child: cam.streaming ?
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                cam.isPause ?
                CustomButton(
                  color: Config.colorSec,
                  extend: false, ispadding: false,
                  child: Padding(
                    padding: const EdgeInsets.all( 7.5),
                    child: Icon(Icons.play_arrow_outlined, color: Colors.white, size: 35,),
                  ),
                  func: cam.buttomOn ? null : () async => cam.pauseLive(),
                ) : CustomButton(
                  color: Config.colorSec,
                  extend: false, ispadding: false,
                  child: Padding(
                    padding: const EdgeInsets.all( 10),
                    child: Icon(Icons.pause, color: Colors.white, size: 30,),
                  ),
                  func: cam.buttomOn ? null : () async {
                    bool _result = await cam.pauseLive();
                    if(_result){
                      CustomAlert(
                        context, title: 'Pausa!',
                        subtitle: 'Sua live está em intervalo neste momento.',
                        body: 'Você colocou a live em pausa, para voltar com a transmissão clique no botão abaixo ou no botão play junto da barra de ferramentas',
                        textConfirm: 'Voltar para Live',
                        confirm: () async {
                          await cam.resumeLive();
                        },
                      );
                    }
                  },
                ),
                CustomButton(
                  color: Colors.red,
                  extend: false, ispadding: false,
                  child: Padding(
                    padding: const EdgeInsets.all(7.5),
                    child: Icon(Icons.stop_outlined, color: Colors.white, size: 35,),
                  ),
                  func: cam.buttomOn ? null : ()  => cam.funcStartStopLive(context),
                ),
              ],
            ),
          ) :
          CustomButton(
              color: cam.streaming ? Colors.red : Config.colorSec,
              extend: false,
              child: Container(
                width: w / 4,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_outlined, color: Colors.white,),
                      Text('Iniciar',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),)
                    ],
                  ),
              ),
              func: cam.buttomOn ? null : () => cam.funcStartStopLive(context),
          )
        ),


      ],
    );
  }

  alertResolution(LiveCam cam){
    RenderBox _box = cam.keyMenuResolution.currentContext!.findRenderObject() as RenderBox;
    Offset offset = _box.localToGlobal(Offset.zero);
    double h = MediaQuery.of(context).size.height;

    return showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (context){
          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Card(
                margin: EdgeInsets.only(left: 2 + offset.dx, bottom: h - offset.dy - 6),
                color: Config.colorPri[50],
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                              extend: false, ispadding: false,
                              color: cam.resolution == ResolutionPreset.max ?
                              Config.colorPri : Colors.white,
                              child: Container(
                                width: 90, height: 50, alignment: Alignment.center,
                                child: Text("Max" ,
                                  style: TextStyle(fontSize: 16,
                                      color: cam.resolution == ResolutionPreset.max ?
                                      Colors.white : Config.colorBlack[600]),),
                              ),
                              func: () => alterResolution(context, cam, ResolutionPreset.max)
                          ),
                          SizedBox(width: 10,),
                          CustomButton(
                              extend: false, ispadding: false,
                              color: cam.resolution == ResolutionPreset.ultraHigh ?
                              Config.colorPri : Colors.white,
                              child: Container(
                                width: 90, height: 50, alignment: Alignment.center,
                                child: Text("2160p" ,
                                  style: TextStyle(fontSize: 16,
                                      color: cam.resolution == ResolutionPreset.ultraHigh ?
                                      Colors.white : Config.colorBlack[600]),),
                              ),
                              func: () => alterResolution(context, cam, ResolutionPreset.ultraHigh)
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                              extend: false, ispadding: false,
                              color: cam.resolution == ResolutionPreset.veryHigh ?
                              Config.colorPri : Colors.white,
                              child: Container(
                                width: 90, height: 50, alignment: Alignment.center,
                                child: Text("1080p" ,
                                  style: TextStyle(fontSize: 16,
                                      color: cam.resolution == ResolutionPreset.veryHigh ?
                                      Colors.white : Config.colorBlack[600]),),
                              ),
                              func: () => alterResolution(context, cam, ResolutionPreset.veryHigh)
                          ),
                          SizedBox(width: 10,),
                          CustomButton(
                              extend: false, ispadding: false,
                              color: cam.resolution == ResolutionPreset.high ?
                              Config.colorPri : Colors.white,
                              child: Container(
                                width: 90, height: 50, alignment: Alignment.center,
                                child: Text("720p" ,
                                  style: TextStyle(fontSize: 16,
                                      color: cam.resolution == ResolutionPreset.high ?
                                      Colors.white : Config.colorBlack[600]),),
                              ),
                              func: () => alterResolution(context, cam, ResolutionPreset.high)
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                              extend: false, ispadding: false,
                              color: cam.resolution == ResolutionPreset.medium ?
                              Config.colorPri : Colors.white,
                              child: Container(
                                width: 90, height: 50, alignment: Alignment.center,
                                child: Text("480p" ,
                                  style: TextStyle(fontSize: 16,
                                      color: cam.resolution == ResolutionPreset.medium ?
                                      Colors.white : Config.colorBlack[600]),),
                              ),
                              func: () => alterResolution(context, cam, ResolutionPreset.medium)
                          ),
                          SizedBox(width: 10,),
                          CustomButton(
                              extend: false, ispadding: false,
                              color: cam.resolution == ResolutionPreset.low ?
                              Config.colorPri : Colors.white,
                              child: Container(
                                width: 90, height: 50, alignment: Alignment.center,
                                child: Text("240p" ,
                                  style: TextStyle(fontSize: 16,
                                      color: cam.resolution == ResolutionPreset.low ?
                                      Colors.white : Config.colorBlack[600]),),
                              ),
                              func: () => alterResolution(context, cam, ResolutionPreset.low)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }
    );
  }


  Widget _cameraPreviewWidget(LiveCam cam) {
    if(cam.qrCode == null){
      if (cam.load) {
        return const CircularProgressIndicator();
      } else{
        return Text('Leia o QR Code para iniciar a live!',
          style: TextStyle(color: Colors.white),);
      }
    } else {
      return LiveCam.controller.screem();
    }
  }

  alterResolution(BuildContext context, LiveCam cam, ResolutionPreset preset) async {
    await cam.alterResolution(preset);
    Navigator.pop(context);
  }

  Future<bool> _onBackPressed() async {
    bool result = false;
    await CustomAlert(
      context,
      subtitle: 'Tem certeza que deseja\nsair do aplicativo?',
      textConfirm: 'Voltar',
      textCancel: 'Sair',
      confirm: (){
        result = false;
      },
      cancel: (){
        result = true;
      },
    );
    return result;
  }

}
