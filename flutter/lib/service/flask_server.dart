import 'dart:io';

class FlaskServerService {
  static Process? _classificationProcess;
  static Process? _regressionProcess;
  static bool _serversStarted = false;

  static Future<bool> startServers() async {
    if (_serversStarted) return true;

    try {
      // Check if Python is installed
      final pythonVersion = await Process.run('python', ['--version']);
      if (pythonVersion.exitCode != 0) {
        print('Python is not installed or not in PATH');
        return false;
      }

      // Start the Classification Flask server
      _classificationProcess = await Process.start(
        'python',
        [r'the-magnificent-three\ML_Model\FlskForClassification.py'],
      );

      // Start the Regression Flask server
      _regressionProcess = await Process.start(
        'python',
        [r'the-magnificent-three\ML_Model\FlaskForRegression.py'],
      );

      // Listen for Classification server output
      _classificationProcess!.stdout.listen((event) {
        print('Classification Server: ${String.fromCharCodes(event)}');
      });

      _classificationProcess!.stderr.listen((event) {
        print('Classification Server Error: ${String.fromCharCodes(event)}');
      });

      // Listen for Regression server output
      _regressionProcess!.stdout.listen((event) {
        print('Regression Server: ${String.fromCharCodes(event)}');
      });

      _regressionProcess!.stderr.listen((event) {
        print('Regression Server Error: ${String.fromCharCodes(event)}');
      });

      // Wait for both servers to start
      await Future.delayed(const Duration(seconds: 2));
      _serversStarted = true;
      return true;
    } catch (e) {
      print('Error starting Flask servers: $e');
      return false;
    }
  }

  static void stopServers() {
    _classificationProcess?.kill();
    _regressionProcess?.kill();
    _classificationProcess = null;
    _regressionProcess = null;
    _serversStarted = false;
  }
}
