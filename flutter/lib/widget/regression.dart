import 'package:flutter/material.dart';
import 'package:project_model_ai/UI_UX/Colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Regression extends StatefulWidget {
  final bool darkMode;
  const Regression({super.key, required this.darkMode});

  @override
  State<Regression> createState() => _RegressionState();
}

class _RegressionState extends State<Regression> {
  bool _showRightBar = false;
  List<Map<String, dynamic>> _history = [];
  final int requiredFeatures = 8;
  final List<TextEditingController> _controllers = List.generate(
    8,
    (index) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('prediction_history') ?? [];
    setState(() {
      _history = historyJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('prediction_history', historyJson);
  }

  void _addToHistory(String message, bool isError) {
    final historyItem = {
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'isError': isError,
    };
    setState(() {
      _history.insert(0, historyItem); // Add to the beginning of the list
    });
    _saveHistory(); // Save after each update
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> sendRegressionData(List<double> features) async {
    if (features.length != requiredFeatures) {
      _addToHistory(
          'Error: Exactly $requiredFeatures features are required', true);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'features': features}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _addToHistory('Prediction: ${result['prediction']}', false);
        // Clear all text fields after successful prediction
        for (var controller in _controllers) {
          controller.clear();
        }
      } else {
        _addToHistory('Server Error: ${response.statusCode}', true);
      }
    } catch (e) {
      _addToHistory('Error: $e', true);
    }
  }

  List<double?> getFeatures() {
    return _controllers
        .map((controller) => double.tryParse(controller.text.trim()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> features = [
      {"label": "Pregnancies", "hint": "Number of pregnancies"},
      {"label": "Glucose", "hint": "Blood glucose level (mg/dL)"},
      {"label": "Blood Pressure", "hint": "Blood pressure (mm Hg)"},
      {"label": "Skin Thickness", "hint": "Thickness of skin fold (mm)"},
      {"label": "Insulin", "hint": "Insulin level (mu U/ml)"},
      {"label": "BMI", "hint": "Body Mass Index"},
      {
        "label": "Diabetes Pedigree Function",
        "hint": "Family history of diabetes"
      },
      {"label": "Age", "hint": "Age of the patient (in years)"},
    ];

    return Scaffold(
      backgroundColor:
          widget.darkMode ? AppColors.primaryColor : AppColors.lightTheme,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: widget.darkMode
                  ? AppColors.lightTheme
                  : AppColors.primaryColor,
            ),
            onPressed: () {
              setState(() {
                _showRightBar = !_showRightBar;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Diabetes Prediction',
                    style: TextStyle(
                      fontSize: 24,
                      color: widget.darkMode
                          ? AppColors.lightTheme
                          : AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Please enter patient information',
                    style: TextStyle(
                      color: widget.darkMode
                          ? AppColors.lightTheme
                          : AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: (requiredFeatures / 2).ceil(),
                      itemBuilder: (context, rowIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controllers[rowIndex * 2],
                                  decoration: InputDecoration(
                                    labelText: features[rowIndex * 2]["label"],
                                    hintText: features[rowIndex * 2]["hint"],
                                    labelStyle: TextStyle(
                                      color: widget.darkMode
                                          ? AppColors.lightTheme
                                              .withOpacity(0.9)
                                          : AppColors.primaryColor
                                              .withOpacity(0.9),
                                    ),
                                    hintStyle: TextStyle(
                                      color: widget.darkMode
                                          ? AppColors.lightTheme
                                              .withOpacity(0.5)
                                          : AppColors.primaryColor
                                              .withOpacity(0.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: widget.darkMode
                                        ? AppColors.lightTheme.withOpacity(0.1)
                                        : AppColors.primaryColor
                                            .withOpacity(0.1),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (rowIndex * 2 + 1 < requiredFeatures)
                                Expanded(
                                  child: TextField(
                                    controller: _controllers[rowIndex * 2 + 1],
                                    decoration: InputDecoration(
                                      labelText: features[rowIndex * 2 + 1]
                                          ["label"],
                                      hintText: features[rowIndex * 2 + 1]
                                          ["hint"],
                                      labelStyle: TextStyle(
                                        color: widget.darkMode
                                            ? AppColors.lightTheme
                                                .withOpacity(0.9)
                                            : AppColors.primaryColor
                                                .withOpacity(0.9),
                                      ),
                                      hintStyle: TextStyle(
                                        color: widget.darkMode
                                            ? AppColors.lightTheme
                                                .withOpacity(0.5)
                                            : AppColors.primaryColor
                                                .withOpacity(0.5),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: widget.darkMode
                                          ? AppColors.lightTheme
                                              .withOpacity(0.1)
                                          : AppColors.primaryColor
                                              .withOpacity(0.1),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.darkMode
                            ? AppColors.lightTheme
                            : AppColors.primaryColor,
                        foregroundColor: widget.darkMode
                            ? AppColors.primaryColor
                            : AppColors.lightTheme,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final features = getFeatures();
                        if (features.any((element) => element == null)) {
                          _addToHistory(
                              'Error: Please enter valid numbers for all features',
                              true);
                          return;
                        }
                        sendRegressionData(features.cast<double>());
                      },
                      child: const Text(
                        'Predict',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: _showRightBar ? 300 : 0,
              decoration: BoxDecoration(
                color: widget.darkMode
                    ? AppColors.primaryColor.withOpacity(0.5)
                    : AppColors.lightTheme.withOpacity(0.5),
                border: Border(
                  left: BorderSide(
                    color: widget.darkMode
                        ? AppColors.lightTheme.withOpacity(0.1)
                        : AppColors.primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: Offset(_showRightBar ? 0 : 1, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showRightBar ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: widget.darkMode
                                      ? AppColors.lightTheme
                                      : AppColors.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'History',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: widget.darkMode
                                        ? AppColors.lightTheme
                                        : AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: widget.darkMode
                                    ? AppColors.lightTheme
                                    : AppColors.primaryColor,
                              ),
                              onPressed: () async {
                                setState(() {
                                  _history.clear();
                                });
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('prediction_history');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _history.isEmpty
                              ? Center(
                                  child: Text(
                                    'No predictions yet',
                                    style: TextStyle(
                                      color: widget.darkMode
                                          ? AppColors.lightTheme
                                              .withOpacity(0.5)
                                          : AppColors.primaryColor
                                              .withOpacity(0.5),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _history.length,
                                  itemBuilder: (context, index) {
                                    final historyItem = _history[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: widget.darkMode
                                            ? AppColors.lightTheme
                                                .withOpacity(0.1)
                                            : AppColors.primaryColor
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.darkMode
                                                ? AppColors.lightTheme
                                                    .withOpacity(0.1)
                                                : AppColors.primaryColor
                                                    .withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      historyItem['isError']
                                                          ? Icons.error_outline
                                                          : Icons
                                                              .check_circle_outline,
                                                      color: widget.darkMode
                                                          ? historyItem[
                                                                  'isError']
                                                              ? Colors.red
                                                                  .withOpacity(
                                                                      0.8)
                                                              : Colors.green
                                                                  .withOpacity(
                                                                      0.8)
                                                          : historyItem[
                                                                  'isError']
                                                              ? Colors.red
                                                              : Colors.green,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        historyItem['message'],
                                                        style: TextStyle(
                                                          color: widget.darkMode
                                                              ? AppColors
                                                                  .lightTheme
                                                              : AppColors
                                                                  .primaryColor,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateTime.parse(historyItem[
                                                          'timestamp'])
                                                      .toString()
                                                      .substring(0, 19),
                                                  style: TextStyle(
                                                    color: widget.darkMode
                                                        ? AppColors.lightTheme
                                                            .withOpacity(0.5)
                                                        : AppColors.primaryColor
                                                            .withOpacity(0.5),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
