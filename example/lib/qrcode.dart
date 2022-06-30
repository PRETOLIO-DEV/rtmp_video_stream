
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


import '../config.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'component/custom_button.dart';
import 'component/custom_container.dart';
import 'controllers/qrcode.dart';
import 'models/qrcode_model.dart';



class QRcodeScreen extends StatefulWidget {
  const QRcodeScreen({Key? key}) : super(key: key);

  @override
  State<QRcodeScreen> createState() => _QRcodeState();
}

class _QRcodeState extends State<QRcodeScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool flashOn = false;
  bool camFrontOn = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: w,
            height: h,
            color: Colors.black,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                //cutOutSize: scanArea
              ),
            ),
          ),

        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: CustomContainer(
          extend: false, ispadding: false,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                    color: flashOn ? Config.colorPri[50]! : Colors.transparent,
                    extend: false, ispadding: false,
                    func: () async {
                      try {
                        await controller?.toggleFlash();
                        setState(() {
                          flashOn = !flashOn;
                        });
                      } on Exception catch (e) {
                        print(e);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                      child: SvgPicture.asset('assets/svg/Flash.svg',
                        width: 30,
                        color: flashOn ? Config.colorPri : Colors.black,
                      ),
                    )
                ),
                SizedBox(width: 8,),
                CustomButton(
                    color: camFrontOn ? Config.colorPri[50]! : Colors.transparent,
                    extend: false, ispadding: false,
                    func: () async {
                      try {
                        await controller?.flipCamera();
                        setState(() {
                          camFrontOn = !camFrontOn;
                        });
                      } on Exception catch (e) {
                        print(e);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                      child: SvgPicture.asset('assets/svg/InvertCam.svg',
                        width: 30,
                        color: camFrontOn ? Config.colorPri : Colors.black,
                      ),
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isQrcode = false;
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if(!isQrcode){
        isQrcode = true;
        try{
          print("scan ${scanData.code}");
          QRCodeModel? _qrcode = await QRCode.getQRCode(scanData.code);
          Navigator.pop(context, _qrcode);
        }catch (e){
          isQrcode = false;
        }
      }
    });
  }
}