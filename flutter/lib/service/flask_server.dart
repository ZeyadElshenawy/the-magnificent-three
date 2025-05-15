import 'dart:io';
import 'package:path/path.dart' as path;

class FlaskServerService {
  static Process? _classificationProcess;
  static Process? _regressionProcess;
  static bool _serversStarted = false;

  static String get _projectRoot {
    // Get the absolute path to the project root
    String currentDir = Directory.current.path;
    // If we're in the Flutter directory, go up one level
    if (currentDir.endsWith('flutter')) {
      currentDir = Directory(currentDir).parent.path;
    }
    return currentDir;
  }

  static Future<bool> startServers() async {
    if (_serversStarted) return true;

    try {
      // Get absolute paths to Python scripts
      final String mlModelPath = path.join(_projectRoot, 'ML_Model');
      final String classificationScript =
          path.join(mlModelPath, 'FlaskForClassification.py');
      final String regressionScript =
          path.join(mlModelPath, 'FlaskForRegression.py');

      // Print current directory and paths for debugging
      print('Current directory: ${Directory.current.path}');
      print('ML Model path: $mlModelPath');
      print('Classification script path: $classificationScript');
      print('Regression script path: $regressionScript');

      // Verify that the scripts exist
      if (!File(classificationScript).existsSync()) {
        print('Classification script not found at: $classificationScript');
        return false;
      }
      if (!File(regressionScript).existsSync()) {
        print('Regression script not found at: $regressionScript');
        return false;
      }

      // Try to start Classification server
      print('Starting Classification server...');
      try {
        _classificationProcess = await Process.start(
          'python',
          [classificationScript],
          workingDirectory: mlModelPath,
        );
        print('Classification server process started');
      } catch (e) {
        print('Error starting Classification server: $e');
        return false;
      }

      // Try to start Regression server
      print('Starting Regression server...');
      try {
        _regressionProcess = await Process.start(
          'python',
          [regressionScript],
          workingDirectory: mlModelPath,
        );
        print('Regression server process started');
      } catch (e) {
        print('Error starting Regression server: $e');
        stopServers(); // Stop classification server if regression fails
        return false;
      }

      // Listen for Classification server output
      _classificationProcess!.stdout.listen(
        (event) {
          print('Classification Server: ${String.fromCharCodes(event)}');
        },
        onError: (error) {
          print('Classification Server Error: $error');
        },
      );

      _classificationProcess!.stderr.listen(
        (event) {
          print('Classification Server Error: ${String.fromCharCodes(event)}');
        },
        onError: (error) {
          print('Classification Server Error: $error');
        },
      );

      // Listen for Regression server output
      _regressionProcess!.stdout.listen(
        (event) {
          print('Regression Server: ${String.fromCharCodes(event)}');
        },
        onError: (error) {
          print('Regression Server Error: $error');
        },
      );

      _regressionProcess!.stderr.listen(
        (event) {
          print('Regression Server Error: ${String.fromCharCodes(event)}');
        },
        onError: (error) {
          print('Regression Server Error: $error');
        },
      );

      // Wait for servers to start
      await Future.delayed(const Duration(seconds: 5));

      // Check if processes are still running
      if (_classificationProcess == null || _regressionProcess == null) {
        print('One or both servers failed to start');
        stopServers();
        return false;
      }

      _serversStarted = true;
      print('Both servers started successfully');
      return true;
    } catch (e) {
      print('Error starting Flask servers: $e');
      stopServers();
      return false;
    }
  }

  static void stopServers() {
    try {
      if (_classificationProcess != null) {
        print('Stopping Classification server...');
        _classificationProcess?.kill();
      }
      if (_regressionProcess != null) {
        print('Stopping Regression server...');
        _regressionProcess?.kill();
      }
    } catch (e) {
      print('Error stopping servers: $e');
    } finally {
      _classificationProcess = null;
      _regressionProcess = null;
      _serversStarted = false;
    }
  }
}
