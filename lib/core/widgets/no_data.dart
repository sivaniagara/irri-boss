import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

Widget get noDataNew => Center(
  child: Lottie.asset(
    "assets/lottie/No_data_current.json",
    width: 250,
    height: 250,
    fit: BoxFit.contain,
  ),
);
