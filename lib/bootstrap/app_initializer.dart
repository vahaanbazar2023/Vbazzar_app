import '../core/services/logger_service.dart';
import '../core/storage/local_storage_service.dart';
import '../core/localization/translations.dart';

class AppInitializer {
  static final LoggerService _logger = LoggerService.instance;

  static Future<void> initialize() async {
    _logger.info('Starting app initialization');

    try {
      await _initializeLocalization();
      await _initializeUserPreferences();
      _logger.info('App initialization completed successfully');
    } catch (e, stack) {
      _logger.error('App initialization failed', e, stack);
      rethrow;
    }
  }

  static Future<void> _initializeLocalization() async {
    try {
      await AppTranslations.initialize();
      _logger.info('Localization initialized');
    } catch (e, stack) {
      _logger.error('Failed to initialize localization', e, stack);
    }
  }

  static Future<void> _initializeUserPreferences() async {
    try {
      final storage = LocalStorageService.instance;
      final isDarkMode = storage.getBool('is_dark_mode');
      final language = storage.getString(
        'selected_language',
        defaultValue: 'en',
      );
      _logger.info(
        'User preferences loaded: darkMode=$isDarkMode, language=$language',
      );
    } catch (e, stack) {
      _logger.error('Failed to load user preferences', e, stack);
    }
  }

  static Future<void> reset() async {
    try {
      _logger.info('Resetting app state');
      final storage = LocalStorageService.instance;
      await storage.clear();
      _logger.info('App state reset completed');
    } catch (e, stack) {
      _logger.error('Failed to reset app state', e, stack);
      rethrow;
    }
  }
}
