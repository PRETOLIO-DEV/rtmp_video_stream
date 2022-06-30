

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_container.dart';

Widget CustomButton({required Widget child, required VoidCallback? func,
  required Color color, bool extend = true, bool ispadding = true, GlobalKey? key }){
  return TextButton(
    key: key,
    onPressed: func,
    style:  ButtonStyle(
      padding:  MaterialStateProperty.resolveWith((state) => EdgeInsets.all(2)),
      minimumSize: MaterialStateProperty.resolveWith((state) => Size.zero),
    ),
    child: CustomContainer(
      color: color,
      extend: extend,
      ispadding: ispadding,
      child: child,
    ),
  );
}

