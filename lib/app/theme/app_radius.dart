import 'package:flutter/widgets.dart';

/// Corner radius tokens.
abstract final class AppRadius {
  static const double chip = 8;
  static const double small = 12;
  static const double button = 14;
  static const double tile = 16;
  static const double card = 20;
  static const double sheet = 28;

  static BorderRadius get chipAll => BorderRadius.circular(chip);
  static BorderRadius get smallAll => BorderRadius.circular(small);
  static BorderRadius get buttonAll => BorderRadius.circular(button);
  static BorderRadius get tileAll => BorderRadius.circular(tile);
  static BorderRadius get cardAll => BorderRadius.circular(card);
  static BorderRadius get sheetAll => BorderRadius.circular(sheet);
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
