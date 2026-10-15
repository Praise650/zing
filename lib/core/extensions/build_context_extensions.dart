import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

extension ZingContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
