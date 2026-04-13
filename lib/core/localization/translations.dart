import 'package:get/get.dart';
import 'locale_keys.dart';

class AppTranslations extends Translations {
  static Future<void> initialize() async {}

  @override
  Map<String, Map<String, String>> get keys => {'en_US': _en, 'hi_IN': _hi};

  static const Map<String, String> _en = {
    // General
    LocaleKeys.ok: 'OK',
    LocaleKeys.cancel: 'Cancel',
    LocaleKeys.retry: 'Retry',
    LocaleKeys.loading: 'Loading…',
    LocaleKeys.save: 'Save',
    LocaleKeys.next: 'Next',
    LocaleKeys.back: 'Back',
    LocaleKeys.skip: 'Skip',
    LocaleKeys.getStarted: 'Get Started',

    // Auth
    LocaleKeys.login: 'Login',
    LocaleKeys.logout: 'Logout',
    LocaleKeys.register: 'Register',
    LocaleKeys.email: 'Email',
    LocaleKeys.password: 'Password',
    LocaleKeys.forgotPassword: 'Forgot password?',

    // Errors
    LocaleKeys.errorGeneric: 'Something went wrong. Please try again.',
    LocaleKeys.errorNetwork: 'Network error. Check your connection.',
    LocaleKeys.errorTimeout: 'Request timed out.',

    // Intro
    LocaleKeys.introTitle1: 'Welcome to Vahaan',
    LocaleKeys.introDesc1: 'Your complete vehicle management companion',
    LocaleKeys.introTitle2: 'Track Everything',
    LocaleKeys.introDesc2: 'Insurance, RC, PUC — all in one place',
    LocaleKeys.introTitle3: 'Smart Reminders',
    LocaleKeys.introDesc3: 'Never miss a renewal or service date',
  };

  static const Map<String, String> _hi = {
    // General
    LocaleKeys.ok: 'ठीक है',
    LocaleKeys.cancel: 'रद्द करें',
    LocaleKeys.retry: 'पुनः प्रयास',
    LocaleKeys.loading: 'लोड हो रहा है…',
    LocaleKeys.save: 'सहेजें',
    LocaleKeys.next: 'अगला',
    LocaleKeys.back: 'वापस',
    LocaleKeys.skip: 'छोड़ें',
    LocaleKeys.getStarted: 'शुरू करें',

    // Auth
    LocaleKeys.login: 'लॉगिन',
    LocaleKeys.logout: 'लॉगआउट',
    LocaleKeys.register: 'पंजीकरण',
    LocaleKeys.email: 'ईमेल',
    LocaleKeys.password: 'पासवर्ड',
    LocaleKeys.forgotPassword: 'पासवर्ड भूल गए?',

    // Errors
    LocaleKeys.errorGeneric: 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।',
    LocaleKeys.errorNetwork: 'नेटवर्क त्रुटि। अपना कनेक्शन जांचें।',
    LocaleKeys.errorTimeout: 'अनुरोध समय समाप्त हो गया।',

    // Intro
    LocaleKeys.introTitle1: 'वाहान में आपका स्वागत है',
    LocaleKeys.introDesc1: 'आपका संपूर्ण वाहन प्रबंधन साथी',
    LocaleKeys.introTitle2: 'सब कुछ ट्रैक करें',
    LocaleKeys.introDesc2: 'बीमा, RC, PUC — एक जगह',
    LocaleKeys.introTitle3: 'स्मार्ट रिमाइंडर',
    LocaleKeys.introDesc3: 'कोई नवीकरण या सेवा तिथि न चूकें',
  };
}
