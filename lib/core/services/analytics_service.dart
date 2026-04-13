import '../services/logger_service.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();
  static AnalyticsService get to => instance;

  final _log = LoggerService.instance;

  // Replace method bodies with your analytics SDK (Firebase, Mixpanel, etc.)

  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    _log.info('Analytics event: $name | params: $parameters');
    // e.g. FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }

  void setUserId(String uid) {
    _log.info('Analytics setUserId: $uid');
    // e.g. FirebaseAnalytics.instance.setUserId(id: uid);
  }

  void logScreen(String screenName) {
    _log.info('Analytics screen: $screenName');
    // e.g. FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }
}
