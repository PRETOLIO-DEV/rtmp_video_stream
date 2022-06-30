import 'package:flutter/material.dart';

import '../component/snakbar.dart';
import '../models/qrcode_model.dart';
import '../services/http/http_cliente.dart';

//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';



class QRCode {
  static bool isProd = true;
  static String? barcodeScanRes;
  static Future<QRCodeModel?> scanQR(BuildContext context) async {
    try {
      //barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
    } catch(e) {
      print('catch scanBarcode ' + e.toString());
      barcodeScanRes = null;
    }
    QRCodeModel? retur;
    //bool _validURL = Uri.parse(barcodeScanRes ?? '').isAbsolute;
    if (barcodeScanRes != null && barcodeScanRes != '-1' && barcodeScanRes != '') {
      try{
        retur = await getQRCode(barcodeScanRes ?? '');
      }catch(e){
        print('catch scanQR  ' + e.toString());
        showInSnackBar(e.toString());
      }
    }
    return retur;
  }

  static Future<QRCodeModel?> getQRCode(String? url) async {
    try {
      isProd = url?.characters.take(47).toString() == 'https://livecommerce-pernambucanas.cliqx.com.br';
    } catch (e) {
      isProd = false;
    }
    try{
      Map result = await HttpCli().get(url: url);
      if (result.containsKey('id')) {
        QRCodeModel qr = QRCodeModel.froMap(result);
        return qr;
      }
      throw '200';
    }catch (e){
      if(e.toString() == '200'){
        throw 'Qrcode invalido, tente novamente!';
      }else if(e == 'Sem conexão'){
        throw 'Sem conexão com intenet, verifique sua conexão e tente novamente!';
      }else{
      throw 'Não foi possivel ler o qrcode, tente novamente!';
      }
    }
  }

}