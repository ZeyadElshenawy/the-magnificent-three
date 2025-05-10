import 'package:flutter/material.dart';
import 'package:project_model_ai/UI_UX/Colors.dart';

class Regression extends StatefulWidget {
  final bool darkMode;
  const Regression({super.key, required this.darkMode});

  @override
  State<Regression> createState() => _RegressionState();
}

class _RegressionState extends State<Regression> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.darkMode ? AppColors.primaryColor : AppColors.lightTheme,
      body: Center(
        child: Text(
          'Regression',
          style: TextStyle(
            fontSize: 24,
            color:
                widget.darkMode ? AppColors.lightTheme : AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
