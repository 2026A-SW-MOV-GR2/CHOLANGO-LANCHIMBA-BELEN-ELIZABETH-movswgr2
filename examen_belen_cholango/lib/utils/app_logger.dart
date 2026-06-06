class AppLogger {
  static void debug(String msg) =>
      print('[DEBUG] ${DateTime.now().toIso8601String()} $msg');

  static void info(String msg) =>
      print('[INFO]  ${DateTime.now().toIso8601String()} $msg');

  static void error(String msg) =>
      print('[ERROR] ${DateTime.now().toIso8601String()} $msg');
}