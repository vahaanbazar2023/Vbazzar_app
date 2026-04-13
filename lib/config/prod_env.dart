import 'env.dart';

class ProdEnv extends Env {
  @override
  String get appName => 'Vahaan';
  @override
  String get baseUrl => 'https://api.vahaan.com';
  @override
  String get wsUrl => 'wss://ws.vahaan.com';
  @override
  String get apiKey => '7B0F2K4R1MSS3P0D'; // Production API Key
  @override
  bool get enableLogging => false;
  @override
  bool get enableCrashlytics => true;
  @override
  int get connectTimeoutMs => 30000;
  @override
  int get receiveTimeoutMs => 30000;
}
