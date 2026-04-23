import 'package:flutter/material.dart';

abstract final class AppShadows {
  AppShadows._();

  /// No shadow — flat, tonal surface (elevation 0).
  static const List<BoxShadow> none = [];

  /// Minimal shadow — barely lifted surfaces (elevation 1).
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Card shadow — clearly elevated content (elevation 2–3).
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevated shadow — significantly raised surface (elevation 6–8).
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Modal shadow — overlay surfaces, dialogs, bottom sheets (elevation 12+).
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x29000000), // 16% black
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}
