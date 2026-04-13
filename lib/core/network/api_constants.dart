class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl = 'https://api.staging.vahaanbazar.in';

  // API Keys
  static const String apiKey = '7B9F2K4R1M6Q3P8D'; // Staging and test API Key
  static const String productionApiKey =
      '7B0F2K4R1MSS3P0D'; // Production API Key

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 300);
  static const Duration receiveTimeout = Duration(seconds: 300);
  static const Duration sendTimeout = Duration(seconds: 300);
}
