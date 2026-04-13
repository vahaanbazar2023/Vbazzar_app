import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/services/logger_service.dart';
import '../core/storage/local_storage_service.dart';
import '../core/network/client/dio_client.dart';
import '../core/services/notification_service.dart';
import '../config/env.dart';
import 'app_initializer.dart';

class Bootstrap {
  static final LoggerService _logger = LoggerService.instance;

  /// Main bootstrap function that sets up the entire app
  static Future<void> initialize() async {
    // Note: WidgetsFlutterBinding.ensureInitialized() should be called
    // in main() inside the zone to avoid zone mismatch

    // Set up error handling
    await _setupErrorHandling();

    // Setup system UI
    await _setupSystemUI();

    // Initialize core services
    await _initializeCoreServices();

    // Initialize environment configuration
    await _initializeEnvironment();

    // Initialize app-specific services
    await _initializeAppServices();

    _logger.info('Bootstrap completed successfully');
  }

  /// Setup global error handling
  static Future<void> _setupErrorHandling() async {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logger.error('Flutter error', details.exception, details.stack);
    };

    // Handle platform dispatcher errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.error('Platform error', error, stack);
      return true;
    };

    _logger.info('Error handling setup completed');
  }

  /// Setup system UI preferences
  static Future<void> _setupSystemUI() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Set status bar to white text/icons globally
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons on Android
        statusBarBrightness: Brightness.dark, // White icons on iOS
      ),
    );

    _logger.info('System UI setup completed');
  }

  /// Initialize core services
  static Future<void> _initializeCoreServices() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      _logger.info('Firebase initialized');

      // Initialize storage service
      await LocalStorageService.initialize();
      _logger.info('Storage service initialized');

      // NOTE: ConnectivityService will be registered in AppBinding after GetMaterialApp
      // to avoid GetX context issues

      // Initialize notification service (includes FCM)
      await NotificationService.initialize();
      _logger.info('Notification service initialized');
    } catch (e, stack) {
      _logger.error('Failed to initialize core services', e, stack);
      rethrow;
    }
  }

  /// Initialize environment configuration
  static Future<void> _initializeEnvironment() async {
    try {
      // Default to dev environment
      Env.initialize(_DefaultEnv());
      _logger.info('Environment configuration initialized');
    } catch (e, stack) {
      _logger.error('Failed to initialize environment', e, stack);
      rethrow;
    }
  }

  /// Initialize app-specific services
  static Future<void> _initializeAppServices() async {
    try {
      // Initialize HTTP client (legacy - kept for backward compatibility)
      DioClient.initialize();
      _logger.info('HTTP client initialized');

      // NOTE: NetworkService will be registered in AppBinding after GetMaterialApp is created
      // to avoid GetX context issues

      // Initialize app-specific configurations
      await AppInitializer.initialize();
      _logger.info('App initializer completed');
    } catch (e, stack) {
      _logger.error('Failed to initialize app services', e, stack);
      rethrow;
    }
  }

  /// Handle bootstrap errors - show error screen
  static void handleBootstrapError(Object error, StackTrace stack) {
    _logger.error('Bootstrap failed', error, stack);

    // Show error screen since app failed to initialize
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to start the app',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please restart the app or contact support.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text('Exit App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle runtime errors after bootstrap - just log them
  static void handleRuntimeError(Object error, StackTrace stack) {
    _logger.error('Runtime error', error, stack);
    // Don't show error screen or call runApp - just log it
    // The app is already running and error boundaries will handle UI errors
  }
}

/// Default dev environment used during bootstrap
class _DefaultEnv extends Env {
  _DefaultEnv();
  @override
  String get appName => 'Vahaan Bazar';
  @override
  String get baseUrl => 'https://api.staging.vahaanbazar.in';
  @override
  String get wsUrl => 'wss://ws.dev.vahaan.com';
  @override
  String get apiKey => '7B9F2K4R1M6Q3P8D'; // Staging and test API Key
  @override
  bool get enableLogging => true;
  @override
  bool get enableCrashlytics => false;
  @override
  int get connectTimeoutMs => 30000;
  @override
  int get receiveTimeoutMs => 30000;
}
