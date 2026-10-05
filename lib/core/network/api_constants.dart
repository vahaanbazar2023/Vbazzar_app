class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl =
      'https://q7imfgydpj.ap-south-1.awsapprunner.com/';

  // API Keys
  static const String apiKey = '7B0F2K4R1MSS3P0D'; // Production API Key
  static const String productionApiKey =
      '7B0F2K4R1MSS3P0D'; // Production API Key

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 300);
  static const Duration receiveTimeout = Duration(seconds: 300);
  static const Duration sendTimeout = Duration(seconds: 300);
}
