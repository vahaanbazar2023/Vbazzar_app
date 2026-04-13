import 'env.dart';

class StagingEnv extends Env {
  @override
  String get appName => 'Vahaan Staging';
  @override
  String get baseUrl => 'https://api.staging.vahaanbazar.in';
  @override
  String get wsUrl => 'wss://staging-ws.vahaan.com';
  @override
  String get apiKey => '7B9F2K4R1M6Q3P8D'; // Staging and test API Key
  @override
  bool get enableLogging => true;
  @override
  bool get enableCrashlytics => true;
  @override
  int get connectTimeoutMs => 30000;
  @override
  int get receiveTimeoutMs => 30000;
}
