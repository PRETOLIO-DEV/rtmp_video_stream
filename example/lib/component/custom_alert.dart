
import 'package:flutter/material.dart';


import '../config.dart';
import 'custom_button.dart';



CustomAlert(BuildContext context, {String? title, required String subtitle,
    String? body, required VoidCallback confirm, required String textConfirm,
    String? textCancel, VoidCallback? cancel, bool quit = true}) async {

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Column(
        children: [
          Container(
            alignment: Alignment.topRight,
            child: IconButton(onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.clear, color: Config.colorBlack,)
            ),
          ) ,
          Container(
            padding: const EdgeInsets.only(left: 30, right: 30,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(title != null)
                  Text(title, textAlign: TextAlign.center,
                    style: TextStyle(color: Config.colorPri, fontWeight: FontWeight.bold, fontSize: 36),),
                if(title == null)
                  SizedBox(height: 15,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 65,
                  child: Text(subtitle, textAlign: TextAlign.center, maxLines: 2,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
                ),
              ],
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 30),
      insetPadding: EdgeInsets.symmetric(horizontal: 20) ,
      titlePadding:  EdgeInsets.all(5),
      actionsPadding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(body != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(body, style: TextStyle(fontSize: 14, color: Config.colorBlack[500]),),
            ),
          SizedBox(height: body != null ? 30 : 18,)
        ],
      ),
      actions: <Widget>[
        Container(
            width: textCancel != null ? 110 : null,
            child: CustomButton(
              color: textCancel != null ?  Colors.white : Config.colorSec,
              func: () async {
                if(quit) Navigator.pop(context);
                confirm();
              },
              child: textCancel != null ? Text(textConfirm, style: TextStyle(color: Config.colorSec),) :
                Center(child: Text(textConfirm, style: TextStyle(color: Colors.white),)),
            )
        ),
        if(textCancel != null)
          Container(
              width: 110,
              child: CustomButton(
                color: Colors.red,
                func: () async {
                  if(quit) Navigator.pop(context);
                  cancel!();
                },
                child: Text(textCancel, style: TextStyle(color: Colors.white),),
              )
          ),
      ],
    ),
  );
}