import 'package:flutter/material.dart';
import 'package:project_model_ai/UI_UX/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  final bool darkMode;
  final Function(bool)? onThemeChanged;
  final VoidCallback? onProfileImageChanged;

  const Settings({
    super.key,
    required this.darkMode,
    this.onThemeChanged,
    this.onProfileImageChanged,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  final TextEditingController _nameController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.darkMode;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _nameController.text = prefs.getString('userName') ?? '';
      _imagePath = prefs.getString('profileImage');
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setString('userName', _nameController.text);
    if (_imagePath != null) {
      await prefs.setString('profileImage', _imagePath!);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      await _saveSettings();
      widget.onProfileImageChanged?.call();
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.secondaryColor,
        child: _imagePath != null
            ? ClipOval(
                child: Image.file(
                  File(_imagePath!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.person, color: AppColors.lightTheme, size: 40),
      ),
    );
  }

  void _handleThemeChange(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    await _saveSettings();
    widget.onThemeChanged?.call(value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isDarkMode ? AppColors.darkTheme : AppColors.lightTheme,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.23,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        _isDarkMode ? AppColors.primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildProfileImage(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Name',
                              style: TextStyle(
                                color: _isDarkMode
                                    ? AppColors.lightTheme
                                    : AppColors.primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              style: TextStyle(
                                color: _isDarkMode
                                    ? AppColors.lightTheme
                                    : AppColors.primaryColor,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: TextStyle(
                                  color: _isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.secondaryColor
                                        .withOpacity(0.7),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.tealAccent,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: _isDarkMode
                                    ? AppColors.primaryColor
                                    : AppColors.lightTheme,
                              ),
                              onChanged: (value) {
                                setState(() {});
                                _saveSettings();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'General Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode
                        ? AppColors.lightTheme
                        : AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.secondaryColor,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: _isDarkMode
                          ? AppColors.lightTheme
                          : AppColors.primaryColor,
                    ),
                  ),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: _handleThemeChange,
                    activeColor: AppColors.secondaryColor,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications,
                      color: AppColors.secondaryColor),
                  title: Text(
                    'Notifications',
                    style: TextStyle(
                      color: _isDarkMode
                          ? AppColors.lightTheme
                          : AppColors.primaryColor,
                    ),
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSettings();
                    },
                    activeColor: AppColors.secondaryColor,
                  ),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.info, color: AppColors.secondaryColor),
                  title: Text(
                    'App Version',
                    style: TextStyle(
                      color: _isDarkMode
                          ? AppColors.lightTheme
                          : AppColors.primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    "1.0.0",
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.message_sharp,
                      color: AppColors.secondaryColor),
                  title: Text(
                    'Contact Us',
                    style: TextStyle(
                      color: _isDarkMode
                          ? AppColors.lightTheme
                          : AppColors.primaryColor,
                    ),
                  ),
                  onTap: () {
                    // Contact functionality can be added here
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode
                        ? AppColors.lightTheme
                        : AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.clear, color: Colors.redAccent),
                  title: const Text(
                    'clear',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    // Logout functionality can be added here
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
