import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ml/UI_UX/Colors.dart';
import 'package:flutter_ml/UI_UX/window_buttons.dart';

class WindowControlsWidget extends StatelessWidget {
  final bool isDarkMode;

  const WindowControlsWidget({
    super.key,
    this.isDarkMode = false,
  });

  Widget _buildTitleBar() {
    return Container(
      color: isDarkMode ? AppColors.primaryColor : AppColors.lightTheme,
    );
  }

  Widget _buildWindowControls() {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Expanded(
            child: MoveWindow(
              child: _buildTitleBar(),
            ),
          ),
          WindowButtons(
            darkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildWindowControls();
  }
}
