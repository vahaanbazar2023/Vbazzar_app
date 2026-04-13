import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/analytics_service.dart';
import '../core/services/logger_service.dart';

class AppLifecycle extends GetxController with WidgetsBindingObserver {
  static AppLifecycle get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    LoggerService.to.info('AppLifecycle initialized');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        LoggerService.to.info('App resumed');
        AnalyticsService.to.logEvent('app_resumed');
        break;
      case AppLifecycleState.paused:
        LoggerService.to.info('App paused');
        AnalyticsService.to.logEvent('app_paused');
        break;
      case AppLifecycleState.detached:
        LoggerService.to.info('App detached');
        break;
      case AppLifecycleState.inactive:
        LoggerService.to.debug('App inactive');
        break;
      case AppLifecycleState.hidden:
        LoggerService.to.debug('App hidden');
        break;
    }
  }
}
