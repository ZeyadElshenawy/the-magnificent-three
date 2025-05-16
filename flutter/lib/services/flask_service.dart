import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class FlaskService {
  Process? _classificationProcess;
  Process? _regressionProcess;
  bool _isClassificationRunning = false;
  bool _isRegressionRunning = false;

  bool get isClassificationRunning => _isClassificationRunning;
  bool get isRegressionRunning => _isRegressionRunning;

  String get _baseDirectory {
    // Get the executable's directory
    String? exePath = Platform.resolvedExecutable;
    String exeDir = path.dirname(exePath);

    if (exeDir.contains('build\\windows\\x64\\runner')) {
      // We're running from the compiled exe
      return path.normalize(path.join(exeDir, '..', '..', '..', '..'));
    } else {
      // We're running in development
      return path.normalize(path.join(Directory.current.path, '..'));
    }
  }

  Future<bool> startClassificationServer() async {
    if (_isClassificationRunning) return true;

    try {
      final String flaskScriptPath =
          path.join(_baseDirectory, 'ML_Model', 'FlaskForClassification.py');

      debugPrint('Classification Script Path: $flaskScriptPath');
      if (!File(flaskScriptPath).existsSync()) {
        debugPrint('Classification Python file not found at: $flaskScriptPath');
        return false;
      }

      final pythonCommand = Platform.isWindows ? 'python' : 'python3';

      _classificationProcess = await Process.start(
        pythonCommand,
        [flaskScriptPath],
        runInShell: true,
        workingDirectory: path.dirname(flaskScriptPath),
      );

      _classificationProcess!.stdout.listen((data) {
        debugPrint(
            'Classification Flask stdout: ${String.fromCharCodes(data)}');
      });

      _classificationProcess!.stderr.listen((data) {
        debugPrint(
            'Classification Flask stderr: ${String.fromCharCodes(data)}');
      });

      await Future.delayed(const Duration(seconds: 2));
      _isClassificationRunning = true;
      return true;
    } catch (e) {
      debugPrint('Error starting Classification Flask server: $e');
      return false;
    }
  }

  Future<bool> startRegressionServer() async {
    if (_isRegressionRunning) return true;

    try {
      final String flaskScriptPath =
          path.join(_baseDirectory, 'ML_Model', 'FlaskForRegression.py');

      debugPrint('Regression Script Path: $flaskScriptPath');
      if (!File(flaskScriptPath).existsSync()) {
        debugPrint('Regression Python file not found at: $flaskScriptPath');
        return false;
      }

      final pythonCommand = Platform.isWindows ? 'python' : 'python3';

      _regressionProcess = await Process.start(
        pythonCommand,
        [flaskScriptPath],
        runInShell: true,
        workingDirectory: path.dirname(flaskScriptPath),
      );

      _regressionProcess!.stdout.listen((data) {
        debugPrint('Regression Flask stdout: ${String.fromCharCodes(data)}');
      });

      _regressionProcess!.stderr.listen((data) {
        debugPrint('Regression Flask stderr: ${String.fromCharCodes(data)}');
      });

      await Future.delayed(const Duration(seconds: 2));
      _isRegressionRunning = true;
      return true;
    } catch (e) {
      debugPrint('Error starting Regression Flask server: $e');
      return false;
    }
  }

  Future<void> stopClassificationServer() async {
    if (_classificationProcess != null) {
      _classificationProcess!.kill();
      _classificationProcess = null;
      _isClassificationRunning = false;
    }
  }

  Future<void> stopRegressionServer() async {
    if (_regressionProcess != null) {
      _regressionProcess!.kill();
      _regressionProcess = null;
      _isRegressionRunning = false;
    }
  }

  Future<void> stopAllServers() async {
    await stopClassificationServer();
    await stopRegressionServer();
  }
}
