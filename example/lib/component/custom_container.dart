

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget CustomContainer({required Widget child, required Color color, bool extend = true, bool ispadding = true, GlobalKey? key}){
  return Container(
    key: key,
    padding: ispadding ? EdgeInsets.symmetric(vertical: 16) : null,
    decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(8))
    ),
    alignment: extend ? Alignment.center : null,
    child: child,
  );
}