abstract class Env {
  String get appName;
  String get baseUrl;
  String get wsUrl;
  String get apiKey;
  bool get enableLogging;
  bool get enableCrashlytics;
  int get connectTimeoutMs;
  int get receiveTimeoutMs;

  static late Env _current;
  static Env get current => _current;

  /// Call this once at startup — pass the right subclass per flavor.
  /// e.g. Env.initialize(DevEnv()) in main_dev.dart
  static void initialize(Env env) {
    _current = env;
  }
}
