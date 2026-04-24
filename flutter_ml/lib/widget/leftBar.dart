import 'package:flutter/material.dart';
import 'package:flutter_ml/UI_UX/Colors.dart';
import 'package:flutter_ml/UI_UX/windowcontrolswidget.dart';
import 'package:flutter_ml/widget/classification.dart';
import 'package:flutter_ml/widget/homepage.dart';
import 'package:flutter_ml/widget/regression.dart';
import 'package:flutter_ml/widget/settings.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Leftbar extends StatefulWidget {
  const Leftbar({super.key});

  @override
  State<Leftbar> createState() => _LeftbarState();
}

class _LeftbarState extends State<Leftbar> {
  int _selectedTab = 0;
  String? _profileImagePath;
  bool _isDarkMode = false;
  int _monthlyOpens = 0;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadProfileImage();
    _updateMonthlyOpens();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profileImage');
    });
  }

  Future<void> _updateMonthlyOpens() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpenMonth = prefs.getInt('lastOpenMonth') ?? 0;
    final currentMonth = DateTime.now().month;

    if (lastOpenMonth != currentMonth) {
      // Reset counter for new month
      await prefs.setInt('monthlyOpens', 1);
      await prefs.setInt('lastOpenMonth', currentMonth);
      setState(() {
        _monthlyOpens = 1;
      });
    } else {
      // Increment counter for current month
      final opens = (prefs.getInt('monthlyOpens') ?? 0) + 1;
      await prefs.setInt('monthlyOpens', opens);
      setState(() {
        _monthlyOpens = opens;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isDarkMode ? AppColors.primaryColor : AppColors.lightTheme,
      body: Row(
        children: [
          _buildNavigationRail(),
          Expanded(
            child: Column(
              children: [
                WindowControlsWidget(isDarkMode: _isDarkMode),
                Expanded(child: _buildPageView()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, Colors.black26],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) =>
                  setState(() => _selectedTab = index),
              labelType: NavigationRailLabelType.all,
              useIndicator: false,
              minWidth: 80,
              minExtendedWidth: 220,
              backgroundColor: Colors.transparent,
              leading: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.secondaryColor, width: 2),
                      image: _profileImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_profileImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImagePath == null
                        ? const Icon(Icons.person,
                            size: 30, color: AppColors.secondaryColor)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(color: Colors.grey, thickness: 1),
                  ),
                ],
              ),
              destinations: [
                _buildAnimatedDestination(
                    Icons.home_outlined, Icons.home, 'Home', 0),
                _buildAnimatedDestination(
                    'images/icon_classification_before.png',
                    'images/icon_classification_after.png',
                    'Classification',
                    1,
                    useImage: true),
                _buildAnimatedDestination(
                  'images/icon_regression.png',
                  'images/icon_regression.png',
                  'Regression',
                  2,
                  useImage: true,
                ),
              ],
            ),
          ),
          // Settings button at the bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white70),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.95,
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? AppColors.darkTheme
                          : AppColors.lightTheme,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: Settings(
                        darkMode: _isDarkMode,
                        onThemeChanged: (bool darkMode) {
                          setState(() {
                            _isDarkMode = darkMode;
                          });
                        },
                        onProfileImageChanged: () {
                          _loadProfileImage();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  NavigationRailDestination _buildAnimatedDestination(
      dynamic unselectedIcon, dynamic selectedIcon, String label, int index,
      {bool useImage = false}) {
    return NavigationRailDestination(
      padding: const EdgeInsets.symmetric(vertical: 10),
      icon: Tooltip(
        message: label,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: useImage
              ? Image.asset(
                  _selectedTab == index ? selectedIcon : unselectedIcon,
                  key: ValueKey<bool>(_selectedTab == index),
                  height: _selectedTab == index ? 30 : 24,
                  color: _selectedTab == index
                      ? AppColors.secondaryColor
                      : Colors.white70,
                )
              : Icon(
                  _selectedTab == index ? selectedIcon : unselectedIcon,
                  key: ValueKey<bool>(_selectedTab == index),
                  color: _selectedTab == index
                      ? AppColors.secondaryColor
                      : Colors.white70,
                  size: _selectedTab == index ? 30 : 24,
                ),
        ),
      ),
      label: Text(
        label,
        style: TextStyle(
          color:
              _selectedTab == index ? AppColors.secondaryColor : Colors.white70,
          fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _getPage(_selectedTab),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Homepage(darkMode: _isDarkMode, monthlyOpens: _monthlyOpens);
      case 1:
        return Classification(darkMode: _isDarkMode);
      case 2:
        return Regression(darkMode: _isDarkMode);
      default:
        return Homepage(darkMode: _isDarkMode, monthlyOpens: _monthlyOpens);
    }
  }
}
