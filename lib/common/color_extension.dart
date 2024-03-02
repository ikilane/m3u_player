import 'package:flutter/material.dart';

class TColor {
  static bool tModeDark = true;
  static Color get primary1 => const Color(0xffF9A61E);
  static Color get primary2 => const Color(0xffDC8E27);
  static List<Color> get primaryG => [primary1, primary2];

  static Color get bgLight => const Color(0xfff5f5f5);
  static Color get bgDark => const Color(0xff000000);
  static Color get bg => tModeDark ? bgDark : bgLight;

  static Color get cardLight => const Color(0xffffffff);
  static Color get cardDark => const Color(0xff212121);
  static Color get card => tModeDark ? cardDark : cardLight;

  static Color get tabBgLight => const Color(0xffffffff);
  static Color get tabBgDark => const Color(0xff1A1A1A);
  static Color get tabBg => tModeDark ? tabBgDark : tabBgLight;

  static Color get textLight => const Color(0xff191919);
  static Color get textDark => const Color(0xffffffff);
  static Color get text => tModeDark ? textDark : textLight;

  static Color get btnText => tModeDark ? bgDark : bgLight;

  static Color get textOpacity => (text).withOpacity(0.6);

  static Color get subtextLight => const Color(0xff282828);
  static Color get subtextDark => const Color(0xffa2a2a2);
  static Color get subtext => tModeDark ? subtextDark : subtextLight;
}
