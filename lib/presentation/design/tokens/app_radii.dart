import 'package:flutter/material.dart';

class AppRadii {
  AppRadii._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;

  static const BorderRadius all4 = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius all8 = BorderRadius.all(Radius.circular(md));
  static const BorderRadius all12 = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
