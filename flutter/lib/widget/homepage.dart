import 'package:flutter/material.dart';
import 'package:project_model_ai/UI_ux/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Homepage extends StatefulWidget {
  final bool darkMode;
  final int monthlyOpens;
  const Homepage(
      {super.key, required this.darkMode, required this.monthlyOpens});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _userName = 'Guest';
  int _totalPredictions = 0;
  double _successRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadPredictionStats();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName')?.trim().isEmpty ?? true
          ? 'Guest'
          : prefs.getString('userName') ?? 'Guest';
    });
  }

  Future<void> _loadPredictionStats() async {
    final prefs = await SharedPreferences.getInstance();

    // Load regression history
    final regressionJson = prefs.getStringList('prediction_history') ?? [];
    final regressionHistory = regressionJson
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    // Load classification history
    final classificationJson =
        prefs.getStringList('classification_history') ?? [];
    final classificationHistory = classificationJson
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    // Calculate total predictions and success rate
    final totalPredictions =
        regressionHistory.length + classificationHistory.length;
    final successfulPredictions =
        regressionHistory.where((item) => !item['isError']).length +
            classificationHistory.where((item) => !item['isError']).length;

    setState(() {
      _totalPredictions = totalPredictions;
      _successRate = totalPredictions > 0
          ? (successfulPredictions / totalPredictions) * 100
          : 0.0;
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color cardColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const Spacer(),
              Icon(icon, color: Colors.white.withOpacity(0.2), size: 48),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ',
                style: TextStyle(
                  fontSize: 32,
                  color: widget.darkMode
                      ? AppColors.lightTheme
                      : AppColors.primaryColor,
                ),
              ),
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 32,
                  color: widget.darkMode
                      ? AppColors.lightTheme
                      : AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Monthly Opens',
                  value: widget.monthlyOpens.toString(),
                  cardColor: const Color(0xFF1E88E5),
                  icon: Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  title: 'Completed',
                  value: _totalPredictions.toString(),
                  cardColor: const Color(0xFF43A047),
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  title: 'Success Rate',
                  value: '${_successRate.toStringAsFixed(1)}%',
                  cardColor: const Color(0xFF8D6E63),
                  icon: Icons.analytics,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.darkMode ? AppColors.primaryColor : AppColors.lightTheme,
      body: SingleChildScrollView(
        child: _buildCurrentView(),
      ),
    );
  }
}
