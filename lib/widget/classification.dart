import 'package:flutter/material.dart';
import 'package:project_model_ai/UI_UX/Colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                                  hintText: 'Enter image name',
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
                            ElevatedButton(
                              onPressed: _image == null
                                  ? null
                                  : () {
                                      // ////////////////////////////////////////////////Add classification logic here
                                    },
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
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children: const [
                              // History items will be added here
                            ],
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
