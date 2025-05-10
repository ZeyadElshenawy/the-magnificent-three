import 'package:flutter/material.dart';
import 'package:project_model_ai/UI_UX/Colors.dart';

class SplashScreen extends StatefulWidget {
  final bool darkMode;
  const SplashScreen({super.key, required this.darkMode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.darkMode ? AppColors.primaryColor : AppColors.lightTheme,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.assistant,
                size: 100,
                color: widget.darkMode
                    ? AppColors.lightTheme
                    : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: Text(
                'Project Model AI',
                style: TextStyle(
                  fontSize: 28,
                  color: widget.darkMode
                      ? AppColors.lightTheme
                      : AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: Text(
                'Your AI Assistant',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.darkMode
                      ? AppColors.lightTheme
                      : AppColors.primaryColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
