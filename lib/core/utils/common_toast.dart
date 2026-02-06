import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


void showToast(
    String message, {
      Color? backgroundColor,
      Color? textColor,
    }) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: backgroundColor ?? Colors.black,
    textColor: textColor ?? Colors.white,
    fontSize: 14.0,
  );
}