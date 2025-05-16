import 'dart:io';

class FlaskServerService {
  static Process? _serverProcess;

  static Future<bool> startServer() async {
    try {
      // Check if Python is installed
      await Process.run('python', ['--version']);

      // Start the Flask server
      _serverProcess = await Process.start('python',
          [r'the-magnificent-three\ML_Model\FlskForClassification.py']);

      // Listen for server output
      _serverProcess!.stdout.listen((event) {
        print('Flask Server: ${String.fromCharCodes(event)}');
      });

      _serverProcess!.stderr.listen((event) {
        print('Flask Server Error: ${String.fromCharCodes(event)}');
      });

      // Wait a bit for the server to start
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      print('Error starting Flask server: $e');
      return false;
    }
  }

  static void stopServer() {
    _serverProcess?.kill();
    _serverProcess = null;
  }
}
