import 'package:flutter/material.dart';
import 'wasel_colors.dart';

class WaselTextStyles {
  WaselTextStyles._();

  static const title = TextStyle(
    color: WaselColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const heading = TextStyle(
    color: WaselColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    color: WaselColors.textPrimary,
    fontSize: 16,
  );

  static const secondary = TextStyle(
    color: WaselColors.textSecondary,
    fontSize: 14,
  );

  static const button = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}
