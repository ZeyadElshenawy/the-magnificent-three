import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:flutter_ml/UI_ux/Colors.dart';

class WindowButtons extends StatelessWidget {
  final bool darkMode;
  const WindowButtons({super.key, required this.darkMode});

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
      iconNormal: darkMode ? AppColors.lightTheme : AppColors.primaryColor,
      mouseOver: darkMode ? AppColors.lightTheme : AppColors.primaryColor,
      mouseDown: darkMode ? AppColors.lightTheme : AppColors.primaryColor,
      iconMouseOver: darkMode ? AppColors.primaryColor : AppColors.lightTheme,
      iconMouseDown: darkMode ? AppColors.primaryColor : AppColors.lightTheme,
      normal: darkMode ? AppColors.primaryColor : AppColors.lightTheme,
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: darkMode ? AppColors.lightTheme : AppColors.primaryColor,
      mouseOver: Colors.red,
      mouseDown: Colors.red.withOpacity(0.5),
      iconMouseOver: darkMode ? AppColors.lightTheme : AppColors.primaryColor,
      iconMouseDown: darkMode ? AppColors.lightTheme : AppColors.primaryColor,
      normal: darkMode ? AppColors.primaryColor : AppColors.lightTheme,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
