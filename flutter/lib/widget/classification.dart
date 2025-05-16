import 'package:flutter/material.dart';
import 'package:project_model_ai/UI_UX/Colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_model_ai/services/flask_service.dart';
import 'package:project_model_ai/main.dart';

class Classification extends StatefulWidget {
  final bool darkMode;
  const Classification({super.key, required this.darkMode});

  @override
  State<Classification> createState() => _ClassificationState();
}

class _ClassificationState extends State<Classification> {
  File? _image;
  final picker = ImagePicker();
  bool _dragging = false;
  bool _showRightBar = false;
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _history = [];
  String _selectedModel = 'svc';
  final FlaskService _flaskService = FlaskService();
  bool _isServerRunning = false;

  final List<Map<String, String>> _models = [
    {'value': 'svc', 'label': 'Support Vector Machine'},
    {'value': 'random_forest', 'label': 'Random Forest'},
    {'value': 'decision_tree', 'label': 'Decision Tree'},
    {'value': 'logistic_regression', 'label': 'Logistic Regression'},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _checkServerStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flaskService.stopClassificationServer();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('classification_history') ?? [];
    setState(() {
      _history = historyJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('classification_history', historyJson);
  }

  void _addToHistory(String message, bool isError, {String? imagePath}) {
    final historyItem = {
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'isError': isError,
      if (imagePath != null) 'imagePath': imagePath,
    };
    setState(() {
      _history.insert(0, historyItem);
    });
    _saveHistory();
  }

  void _checkServerStatus() {
    setState(() {
      _isServerRunning = flaskService.isClassificationRunning;
    });
  }

  Future<void> sendImageForClassification() async {
    if (_image == null) return;
    if (!_isServerRunning) {
      _addToHistory(
          'Server is not running. Please wait for the server to start.', true);
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5000/classify'),
      );

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          filename: _nameController.text.isNotEmpty
              ? _nameController.text
              : _image!.path.split('/').last,
        ),
      );

      // Add model selection
      request.fields['model'] = _selectedModel;

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final result = jsonDecode(responseData);
        String diagnosis = result['class_name'];
        String patinName = _nameController.text.isNotEmpty
            ? _nameController.text
            : "Unnamed Patient";

        // Update history message to include model used
        String modelUsed = _models.firstWhere(
                (m) => m['value'] == result['model_used'])['label'] ??
            result['model_used'];
        _addToHistory(
          'Patient: $patinName\nDiagnosis: $diagnosis\nConfidence: ${(result['confidence'] * 100).toStringAsFixed(2)}%\nModel Used: $modelUsed',
          false,
          imagePath: _image!.path,
        );

        // Clear image after successful classification
        setState(() {
          _image = null;
          _nameController.clear();
        });
      } else {
        _addToHistory('Server Error: ${response.statusCode}', true);
      }
    } catch (e) {
      _addToHistory('Error: $e', true);
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Add server status indicator
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isServerRunning
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: _isServerRunning ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isServerRunning ? 'Server Online' : 'Server Offline',
                    style: TextStyle(
                      color: widget.darkMode
                          ? AppColors.lightTheme
                          : AppColors.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Image Classification',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.darkMode
                                ? AppColors.lightTheme
                                : AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload your image to classify it',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.darkMode
                                ? AppColors.lightTheme.withOpacity(0.7)
                                : AppColors.primaryColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        DropTarget(
                          onDragDone: (detail) => setState(
                              () => _image = File(detail.files.first.path)),
                          onDragEntered: (detail) =>
                              setState(() => _dragging = true),
                          onDragExited: (detail) =>
                              setState(() => _dragging = false),
                          child: GestureDetector(
                            onTap: getImage,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _dragging
                                      ? Colors.blue
                                      : widget.darkMode
                                          ? const Color.fromARGB(
                                                  255, 228, 207, 207)
                                              .withOpacity(0.3)
                                          : AppColors.primaryColor
                                              .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: _image == null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 36,
                                            color: widget.darkMode
                                                ? AppColors.lightTheme
                                                : AppColors.primaryColor,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Drop image here or click to browse',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: widget.darkMode
                                                  ? AppColors.lightTheme
                                                      .withOpacity(0.7)
                                                  : AppColors.primaryColor
                                                      .withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _image!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: TextStyle(
                                  color: widget.darkMode
                                      ? AppColors.lightTheme
                                      : AppColors.primaryColor,
                                  fontSize: 16,
                                ),
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter Patin fish name',
                                  hintStyle: TextStyle(
                                    color: widget.darkMode
                                        ? AppColors.lightTheme.withOpacity(0.5)
                                        : AppColors.primaryColor
                                            .withOpacity(0.5),
                                  ),
                                  filled: true,
                                  fillColor: widget.darkMode
                                      ? AppColors.primaryColor.withOpacity(0.2)
                                      : AppColors.lightTheme.withOpacity(0.2),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: widget.darkMode
                                          ? AppColors.lightTheme
                                              .withOpacity(0.1)
                                          : AppColors.primaryColor
                                              .withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                      color: widget.darkMode
                                          ? AppColors.lightTheme
                                              .withOpacity(0.3)
                                          : AppColors.primaryColor
                                              .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: widget.darkMode
                                    ? AppColors.lightTheme.withOpacity(0.1)
                                    : AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton<String>(
                                value: _selectedModel,
                                dropdownColor: widget.darkMode
                                    ? AppColors.primaryColor
                                    : AppColors.lightTheme,
                                style: TextStyle(
                                  color: widget.darkMode
                                      ? AppColors.lightTheme
                                      : AppColors.primaryColor,
                                ),
                                underline: Container(),
                                items: _models.map((model) {
                                  return DropdownMenuItem<String>(
                                    value: model['value'],
                                    child: Text(model['label']!),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedModel = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _image == null
                                  ? null
                                  : sendImageForClassification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.darkMode
                                    ? AppColors.lightTheme
                                    : AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: widget.darkMode
                                    ? AppColors.lightTheme.withOpacity(0.3)
                                    : AppColors.primaryColor.withOpacity(0.3),
                              ),
                              child: Text(
                                'Classify',
                                style: TextStyle(
                                  color: widget.darkMode
                                      ? AppColors.primaryColor
                                      : AppColors.lightTheme,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
                                await prefs.remove('classification_history');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _history.isEmpty
                              ? Center(
                                  child: Text(
                                    'No classifications yet',
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
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (historyItem['imagePath'] !=
                                                null)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  File(
                                                      historyItem['imagePath']),
                                                  height: 120,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              historyItem['message'],
                                              style: TextStyle(
                                                color: historyItem['isError']
                                                    ? Colors.red
                                                    : widget.darkMode
                                                        ? AppColors.lightTheme
                                                        : AppColors
                                                            .primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateTime.parse(
                                                      historyItem['timestamp'])
                                                  .toLocal()
                                                  .toString()
                                                  .split('.')[0],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: widget.darkMode
                                                    ? AppColors.lightTheme
                                                        .withOpacity(0.5)
                                                    : AppColors.primaryColor
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
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
