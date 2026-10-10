import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localisation/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'VahaanBazar'**
  String get appName;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// No description provided for @welcomeToVahaanBazar.
  ///
  /// In en, this message translates to:
  /// **'Welcome to VahaanBazar'**
  String get welcomeToVahaanBazar;

  /// No description provided for @selectPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your Preferred Language.'**
  String get selectPreferredLanguage;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @languagePreference.
  ///
  /// In en, this message translates to:
  /// **'Language Preference'**
  String get languagePreference;

  /// No description provided for @chooseYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Preferred Language'**
  String get chooseYourPreferredLanguage;

  /// No description provided for @weWillUseThisAcrossTheApp.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this across the app !'**
  String get weWillUseThisAcrossTheApp;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @languageRequired.
  ///
  /// In en, this message translates to:
  /// **'Language Required'**
  String get languageRequired;

  /// No description provided for @pleaseSelectALanguageToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please select a language to continue'**
  String get pleaseSelectALanguageToContinue;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @show_more.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get show_more;

  /// No description provided for @show_less.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get show_less;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginWithOTP.
  ///
  /// In en, this message translates to:
  /// **'Login With'**
  String get loginWithOTP;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username / Mobile Number'**
  String get usernameHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @havingTrouble.
  ///
  /// In en, this message translates to:
  /// **'Having trouble logging in?'**
  String get havingTrouble;

  /// No description provided for @pleaseCallUs.
  ///
  /// In en, this message translates to:
  /// **'Please Call us at '**
  String get pleaseCallUs;

  /// No description provided for @supportNumber.
  ///
  /// In en, this message translates to:
  /// **'8886630455 '**
  String get supportNumber;

  /// No description provided for @forAssistance.
  ///
  /// In en, this message translates to:
  /// **' for assistance.'**
  String get forAssistance;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @weWillSendYouOtp.
  ///
  /// In en, this message translates to:
  /// **'( We will send you OTP to the mentioned Number )'**
  String get weWillSendYouOtp;

  /// No description provided for @phoneNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberPlaceholder;

  /// No description provided for @contactSupportForAssistance.
  ///
  /// In en, this message translates to:
  /// **'Contact support for assistance'**
  String get contactSupportForAssistance;

  /// No description provided for @haveTroubleLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Have trouble logging in?'**
  String get haveTroubleLoggingIn;

  /// No description provided for @logInWithOtp.
  ///
  /// In en, this message translates to:
  /// **'Log In with OTP'**
  String get logInWithOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to'**
  String get otpSentTo;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @findYourDreamVehicle.
  ///
  /// In en, this message translates to:
  /// **'Find Your Dream Vehicle'**
  String get findYourDreamVehicle;

  /// No description provided for @searchVehicles.
  ///
  /// In en, this message translates to:
  /// **'Search vehicles...'**
  String get searchVehicles;

  /// No description provided for @featuredVehicles.
  ///
  /// In en, this message translates to:
  /// **'Featured Vehicles'**
  String get featuredVehicles;

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get recentlyAdded;

  /// No description provided for @popularCategories.
  ///
  /// In en, this message translates to:
  /// **'Popular Categories'**
  String get popularCategories;

  /// No description provided for @nearbyDeals.
  ///
  /// In en, this message translates to:
  /// **'Nearby Deals'**
  String get nearbyDeals;

  /// No description provided for @cars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

  /// No description provided for @bikes.
  ///
  /// In en, this message translates to:
  /// **'Bikes'**
  String get bikes;

  /// No description provided for @trucks.
  ///
  /// In en, this message translates to:
  /// **'Trucks'**
  String get trucks;

  /// No description provided for @autos.
  ///
  /// In en, this message translates to:
  /// **'Autos'**
  String get autos;

  /// No description provided for @buses.
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get buses;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @kmDriven.
  ///
  /// In en, this message translates to:
  /// **'KM Driven'**
  String get kmDriven;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fuelType;

  /// No description provided for @transmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get transmission;

  /// No description provided for @owners.
  ///
  /// In en, this message translates to:
  /// **'Owners'**
  String get owners;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @sellerInfo.
  ///
  /// In en, this message translates to:
  /// **'Seller Information'**
  String get sellerInfo;

  /// No description provided for @contactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact Seller'**
  String get contactSeller;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @reportListing.
  ///
  /// In en, this message translates to:
  /// **'Report Listing'**
  String get reportListing;

  /// No description provided for @petrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get petrol;

  /// No description provided for @diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @cng.
  ///
  /// In en, this message translates to:
  /// **'CNG'**
  String get cng;

  /// No description provided for @lpg.
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get lpg;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @semiAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Semi-Automatic'**
  String get semiAutomatic;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred. Please try again.'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get serverError;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection available.'**
  String get noInternetConnection;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found.'**
  String get noDataFound;

  /// No description provided for @noVehiclesFound.
  ///
  /// In en, this message translates to:
  /// **'No vehicles found.'**
  String get noVehiclesFound;

  /// No description provided for @emptyFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.'**
  String get emptyFavorites;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please restart the process.'**
  String get sessionExpired;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email.'**
  String get passwordResetSent;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites!'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites!'**
  String get removedFromFavorites;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get passwordRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShort;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enterMobileNumber;

  /// No description provided for @otpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get otpSendFailed;

  /// No description provided for @rupee.
  ///
  /// In en, this message translates to:
  /// **'₹'**
  String get rupee;

  /// No description provided for @dollar.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get dollar;

  /// No description provided for @euro.
  ///
  /// In en, this message translates to:
  /// **'€'**
  String get euro;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @cc.
  ///
  /// In en, this message translates to:
  /// **'cc'**
  String get cc;

  /// No description provided for @hp.
  ///
  /// In en, this message translates to:
  /// **'hp'**
  String get hp;

  /// No description provided for @kmpl.
  ///
  /// In en, this message translates to:
  /// **'kmpl'**
  String get kmpl;

  /// No description provided for @seater.
  ///
  /// In en, this message translates to:
  /// **'seater'**
  String get seater;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'weeks ago'**
  String get weeksAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'months ago'**
  String get monthsAgo;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'years ago'**
  String get yearsAgo;

  /// No description provided for @intro1Text.
  ///
  /// In en, this message translates to:
  /// **'Trusted platform for verified listings, fair pricing, and easy transactions.\nStart your resale journey now!'**
  String get intro1Text;

  /// No description provided for @intro2Text.
  ///
  /// In en, this message translates to:
  /// **'Your Resale Hub for Commercial Vehicles & Construction Equipment\nResale Made Simple'**
  String get intro2Text;

  /// No description provided for @usernameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty.'**
  String get usernameCannotBeEmpty;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty.'**
  String get passwordCannotBeEmpty;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least {length} characters'**
  String usernameMinLength(int length);

  /// No description provided for @usernameInvalidPattern.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, underscores, and hyphens'**
  String get usernameInvalidPattern;

  /// No description provided for @usernameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Username already exists. Please choose a different username.'**
  String get usernameAlreadyExists;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists. Please use a different email address.'**
  String get emailAlreadyExists;

  /// No description provided for @incorrectOtp.
  ///
  /// In en, this message translates to:
  /// **'Incorrect OTP. Please try again.'**
  String get incorrectOtp;

  /// No description provided for @otpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'OTP verification failed. Please try again.'**
  String get otpVerificationFailed;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number. Please enter a valid phone number.'**
  String get invalidPhoneNumber;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {length} characters'**
  String passwordMinLength(int length);

  /// No description provided for @passwordMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at most {length} characters'**
  String passwordMaxLength(int length);

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get invalidCredentials;

  /// No description provided for @loginFailedCheckCredentials.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailedCheckCredentials;

  /// No description provided for @loginwithOTFailed.
  ///
  /// In en, this message translates to:
  /// **' Please check your Mobile Number .'**
  String get loginwithOTFailed;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @enterYourMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Mobile Number'**
  String get enterYourMobileNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @loginWith.
  ///
  /// In en, this message translates to:
  /// **'Login with'**
  String get loginWith;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @failedToSendOTP.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get failedToSendOTP;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating Account...'**
  String get creatingAccount;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @registerWithOTP.
  ///
  /// In en, this message translates to:
  /// **'Register with OTP'**
  String get registerWithOTP;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @termsAndConditionsText.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our'**
  String get termsAndConditionsText;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter your city'**
  String get enterCity;

  /// No description provided for @enterState.
  ///
  /// In en, this message translates to:
  /// **'Enter your state'**
  String get enterState;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterLastName;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter Password'**
  String get reEnterPassword;

  /// No description provided for @enterReEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get enterReEnterPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @firstNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'First name must be at least {length} characters'**
  String firstNameMinLength(int length);

  /// No description provided for @lastNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least {length} characters'**
  String lastNameMinLength(int length);

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityRequired;

  /// No description provided for @stateRequired.
  ///
  /// In en, this message translates to:
  /// **'State is required'**
  String get stateRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmailFormat;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @invalidPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid number'**
  String get invalidPhoneFormat;

  /// No description provided for @namesCannotContainNumbers.
  ///
  /// In en, this message translates to:
  /// **'Names cannot contain numbers'**
  String get namesCannotContainNumbers;

  /// No description provided for @invalidCharactersInName.
  ///
  /// In en, this message translates to:
  /// **'Invalid characters in name fields'**
  String get invalidCharactersInName;

  /// No description provided for @newPasswordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'New password cannot be empty'**
  String get newPasswordCannotBeEmpty;

  /// No description provided for @passwordMinLength8.
  ///
  /// In en, this message translates to:
  /// **'Password should be at least 8 characters'**
  String get passwordMinLength8;

  /// No description provided for @passwordComplexity.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter, one lowercase letter, one number and one special character.'**
  String get passwordComplexity;

  /// No description provided for @confirmPasswordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Confirm password cannot be empty'**
  String get confirmPasswordCannotBeEmpty;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select your City'**
  String get pleaseSelectCity;

  /// No description provided for @pleaseSelectState.
  ///
  /// In en, this message translates to:
  /// **'Please select your State'**
  String get pleaseSelectState;

  /// No description provided for @pleaseEnterCompleteOTP.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete OTP'**
  String get pleaseEnterCompleteOTP;

  /// No description provided for @invalidOTPEntered.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP entered'**
  String get invalidOTPEntered;

  /// No description provided for @otpCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'OTP cannot be empty'**
  String get otpCannotBeEmpty;

  /// No description provided for @emailCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email ID cannot be empty'**
  String get emailCannotBeEmpty;

  /// No description provided for @enterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmailAddress;

  /// No description provided for @phoneCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be empty'**
  String get phoneCannotBeEmpty;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhoneNumber;

  /// No description provided for @firstNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'First Name cannot be empty'**
  String get firstNameCannotBeEmpty;

  /// No description provided for @lastNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Last Name cannot be empty'**
  String get lastNameCannotBeEmpty;

  /// No description provided for @otpVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP Verified Successfully!'**
  String get otpVerifiedSuccessfully;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'New OTP sent to your mobile number!'**
  String get otpResent;

  /// No description provided for @failedToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP.'**
  String get failedToResendOtp;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully to your phone number'**
  String get otpSentSuccessfully;

  /// No description provided for @transactionIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID not found. Please request OTP again.'**
  String get transactionIdNotFound;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error occurred. Please try again.'**
  String get authError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error. Please check your input.'**
  String get validationError;

  /// No description provided for @networkErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred. Please check your connection.'**
  String get networkErrorOccurred;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @facingIssuesGeneral.
  ///
  /// In en, this message translates to:
  /// **'Having trouble?'**
  String get facingIssuesGeneral;

  /// No description provided for @accessYourPortalWithLogin.
  ///
  /// In en, this message translates to:
  /// **'Access Your Portal with Login'**
  String get accessYourPortalWithLogin;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please Log In '**
  String get pleaseLogIn;

  /// No description provided for @loginWithUsername.
  ///
  /// In en, this message translates to:
  /// **'Login with Username'**
  String get loginWithUsername;

  /// No description provided for @facingIssueWithOtpLogin.
  ///
  /// In en, this message translates to:
  /// **'Facing issue with OTP login?'**
  String get facingIssueWithOtpLogin;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @loggingInViaOtp.
  ///
  /// In en, this message translates to:
  /// **'Logging in via OTP'**
  String get loggingInViaOtp;

  /// No description provided for @enterSixDigitOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 Digit OTP sent to'**
  String get enterSixDigitOtpSentTo;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @didNotReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP?'**
  String get didNotReceiveOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @weAreAutomaticallyDetectingOtp.
  ///
  /// In en, this message translates to:
  /// **'We are automatically detecting OTP'**
  String get weAreAutomaticallyDetectingOtp;

  /// No description provided for @facingIssuesReceivingOtp.
  ///
  /// In en, this message translates to:
  /// **'Facing issues receiving OTP?'**
  String get facingIssuesReceivingOtp;

  /// No description provided for @stateCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'State cannot be empty'**
  String get stateCannotBeEmpty;

  /// No description provided for @stateMinLength.
  ///
  /// In en, this message translates to:
  /// **'State must be at least 2 characters'**
  String get stateMinLength;

  /// No description provided for @pleaseSelectStateFromDropdown.
  ///
  /// In en, this message translates to:
  /// **'Please select state from dropdown options'**
  String get pleaseSelectStateFromDropdown;

  /// No description provided for @cityCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'City cannot be empty'**
  String get cityCannotBeEmpty;

  /// No description provided for @cityMinLength.
  ///
  /// In en, this message translates to:
  /// **'City must be at least 2 characters'**
  String get cityMinLength;

  /// No description provided for @pleaseSelectCityFromDropdown.
  ///
  /// In en, this message translates to:
  /// **'Please select city from dropdown options'**
  String get pleaseSelectCityFromDropdown;

  /// No description provided for @vehicleImagesCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one vehicle image'**
  String get vehicleImagesCannotBeEmpty;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @emailId.
  ///
  /// In en, this message translates to:
  /// **'Email ID'**
  String get emailId;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'About Vahaan Bazar'**
  String get about_title;

  /// No description provided for @intro_heading.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get intro_heading;

  /// No description provided for @intro_text_1.
  ///
  /// In en, this message translates to:
  /// **'Vahaan Bazar is India’s first-of-its-kind, next-generation digital marketplace for commercial vehicles, construction equipment, and end-to-end vehicle-related services.'**
  String get intro_text_1;

  /// No description provided for @intro_text_2.
  ///
  /// In en, this message translates to:
  /// **'Our user-friendly interface and transparent ecosystem empower buyers and sellers to connect, negotiate, and finalize deals in a timely and cost-efficient manner.'**
  String get intro_text_2;

  /// No description provided for @who_we_are_heading.
  ///
  /// In en, this message translates to:
  /// **'Who We Are'**
  String get who_we_are_heading;

  /// No description provided for @who_we_are_text_1.
  ///
  /// In en, this message translates to:
  /// **'We are a Hyderabad-based automotive startup, led by seasoned professionals with deep experience across OEMs, aftermarket services, sales, and startup innovation.'**
  String get who_we_are_text_1;

  /// No description provided for @who_we_are_text_2.
  ///
  /// In en, this message translates to:
  /// **'With strong IT and operational capabilities, our team is focused on redefining how vehicles are bought, sold, and managed in India.'**
  String get who_we_are_text_2;

  /// No description provided for @mission_vision_heading.
  ///
  /// In en, this message translates to:
  /// **'Mission & Vision'**
  String get mission_vision_heading;

  /// No description provided for @mission_text.
  ///
  /// In en, this message translates to:
  /// **'To Build a Generic Customer Satisfaction and provide a Fab Experience in terms of Digital Used Vehicles Market Place.'**
  String get mission_text;

  /// No description provided for @vision_text.
  ///
  /// In en, this message translates to:
  /// **'Our vision is to create an automotive digital ecosystem which connects automobile customers, OEM’s, Dealers, Banks, Insurance companies and other stakeholders.'**
  String get vision_text;

  /// No description provided for @what_we_do_heading.
  ///
  /// In en, this message translates to:
  /// **'What We Do'**
  String get what_we_do_heading;

  /// No description provided for @what_we_do_text_1.
  ///
  /// In en, this message translates to:
  /// **'We bridge the gap between buyers and sellers through our all-in-one platform.'**
  String get what_we_do_text_1;

  /// No description provided for @what_we_do_text_2.
  ///
  /// In en, this message translates to:
  /// **'Whether you\'re a fleet operator, individual buyer, or dealer, Vahaan Bazar simplifies transactions with transparency and support at every step.'**
  String get what_we_do_text_2;

  /// No description provided for @offerings_heading.
  ///
  /// In en, this message translates to:
  /// **'Our offerings include:'**
  String get offerings_heading;

  /// No description provided for @offering_vehicle_listings.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Listings (new & used)'**
  String get offering_vehicle_listings;

  /// No description provided for @offering_valuation_tools.
  ///
  /// In en, this message translates to:
  /// **'Real-time Valuation Tools'**
  String get offering_valuation_tools;

  /// No description provided for @offering_financing_rta.
  ///
  /// In en, this message translates to:
  /// **'Financing & RTA Documentation Assistance'**
  String get offering_financing_rta;

  /// No description provided for @offering_post_sale_services.
  ///
  /// In en, this message translates to:
  /// **'Post-Sale Services (Insurance, Towing, and more)'**
  String get offering_post_sale_services;

  /// No description provided for @our_services_heading.
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get our_services_heading;

  /// No description provided for @service_vehicle_asset_solutions_heading.
  ///
  /// In en, this message translates to:
  /// **'Vehicle & Asset Solutions'**
  String get service_vehicle_asset_solutions_heading;

  /// No description provided for @service_buy_sell_title.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell:'**
  String get service_buy_sell_title;

  /// No description provided for @service_buy_sell_desc.
  ///
  /// In en, this message translates to:
  /// **'Quick listings and easy access to quality vehicles and machines'**
  String get service_buy_sell_desc;

  /// No description provided for @service_inspection_title.
  ///
  /// In en, this message translates to:
  /// **'Inspection:'**
  String get service_inspection_title;

  /// No description provided for @service_inspection_desc.
  ///
  /// In en, this message translates to:
  /// **'Ground checks and verified condition reports'**
  String get service_inspection_desc;

  /// No description provided for @service_valuation_title.
  ///
  /// In en, this message translates to:
  /// **'Valuation:'**
  String get service_valuation_title;

  /// No description provided for @service_valuation_desc.
  ///
  /// In en, this message translates to:
  /// **'Market-linked pricing tools to support informed decision-making'**
  String get service_valuation_desc;

  /// No description provided for @service_support_compliance_heading.
  ///
  /// In en, this message translates to:
  /// **'Support & Compliance'**
  String get service_support_compliance_heading;

  /// No description provided for @service_finance_support_title.
  ///
  /// In en, this message translates to:
  /// **'Finance Support:'**
  String get service_finance_support_title;

  /// No description provided for @service_finance_support_desc.
  ///
  /// In en, this message translates to:
  /// **'Access to multiple NBFCs and banks for financing'**
  String get service_finance_support_desc;

  /// No description provided for @service_rta_assistance_title.
  ///
  /// In en, this message translates to:
  /// **'RTA Assistance:'**
  String get service_rta_assistance_title;

  /// No description provided for @service_rta_assistance_desc.
  ///
  /// In en, this message translates to:
  /// **'Full documentation and ownership transfer solutions'**
  String get service_rta_assistance_desc;

  /// No description provided for @service_insurance_title.
  ///
  /// In en, this message translates to:
  /// **'Insurance:'**
  String get service_insurance_title;

  /// No description provided for @service_insurance_desc.
  ///
  /// In en, this message translates to:
  /// **'Best-in-class rates with high claim success support'**
  String get service_insurance_desc;

  /// No description provided for @service_operational_technical_heading.
  ///
  /// In en, this message translates to:
  /// **'Operational & Technical Services'**
  String get service_operational_technical_heading;

  /// No description provided for @service_leasing_rentals.
  ///
  /// In en, this message translates to:
  /// **'Leasing & Rentals'**
  String get service_leasing_rentals;

  /// No description provided for @service_fleet_management.
  ///
  /// In en, this message translates to:
  /// **'Fleet Management Solutions'**
  String get service_fleet_management;

  /// No description provided for @service_spare_parts.
  ///
  /// In en, this message translates to:
  /// **'Spare Parts (New & Used)'**
  String get service_spare_parts;

  /// No description provided for @service_auctions.
  ///
  /// In en, this message translates to:
  /// **'Auctions (B2B & B2C)'**
  String get service_auctions;

  /// No description provided for @service_scrap_towing.
  ///
  /// In en, this message translates to:
  /// **'Scrap Handling & Towing Services'**
  String get service_scrap_towing;

  /// No description provided for @service_web_app_dev.
  ///
  /// In en, this message translates to:
  /// **'Web & App Development for automotive businesses'**
  String get service_web_app_dev;

  /// No description provided for @why_choose_heading.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Vahaan Bazar?'**
  String get why_choose_heading;

  /// No description provided for @why_choose_extensive_reach_title.
  ///
  /// In en, this message translates to:
  /// **'Extensive Reach:'**
  String get why_choose_extensive_reach_title;

  /// No description provided for @why_choose_extensive_reach_desc.
  ///
  /// In en, this message translates to:
  /// **'Pan-India network of sellers and buyers'**
  String get why_choose_extensive_reach_desc;

  /// No description provided for @why_choose_trust_transparency_title.
  ///
  /// In en, this message translates to:
  /// **'Trust & Transparency:'**
  String get why_choose_trust_transparency_title;

  /// No description provided for @why_choose_trust_transparency_desc.
  ///
  /// In en, this message translates to:
  /// **'Verified data and honest pricing'**
  String get why_choose_trust_transparency_desc;

  /// No description provided for @why_choose_full_service_convenience_title.
  ///
  /// In en, this message translates to:
  /// **'Full-Service Convenience:'**
  String get why_choose_full_service_convenience_title;

  /// No description provided for @why_choose_full_service_convenience_desc.
  ///
  /// In en, this message translates to:
  /// **'One-stop platform from listing to delivery'**
  String get why_choose_full_service_convenience_desc;

  /// No description provided for @why_choose_industry_expertise_title.
  ///
  /// In en, this message translates to:
  /// **'Industry Expertise:'**
  String get why_choose_industry_expertise_title;

  /// No description provided for @why_choose_industry_expertise_desc.
  ///
  /// In en, this message translates to:
  /// **'Professionals guiding you with real-time support'**
  String get why_choose_industry_expertise_desc;

  /// No description provided for @our_commitment_heading.
  ///
  /// In en, this message translates to:
  /// **'Our Commitment'**
  String get our_commitment_heading;

  /// No description provided for @our_commitment_text_1.
  ///
  /// In en, this message translates to:
  /// **'At Vahaan Bazar, we don’t just enable transactions—we enhance the overall experience.'**
  String get our_commitment_text_1;

  /// No description provided for @our_commitment_text_2.
  ///
  /// In en, this message translates to:
  /// **'Our commitment is to continuously evolve, innovate, and create value for every stakeholder by placing customer satisfaction at the heart of everything we do.'**
  String get our_commitment_text_2;

  /// No description provided for @contact_us_heading.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_us_heading;

  /// No description provided for @contact_email.
  ///
  /// In en, this message translates to:
  /// **'contactus@vahaanbazar.com'**
  String get contact_email;

  /// No description provided for @contact_website.
  ///
  /// In en, this message translates to:
  /// **'www.vahaanbazar.com'**
  String get contact_website;

  /// No description provided for @contact_phone.
  ///
  /// In en, this message translates to:
  /// **'+91 88866 30456'**
  String get contact_phone;

  /// No description provided for @contact_address.
  ///
  /// In en, this message translates to:
  /// **'Vahaan Bazar Private Limited'**
  String get contact_address;

  /// No description provided for @follow_us.
  ///
  /// In en, this message translates to:
  /// **'Follow us on:'**
  String get follow_us;

  /// No description provided for @social_instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get social_instagram;

  /// No description provided for @social_facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get social_facebook;

  /// No description provided for @social_linkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get social_linkedin;

  /// No description provided for @social_handle.
  ///
  /// In en, this message translates to:
  /// **'@vahaanbazar'**
  String get social_handle;

  /// No description provided for @update_term.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_term;

  /// No description provided for @edit_profile_term.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_term;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @mySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'My Subscriptions'**
  String get mySubscriptions;

  /// No description provided for @remainders.
  ///
  /// In en, this message translates to:
  /// **'Remainders'**
  String get remainders;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help And Support'**
  String get helpAndSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @policy_title.
  ///
  /// In en, this message translates to:
  /// **'Unified Terms of Use, Privacy & Auction Policy'**
  String get policy_title;

  /// No description provided for @policy_intro_text_1.
  ///
  /// In en, this message translates to:
  /// **'This document governs your use of our vehicle auction platform and related services (the \"Platform\").'**
  String get policy_intro_text_1;

  /// No description provided for @policy_intro_text_2.
  ///
  /// In en, this message translates to:
  /// **'It consolidates the terms of use, privacy policies, and auction procedures for all users (\"Buyers\" and \"Sellers\").'**
  String get policy_intro_text_2;

  /// No description provided for @section_1_heading.
  ///
  /// In en, this message translates to:
  /// **'1. Legal Notice'**
  String get section_1_heading;

  /// No description provided for @section_1_text_1.
  ///
  /// In en, this message translates to:
  /// **'This is an electronic record as per the Information Technology Act, 2000.'**
  String get section_1_text_1;

  /// No description provided for @section_1_text_2.
  ///
  /// In en, this message translates to:
  /// **'Use of the Platform confirms your acceptance of these terms.'**
  String get section_1_text_2;

  /// No description provided for @section_2_heading.
  ///
  /// In en, this message translates to:
  /// **'2. Definitions'**
  String get section_2_heading;

  /// No description provided for @definition_user.
  ///
  /// In en, this message translates to:
  /// **'• User: Any registered individual or entity on the Platform.'**
  String get definition_user;

  /// No description provided for @definition_auction_buyer.
  ///
  /// In en, this message translates to:
  /// **'• Auction Buyer: Any person or business placing bids on vehicles.'**
  String get definition_auction_buyer;

  /// No description provided for @definition_seller.
  ///
  /// In en, this message translates to:
  /// **'• Seller: Any person or business listing vehicles for auction.'**
  String get definition_seller;

  /// No description provided for @definition_platform.
  ///
  /// In en, this message translates to:
  /// **'• Platform: The digital interface (website/app) that facilitates online vehicle auctions. i.e. Vahaan Bazar Private Limited.'**
  String get definition_platform;

  /// No description provided for @section_3_heading.
  ///
  /// In en, this message translates to:
  /// **'3. Eligibility & Registration'**
  String get section_3_heading;

  /// No description provided for @eligibility_text_1.
  ///
  /// In en, this message translates to:
  /// **'• Users must be 18 years or older.'**
  String get eligibility_text_1;

  /// No description provided for @eligibility_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Business users must be authorized to represent their organization.'**
  String get eligibility_text_2;

  /// No description provided for @eligibility_text_3.
  ///
  /// In en, this message translates to:
  /// **'• Accurate, updated registration details are mandatory.'**
  String get eligibility_text_3;

  /// No description provided for @eligibility_text_4.
  ///
  /// In en, this message translates to:
  /// **'• Platform reserves the right to reject or terminate access at its discretion.'**
  String get eligibility_text_4;

  /// No description provided for @section_4_heading.
  ///
  /// In en, this message translates to:
  /// **'4. Account Responsibilities'**
  String get section_4_heading;

  /// No description provided for @account_responsibility_text_1.
  ///
  /// In en, this message translates to:
  /// **'• Keep login credentials secure.'**
  String get account_responsibility_text_1;

  /// No description provided for @account_responsibility_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Do not create multiple accounts to circumvent restrictions.'**
  String get account_responsibility_text_2;

  /// No description provided for @account_responsibility_text_3.
  ///
  /// In en, this message translates to:
  /// **'• Users are responsible for all activities under their registered ID.'**
  String get account_responsibility_text_3;

  /// No description provided for @section_5_heading.
  ///
  /// In en, this message translates to:
  /// **'5. Privacy Policy'**
  String get section_5_heading;

  /// No description provided for @privacy_policy_intro.
  ///
  /// In en, this message translates to:
  /// **'We collect and process user data including:'**
  String get privacy_policy_intro;

  /// No description provided for @privacy_data_collected_1.
  ///
  /// In en, this message translates to:
  /// **'• Name, contact details, Browse history, payment records.'**
  String get privacy_data_collected_1;

  /// No description provided for @privacy_data_used_for.
  ///
  /// In en, this message translates to:
  /// **'• Used to provide services, personalize content, detect fraud, and improve security.'**
  String get privacy_data_used_for;

  /// No description provided for @privacy_user_rights.
  ///
  /// In en, this message translates to:
  /// **'• Users have the right to access, update, or delete their data by contacting support.'**
  String get privacy_user_rights;

  /// No description provided for @section_6_heading.
  ///
  /// In en, this message translates to:
  /// **'6. Use of Platform'**
  String get section_6_heading;

  /// No description provided for @use_platform_text_1.
  ///
  /// In en, this message translates to:
  /// **'• The Platform facilitates transactions; it is not a party to the sale contract.'**
  String get use_platform_text_1;

  /// No description provided for @use_platform_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Buyers must independently inspect vehicles and verify information.'**
  String get use_platform_text_2;

  /// No description provided for @use_platform_text_3.
  ///
  /// In en, this message translates to:
  /// **'• All listings are strictly \"As-Is-Where-Is\".'**
  String get use_platform_text_3;

  /// No description provided for @section_7_heading.
  ///
  /// In en, this message translates to:
  /// **'7. Auction & Bidding Rules'**
  String get section_7_heading;

  /// No description provided for @bidding_rules_text_1.
  ///
  /// In en, this message translates to:
  /// **'• All bids are legally binding.'**
  String get bidding_rules_text_1;

  /// No description provided for @bidding_rules_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Highest bid (price + earliest time) prevails.'**
  String get bidding_rules_text_2;

  /// No description provided for @bidding_rules_text_3.
  ///
  /// In en, this message translates to:
  /// **'• Bids may be rejected if found suspicious.'**
  String get bidding_rules_text_3;

  /// No description provided for @bidding_rules_text_4.
  ///
  /// In en, this message translates to:
  /// **'• Sellers have final discretion over sale acceptance.'**
  String get bidding_rules_text_4;

  /// No description provided for @section_8_heading.
  ///
  /// In en, this message translates to:
  /// **'8. Vehicle Inspection'**
  String get section_8_heading;

  /// No description provided for @vehicle_inspection_text_1.
  ///
  /// In en, this message translates to:
  /// **'• Vehicle condition certifications are indicative only.'**
  String get vehicle_inspection_text_1;

  /// No description provided for @vehicle_inspection_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Buyers must inspect vehicles themselves and verify liabilities (taxes, fines, etc.).'**
  String get vehicle_inspection_text_2;

  /// No description provided for @vehicle_inspection_text_3.
  ///
  /// In en, this message translates to:
  /// **'• The Platform does not guarantee listing accuracy.'**
  String get vehicle_inspection_text_3;

  /// No description provided for @section_9_heading.
  ///
  /// In en, this message translates to:
  /// **'9. Payments'**
  String get section_9_heading;

  /// No description provided for @payments_text_1.
  ///
  /// In en, this message translates to:
  /// **'• Payment is due within the specified timeline (e.g., 5–7 working days).'**
  String get payments_text_1;

  /// No description provided for @payments_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Buyers pay applicable taxes, parking charges, and RTO/GST/TCS dues.'**
  String get payments_text_2;

  /// No description provided for @payments_text_3.
  ///
  /// In en, this message translates to:
  /// **'• Non-payment may lead to forfeiture or legal action.'**
  String get payments_text_3;

  /// No description provided for @section_10_heading.
  ///
  /// In en, this message translates to:
  /// **'10. Ownership Transfer'**
  String get section_10_heading;

  /// No description provided for @ownership_transfer_text_1.
  ///
  /// In en, this message translates to:
  /// **'• Buyers must transfer ownership within 60 days post-NOC/TTO issuance.'**
  String get ownership_transfer_text_1;

  /// No description provided for @ownership_transfer_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Failure to comply may result in account blocking.'**
  String get ownership_transfer_text_2;

  /// No description provided for @ownership_transfer_text_3.
  ///
  /// In en, this message translates to:
  /// **'• Tax receipts may be required for vehicle release.'**
  String get ownership_transfer_text_3;

  /// No description provided for @section_11_heading.
  ///
  /// In en, this message translates to:
  /// **'11. Indemnity'**
  String get section_11_heading;

  /// No description provided for @indemnity_intro.
  ///
  /// In en, this message translates to:
  /// **'Users agree to indemnify the Platform from all claims, penalties, or liabilities arising from:'**
  String get indemnity_intro;

  /// No description provided for @indemnity_item_1.
  ///
  /// In en, this message translates to:
  /// **'• Breach of terms'**
  String get indemnity_item_1;

  /// No description provided for @indemnity_item_2.
  ///
  /// In en, this message translates to:
  /// **'• Law violations'**
  String get indemnity_item_2;

  /// No description provided for @indemnity_item_3.
  ///
  /// In en, this message translates to:
  /// **'• Post-sale misuse of vehicles'**
  String get indemnity_item_3;

  /// No description provided for @section_12_heading.
  ///
  /// In en, this message translates to:
  /// **'12. Limitation of Liability'**
  String get section_12_heading;

  /// No description provided for @limitation_liability_text_1.
  ///
  /// In en, this message translates to:
  /// **'• Services are offered \"as-is.\"'**
  String get limitation_liability_text_1;

  /// No description provided for @limitation_liability_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Platform is not liable for delays, failures, or listing inaccuracies.'**
  String get limitation_liability_text_2;

  /// No description provided for @limitation_liability_text_3.
  ///
  /// In en, this message translates to:
  /// **'• Maximum liability is limited to any service fee paid to the Platform.'**
  String get limitation_liability_text_3;

  /// No description provided for @section_13_heading.
  ///
  /// In en, this message translates to:
  /// **'13. Intellectual Property'**
  String get section_13_heading;

  /// No description provided for @intellectual_property_text.
  ///
  /// In en, this message translates to:
  /// **'All platform content (text, visuals, tools) is protected IP. No reproduction, distribution, or unauthorized usage is allowed.'**
  String get intellectual_property_text;

  /// No description provided for @section_14_heading.
  ///
  /// In en, this message translates to:
  /// **'14. Dispute Resolution'**
  String get section_14_heading;

  /// No description provided for @dispute_resolution_text_1.
  ///
  /// In en, this message translates to:
  /// **'• Indian law governs this agreement.'**
  String get dispute_resolution_text_1;

  /// No description provided for @dispute_resolution_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Arbitration will be conducted in Hyderabad under the Arbitration & Conciliation Act, 1996.'**
  String get dispute_resolution_text_2;

  /// No description provided for @dispute_resolution_text_3.
  ///
  /// In en, this message translates to:
  /// **'• Each party bears its own legal costs unless otherwise specified.'**
  String get dispute_resolution_text_3;

  /// No description provided for @section_15_heading.
  ///
  /// In en, this message translates to:
  /// **'15. Notices'**
  String get section_15_heading;

  /// No description provided for @notices_text_1.
  ///
  /// In en, this message translates to:
  /// **'• Official communication will be made via registered mail or email.'**
  String get notices_text_1;

  /// No description provided for @notices_text_2.
  ///
  /// In en, this message translates to:
  /// **'• Users must keep their contact information current.'**
  String get notices_text_2;

  /// No description provided for @policy_acknowledgement.
  ///
  /// In en, this message translates to:
  /// **'By continuing to use the Platform, you acknowledge that you have read, understood, and agreed to these unified terms of Vahaan Bazar Private Limited.'**
  String get policy_acknowledgement;

  /// No description provided for @terms_and_conditions_title.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_and_conditions_title;

  /// No description provided for @delete_account_warning.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account is permanent, and all data will be lost. Contact customer support for assistance before proceeding.'**
  String get delete_account_warning;

  /// No description provided for @my_subscriptions_title.
  ///
  /// In en, this message translates to:
  /// **'My Subscriptions'**
  String get my_subscriptions_title;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @vehicle_id.
  ///
  /// In en, this message translates to:
  /// **'Vehicle ID'**
  String get vehicle_id;

  /// No description provided for @auction_id.
  ///
  /// In en, this message translates to:
  /// **'Auction ID'**
  String get auction_id;

  /// No description provided for @seller_reference.
  ///
  /// In en, this message translates to:
  /// **'Seller Reference'**
  String get seller_reference;

  /// No description provided for @repo_date.
  ///
  /// In en, this message translates to:
  /// **'Repo Date'**
  String get repo_date;

  /// No description provided for @transaction_fees.
  ///
  /// In en, this message translates to:
  /// **'Transaction Fees'**
  String get transaction_fees;

  /// No description provided for @parking_charges.
  ///
  /// In en, this message translates to:
  /// **'Parking Charges'**
  String get parking_charges;

  /// No description provided for @rc_availability.
  ///
  /// In en, this message translates to:
  /// **'RC Availability'**
  String get rc_availability;

  /// No description provided for @make.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get make;

  /// No description provided for @registration_no.
  ///
  /// In en, this message translates to:
  /// **'Registration No'**
  String get registration_no;

  /// No description provided for @chassis_no.
  ///
  /// In en, this message translates to:
  /// **'Chassis No'**
  String get chassis_no;

  /// No description provided for @engine_no.
  ///
  /// In en, this message translates to:
  /// **'Engine No'**
  String get engine_no;

  /// No description provided for @registered_rto.
  ///
  /// In en, this message translates to:
  /// **'Registered RTO'**
  String get registered_rto;

  /// No description provided for @variant.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get variant;

  /// No description provided for @vehicle_type.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicle_type;

  /// No description provided for @fuel_type.
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fuel_type;

  /// No description provided for @kilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get kilometers;

  /// No description provided for @colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// No description provided for @market_value.
  ///
  /// In en, this message translates to:
  /// **'Market Value'**
  String get market_value;

  /// No description provided for @max_bids.
  ///
  /// In en, this message translates to:
  /// **'Max Bids'**
  String get max_bids;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @minimum_price.
  ///
  /// In en, this message translates to:
  /// **'Minimum Price'**
  String get minimum_price;

  /// No description provided for @reserve_price.
  ///
  /// In en, this message translates to:
  /// **'Reserve Price'**
  String get reserve_price;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @yard_name.
  ///
  /// In en, this message translates to:
  /// **'Yard Name'**
  String get yard_name;

  /// No description provided for @yard_location.
  ///
  /// In en, this message translates to:
  /// **'Yard Location'**
  String get yard_location;

  /// No description provided for @contact_person_name.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Name'**
  String get contact_person_name;

  /// No description provided for @contact_person_number.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Number'**
  String get contact_person_number;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @inserted_at.
  ///
  /// In en, this message translates to:
  /// **'Inserted At'**
  String get inserted_at;

  /// No description provided for @updated_at.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get updated_at;

  /// No description provided for @choose_your_subscription_plan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Subscription Plan'**
  String get choose_your_subscription_plan;

  /// No description provided for @download_listing.
  ///
  /// In en, this message translates to:
  /// **'Download Listing'**
  String get download_listing;

  /// No description provided for @bid_now.
  ///
  /// In en, this message translates to:
  /// **'Bid Now'**
  String get bid_now;

  /// No description provided for @your_bid.
  ///
  /// In en, this message translates to:
  /// **'Your Bid'**
  String get your_bid;

  /// No description provided for @bids_left.
  ///
  /// In en, this message translates to:
  /// **'Bids Left'**
  String get bids_left;

  /// No description provided for @start_price.
  ///
  /// In en, this message translates to:
  /// **'Start Price'**
  String get start_price;

  /// No description provided for @bids_received.
  ///
  /// In en, this message translates to:
  /// **'Bids Received'**
  String get bids_received;

  /// No description provided for @choose_your_refundable_deposite_plan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Refundable Deposit Plan'**
  String get choose_your_refundable_deposite_plan;

  /// No description provided for @fieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldIsRequired;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get ownerName;

  /// No description provided for @enterOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Enter Owner Name'**
  String get enterOwnerName;

  /// No description provided for @vehicleRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration Number'**
  String get vehicleRegistrationNumber;

  /// No description provided for @enterRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Registration Number'**
  String get enterRegistrationNumber;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @chassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Chasis Number'**
  String get chassisNumber;

  /// No description provided for @enterChassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Chasis Number'**
  String get enterChassisNumber;

  /// No description provided for @manufacturingYear.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing Year'**
  String get manufacturingYear;

  /// No description provided for @enterManufacturingYear.
  ///
  /// In en, this message translates to:
  /// **'Enter Manufacturing Year'**
  String get enterManufacturingYear;

  /// No description provided for @engineNumber.
  ///
  /// In en, this message translates to:
  /// **'Engine Number'**
  String get engineNumber;

  /// No description provided for @enterEngineNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Engine Number'**
  String get enterEngineNumber;

  /// No description provided for @rtoLocation.
  ///
  /// In en, this message translates to:
  /// **'RTO Location'**
  String get rtoLocation;

  /// No description provided for @enterRtoLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter RTO Location'**
  String get enterRtoLocation;

  /// No description provided for @vehicleCondition.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Condition'**
  String get vehicleCondition;

  /// No description provided for @insuranceValidTill.
  ///
  /// In en, this message translates to:
  /// **'Insurance valid Till'**
  String get insuranceValidTill;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @fitnessValidTill.
  ///
  /// In en, this message translates to:
  /// **'Fitness Valid Till'**
  String get fitnessValidTill;

  /// No description provided for @taxPending.
  ///
  /// In en, this message translates to:
  /// **'Tax Pending'**
  String get taxPending;

  /// No description provided for @ownerNumber.
  ///
  /// In en, this message translates to:
  /// **'Owner Number'**
  String get ownerNumber;

  /// No description provided for @enterOwnerNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Owner Number'**
  String get enterOwnerNumber;

  /// No description provided for @vehicleNotes.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Notes'**
  String get vehicleNotes;

  /// No description provided for @enterVehicleConditionNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle Condition Notes'**
  String get enterVehicleConditionNotes;

  /// No description provided for @hypothecation.
  ///
  /// In en, this message translates to:
  /// **'Hypothecation'**
  String get hypothecation;

  /// No description provided for @hypothecatedTo.
  ///
  /// In en, this message translates to:
  /// **'Hypothecated To'**
  String get hypothecatedTo;

  /// No description provided for @enterHypothecatedTo.
  ///
  /// In en, this message translates to:
  /// **'Enter Hypothecated To'**
  String get enterHypothecatedTo;

  /// No description provided for @caseType.
  ///
  /// In en, this message translates to:
  /// **'Case Type'**
  String get caseType;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @enterHours.
  ///
  /// In en, this message translates to:
  /// **'Enter Hours'**
  String get enterHours;

  /// No description provided for @odometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get odometer;

  /// No description provided for @enterOdometer.
  ///
  /// In en, this message translates to:
  /// **'Enter Odometer'**
  String get enterOdometer;

  /// No description provided for @fuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuel;

  /// No description provided for @transmissionType.
  ///
  /// In en, this message translates to:
  /// **'Transmission Type'**
  String get transmissionType;

  /// No description provided for @accidentalStats.
  ///
  /// In en, this message translates to:
  /// **'Accidental Stats'**
  String get accidentalStats;

  /// No description provided for @engineRemarks.
  ///
  /// In en, this message translates to:
  /// **'Engine Remarks'**
  String get engineRemarks;

  /// No description provided for @enterEngineRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter engine remarks'**
  String get enterEngineRemarks;

  /// No description provided for @engineCondition.
  ///
  /// In en, this message translates to:
  /// **'Engine Condition'**
  String get engineCondition;

  /// No description provided for @engineImages.
  ///
  /// In en, this message translates to:
  /// **'Engine Images'**
  String get engineImages;

  /// No description provided for @transmissionRemarks.
  ///
  /// In en, this message translates to:
  /// **'Transmission Remarks'**
  String get transmissionRemarks;

  /// No description provided for @enterTransmissionRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter transmission remarks'**
  String get enterTransmissionRemarks;

  /// No description provided for @transmissionCondition.
  ///
  /// In en, this message translates to:
  /// **'Transmission Condition'**
  String get transmissionCondition;

  /// No description provided for @transmissionImages.
  ///
  /// In en, this message translates to:
  /// **'Transmission Images'**
  String get transmissionImages;

  /// No description provided for @suspensionRemarks.
  ///
  /// In en, this message translates to:
  /// **'Suspension Remarks'**
  String get suspensionRemarks;

  /// No description provided for @enterSuspensionRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter suspension remarks'**
  String get enterSuspensionRemarks;

  /// No description provided for @suspensionCondition.
  ///
  /// In en, this message translates to:
  /// **'Suspension Condition'**
  String get suspensionCondition;

  /// No description provided for @suspensionImages.
  ///
  /// In en, this message translates to:
  /// **'Suspension Images'**
  String get suspensionImages;

  /// No description provided for @tyres.
  ///
  /// In en, this message translates to:
  /// **'Tyres'**
  String get tyres;

  /// No description provided for @frontAxleTyresPercentage.
  ///
  /// In en, this message translates to:
  /// **'Front Axle Tyres Percentage'**
  String get frontAxleTyresPercentage;

  /// No description provided for @rearAxleTyresPercentage.
  ///
  /// In en, this message translates to:
  /// **'Rear Axle Tyres Percentage'**
  String get rearAxleTyresPercentage;

  /// No description provided for @tyreImages.
  ///
  /// In en, this message translates to:
  /// **'Tyre Images'**
  String get tyreImages;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @bodyRemarks.
  ///
  /// In en, this message translates to:
  /// **'Body Remarks'**
  String get bodyRemarks;

  /// No description provided for @enterBodyRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter body remarks'**
  String get enterBodyRemarks;

  /// No description provided for @bodyCondition.
  ///
  /// In en, this message translates to:
  /// **'Body Condition'**
  String get bodyCondition;

  /// No description provided for @bodyFrontImage.
  ///
  /// In en, this message translates to:
  /// **'Body Front Image'**
  String get bodyFrontImage;

  /// No description provided for @bodyBackImage.
  ///
  /// In en, this message translates to:
  /// **'Body Back Image'**
  String get bodyBackImage;

  /// No description provided for @bodyLeftImage.
  ///
  /// In en, this message translates to:
  /// **'Body Left Image'**
  String get bodyLeftImage;

  /// No description provided for @bodyRightImage.
  ///
  /// In en, this message translates to:
  /// **'Body Right Image'**
  String get bodyRightImage;

  /// No description provided for @cabinInterior.
  ///
  /// In en, this message translates to:
  /// **'Cabin & Interior'**
  String get cabinInterior;

  /// No description provided for @cabinInteriorRemarks.
  ///
  /// In en, this message translates to:
  /// **'Cabin & Interior Remarks'**
  String get cabinInteriorRemarks;

  /// No description provided for @enterCabinRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter cabin remarks'**
  String get enterCabinRemarks;

  /// No description provided for @cabinInteriorCondition.
  ///
  /// In en, this message translates to:
  /// **'Cabin & Interior Condition'**
  String get cabinInteriorCondition;

  /// No description provided for @cabinInteriorImages.
  ///
  /// In en, this message translates to:
  /// **'Cabin & Interior Images'**
  String get cabinInteriorImages;

  /// No description provided for @electrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get electrical;

  /// No description provided for @electricalRemarks.
  ///
  /// In en, this message translates to:
  /// **'Electrical Remarks'**
  String get electricalRemarks;

  /// No description provided for @enterElectricalRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter electrical remarks'**
  String get enterElectricalRemarks;

  /// No description provided for @electricalCondition.
  ///
  /// In en, this message translates to:
  /// **'Electrical Condition'**
  String get electricalCondition;

  /// No description provided for @electricalImages.
  ///
  /// In en, this message translates to:
  /// **'Electrical Images'**
  String get electricalImages;

  /// No description provided for @chassis.
  ///
  /// In en, this message translates to:
  /// **'Chasis'**
  String get chassis;

  /// No description provided for @chassisRemarks.
  ///
  /// In en, this message translates to:
  /// **'Chasis Remarks'**
  String get chassisRemarks;

  /// No description provided for @enterChassisRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter chasis remarks'**
  String get enterChassisRemarks;

  /// No description provided for @chassisCondition.
  ///
  /// In en, this message translates to:
  /// **'Chasis Condition'**
  String get chassisCondition;

  /// No description provided for @chassisImages.
  ///
  /// In en, this message translates to:
  /// **'Chasis Images'**
  String get chassisImages;

  /// No description provided for @odometerRemarks.
  ///
  /// In en, this message translates to:
  /// **'Odometer Remarks'**
  String get odometerRemarks;

  /// No description provided for @enterOdometerRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter odometer remarks'**
  String get enterOdometerRemarks;

  /// No description provided for @odometerImages.
  ///
  /// In en, this message translates to:
  /// **'Odometer Images'**
  String get odometerImages;

  /// No description provided for @assetMarketValue.
  ///
  /// In en, this message translates to:
  /// **'Asset Market Value (Optional)'**
  String get assetMarketValue;

  /// No description provided for @enterMarketValue.
  ///
  /// In en, this message translates to:
  /// **'Enter market value'**
  String get enterMarketValue;

  /// No description provided for @otherRemarks.
  ///
  /// In en, this message translates to:
  /// **'Other Remarks (Optional)'**
  String get otherRemarks;

  /// No description provided for @enterOtherRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter other remarks'**
  String get enterOtherRemarks;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @bus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get bus;

  /// No description provided for @tractor.
  ///
  /// In en, this message translates to:
  /// **'Tractor'**
  String get tractor;

  /// No description provided for @auction.
  ///
  /// In en, this message translates to:
  /// **'Auction'**
  String get auction;

  /// No description provided for @buyAndSell.
  ///
  /// In en, this message translates to:
  /// **'Buy&Sell'**
  String get buyAndSell;

  /// No description provided for @byOwnerRequest.
  ///
  /// In en, this message translates to:
  /// **'By owner request'**
  String get byOwnerRequest;

  /// Snackbar message on successful form submission
  ///
  /// In en, this message translates to:
  /// **'Form submitted'**
  String get formSubmitted;

  /// No description provided for @pleaseCompleteRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete required fields'**
  String get pleaseCompleteRequiredFields;

  /// No description provided for @loadingBrands.
  ///
  /// In en, this message translates to:
  /// **'Loading brands...'**
  String get loadingBrands;

  /// No description provided for @selectCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a category first'**
  String get selectCategoryFirst;

  /// No description provided for @enterVehicleBrand.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle brand'**
  String get enterVehicleBrand;

  /// No description provided for @loadingTireOptions.
  ///
  /// In en, this message translates to:
  /// **'Loading tire options...'**
  String get loadingTireOptions;

  /// No description provided for @vehicleCategory.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Category'**
  String get vehicleCategory;

  /// No description provided for @vehicleState.
  ///
  /// In en, this message translates to:
  /// **'Vehicle State'**
  String get vehicleState;

  /// No description provided for @vehicleCity.
  ///
  /// In en, this message translates to:
  /// **'Vehicle City'**
  String get vehicleCity;

  /// No description provided for @accidentalStatus.
  ///
  /// In en, this message translates to:
  /// **'Accidental Status'**
  String get accidentalStatus;

  /// No description provided for @bodyFrontImages.
  ///
  /// In en, this message translates to:
  /// **'Body Front Images'**
  String get bodyFrontImages;

  /// No description provided for @bodyBackImages.
  ///
  /// In en, this message translates to:
  /// **'Body Back Images'**
  String get bodyBackImages;

  /// No description provided for @bodyLeftImages.
  ///
  /// In en, this message translates to:
  /// **'Body Left Images'**
  String get bodyLeftImages;

  /// No description provided for @bodyRightImages.
  ///
  /// In en, this message translates to:
  /// **'Body Right Images'**
  String get bodyRightImages;

  /// No description provided for @cabinAndInterior.
  ///
  /// In en, this message translates to:
  /// **'Cabin & Interior'**
  String get cabinAndInterior;

  /// No description provided for @cabinAndInteriorRemarks.
  ///
  /// In en, this message translates to:
  /// **'Cabin & Interior Remarks'**
  String get cabinAndInteriorRemarks;

  /// No description provided for @cabinAndInteriorCondition.
  ///
  /// In en, this message translates to:
  /// **'Cabin & Interior Condition'**
  String get cabinAndInteriorCondition;

  /// No description provided for @cabinAndInteriorImages.
  ///
  /// In en, this message translates to:
  /// **'Cabin & Interior Images'**
  String get cabinAndInteriorImages;

  /// No description provided for @chasisRemarks.
  ///
  /// In en, this message translates to:
  /// **'Chasis Remarks'**
  String get chasisRemarks;

  /// No description provided for @chasisCondition.
  ///
  /// In en, this message translates to:
  /// **'Chasis Condition'**
  String get chasisCondition;

  /// No description provided for @chasisImages.
  ///
  /// In en, this message translates to:
  /// **'Chasis Images'**
  String get chasisImages;

  /// No description provided for @assetMarketValueOptional.
  ///
  /// In en, this message translates to:
  /// **'Asset Market Value (Optional)'**
  String get assetMarketValueOptional;

  /// No description provided for @otherRemarksOptional.
  ///
  /// In en, this message translates to:
  /// **'Other Remarks (Optional)'**
  String get otherRemarksOptional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @internalTeamInspectionReport.
  ///
  /// In en, this message translates to:
  /// **'Internal Team Inspection Report'**
  String get internalTeamInspectionReport;

  /// No description provided for @ownerNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Owner name is required'**
  String get ownerNameValidation;

  /// No description provided for @vehicleRegNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration number is required'**
  String get vehicleRegNumberValidation;

  /// No description provided for @vehicleCategoryValidation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle category is required'**
  String get vehicleCategoryValidation;

  /// No description provided for @chassisNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Chassis number is required'**
  String get chassisNumberValidation;

  /// No description provided for @engineNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Engine number is required'**
  String get engineNumberValidation;

  /// No description provided for @manufacturingYearValidation.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing year is required'**
  String get manufacturingYearValidation;

  /// No description provided for @vehicleStateValidation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle state is required'**
  String get vehicleStateValidation;

  /// No description provided for @vehicleCityValidation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle city is required'**
  String get vehicleCityValidation;

  /// No description provided for @rtoLocationValidation.
  ///
  /// In en, this message translates to:
  /// **'RTO location is required'**
  String get rtoLocationValidation;

  /// No description provided for @vehicleConditionValidation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle condition is required'**
  String get vehicleConditionValidation;

  /// No description provided for @insuranceDateValidation.
  ///
  /// In en, this message translates to:
  /// **'Insurance valid till date is required'**
  String get insuranceDateValidation;

  /// No description provided for @fitnessDateValidation.
  ///
  /// In en, this message translates to:
  /// **'Fitness valid till date is required'**
  String get fitnessDateValidation;

  /// No description provided for @ownerNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Owner number is required'**
  String get ownerNumberValidation;

  /// No description provided for @hypothecationToValidation.
  ///
  /// In en, this message translates to:
  /// **'Hypothecated to is required when hypothecation is Yes'**
  String get hypothecationToValidation;

  /// No description provided for @caseTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Case type is required'**
  String get caseTypeValidation;

  /// No description provided for @hoursValidation.
  ///
  /// In en, this message translates to:
  /// **'Hours are required'**
  String get hoursValidation;

  /// No description provided for @odometerReadingValidation.
  ///
  /// In en, this message translates to:
  /// **'Odometer reading is required'**
  String get odometerReadingValidation;

  /// No description provided for @fuelTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Fuel type is required'**
  String get fuelTypeValidation;

  /// No description provided for @transmissionTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Transmission type is required'**
  String get transmissionTypeValidation;

  /// No description provided for @accidentalStatusValidation.
  ///
  /// In en, this message translates to:
  /// **'Accidental status is required'**
  String get accidentalStatusValidation;

  /// No description provided for @engineRemarksValidation.
  ///
  /// In en, this message translates to:
  /// **'Engine remarks are required'**
  String get engineRemarksValidation;

  /// No description provided for @engineConditionValidation.
  ///
  /// In en, this message translates to:
  /// **'Engine condition is required'**
  String get engineConditionValidation;

  /// No description provided for @engineImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Engine images are required'**
  String get engineImagesValidation;

  /// No description provided for @transmissionRemarksValidation.
  ///
  /// In en, this message translates to:
  /// **'Transmission remarks are required'**
  String get transmissionRemarksValidation;

  /// No description provided for @transmissionConditionValidation.
  ///
  /// In en, this message translates to:
  /// **'Transmission condition is required'**
  String get transmissionConditionValidation;

  /// No description provided for @transmissionImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Transmission images are required'**
  String get transmissionImagesValidation;

  /// No description provided for @suspensionRemarksValidation.
  ///
  /// In en, this message translates to:
  /// **'Suspension remarks are required'**
  String get suspensionRemarksValidation;

  /// No description provided for @suspensionConditionValidation.
  ///
  /// In en, this message translates to:
  /// **'Suspension condition is required'**
  String get suspensionConditionValidation;

  /// No description provided for @suspensionImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Suspension images are required'**
  String get suspensionImagesValidation;

  /// No description provided for @frontAxleTyresValidation.
  ///
  /// In en, this message translates to:
  /// **'Front axle tyres percentage is required'**
  String get frontAxleTyresValidation;

  /// No description provided for @rearAxleTyresValidation.
  ///
  /// In en, this message translates to:
  /// **'Rear axle tyres percentage is required'**
  String get rearAxleTyresValidation;

  /// No description provided for @tyreImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Tyre images are required'**
  String get tyreImagesValidation;

  /// No description provided for @bodyRemarksValidation.
  ///
  /// In en, this message translates to:
  /// **'Body remarks are required'**
  String get bodyRemarksValidation;

  /// No description provided for @bodyConditionValidation.
  ///
  /// In en, this message translates to:
  /// **'Body condition is required'**
  String get bodyConditionValidation;

  /// No description provided for @bodyFrontImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Body front images are required'**
  String get bodyFrontImagesValidation;

  /// No description provided for @bodyBackImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Body back images are required'**
  String get bodyBackImagesValidation;

  /// No description provided for @bodyLeftImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Body left images are required'**
  String get bodyLeftImagesValidation;

  /// No description provided for @bodyRightImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Body right images are required'**
  String get bodyRightImagesValidation;

  /// No description provided for @cabinInteriorRemarksValidation.
  ///
  /// In en, this message translates to:
  /// **'Cabin & interior remarks are required'**
  String get cabinInteriorRemarksValidation;

  /// No description provided for @cabinInteriorConditionValidation.
  ///
  /// In en, this message translates to:
  /// **'Cabin & interior condition is required'**
  String get cabinInteriorConditionValidation;

  /// No description provided for @cabinInteriorImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Cabin & interior images are required'**
  String get cabinInteriorImagesValidation;

  /// No description provided for @electricalRemarksValidation.
  ///
  /// In en, this message translates to:
  /// **'Electrical remarks are required'**
  String get electricalRemarksValidation;

  /// No description provided for @electricalConditionValidation.
  ///
  /// In en, this message translates to:
  /// **'Electrical condition is required'**
  String get electricalConditionValidation;

  /// No description provided for @electricalImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Electrical images are required'**
  String get electricalImagesValidation;

  /// No description provided for @chassisRemarksValidation.
  ///
  /// In en, this message translates to:
  /// **'Chassis remarks are required'**
  String get chassisRemarksValidation;

  /// No description provided for @chassisConditionValidation.
  ///
  /// In en, this message translates to:
  /// **'Chassis condition is required'**
  String get chassisConditionValidation;

  /// No description provided for @chassisImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Chassis images are required'**
  String get chassisImagesValidation;

  /// No description provided for @odometerRemarksValidation.
  ///
  /// In en, this message translates to:
  /// **'Odometer remarks are required'**
  String get odometerRemarksValidation;

  /// No description provided for @odometerImagesValidation.
  ///
  /// In en, this message translates to:
  /// **'Odometer images are required'**
  String get odometerImagesValidation;

  /// No description provided for @selectBrand.
  ///
  /// In en, this message translates to:
  /// **'Select Brand'**
  String get selectBrand;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// No description provided for @selectFuelType.
  ///
  /// In en, this message translates to:
  /// **'Select Fuel Type'**
  String get selectFuelType;

  /// No description provided for @selectTransmission.
  ///
  /// In en, this message translates to:
  /// **'Select Transmission'**
  String get selectTransmission;

  /// No description provided for @selectAccidentalStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Accidental Status'**
  String get selectAccidentalStatus;

  /// No description provided for @selectEngineCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Engine Condition'**
  String get selectEngineCondition;

  /// No description provided for @selectTransmissionCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Transmission Condition'**
  String get selectTransmissionCondition;

  /// No description provided for @selectSuspensionCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Suspension Condition'**
  String get selectSuspensionCondition;

  /// No description provided for @selectFrontAxleTyres.
  ///
  /// In en, this message translates to:
  /// **'Select Front Axle Tyres'**
  String get selectFrontAxleTyres;

  /// No description provided for @selectRearAxleTyres.
  ///
  /// In en, this message translates to:
  /// **'Select Rear Axle Tyres'**
  String get selectRearAxleTyres;

  /// No description provided for @selectBodyCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Body Condition'**
  String get selectBodyCondition;

  /// No description provided for @selectCabinCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Cabin & Interior Condition'**
  String get selectCabinCondition;

  /// No description provided for @selectElectricalCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Electrical Condition'**
  String get selectElectricalCondition;

  /// No description provided for @selectChassisCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Chassis Condition'**
  String get selectChassisCondition;

  /// No description provided for @selectTyreCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Tyre Condition'**
  String get selectTyreCondition;

  /// No description provided for @selectCaseType.
  ///
  /// In en, this message translates to:
  /// **'Select Case Type'**
  String get selectCaseType;

  /// No description provided for @brandValidation.
  ///
  /// In en, this message translates to:
  /// **'Brand is required'**
  String get brandValidation;

  /// No description provided for @engine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get engine;

  /// No description provided for @selectVehicleCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Condition'**
  String get selectVehicleCondition;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter Price'**
  String get enterPrice;

  /// No description provided for @registrationNumberCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Registration number cannot be empty'**
  String get registrationNumberCannotBeEmpty;

  /// No description provided for @registrationNumberMinLength.
  ///
  /// In en, this message translates to:
  /// **'Registration number must be at least 4 characters'**
  String get registrationNumberMinLength;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @numberOfTyres.
  ///
  /// In en, this message translates to:
  /// **'Number of Tyres'**
  String get numberOfTyres;

  /// No description provided for @enterNumberOfTyres.
  ///
  /// In en, this message translates to:
  /// **'Enter Number of Tyres'**
  String get enterNumberOfTyres;

  /// No description provided for @enterVehicleLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle Location'**
  String get enterVehicleLocation;

  /// No description provided for @ownerMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Owner Mobile Number'**
  String get ownerMobileNumber;

  /// No description provided for @enterOwnerMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter Owner Mobile'**
  String get enterOwnerMobile;

  /// No description provided for @assetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Assets Description'**
  String get assetsDescription;

  /// No description provided for @enterAssetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter Assets Description'**
  String get enterAssetsDescription;

  /// No description provided for @yearOfManufacture.
  ///
  /// In en, this message translates to:
  /// **'Year of Manufacture'**
  String get yearOfManufacture;

  /// No description provided for @enterYearOfManufacture.
  ///
  /// In en, this message translates to:
  /// **'Enter Year of Manufacture'**
  String get enterYearOfManufacture;

  /// No description provided for @odometerReading.
  ///
  /// In en, this message translates to:
  /// **'Odometer Reading (KM/HRS)'**
  String get odometerReading;

  /// No description provided for @enterOdometerReading.
  ///
  /// In en, this message translates to:
  /// **'Enter Odometer Reading (KM/HRS)'**
  String get enterOdometerReading;

  /// No description provided for @submittingRequest.
  ///
  /// In en, this message translates to:
  /// **'Submitting Request...'**
  String get submittingRequest;

  /// No description provided for @vehicleNo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle No.'**
  String get vehicleNo;

  /// No description provided for @enterVehicleNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle No.'**
  String get enterVehicleNo;

  /// No description provided for @aadharDocument.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Document'**
  String get aadharDocument;

  /// No description provided for @panDocument.
  ///
  /// In en, this message translates to:
  /// **'PAN Document'**
  String get panDocument;

  /// No description provided for @rcDocument.
  ///
  /// In en, this message translates to:
  /// **'RC Document'**
  String get rcDocument;

  /// No description provided for @selectInsuranceType.
  ///
  /// In en, this message translates to:
  /// **'Select Insurance Type'**
  String get selectInsuranceType;

  /// No description provided for @comprehensive.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive'**
  String get comprehensive;

  /// No description provided for @thirdParty.
  ///
  /// In en, this message translates to:
  /// **'Third Party'**
  String get thirdParty;

  /// No description provided for @previousYearPolicy.
  ///
  /// In en, this message translates to:
  /// **'Previous Year Policy'**
  String get previousYearPolicy;

  /// No description provided for @selectClaim.
  ///
  /// In en, this message translates to:
  /// **'Select Claim'**
  String get selectClaim;

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the'**
  String get iAcceptThe;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditions;

  /// Validation error message for missing insurance copy
  ///
  /// In en, this message translates to:
  /// **'Please upload the insurance copy.'**
  String get pleaseUploadInsurance;

  /// Validation error message for missing company GST
  ///
  /// In en, this message translates to:
  /// **'Please upload the company GST.'**
  String get pleaseUploadGst;

  /// Label for the Company GST upload field
  ///
  /// In en, this message translates to:
  /// **'Company GST'**
  String get companyGst;

  /// No description provided for @rcCopy.
  ///
  /// In en, this message translates to:
  /// **'RC Copy'**
  String get rcCopy;

  /// No description provided for @insuranceCopy.
  ///
  /// In en, this message translates to:
  /// **'Insurance Copy'**
  String get insuranceCopy;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter Company Name'**
  String get enterCompanyName;

  /// Title for the file size error snackbar
  ///
  /// In en, this message translates to:
  /// **'File Too Large'**
  String get fileTooLarge;

  /// Message for a file that is too large
  ///
  /// In en, this message translates to:
  /// **'File \'{fileName}\' exceeds the 12MB size limit.'**
  String fileExceeds12MB(String fileName);

  /// No description provided for @categoryCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Category cannot be empty'**
  String get categoryCannotBeEmpty;

  /// No description provided for @priceCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Price cannot be empty'**
  String get priceCannotBeEmpty;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get invalidPrice;

  /// No description provided for @brandCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Brand cannot be empty'**
  String get brandCannotBeEmpty;

  /// No description provided for @brandMinLength.
  ///
  /// In en, this message translates to:
  /// **'Brand must be at least 2 characters'**
  String get brandMinLength;

  /// No description provided for @numberOfTyresCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Number of tyres cannot be empty'**
  String get numberOfTyresCannotBeEmpty;

  /// No description provided for @invalidNumberOfTyres.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of tyres'**
  String get invalidNumberOfTyres;

  /// No description provided for @chassisNumberCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Chassis number cannot be empty'**
  String get chassisNumberCannotBeEmpty;

  /// No description provided for @chassisNumberMinLength.
  ///
  /// In en, this message translates to:
  /// **'Chassis number must be at least 4 characters'**
  String get chassisNumberMinLength;

  /// No description provided for @locationCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Location cannot be empty'**
  String get locationCannotBeEmpty;

  /// No description provided for @locationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Location must be at least 3 characters'**
  String get locationMinLength;

  /// No description provided for @ownerMobileCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Owner mobile number cannot be empty'**
  String get ownerMobileCannotBeEmpty;

  /// No description provided for @invalidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get invalidMobileNumber;

  /// No description provided for @assetsDescriptionCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Assets description cannot be empty'**
  String get assetsDescriptionCannotBeEmpty;

  /// No description provided for @assetsDescriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Assets description must be at least 10 characters'**
  String get assetsDescriptionMinLength;

  /// No description provided for @yearOfManufactureCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Year of manufacture cannot be empty'**
  String get yearOfManufactureCannotBeEmpty;

  /// Error message for invalid year of manufacture
  ///
  /// In en, this message translates to:
  /// **'Year must be between 1900 and {currentYear}'**
  String invalidYearOfManufacture(int currentYear);

  /// No description provided for @odometerCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Odometer reading cannot be empty'**
  String get odometerCannotBeEmpty;

  /// No description provided for @invalidOdometerReading.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid odometer reading'**
  String get invalidOdometerReading;

  /// No description provided for @vehicleNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number is required'**
  String get vehicleNumberRequired;

  /// No description provided for @vehicleNumberMinLength.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number must be at least 6 characters'**
  String get vehicleNumberMinLength;

  /// No description provided for @invalidVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid vehicle number'**
  String get invalidVehicleNumber;

  /// No description provided for @rcDocumentRequired.
  ///
  /// In en, this message translates to:
  /// **'RC document is required'**
  String get rcDocumentRequired;

  /// No description provided for @insuranceTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Insurance type is required'**
  String get insuranceTypeRequired;

  /// No description provided for @claimStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Claim status is required'**
  String get claimStatusRequired;

  /// No description provided for @termsAcceptanceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept terms and conditions'**
  String get termsAcceptanceRequired;

  /// No description provided for @aadharDocumentRequired.
  ///
  /// In en, this message translates to:
  /// **'Aadhar document is required'**
  String get aadharDocumentRequired;

  /// No description provided for @panDocumentRequired.
  ///
  /// In en, this message translates to:
  /// **'PAN document is required'**
  String get panDocumentRequired;

  /// No description provided for @previousPolicyRequired.
  ///
  /// In en, this message translates to:
  /// **'Previous policy document is required'**
  String get previousPolicyRequired;

  /// No description provided for @vehicleLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle location is required'**
  String get vehicleLocationRequired;

  /// No description provided for @mobileNumberMinLength.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be at least 10 digits'**
  String get mobileNumberMinLength;

  /// No description provided for @validation_error.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validation_error;

  /// No description provided for @please_fix_all_validation_errors.
  ///
  /// In en, this message translates to:
  /// **'Please fix all validation errors before submitting'**
  String get please_fix_all_validation_errors;

  /// No description provided for @vehicleDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetailsTitle;

  /// No description provided for @modelYear.
  ///
  /// In en, this message translates to:
  /// **'Model Year'**
  String get modelYear;

  /// No description provided for @keySpecifications.
  ///
  /// In en, this message translates to:
  /// **'Key Specifications'**
  String get keySpecifications;

  /// No description provided for @categoryCode.
  ///
  /// In en, this message translates to:
  /// **'Category Code'**
  String get categoryCode;

  /// No description provided for @brandCode.
  ///
  /// In en, this message translates to:
  /// **'Brand Code'**
  String get brandCode;

  /// No description provided for @bodyType.
  ///
  /// In en, this message translates to:
  /// **'Body Type'**
  String get bodyType;

  /// No description provided for @tonnage.
  ///
  /// In en, this message translates to:
  /// **'Tonnage'**
  String get tonnage;

  /// No description provided for @noOfTyres.
  ///
  /// In en, this message translates to:
  /// **'No. of Tyres'**
  String get noOfTyres;

  /// No description provided for @kvRating.
  ///
  /// In en, this message translates to:
  /// **'KV Rating'**
  String get kvRating;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @letUsKnow.
  ///
  /// In en, this message translates to:
  /// **'Let Us Know'**
  String get letUsKnow;

  /// No description provided for @youreInterested.
  ///
  /// In en, this message translates to:
  /// **'You\'re Interested'**
  String get youreInterested;

  /// No description provided for @interested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get interested;

  /// No description provided for @becomeMember.
  ///
  /// In en, this message translates to:
  /// **'Become a Member'**
  String get becomeMember;

  /// No description provided for @connectWithOwner.
  ///
  /// In en, this message translates to:
  /// **'Connect with owner'**
  String get connectWithOwner;

  /// No description provided for @fetchingContact.
  ///
  /// In en, this message translates to:
  /// **'Fetching contact...'**
  String get fetchingContact;

  /// No description provided for @callButton.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButton;

  /// No description provided for @connectWithOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with Owner'**
  String get connectWithOwnerTitle;

  /// No description provided for @connectWithOwnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to get the owner\'s contact number and connect directly.'**
  String get connectWithOwnerSubtitle;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @submitYour.
  ///
  /// In en, this message translates to:
  /// **'Submit Your'**
  String get submitYour;

  /// No description provided for @bestVehicleOffer.
  ///
  /// In en, this message translates to:
  /// **'Best Vehicle Offer'**
  String get bestVehicleOffer;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get invalidAmount;

  /// No description provided for @pleaseEnterValidOfferAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid offer amount.'**
  String get pleaseEnterValidOfferAmount;

  /// No description provided for @offerTooLow.
  ///
  /// In en, this message translates to:
  /// **'Offer Too Low'**
  String get offerTooLow;

  /// No description provided for @minimumOfferPercent.
  ///
  /// In en, this message translates to:
  /// **'Minimum offer is 60% of the price: ₹{amount}'**
  String minimumOfferPercent(String amount);

  /// No description provided for @offerSent.
  ///
  /// In en, this message translates to:
  /// **'Your offer has been sent.'**
  String get offerSent;

  /// No description provided for @offerFailed.
  ///
  /// In en, this message translates to:
  /// **'Offer Failed'**
  String get offerFailed;

  /// No description provided for @inspectionRequested.
  ///
  /// In en, this message translates to:
  /// **'Inspection Requested'**
  String get inspectionRequested;

  /// No description provided for @requestVehicleInspection.
  ///
  /// In en, this message translates to:
  /// **'Request Vehicle Inspection'**
  String get requestVehicleInspection;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @inspectionValuation.
  ///
  /// In en, this message translates to:
  /// **'Inspection & Valuation'**
  String get inspectionValuation;

  /// No description provided for @professionalVehicleInspection.
  ///
  /// In en, this message translates to:
  /// **'Professional vehicle inspection services'**
  String get professionalVehicleInspection;

  /// No description provided for @vehicleInspectionHero.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Inspection\n& Valuation'**
  String get vehicleInspectionHero;

  /// No description provided for @inspectionHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get professional vehicle inspection and accurate valuation reports'**
  String get inspectionHeroSubtitle;

  /// No description provided for @requestInspectionCard.
  ///
  /// In en, this message translates to:
  /// **'Request Inspection'**
  String get requestInspectionCard;

  /// No description provided for @requestInspectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Submit your vehicle for professional inspection and valuation'**
  String get requestInspectionDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @agentInspection.
  ///
  /// In en, this message translates to:
  /// **'Agent Inspection'**
  String get agentInspection;

  /// No description provided for @agentInspectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Perform detailed on-site vehicle inspection and submit report'**
  String get agentInspectionDesc;

  /// No description provided for @startInspection.
  ///
  /// In en, this message translates to:
  /// **'Start Inspection'**
  String get startInspection;

  /// No description provided for @myInspections.
  ///
  /// In en, this message translates to:
  /// **'My Inspections'**
  String get myInspections;

  /// No description provided for @trackInspectionRequests.
  ///
  /// In en, this message translates to:
  /// **'Track your vehicle inspection requests and valuations'**
  String get trackInspectionRequests;

  /// No description provided for @unableToLoadInspections.
  ///
  /// In en, this message translates to:
  /// **'Unable to load inspections. Please try again.'**
  String get unableToLoadInspections;

  /// No description provided for @noInspectionsFound.
  ///
  /// In en, this message translates to:
  /// **'No inspections found'**
  String get noInspectionsFound;

  /// No description provided for @inspectionRequestsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your inspection requests will appear here'**
  String get inspectionRequestsAppearHere;

  /// No description provided for @requestInspection.
  ///
  /// In en, this message translates to:
  /// **'Request Inspection'**
  String get requestInspection;

  /// No description provided for @noMoreInspections.
  ///
  /// In en, this message translates to:
  /// **'No more inspections'**
  String get noMoreInspections;

  /// No description provided for @insuranceFinance.
  ///
  /// In en, this message translates to:
  /// **'Insurance & Finance'**
  String get insuranceFinance;

  /// No description provided for @insuranceFinanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get quotes for vehicle insurance and financing'**
  String get insuranceFinanceSubtitle;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @enterLastNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter last name (optional)'**
  String get enterLastNameOptional;

  /// No description provided for @selectStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a Region first'**
  String get selectStateFirst;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get yourReferralCode;

  /// No description provided for @shareCodeEarnCredits.
  ///
  /// In en, this message translates to:
  /// **'Share this code to earn wallet credits'**
  String get shareCodeEarnCredits;

  /// No description provided for @copyReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Referral Code'**
  String get copyReferralCode;

  /// No description provided for @referralCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied!'**
  String get referralCodeCopied;

  /// No description provided for @unableToLoadWallet.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Wallet'**
  String get unableToLoadWallet;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get pleaseTryAgainLater;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Yet'**
  String get noTransactionsYet;

  /// No description provided for @walletTransactionsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your wallet transactions will appear here'**
  String get walletTransactionsAppearHere;

  /// No description provided for @selectSubscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the subscription plan that suits you best'**
  String get selectSubscriptionSubtitle;

  /// No description provided for @haveReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Have Any Referral Code ?'**
  String get haveReferralCode;

  /// No description provided for @enterHere.
  ///
  /// In en, this message translates to:
  /// **'Enter here'**
  String get enterHere;

  /// No description provided for @proceedPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed Payment'**
  String get proceedPayment;

  /// No description provided for @orPayFromWallet.
  ///
  /// In en, this message translates to:
  /// **'or pay from '**
  String get orPayFromWallet;

  /// No description provided for @myWalletLink.
  ///
  /// In en, this message translates to:
  /// **'\"My wallet\"'**
  String get myWalletLink;

  /// No description provided for @validity.
  ///
  /// In en, this message translates to:
  /// **'Validity : {label}'**
  String validity(String label);

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment Cancelled'**
  String get paymentCancelled;

  /// No description provided for @youCancelledPayment.
  ///
  /// In en, this message translates to:
  /// **'You cancelled the payment'**
  String get youCancelledPayment;

  /// No description provided for @buyingLimitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Buying limit updated!'**
  String get buyingLimitUpdated;

  /// No description provided for @membershipActivated.
  ///
  /// In en, this message translates to:
  /// **'Membership activated! Fetching owner contact...'**
  String get membershipActivated;

  /// No description provided for @inspectionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Inspection request submitted!'**
  String get inspectionSubmitted;

  /// No description provided for @vehicleDetailsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details unlocked!'**
  String get vehicleDetailsUnlocked;

  /// No description provided for @auctionAccessActivated.
  ///
  /// In en, this message translates to:
  /// **'Auction Access Activated!'**
  String get auctionAccessActivated;

  /// No description provided for @subscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Subscription Activated!'**
  String get subscriptionActivated;

  /// No description provided for @couldNotRefreshSubscription.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh subscription. Please try again.'**
  String get couldNotRefreshSubscription;

  /// No description provided for @pleaseLoginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue'**
  String get pleaseLoginToContinue;

  /// No description provided for @yourActivePlans.
  ///
  /// In en, this message translates to:
  /// **'Your active plans'**
  String get yourActivePlans;

  /// No description provided for @activePlanCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Active Plan'**
  String activePlanCount(String count);

  /// No description provided for @yourCurrentSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Your current subscriptions'**
  String get yourCurrentSubscriptions;

  /// No description provided for @noExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'No expiry date'**
  String get noExpiryDate;

  /// No description provided for @noActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No Active Subscriptions'**
  String get noActiveSubscriptions;

  /// No description provided for @notSubscribedYet.
  ///
  /// In en, this message translates to:
  /// **'You have not subscribed to any plan yet.'**
  String get notSubscribedYet;

  /// No description provided for @serviceProviders.
  ///
  /// In en, this message translates to:
  /// **'Service Providers'**
  String get serviceProviders;

  /// No description provided for @findNearbyMechanics.
  ///
  /// In en, this message translates to:
  /// **'Find nearby mechanics and garages'**
  String get findNearbyMechanics;

  /// No description provided for @providersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} providers found'**
  String providersFound(String count);

  /// No description provided for @findingShopsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Finding shops near you...'**
  String get findingShopsNearYou;

  /// No description provided for @subscribeToCAll.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Call'**
  String get subscribeToCAll;

  /// No description provided for @noMechanicsFound.
  ///
  /// In en, this message translates to:
  /// **'No Mechanics Found'**
  String get noMechanicsFound;

  /// No description provided for @noServiceProvidersFound.
  ///
  /// In en, this message translates to:
  /// **'No service providers found near your location'**
  String get noServiceProvidersFound;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer'**
  String get couldNotLaunchDialer;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @sparesTitle.
  ///
  /// In en, this message translates to:
  /// **'Spares'**
  String get sparesTitle;

  /// No description provided for @findSparePartsShops.
  ///
  /// In en, this message translates to:
  /// **'Find spare parts and nearby shops'**
  String get findSparePartsShops;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @yourSparePartsOrders.
  ///
  /// In en, this message translates to:
  /// **'Your spare parts orders'**
  String get yourSparePartsOrders;

  /// No description provided for @noBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookingsYet;

  /// No description provided for @spareOrdersAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your spare parts orders will appear here'**
  String get spareOrdersAppearHere;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// No description provided for @spareDetail.
  ///
  /// In en, this message translates to:
  /// **'Spare Detail'**
  String get spareDetail;

  /// No description provided for @orderDetail.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get orderDetail;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetails;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @partId.
  ///
  /// In en, this message translates to:
  /// **'Part ID'**
  String get partId;

  /// No description provided for @spareName.
  ///
  /// In en, this message translates to:
  /// **'Spare Name'**
  String get spareName;

  /// No description provided for @suitsFor.
  ///
  /// In en, this message translates to:
  /// **'Suits For'**
  String get suitsFor;

  /// No description provided for @noSparePartData.
  ///
  /// In en, this message translates to:
  /// **'No spare part data'**
  String get noSparePartData;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available for this spare part.'**
  String get noDescriptionAvailable;

  /// No description provided for @showInterest.
  ///
  /// In en, this message translates to:
  /// **'Show Interest'**
  String get showInterest;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status: {status}'**
  String orderStatus(String status);

  /// No description provided for @constructionEquipmentShops.
  ///
  /// In en, this message translates to:
  /// **'Construction Equipment Shops'**
  String get constructionEquipmentShops;

  /// No description provided for @commercialVehicleShops.
  ///
  /// In en, this message translates to:
  /// **'Commercial Vehicle Shops'**
  String get commercialVehicleShops;

  /// No description provided for @shopsNearLocation.
  ///
  /// In en, this message translates to:
  /// **'Shops near your location'**
  String get shopsNearLocation;

  /// No description provided for @noShopsFound.
  ///
  /// In en, this message translates to:
  /// **'No shops found'**
  String get noShopsFound;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @chooseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose By Category'**
  String get chooseByCategory;

  /// No description provided for @exploreServicesYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Explore the services that your vehicle need.'**
  String get exploreServicesYourVehicle;

  /// No description provided for @bidDetails.
  ///
  /// In en, this message translates to:
  /// **'Bid Details'**
  String get bidDetails;

  /// No description provided for @vehicleRef.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Ref'**
  String get vehicleRef;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @currentHighest.
  ///
  /// In en, this message translates to:
  /// **'Current Highest'**
  String get currentHighest;

  /// No description provided for @placedAt.
  ///
  /// In en, this message translates to:
  /// **'Placed At'**
  String get placedAt;

  /// No description provided for @makeAndModel.
  ///
  /// In en, this message translates to:
  /// **'Make & Model'**
  String get makeAndModel;

  /// No description provided for @mfgYear.
  ///
  /// In en, this message translates to:
  /// **'Mfg Year'**
  String get mfgYear;

  /// No description provided for @enterBidHint.
  ///
  /// In en, this message translates to:
  /// **'Enter bid'**
  String get enterBidHint;

  /// No description provided for @invalidBidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid bid amount.'**
  String get invalidBidAmount;

  /// No description provided for @regNumber.
  ///
  /// In en, this message translates to:
  /// **'Reg. Number'**
  String get regNumber;

  /// No description provided for @auctionClosed.
  ///
  /// In en, this message translates to:
  /// **'Auction Closed'**
  String get auctionClosed;

  /// No description provided for @winDetails.
  ///
  /// In en, this message translates to:
  /// **'Win Details'**
  String get winDetails;

  /// No description provided for @winningBidLabel.
  ///
  /// In en, this message translates to:
  /// **'Winning Bid:'**
  String get winningBidLabel;

  /// No description provided for @bidApprovedAt.
  ///
  /// In en, this message translates to:
  /// **'Bid Approved At'**
  String get bidApprovedAt;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @winningLetter.
  ///
  /// In en, this message translates to:
  /// **'Winning Letter'**
  String get winningLetter;

  /// No description provided for @sentStatus.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// No description provided for @auctionEnded.
  ///
  /// In en, this message translates to:
  /// **'Auction Ended'**
  String get auctionEnded;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @approvedVehicles.
  ///
  /// In en, this message translates to:
  /// **'Approved Vehicles'**
  String get approvedVehicles;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// No description provided for @approvedVehiclesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Approved vehicles available'**
  String get approvedVehiclesAvailable;

  /// No description provided for @noVehiclesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No vehicles available'**
  String get noVehiclesAvailable;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No Image'**
  String get noImage;

  /// No description provided for @knowMore.
  ///
  /// In en, this message translates to:
  /// **'Know More'**
  String get knowMore;

  /// No description provided for @auctionZone.
  ///
  /// In en, this message translates to:
  /// **'Auction Zone'**
  String get auctionZone;

  /// No description provided for @chooseAnyOne.
  ///
  /// In en, this message translates to:
  /// **'Choose any one'**
  String get chooseAnyOne;

  /// No description provided for @liveAuctionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auctions currently live — bid now before time runs out'**
  String get liveAuctionSubtitle;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveBadge;

  /// No description provided for @auctionKnowCondition.
  ///
  /// In en, this message translates to:
  /// **'Know the real condition of your vehicle.'**
  String get auctionKnowCondition;

  /// No description provided for @liveTab.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveTab;

  /// No description provided for @closingTodayTab.
  ///
  /// In en, this message translates to:
  /// **'Closing Today'**
  String get closingTodayTab;

  /// No description provided for @upcomingTab.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingTab;

  /// No description provided for @noAuctionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No auctions available'**
  String get noAuctionsAvailable;

  /// No description provided for @tapToBid.
  ///
  /// In en, this message translates to:
  /// **'Tap to Bid'**
  String get tapToBid;

  /// No description provided for @auctionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'AUCTION ID'**
  String get auctionIdLabel;

  /// No description provided for @lot.
  ///
  /// In en, this message translates to:
  /// **'LOT'**
  String get lot;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @liveAuctions.
  ///
  /// In en, this message translates to:
  /// **'Live Auctions'**
  String get liveAuctions;

  /// No description provided for @searchVehiclesHint.
  ///
  /// In en, this message translates to:
  /// **'Search vehicles'**
  String get searchVehiclesHint;

  /// No description provided for @bidStartPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Bid Start Price:'**
  String get bidStartPriceLabel;

  /// No description provided for @viewMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'View more details'**
  String get viewMoreDetails;

  /// No description provided for @registrationRto.
  ///
  /// In en, this message translates to:
  /// **'Registration RTO'**
  String get registrationRto;

  /// No description provided for @yourBidAmount.
  ///
  /// In en, this message translates to:
  /// **'Your Bid Amount'**
  String get yourBidAmount;

  /// No description provided for @minBid.
  ///
  /// In en, this message translates to:
  /// **'Min. Bid'**
  String get minBid;

  /// No description provided for @bidStartPrice.
  ///
  /// In en, this message translates to:
  /// **'Bid Start Price'**
  String get bidStartPrice;

  /// No description provided for @availableBuyingLimit.
  ///
  /// In en, this message translates to:
  /// **'Available Buying Limit'**
  String get availableBuyingLimit;

  /// No description provided for @placeBidTitle.
  ///
  /// In en, this message translates to:
  /// **'Place Bid'**
  String get placeBidTitle;

  /// No description provided for @placeBid.
  ///
  /// In en, this message translates to:
  /// **'Place Bid'**
  String get placeBid;

  /// No description provided for @enterValidBidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid bid amount'**
  String get enterValidBidAmount;

  /// No description provided for @bidMultipleOf100.
  ///
  /// In en, this message translates to:
  /// **'Bid amount must be a multiple of ₹100'**
  String get bidMultipleOf100;

  /// No description provided for @bidPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bid placed successfully!'**
  String get bidPlacedSuccessfully;

  /// No description provided for @repoDate.
  ///
  /// In en, this message translates to:
  /// **'Repo Date'**
  String get repoDate;

  /// No description provided for @transactionFees.
  ///
  /// In en, this message translates to:
  /// **'Transaction Fees'**
  String get transactionFees;

  /// No description provided for @rcStatus.
  ///
  /// In en, this message translates to:
  /// **'RC Status'**
  String get rcStatus;

  /// No description provided for @parkingCharges.
  ///
  /// In en, this message translates to:
  /// **'Parking Charges'**
  String get parkingCharges;

  /// No description provided for @yardDetails.
  ///
  /// In en, this message translates to:
  /// **'Yard Details'**
  String get yardDetails;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @mobileNo.
  ///
  /// In en, this message translates to:
  /// **'Mobile No.'**
  String get mobileNo;

  /// No description provided for @filterAuctions.
  ///
  /// In en, this message translates to:
  /// **'Filter Auctions'**
  String get filterAuctions;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @selectVehicleTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Type'**
  String get selectVehicleTypeFilter;

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get selectRegion;

  /// No description provided for @searchState.
  ///
  /// In en, this message translates to:
  /// **'Search state...'**
  String get searchState;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @vehiclesAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} vehicles available'**
  String vehiclesAvailableCount(int count);

  /// No description provided for @noVehiclesYet.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get noVehiclesYet;

  /// No description provided for @myBids.
  ///
  /// In en, this message translates to:
  /// **'My Bids'**
  String get myBids;

  /// No description provided for @yourAuctionBids.
  ///
  /// In en, this message translates to:
  /// **'Your auction bids'**
  String get yourAuctionBids;

  /// No description provided for @noBidsYet.
  ///
  /// In en, this message translates to:
  /// **'No bids placed yet.\nStart bidding in live auctions!'**
  String get noBidsYet;

  /// No description provided for @closedBadge.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get closedBadge;

  /// No description provided for @highestBid.
  ///
  /// In en, this message translates to:
  /// **'Highest Bid:'**
  String get highestBid;

  /// No description provided for @auctionClosedButton.
  ///
  /// In en, this message translates to:
  /// **'Auction Closed'**
  String get auctionClosedButton;

  /// No description provided for @myWins.
  ///
  /// In en, this message translates to:
  /// **'My Wins'**
  String get myWins;

  /// No description provided for @yourWonAuctions.
  ///
  /// In en, this message translates to:
  /// **'Your won auctions'**
  String get yourWonAuctions;

  /// No description provided for @noWinsYet.
  ///
  /// In en, this message translates to:
  /// **'No wins yet.\nStart bidding to win auctions!'**
  String get noWinsYet;

  /// No description provided for @wonBadge.
  ///
  /// In en, this message translates to:
  /// **'WON'**
  String get wonBadge;

  /// No description provided for @paymentChip.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentChip;

  /// No description provided for @letterChip.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get letterChip;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @manageProfile.
  ///
  /// In en, this message translates to:
  /// **'Manage Profile'**
  String get manageProfile;

  /// No description provided for @passwordAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Password & Security'**
  String get passwordAndSecurity;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @auctions.
  ///
  /// In en, this message translates to:
  /// **'Auctions'**
  String get auctions;

  /// No description provided for @initiateRefund.
  ///
  /// In en, this message translates to:
  /// **'Initiate Refund'**
  String get initiateRefund;

  /// No description provided for @myVehicles.
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get myVehicles;

  /// No description provided for @mySubscribedVehicles.
  ///
  /// In en, this message translates to:
  /// **'My Subscribed Vehicles'**
  String get mySubscribedVehicles;

  /// No description provided for @inspectionAndValuation.
  ///
  /// In en, this message translates to:
  /// **'Inspection & Valuation'**
  String get inspectionAndValuation;

  /// No description provided for @spareFms.
  ///
  /// In en, this message translates to:
  /// **'Spare & FMS'**
  String get spareFms;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name *'**
  String get accountHolderName;

  /// No description provided for @enterAccountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter account holder name'**
  String get enterAccountHolderName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number *'**
  String get accountNumber;

  /// No description provided for @enterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter account number'**
  String get enterAccountNumber;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name *'**
  String get bankName;

  /// No description provided for @enterBankName.
  ///
  /// In en, this message translates to:
  /// **'Enter bank name'**
  String get enterBankName;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name *'**
  String get branchName;

  /// No description provided for @enterBranchName.
  ///
  /// In en, this message translates to:
  /// **'Enter branch name'**
  String get enterBranchName;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code *'**
  String get ifscCode;

  /// No description provided for @enterIfscCode.
  ///
  /// In en, this message translates to:
  /// **'Enter IFSC code'**
  String get enterIfscCode;

  /// No description provided for @refundType.
  ///
  /// In en, this message translates to:
  /// **'Refund Type *'**
  String get refundType;

  /// No description provided for @enterRefundType.
  ///
  /// In en, this message translates to:
  /// **'Enter refund type'**
  String get enterRefundType;

  /// No description provided for @initiateRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Initiate Refund'**
  String get initiateRefundTitle;

  /// No description provided for @searchByServiceVehicle.
  ///
  /// In en, this message translates to:
  /// **'Search by service, vehicle...'**
  String get searchByServiceVehicle;

  /// No description provided for @mostBoughtVehicles.
  ///
  /// In en, this message translates to:
  /// **'Most Bought Vehicles'**
  String get mostBoughtVehicles;

  /// No description provided for @fmsItems.
  ///
  /// In en, this message translates to:
  /// **'FMS Items'**
  String get fmsItems;

  /// No description provided for @spareSupportNearYou.
  ///
  /// In en, this message translates to:
  /// **'Spare Support Near You'**
  String get spareSupportNearYou;

  /// No description provided for @isYourVehicleReadyForInspection.
  ///
  /// In en, this message translates to:
  /// **'Is Your Vehicle Ready For Inspection?'**
  String get isYourVehicleReadyForInspection;

  /// No description provided for @inspectionBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get professional vehicle inspection and accurate valuation reports.'**
  String get inspectionBannerSubtitle;

  /// No description provided for @inspectNow.
  ///
  /// In en, this message translates to:
  /// **'Inspect Now'**
  String get inspectNow;

  /// No description provided for @isYourVehicleLookingForInsurance.
  ///
  /// In en, this message translates to:
  /// **'Is Your Vehicle Looking For Insurance?'**
  String get isYourVehicleLookingForInsurance;

  /// No description provided for @insuranceBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get the best insurance rates with high claim success support.'**
  String get insuranceBannerSubtitle;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @isYourVehicleLookingForFinance.
  ///
  /// In en, this message translates to:
  /// **'Need Finance For Your Vehicle?'**
  String get isYourVehicleLookingForFinance;

  /// No description provided for @financeBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick approvals from top NBFCs and banks at competitive rates.'**
  String get financeBannerSubtitle;

  /// No description provided for @applyForFinance.
  ///
  /// In en, this message translates to:
  /// **'Apply For Finance'**
  String get applyForFinance;

  /// No description provided for @constructionEquipmentCe.
  ///
  /// In en, this message translates to:
  /// **'Construction Equipment (CE)'**
  String get constructionEquipmentCe;

  /// No description provided for @commercialVehicleCv.
  ///
  /// In en, this message translates to:
  /// **'Commercial Vehicle (CV)'**
  String get commercialVehicleCv;

  /// No description provided for @spareSupportTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find nearby shops and spare parts near you.'**
  String get spareSupportTileSubtitle;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModel;

  /// No description provided for @availableVehicles.
  ///
  /// In en, this message translates to:
  /// **'Available Vehicles'**
  String get availableVehicles;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @liveAuction.
  ///
  /// In en, this message translates to:
  /// **'Live Auction'**
  String get liveAuction;

  /// No description provided for @mechanicsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Mechanics Near You'**
  String get mechanicsNearYou;

  /// No description provided for @apprBuySellSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy & sell verified commercial vehicles'**
  String get apprBuySellSubtitle;

  /// No description provided for @apprNoCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get apprNoCategoriesFound;

  /// No description provided for @apprAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'Available : {count}'**
  String apprAvailableCount(int count);

  /// No description provided for @apprBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get apprBuy;

  /// No description provided for @apprSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get apprSell;

  /// No description provided for @apprVehiclesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} vehicles'**
  String apprVehiclesCount(int count);

  /// No description provided for @apprUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get apprUnavailable;

  /// No description provided for @apprSelectCategoryToBrowse.
  ///
  /// In en, this message translates to:
  /// **'Select a category to browse'**
  String get apprSelectCategoryToBrowse;

  /// No description provided for @apprInspectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicles you requested inspection for'**
  String get apprInspectionsSubtitle;

  /// No description provided for @apprBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicles you have booked'**
  String get apprBookingsSubtitle;

  /// No description provided for @apprNoInspectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No inspections requested yet'**
  String get apprNoInspectionsYet;

  /// No description provided for @apprNoBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No vehicles booked yet'**
  String get apprNoBookingsYet;

  /// No description provided for @apprInspectionsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Vehicles you request inspection for will appear here.'**
  String get apprInspectionsEmptyHint;

  /// No description provided for @apprBookingsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Vehicles you book will appear here.'**
  String get apprBookingsEmptyHint;

  /// No description provided for @apprRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get apprRefresh;

  /// No description provided for @apprBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get apprBookNow;

  /// No description provided for @apprInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get apprInspection;

  /// No description provided for @apprBookedCheck.
  ///
  /// In en, this message translates to:
  /// **'Booked ✓'**
  String get apprBookedCheck;

  /// No description provided for @apprRequestedCheck.
  ///
  /// In en, this message translates to:
  /// **'Requested ✓'**
  String get apprRequestedCheck;

  /// No description provided for @apprVehicleDetailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Vehicle details not available'**
  String get apprVehicleDetailsUnavailable;

  /// No description provided for @apprGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get apprGoBack;

  /// No description provided for @apprBookVehicle.
  ///
  /// In en, this message translates to:
  /// **'Book Vehicle'**
  String get apprBookVehicle;

  /// No description provided for @apprBookVehicleDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay to book this vehicle and access full details.'**
  String get apprBookVehicleDesc;

  /// No description provided for @apprRequestInspectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay to request professional inspection.'**
  String get apprRequestInspectionDesc;

  /// No description provided for @apprSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get apprSuccess;

  /// No description provided for @apprError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get apprError;

  /// No description provided for @apprVehicleBookedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle booked successfully!'**
  String get apprVehicleBookedSuccess;

  /// No description provided for @apprInspectionRequestedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Inspection requested successfully!'**
  String get apprInspectionRequestedSuccess;

  /// No description provided for @apprRegistrationNo.
  ///
  /// In en, this message translates to:
  /// **'Registration No.'**
  String get apprRegistrationNo;

  /// No description provided for @apprChassisNo.
  ///
  /// In en, this message translates to:
  /// **'Chassis No.'**
  String get apprChassisNo;

  /// No description provided for @apprFitnessCertificate.
  ///
  /// In en, this message translates to:
  /// **'Fitness Certificate'**
  String get apprFitnessCertificate;

  /// No description provided for @apprOriginalInvoice.
  ///
  /// In en, this message translates to:
  /// **'Original Invoice'**
  String get apprOriginalInvoice;

  /// No description provided for @apprGstApplicable.
  ///
  /// In en, this message translates to:
  /// **'GST Applicable'**
  String get apprGstApplicable;

  /// No description provided for @apprInsuranceValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Insurance Valid Until'**
  String get apprInsuranceValidUntil;

  /// No description provided for @apprOfferEnds.
  ///
  /// In en, this message translates to:
  /// **'Offer Ends'**
  String get apprOfferEnds;

  /// No description provided for @apprInsuranceDoc.
  ///
  /// In en, this message translates to:
  /// **'Insurance Doc'**
  String get apprInsuranceDoc;

  /// No description provided for @apprAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get apprAvailableLabel;

  /// No description provided for @apprNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get apprNotAvailable;

  /// No description provided for @apprInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get apprInfo;

  /// No description provided for @apprFilePickerPending.
  ///
  /// In en, this message translates to:
  /// **'File picker integration pending. Add file_picker package to enable uploads.'**
  String get apprFilePickerPending;

  /// No description provided for @apprSellYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Sell Your Vehicle'**
  String get apprSellYourVehicle;

  /// No description provided for @apprSubmitVehicleForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit your vehicle for approval'**
  String get apprSubmitVehicleForApproval;

  /// No description provided for @apprRegNoHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. MH12AB1234'**
  String get apprRegNoHint;

  /// No description provided for @apprChassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Chassis Number'**
  String get apprChassisNumber;

  /// No description provided for @apprEnterChassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter chassis number'**
  String get apprEnterChassisNumber;

  /// No description provided for @apprYearOfManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Year of Manufacturing'**
  String get apprYearOfManufacturing;

  /// No description provided for @apprYearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2021'**
  String get apprYearHint;

  /// No description provided for @apprExpectedPrice.
  ///
  /// In en, this message translates to:
  /// **'Expected Price (₹)'**
  String get apprExpectedPrice;

  /// No description provided for @apprPriceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2500000'**
  String get apprPriceHint;

  /// No description provided for @apprOwnerMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Owner Mobile Number'**
  String get apprOwnerMobileNumber;

  /// No description provided for @apprMobileHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get apprMobileHint;

  /// No description provided for @apprAssetDescription.
  ///
  /// In en, this message translates to:
  /// **'Asset Description'**
  String get apprAssetDescription;

  /// No description provided for @apprAssetDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tata Signa 2823.T 6x4'**
  String get apprAssetDescriptionHint;

  /// No description provided for @apprFitnessCertificateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Fitness Certificate Available'**
  String get apprFitnessCertificateAvailable;

  /// No description provided for @apprOriginalInvoiceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Original Invoice Available'**
  String get apprOriginalInvoiceAvailable;

  /// No description provided for @apprPhotosAndDocuments.
  ///
  /// In en, this message translates to:
  /// **'Photos & Documents'**
  String get apprPhotosAndDocuments;

  /// No description provided for @apprVehiclePhotos.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Photos'**
  String get apprVehiclePhotos;

  /// No description provided for @apprRcDocuments.
  ///
  /// In en, this message translates to:
  /// **'RC Documents'**
  String get apprRcDocuments;

  /// No description provided for @apprInsuranceDocuments.
  ///
  /// In en, this message translates to:
  /// **'Insurance Documents'**
  String get apprInsuranceDocuments;

  /// No description provided for @apprSubmitVehicle.
  ///
  /// In en, this message translates to:
  /// **'Submit Vehicle'**
  String get apprSubmitVehicle;

  /// No description provided for @apprVehicleCategory.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Category'**
  String get apprVehicleCategory;

  /// No description provided for @apprAutoFilled.
  ///
  /// In en, this message translates to:
  /// **'Auto-filled'**
  String get apprAutoFilled;

  /// No description provided for @apprSelectStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select state first'**
  String get apprSelectStateFirst;

  /// No description provided for @apprConfirmedCheck.
  ///
  /// In en, this message translates to:
  /// **'Confirmed ✓'**
  String get apprConfirmedCheck;

  /// No description provided for @apprTapToAddMore.
  ///
  /// In en, this message translates to:
  /// **'Tap to add more'**
  String get apprTapToAddMore;

  /// No description provided for @apprTapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get apprTapToUpload;

  /// No description provided for @apprFailedLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories. Pull to refresh.'**
  String get apprFailedLoadCategories;

  /// No description provided for @apprFailedLoadVehicles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicles. Please try again.'**
  String get apprFailedLoadVehicles;

  /// No description provided for @apprFailedBookVehicle.
  ///
  /// In en, this message translates to:
  /// **'Failed to book vehicle. Please try again.'**
  String get apprFailedBookVehicle;

  /// No description provided for @apprFailedRequestInspection.
  ///
  /// In en, this message translates to:
  /// **'Failed to request inspection. Please try again.'**
  String get apprFailedRequestInspection;

  /// No description provided for @apprRegNoRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration number is required'**
  String get apprRegNoRequired;

  /// No description provided for @apprFitnessRequired.
  ///
  /// In en, this message translates to:
  /// **'Fitness is required'**
  String get apprFitnessRequired;

  /// No description provided for @apprOriginalInvoiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Original invoice is required'**
  String get apprOriginalInvoiceRequired;

  /// No description provided for @apprAssetDescRequired.
  ///
  /// In en, this message translates to:
  /// **'Asset description is required'**
  String get apprAssetDescRequired;

  /// No description provided for @apprOwnerMobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Owner mobile number is required'**
  String get apprOwnerMobileRequired;

  /// No description provided for @apprEnterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter valid 10-digit mobile number'**
  String get apprEnterValidMobile;

  /// No description provided for @apprPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get apprPriceRequired;

  /// No description provided for @apprEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter valid price'**
  String get apprEnterValidPrice;

  /// No description provided for @apprMfgYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing year is required'**
  String get apprMfgYearRequired;

  /// No description provided for @apprInsuranceRequired.
  ///
  /// In en, this message translates to:
  /// **'Insurance is required'**
  String get apprInsuranceRequired;

  /// No description provided for @apprGstApplicabilityRequired.
  ///
  /// In en, this message translates to:
  /// **'GST applicability is required'**
  String get apprGstApplicabilityRequired;

  /// No description provided for @apprVehicleImagesRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle images are required'**
  String get apprVehicleImagesRequired;

  /// No description provided for @apprOfferEndDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Offer end date is required'**
  String get apprOfferEndDateRequired;

  /// No description provided for @apprOfferEndTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Offer end time is required'**
  String get apprOfferEndTimeRequired;

  /// No description provided for @apprFixErrorsBeforeSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors before submitting'**
  String get apprFixErrorsBeforeSubmitting;

  /// No description provided for @apprVehicleSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle submitted successfully!'**
  String get apprVehicleSubmittedSuccess;

  /// No description provided for @apprFailedSubmitVehicle.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit vehicle. Please try again.'**
  String get apprFailedSubmitVehicle;

  /// No description provided for @apprReferralAndRewards.
  ///
  /// In en, this message translates to:
  /// **'Referral & Rewards'**
  String get apprReferralAndRewards;

  /// No description provided for @apprRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get apprRecentTransactions;

  /// No description provided for @apprHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get apprHowItWorks;

  /// No description provided for @apprTotalWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Wallet Balance'**
  String get apprTotalWalletBalance;

  /// No description provided for @apprThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} this month'**
  String apprThisMonth(String amount);

  /// No description provided for @apprWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get apprWithdraw;

  /// No description provided for @apprConvertCoins.
  ///
  /// In en, this message translates to:
  /// **'Convert Coins'**
  String get apprConvertCoins;

  /// No description provided for @apprConvertCoinsMessage.
  ///
  /// In en, this message translates to:
  /// **'Convert {coins} coins into {rupees} wallet balance?\n\nRate: {rate} coins = ₹1  ·  Once per 24 h'**
  String apprConvertCoinsMessage(String coins, String rupees, int rate);

  /// No description provided for @apprConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get apprConfirm;

  /// No description provided for @apprWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get apprWalletBalance;

  /// No description provided for @apprRewardCoins.
  ///
  /// In en, this message translates to:
  /// **'Reward Coins'**
  String get apprRewardCoins;

  /// No description provided for @apprConvertNow.
  ///
  /// In en, this message translates to:
  /// **'Convert Now'**
  String get apprConvertNow;

  /// No description provided for @apprConvert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get apprConvert;

  /// No description provided for @apprEarnMoreGrowWallet.
  ///
  /// In en, this message translates to:
  /// **'Earn more, grow your wallet!'**
  String get apprEarnMoreGrowWallet;

  /// No description provided for @apprInviteMoreFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite more friends and earn exciting rewards.'**
  String get apprInviteMoreFriends;

  /// No description provided for @apprReferNow.
  ///
  /// In en, this message translates to:
  /// **'Refer Now'**
  String get apprReferNow;

  /// No description provided for @apprFromName.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String apprFromName(String name);

  /// No description provided for @apprStepReferFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Refer Friends'**
  String get apprStepReferFriendsTitle;

  /// No description provided for @apprStepReferFriendsDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your referral link with your friends'**
  String get apprStepReferFriendsDesc;

  /// No description provided for @apprStepTheyJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'They Join'**
  String get apprStepTheyJoinTitle;

  /// No description provided for @apprStepTheyJoinDesc.
  ///
  /// In en, this message translates to:
  /// **'Your friends sign up using your link'**
  String get apprStepTheyJoinDesc;

  /// No description provided for @apprStepTheyUseTitle.
  ///
  /// In en, this message translates to:
  /// **'They Actively Use'**
  String get apprStepTheyUseTitle;

  /// No description provided for @apprStepTheyUseDesc.
  ///
  /// In en, this message translates to:
  /// **'They explore, participate and place bids'**
  String get apprStepTheyUseDesc;

  /// No description provided for @apprStepYouEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'You Earn'**
  String get apprStepYouEarnTitle;

  /// No description provided for @apprStepYouEarnDesc.
  ///
  /// In en, this message translates to:
  /// **'You earn rewards which reflect in your wallet'**
  String get apprStepYouEarnDesc;

  /// No description provided for @apprPleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get apprPleaseTryAgainLater;

  /// No description provided for @aucSearchAuctionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bid on live vehicle auctions'**
  String get aucSearchAuctionSubtitle;

  /// No description provided for @aucChooseSubscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Subscription Plan'**
  String get aucChooseSubscriptionPlan;

  /// No description provided for @aucChoosePlanUnlockAuction.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to unlock auction features'**
  String get aucChoosePlanUnlockAuction;

  /// No description provided for @aucSearchBuySellTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell'**
  String get aucSearchBuySellTitle;

  /// No description provided for @aucSearchBuySellSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse and list vehicles for sale'**
  String get aucSearchBuySellSubtitle;

  /// No description provided for @aucSearchFmsTitle.
  ///
  /// In en, this message translates to:
  /// **'FMS / Spare Parts'**
  String get aucSearchFmsTitle;

  /// No description provided for @aucSearchFmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find spare parts and FMS items'**
  String get aucSearchFmsSubtitle;

  /// No description provided for @aucSearchInsuranceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get insurance quotes and financing'**
  String get aucSearchInsuranceSubtitle;

  /// No description provided for @aucSearchInspectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get aucSearchInspectionTitle;

  /// No description provided for @aucSearchInspectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request vehicle inspection & valuation'**
  String get aucSearchInspectionSubtitle;

  /// No description provided for @aucSearchServiceSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Support'**
  String get aucSearchServiceSupportTitle;

  /// No description provided for @aucSearchServiceSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find mechanics and service centers'**
  String get aucSearchServiceSupportSubtitle;

  /// No description provided for @aucSearchMyBidsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your active and past bids'**
  String get aucSearchMyBidsSubtitle;

  /// No description provided for @aucSearchMyWinsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View vehicles you have won'**
  String get aucSearchMyWinsSubtitle;

  /// No description provided for @aucSearchMySubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your subscription plans'**
  String get aucSearchMySubscriptionsSubtitle;

  /// No description provided for @aucCatBackhoeLoader.
  ///
  /// In en, this message translates to:
  /// **'Backhoe Loader (BHL)'**
  String get aucCatBackhoeLoader;

  /// No description provided for @aucCatExcavators.
  ///
  /// In en, this message translates to:
  /// **'Excavators'**
  String get aucCatExcavators;

  /// No description provided for @aucCatTippers.
  ///
  /// In en, this message translates to:
  /// **'Tippers'**
  String get aucCatTippers;

  /// No description provided for @aucCatICV.
  ///
  /// In en, this message translates to:
  /// **'ICV'**
  String get aucCatICV;

  /// No description provided for @aucCatLCV.
  ///
  /// In en, this message translates to:
  /// **'LCV'**
  String get aucCatLCV;

  /// No description provided for @aucCatTrailers.
  ///
  /// In en, this message translates to:
  /// **'Trailers'**
  String get aucCatTrailers;

  /// No description provided for @aucCatFarmEquipment.
  ///
  /// In en, this message translates to:
  /// **'Farm Equipment'**
  String get aucCatFarmEquipment;

  /// No description provided for @aucCatWheelLoader.
  ///
  /// In en, this message translates to:
  /// **'Wheel Loader'**
  String get aucCatWheelLoader;

  /// No description provided for @aucCatRollers.
  ///
  /// In en, this message translates to:
  /// **'Rollers'**
  String get aucCatRollers;

  /// No description provided for @aucCatMotorGrader.
  ///
  /// In en, this message translates to:
  /// **'Motor Grader'**
  String get aucCatMotorGrader;

  /// No description provided for @aucCatSelfLoadingMixer.
  ///
  /// In en, this message translates to:
  /// **'Self Loading Mixer'**
  String get aucCatSelfLoadingMixer;

  /// No description provided for @aucCatTransitmixer.
  ///
  /// In en, this message translates to:
  /// **'Transitmixer'**
  String get aucCatTransitmixer;

  /// No description provided for @aucCatCrushingBatchingPlant.
  ///
  /// In en, this message translates to:
  /// **'Crushing & Batching Plant'**
  String get aucCatCrushingBatchingPlant;

  /// No description provided for @aucCatCranes.
  ///
  /// In en, this message translates to:
  /// **'Cranes (Lifter)'**
  String get aucCatCranes;

  /// No description provided for @aucCatGenSet.
  ///
  /// In en, this message translates to:
  /// **'Gen-Set'**
  String get aucCatGenSet;

  /// No description provided for @aucCatOtherMachines.
  ///
  /// In en, this message translates to:
  /// **'Other Machines'**
  String get aucCatOtherMachines;

  /// No description provided for @aucCatScrap.
  ///
  /// In en, this message translates to:
  /// **'Scrap'**
  String get aucCatScrap;

  /// No description provided for @aucCatJeepsy.
  ///
  /// In en, this message translates to:
  /// **'jeepsy'**
  String get aucCatJeepsy;

  /// No description provided for @aucLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get aucLocating;

  /// No description provided for @aucSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by service, vehicle...'**
  String get aucSearchHint;

  /// No description provided for @aucQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get aucQuickAccess;

  /// No description provided for @aucBrowseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse by Category'**
  String get aucBrowseByCategory;

  /// No description provided for @aucNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String aucNoResultsFor(String query);

  /// No description provided for @aucSearchSuggestionHint.
  ///
  /// In en, this message translates to:
  /// **'Try auction, buy & sell, inspection...'**
  String get aucSearchSuggestionHint;

  /// No description provided for @aucSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get aucSearchFailed;

  /// No description provided for @aucPleaseLoginToDownload.
  ///
  /// In en, this message translates to:
  /// **'Please login to download'**
  String get aucPleaseLoginToDownload;

  /// No description provided for @aucNoAuctionData.
  ///
  /// In en, this message translates to:
  /// **'No auction data available'**
  String get aucNoAuctionData;

  /// No description provided for @aucExcelDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Excel file downloaded successfully'**
  String get aucExcelDownloaded;

  /// No description provided for @aucFailedToDownload.
  ///
  /// In en, this message translates to:
  /// **'Failed to download: {error}'**
  String aucFailedToDownload(String error);

  /// No description provided for @aucWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get aucWishlist;

  /// No description provided for @aucTwoWheeler.
  ///
  /// In en, this message translates to:
  /// **'Two Wheeler'**
  String get aucTwoWheeler;

  /// No description provided for @aucThreeWheeler.
  ///
  /// In en, this message translates to:
  /// **'Three Wheeler'**
  String get aucThreeWheeler;

  /// No description provided for @aucFourWheeler.
  ///
  /// In en, this message translates to:
  /// **'Four Wheeler'**
  String get aucFourWheeler;

  /// No description provided for @aucCommercialVehicle.
  ///
  /// In en, this message translates to:
  /// **'Commercial Vehicle'**
  String get aucCommercialVehicle;

  /// No description provided for @aucConstructionEquipment.
  ///
  /// In en, this message translates to:
  /// **'Construction Equipment'**
  String get aucConstructionEquipment;

  /// No description provided for @aucFarmEquipment.
  ///
  /// In en, this message translates to:
  /// **'Farm Equipment'**
  String get aucFarmEquipment;

  /// No description provided for @aucFailedLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories. Pull to refresh.'**
  String get aucFailedLoadCategories;

  /// No description provided for @aucLiveBidding.
  ///
  /// In en, this message translates to:
  /// **'Live Bidding'**
  String get aucLiveBidding;

  /// No description provided for @aucFailedLoadAuctions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load auctions. Please try again.'**
  String get aucFailedLoadAuctions;

  /// No description provided for @aucFailedLoadWishlist.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wishlist. Please try again.'**
  String get aucFailedLoadWishlist;

  /// No description provided for @aucStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get aucStatusCompleted;

  /// No description provided for @aucStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get aucStatusCancelled;

  /// No description provided for @aucVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get aucVerified;

  /// No description provided for @aucMinimumBid.
  ///
  /// In en, this message translates to:
  /// **'Minimum bid is ₹{amount}'**
  String aucMinimumBid(String amount);

  /// No description provided for @aucMustBeHigherThanCurrentBid.
  ///
  /// In en, this message translates to:
  /// **'Must be higher than current bid'**
  String get aucMustBeHigherThanCurrentBid;

  /// No description provided for @aucBidLimitSubscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'You need a Bid Limit subscription to place bids. Please subscribe to continue.'**
  String get aucBidLimitSubscriptionRequired;

  /// No description provided for @aucBidLimitPlanRequired.
  ///
  /// In en, this message translates to:
  /// **'Bid Limit Plan Required'**
  String get aucBidLimitPlanRequired;

  /// No description provided for @aucBidLimitPlanRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to a bid limit plan to place bids in auctions.'**
  String get aucBidLimitPlanRequiredSubtitle;

  /// No description provided for @aucBuyingLimitZeroUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Your available buying limit is ₹0. Please upgrade your bid limit plan to continue.'**
  String get aucBuyingLimitZeroUpgrade;

  /// No description provided for @aucBidExceedsLimitUpgradeHigher.
  ///
  /// In en, this message translates to:
  /// **'Your bid of ₹{bid} exceeds your available buying limit of ₹{limit}. Please upgrade your plan to place higher bids.'**
  String aucBidExceedsLimitUpgradeHigher(String bid, String limit);

  /// No description provided for @aucBidExceedsLimitUpgradeContinue.
  ///
  /// In en, this message translates to:
  /// **'Your bid of ₹{bid} exceeds your available buying limit of ₹{limit}. Please upgrade your plan to continue.'**
  String aucBidExceedsLimitUpgradeContinue(String bid, String limit);

  /// No description provided for @aucBidLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Bid Limit Exceeded'**
  String get aucBidLimitExceeded;

  /// No description provided for @aucNoBuyingLimitUpgrade.
  ///
  /// In en, this message translates to:
  /// **'You have no available buying limit. Upgrade your bid limit plan to continue.'**
  String get aucNoBuyingLimitUpgrade;

  /// No description provided for @aucBuyingLimitUpgradeHigher.
  ///
  /// In en, this message translates to:
  /// **'Your available buying limit is ₹{limit}. Upgrade your plan to place higher bids.'**
  String aucBuyingLimitUpgradeHigher(String limit);

  /// No description provided for @aucBidMustBeHigherThanHighest.
  ///
  /// In en, this message translates to:
  /// **'Bid must be higher than the current highest bid'**
  String get aucBidMustBeHigherThanHighest;

  /// No description provided for @aucVehicleNotFoundRefresh.
  ///
  /// In en, this message translates to:
  /// **'Vehicle not found. Please refresh and try again.'**
  String get aucVehicleNotFoundRefresh;

  /// No description provided for @aucBidCouldNotBePlaced.
  ///
  /// In en, this message translates to:
  /// **'Bid could not be placed.'**
  String get aucBidCouldNotBePlaced;

  /// No description provided for @aucFailedLoadBids.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bids. Please try again.'**
  String get aucFailedLoadBids;

  /// No description provided for @aucFailedLoadWins.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wins. Please try again.'**
  String get aucFailedLoadWins;

  /// No description provided for @aucFailedLoadVehicles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicles. Please try again.'**
  String get aucFailedLoadVehicles;

  /// No description provided for @aucNoVehiclesFoundMatching.
  ///
  /// In en, this message translates to:
  /// **'No vehicles found matching \"{query}\"'**
  String aucNoVehiclesFoundMatching(String query);

  /// No description provided for @aucAddedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get aucAddedToWishlist;

  /// No description provided for @aucRemovedFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get aucRemovedFromWishlist;

  /// No description provided for @aucFailedUpdateWishlist.
  ///
  /// In en, this message translates to:
  /// **'Failed to update wishlist. Please try again.'**
  String get aucFailedUpdateWishlist;

  /// No description provided for @aucLotLabel.
  ///
  /// In en, this message translates to:
  /// **'# LOT'**
  String get aucLotLabel;

  /// No description provided for @aucComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get aucComingSoon;

  /// No description provided for @aucBidsPlaced.
  ///
  /// In en, this message translates to:
  /// **'Bids Placed'**
  String get aucBidsPlaced;

  /// No description provided for @aucContactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get aucContactPerson;

  /// No description provided for @aucDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get aucDetails;

  /// No description provided for @aucHighestBid.
  ///
  /// In en, this message translates to:
  /// **'Highest Bid'**
  String get aucHighestBid;

  /// No description provided for @aucLosing.
  ///
  /// In en, this message translates to:
  /// **'Losing'**
  String get aucLosing;

  /// No description provided for @aucStatusLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get aucStatusLost;

  /// No description provided for @aucMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get aucMobile;

  /// No description provided for @aucNoBids.
  ///
  /// In en, this message translates to:
  /// **'No bids'**
  String get aucNoBids;

  /// No description provided for @aucOutbid.
  ///
  /// In en, this message translates to:
  /// **'Outbid'**
  String get aucOutbid;

  /// No description provided for @aucSeeLess.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get aucSeeLess;

  /// No description provided for @aucViewFullDetails.
  ///
  /// In en, this message translates to:
  /// **'View Full Details →'**
  String get aucViewFullDetails;

  /// No description provided for @aucWinning.
  ///
  /// In en, this message translates to:
  /// **'Winning'**
  String get aucWinning;

  /// No description provided for @aucStatusWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get aucStatusWon;

  /// No description provided for @aucAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get aucAllCategories;

  /// No description provided for @aucAllStates.
  ///
  /// In en, this message translates to:
  /// **'All States'**
  String get aucAllStates;

  /// No description provided for @aucApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get aucApply;

  /// No description provided for @aucBids.
  ///
  /// In en, this message translates to:
  /// **'Bids'**
  String get aucBids;

  /// No description provided for @aucMyWishlist.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get aucMyWishlist;

  /// No description provided for @aucNoVehiclesFoundShort.
  ///
  /// In en, this message translates to:
  /// **'No vehicles found'**
  String get aucNoVehiclesFoundShort;

  /// No description provided for @aucNoWishlistItems.
  ///
  /// In en, this message translates to:
  /// **'No wishlist items yet'**
  String get aucNoWishlistItems;

  /// No description provided for @aucUpcomingBiddingNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Auction — Bidding Not Started'**
  String get aucUpcomingBiddingNotStarted;

  /// No description provided for @aucVehicleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Vehicle not found'**
  String get aucVehicleNotFound;

  /// No description provided for @aucWishlistDetails.
  ///
  /// In en, this message translates to:
  /// **'Wishlist Details'**
  String get aucWishlistDetails;

  /// No description provided for @aucWishlisted.
  ///
  /// In en, this message translates to:
  /// **'Wishlisted'**
  String get aucWishlisted;

  /// No description provided for @aucYouAreLosing.
  ///
  /// In en, this message translates to:
  /// **'You Are Losing'**
  String get aucYouAreLosing;

  /// No description provided for @aucYouAreWinning.
  ///
  /// In en, this message translates to:
  /// **'You Are Winning'**
  String get aucYouAreWinning;

  /// No description provided for @aucYourFavoriteVehicles.
  ///
  /// In en, this message translates to:
  /// **'Your favorite vehicles'**
  String get aucYourFavoriteVehicles;

  /// No description provided for @aucSearchVehicles.
  ///
  /// In en, this message translates to:
  /// **'Search Vehicles'**
  String get aucSearchVehicles;

  /// No description provided for @aucStartBiddingStartPrice.
  ///
  /// In en, this message translates to:
  /// **'Start Bidding — Start Price ₹ {price}'**
  String aucStartBiddingStartPrice(String price);

  /// No description provided for @coreSearchEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get coreSearchEllipsis;

  /// No description provided for @coreNoOptionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No options available'**
  String get coreNoOptionsAvailable;

  /// No description provided for @coreNoResultsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String coreNoResultsFoundFor(String query);

  /// No description provided for @coreNoItemsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get coreNoItemsAvailable;

  /// No description provided for @coreNoItemsAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No Items Available'**
  String get coreNoItemsAvailableTitle;

  /// No description provided for @coreNoItemsToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No items to display.'**
  String get coreNoItemsToDisplay;

  /// No description provided for @coreNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get coreNoResultsFound;

  /// No description provided for @coreSelectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get coreSelectYear;

  /// No description provided for @coreEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get coreEnterPassword;

  /// No description provided for @coreFileUploadHint.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG & PDF (up to 12 MB)'**
  String get coreFileUploadHint;

  /// No description provided for @coreEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get coreEnterYourPassword;

  /// No description provided for @coreEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get coreEnterPhoneNumber;

  /// No description provided for @coreTimeLeftDhms.
  ///
  /// In en, this message translates to:
  /// **'{d}d {h}h {m}m {s}s left'**
  String coreTimeLeftDhms(int d, int h, int m, int s);

  /// No description provided for @coreTimeLeftHms.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m {s}s left'**
  String coreTimeLeftHms(int h, int m, int s);

  /// No description provided for @coreTimeLeftMs.
  ///
  /// In en, this message translates to:
  /// **'{m}m {s}s left'**
  String coreTimeLeftMs(int m, int s);

  /// No description provided for @coreTimeLeftS.
  ///
  /// In en, this message translates to:
  /// **'{s}s left'**
  String coreTimeLeftS(int s);

  /// No description provided for @coreSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get coreSubscriptions;

  /// No description provided for @coreRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get coreRewards;

  /// No description provided for @coreEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get coreEnterValidEmail;

  /// No description provided for @corePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get corePasswordRequired;

  /// No description provided for @corePasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get corePasswordMinLength;

  /// No description provided for @coreShareVehicleSubject.
  ///
  /// In en, this message translates to:
  /// **'{name} — Vahaan Bazar'**
  String coreShareVehicleSubject(String name);

  /// No description provided for @coreShareVehicleSubjectFallback.
  ///
  /// In en, this message translates to:
  /// **'Check out this vehicle on Vahaan Bazar'**
  String get coreShareVehicleSubjectFallback;

  /// No description provided for @coreShareReferralText.
  ///
  /// In en, this message translates to:
  /// **'🚛 Join Vahaan Bazar — India\'s trusted vehicle marketplace!\n\nSign up using my referral link and start buying & selling vehicles:\n\n{url}\n\n📱 Available on Android & iOS.'**
  String coreShareReferralText(String url);

  /// No description provided for @coreShareReferralSubject.
  ///
  /// In en, this message translates to:
  /// **'Join Vahaan Bazar'**
  String get coreShareReferralSubject;

  /// No description provided for @coreShareVehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get coreShareVehicleLabel;

  /// No description provided for @coreShareYearLine.
  ///
  /// In en, this message translates to:
  /// **'Year: {year}'**
  String coreShareYearLine(String year);

  /// No description provided for @coreShareVehicleBody.
  ///
  /// In en, this message translates to:
  /// **'Found on *Vahaan Bazar* — India\'s trusted vehicle marketplace.\n\n👉 View details & contact seller:\n{url}'**
  String coreShareVehicleBody(String url);

  /// No description provided for @coreNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get coreNotification;

  /// No description provided for @coreSessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get coreSessionExpiredTitle;

  /// No description provided for @coreSessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please login again to continue'**
  String get coreSessionExpiredMessage;

  /// No description provided for @coreJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get coreJustNow;

  /// No description provided for @coreYearsAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{n}y ago'**
  String coreYearsAgoShort(int n);

  /// No description provided for @coreMonthsAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{n}mo ago'**
  String coreMonthsAgoShort(int n);

  /// No description provided for @coreDaysAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String coreDaysAgoShort(int n);

  /// No description provided for @coreHoursAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String coreHoursAgoShort(int n);

  /// No description provided for @coreMinutesAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String coreMinutesAgoShort(int n);

  /// No description provided for @coreFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String coreFieldRequired(String field);

  /// No description provided for @coreThisField.
  ///
  /// In en, this message translates to:
  /// **'This field'**
  String get coreThisField;

  /// No description provided for @coreEnterValidEmailShort.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get coreEnterValidEmailShort;

  /// No description provided for @coreMinCharactersRequired.
  ///
  /// In en, this message translates to:
  /// **'Minimum {min} characters required'**
  String coreMinCharactersRequired(int min);

  /// No description provided for @coreConfirmPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get coreConfirmPasswordPrompt;

  /// No description provided for @corePasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get corePasswordsDoNotMatch;

  /// No description provided for @corePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get corePhoneRequired;

  /// No description provided for @coreEnterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get coreEnterValidMobile;

  /// No description provided for @coreRegNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration number is required'**
  String get coreRegNumberRequired;

  /// No description provided for @coreEnterValidRegNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid registration (e.g. MH12AB1234)'**
  String get coreEnterValidRegNumber;

  /// No description provided for @coreMinCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum {min} characters'**
  String coreMinCharacters(int min);

  /// No description provided for @coreMaxCharacters.
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} characters'**
  String coreMaxCharacters(int max);

  /// No description provided for @coreBuyAndSell.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell'**
  String get coreBuyAndSell;

  /// No description provided for @coreFms.
  ///
  /// In en, this message translates to:
  /// **'FMS'**
  String get coreFms;

  /// No description provided for @coreInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get coreInspection;

  /// No description provided for @coreServiceSupport.
  ///
  /// In en, this message translates to:
  /// **'Service Support'**
  String get coreServiceSupport;

  /// No description provided for @corePageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get corePageNotFound;

  /// No description provided for @coreChooseAPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a Plan'**
  String get coreChooseAPlan;

  /// No description provided for @coreChooseSubscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Subscription Plan'**
  String get coreChooseSubscriptionPlan;

  /// No description provided for @coreChooseSubscriptionPlanAuctionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a subscription plan to unlock features of auction'**
  String get coreChooseSubscriptionPlanAuctionSubtitle;

  /// No description provided for @coreWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get coreWishlist;

  /// No description provided for @coreYourWishlist.
  ///
  /// In en, this message translates to:
  /// **'Your Wishlist'**
  String get coreYourWishlist;

  /// No description provided for @coreSaveVehiclesYouLike.
  ///
  /// In en, this message translates to:
  /// **'Save vehicles you like'**
  String get coreSaveVehiclesYouLike;

  /// No description provided for @coreComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get coreComingSoon;

  /// No description provided for @coreSellYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Sell Your Vehicle'**
  String get coreSellYourVehicle;

  /// No description provided for @coreListYourVehicleForSale.
  ///
  /// In en, this message translates to:
  /// **'List your vehicle for sale'**
  String get coreListYourVehicleForSale;

  /// No description provided for @coreTitleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{title} Coming Soon'**
  String coreTitleComingSoon(String title);

  /// No description provided for @coreEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get coreEquipment;

  /// No description provided for @coreTractors.
  ///
  /// In en, this message translates to:
  /// **'Tractors'**
  String get coreTractors;

  /// No description provided for @coreSearchVehiclesEquipment.
  ///
  /// In en, this message translates to:
  /// **'Search vehicles, equipment...'**
  String get coreSearchVehiclesEquipment;

  /// No description provided for @coreFeaturedListings.
  ///
  /// In en, this message translates to:
  /// **'Featured Listings'**
  String get coreFeaturedListings;

  /// No description provided for @coreSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get coreSetLocation;

  /// No description provided for @coreFailedToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard.'**
  String get coreFailedToLoadDashboard;

  /// No description provided for @coreFailedToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications.'**
  String get coreFailedToLoadNotifications;

  /// No description provided for @coreNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get coreNotifications;

  /// No description provided for @coreMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get coreMarkAllRead;

  /// No description provided for @coreMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String coreMinAgo(int n);

  /// No description provided for @coreHrAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} hr ago'**
  String coreHrAgo(int n);

  /// No description provided for @coreNotifLiveAuction.
  ///
  /// In en, this message translates to:
  /// **'LIVE AUCTION'**
  String get coreNotifLiveAuction;

  /// No description provided for @coreNotifPriceUpdate.
  ///
  /// In en, this message translates to:
  /// **'PRICE UPDATE'**
  String get coreNotifPriceUpdate;

  /// No description provided for @coreNotifReferralBonus.
  ///
  /// In en, this message translates to:
  /// **'REFERRAL BONUS'**
  String get coreNotifReferralBonus;

  /// No description provided for @coreNotifPayment.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT'**
  String get coreNotifPayment;

  /// No description provided for @coreNotifGeneral.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get coreNotifGeneral;

  /// No description provided for @coreNoNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get coreNoNotificationsYet;

  /// No description provided for @coreNotifyAboutAuctions.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you about auctions, bids and more.'**
  String get coreNotifyAboutAuctions;

  /// No description provided for @coreIntroWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nVAHAAN BAZAR'**
  String get coreIntroWelcomeTitle;

  /// No description provided for @coreIntroSlide1Desc.
  ///
  /// In en, this message translates to:
  /// **'Buy and sell vehicles in one place Across trucks, equipment, and more'**
  String get coreIntroSlide1Desc;

  /// No description provided for @coreIntroSlide2Desc.
  ///
  /// In en, this message translates to:
  /// **'Create listings in minutes and connect with thousands of buyers instantly.'**
  String get coreIntroSlide2Desc;

  /// No description provided for @coreIntroSlide3Desc.
  ///
  /// In en, this message translates to:
  /// **'Join live auctions and secure vehicles at competitive prices.'**
  String get coreIntroSlide3Desc;

  /// No description provided for @coreIntroBuy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get coreIntroBuy;

  /// No description provided for @coreIntroSell.
  ///
  /// In en, this message translates to:
  /// **'SELL'**
  String get coreIntroSell;

  /// No description provided for @coreIntroBid.
  ///
  /// In en, this message translates to:
  /// **'BID'**
  String get coreIntroBid;

  /// No description provided for @corePaymentCancelledByUser.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled by user'**
  String get corePaymentCancelledByUser;

  /// No description provided for @coreUnknownPaymentError.
  ///
  /// In en, this message translates to:
  /// **'Unknown payment error'**
  String get coreUnknownPaymentError;

  /// No description provided for @coreSecurePaymentPoweredByPayU.
  ///
  /// In en, this message translates to:
  /// **'Secure payment powered by PayU'**
  String get coreSecurePaymentPoweredByPayU;

  /// No description provided for @coreChoosePreferredPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred payment method'**
  String get coreChoosePreferredPaymentMethod;

  /// No description provided for @corePaymentInitiationFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment initiation failed'**
  String get corePaymentInitiationFailed;

  /// No description provided for @corePaymentSuccessReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment success report failed'**
  String get corePaymentSuccessReportFailed;

  /// No description provided for @corePaymentFailureReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failure report failed'**
  String get corePaymentFailureReportFailed;

  /// No description provided for @coreUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String coreUnexpectedError(String error);

  /// No description provided for @coreNoDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get coreNoDataAvailable;

  /// No description provided for @coreLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get coreLocating;

  /// No description provided for @coreEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get coreEnded;

  /// No description provided for @coreAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get coreAvailable;

  /// No description provided for @coreTimeLeftDh.
  ///
  /// In en, this message translates to:
  /// **'{d}d {h}h left'**
  String coreTimeLeftDh(int d, int h);

  /// No description provided for @coreTimeLeftHm.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m left'**
  String coreTimeLeftHm(int h, int m);

  /// No description provided for @coreCategoryAuction.
  ///
  /// In en, this message translates to:
  /// **'{category} Auction'**
  String coreCategoryAuction(String category);

  /// No description provided for @corePinchToZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom  •  Swipe to navigate'**
  String get corePinchToZoomHint;

  /// No description provided for @inspInspectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Inspection Details'**
  String get inspInspectionDetails;

  /// No description provided for @inspNoInspectionDataFound.
  ///
  /// In en, this message translates to:
  /// **'No inspection data found'**
  String get inspNoInspectionDataFound;

  /// No description provided for @inspOwnerInformation.
  ///
  /// In en, this message translates to:
  /// **'Owner Information'**
  String get inspOwnerInformation;

  /// No description provided for @inspViewFullReport.
  ///
  /// In en, this message translates to:
  /// **'View Full Report'**
  String get inspViewFullReport;

  /// No description provided for @inspOpenReportInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open inspection report in browser'**
  String get inspOpenReportInBrowser;

  /// No description provided for @inspStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get inspStatusCompleted;

  /// No description provided for @inspStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inspStatusInProgress;

  /// No description provided for @inspStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get inspStatusRejected;

  /// No description provided for @inspViewReport.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get inspViewReport;

  /// No description provided for @inspAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get inspAdd;

  /// No description provided for @inspStepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String inspStepNumber(int number);

  /// No description provided for @inspVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get inspVehicleInfo;

  /// No description provided for @inspDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get inspDocumentation;

  /// No description provided for @inspMechanicalInspection.
  ///
  /// In en, this message translates to:
  /// **'Mechanical Inspection'**
  String get inspMechanicalInspection;

  /// No description provided for @inspBodyAndInterior.
  ///
  /// In en, this message translates to:
  /// **'Body & Interior'**
  String get inspBodyAndInterior;

  /// No description provided for @inspPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get inspPhotos;

  /// No description provided for @inspValuation.
  ///
  /// In en, this message translates to:
  /// **'Valuation'**
  String get inspValuation;

  /// No description provided for @inspInspectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Inspection Summary'**
  String get inspInspectionSummary;

  /// No description provided for @inspVehicleBrand.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Brand'**
  String get inspVehicleBrand;

  /// No description provided for @inspRto.
  ///
  /// In en, this message translates to:
  /// **'RTO'**
  String get inspRto;

  /// No description provided for @inspCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get inspCondition;

  /// No description provided for @inspInsuranceValid.
  ///
  /// In en, this message translates to:
  /// **'Insurance Valid'**
  String get inspInsuranceValid;

  /// No description provided for @inspFitnessValid.
  ///
  /// In en, this message translates to:
  /// **'Fitness Valid'**
  String get inspFitnessValid;

  /// No description provided for @inspAccidental.
  ///
  /// In en, this message translates to:
  /// **'Accidental'**
  String get inspAccidental;

  /// No description provided for @inspSuspension.
  ///
  /// In en, this message translates to:
  /// **'Suspension'**
  String get inspSuspension;

  /// No description provided for @inspCabinInterior.
  ///
  /// In en, this message translates to:
  /// **'Cabin/Interior'**
  String get inspCabinInterior;

  /// No description provided for @inspBodyFront.
  ///
  /// In en, this message translates to:
  /// **'Body Front'**
  String get inspBodyFront;

  /// No description provided for @inspBodyBack.
  ///
  /// In en, this message translates to:
  /// **'Body Back'**
  String get inspBodyBack;

  /// No description provided for @inspBodyLeft.
  ///
  /// In en, this message translates to:
  /// **'Body Left'**
  String get inspBodyLeft;

  /// No description provided for @inspBodyRight.
  ///
  /// In en, this message translates to:
  /// **'Body Right'**
  String get inspBodyRight;

  /// No description provided for @inspPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photo'**
  String inspPhotoCount(int count);

  /// No description provided for @inspPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String inspPhotosCount(int count);

  /// No description provided for @inspFrontRearTyres.
  ///
  /// In en, this message translates to:
  /// **'Front: {front}%, Rear: {rear}%'**
  String inspFrontRearTyres(int front, int rear);

  /// No description provided for @inspMarketValueRupee.
  ///
  /// In en, this message translates to:
  /// **'₹ {value}'**
  String inspMarketValueRupee(String value);

  /// No description provided for @inspVehicleDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get inspVehicleDetailsSection;

  /// No description provided for @inspCompanyDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Company Details (Optional)'**
  String get inspCompanyDetailsOptional;

  /// No description provided for @inspUploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get inspUploadDocuments;

  /// No description provided for @inspVehicleRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration Number'**
  String get inspVehicleRegistrationNumber;

  /// No description provided for @inspRegNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. MH-01-AB-1234'**
  String get inspRegNumberHint;

  /// No description provided for @inspRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get inspRequired;

  /// No description provided for @inspMin5Characters.
  ///
  /// In en, this message translates to:
  /// **'Min 5 characters'**
  String get inspMin5Characters;

  /// No description provided for @inspChassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Chassis Number'**
  String get inspChassisNumber;

  /// No description provided for @inspEnterChassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter chassis number'**
  String get inspEnterChassisNumber;

  /// No description provided for @inspSelectVehicleBrand.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Brand'**
  String get inspSelectVehicleBrand;

  /// No description provided for @inspSelectStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select state first'**
  String get inspSelectStateFirst;

  /// No description provided for @inspNoCitiesForState.
  ///
  /// In en, this message translates to:
  /// **'No cities available for selected state'**
  String get inspNoCitiesForState;

  /// No description provided for @inspEnter10DigitMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile number'**
  String get inspEnter10DigitMobile;

  /// No description provided for @inspEnterValid10DigitNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter valid 10-digit number'**
  String get inspEnterValid10DigitNumber;

  /// No description provided for @inspEnterCompanyNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter company name (optional)'**
  String get inspEnterCompanyNameOptional;

  /// No description provided for @inspInsuranceDocument.
  ///
  /// In en, this message translates to:
  /// **'Insurance Document'**
  String get inspInsuranceDocument;

  /// No description provided for @inspChooseFiles.
  ///
  /// In en, this message translates to:
  /// **'Choose a file/browse multiple files'**
  String get inspChooseFiles;

  /// No description provided for @inspSubmitInspectionRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Inspection Request'**
  String get inspSubmitInspectionRequest;

  /// No description provided for @inspFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) selected'**
  String inspFilesSelected(int count);

  /// No description provided for @inspAgentFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill out the inspection details for the customer'**
  String get inspAgentFormSubtitle;

  /// No description provided for @inspBodyPhotos.
  ///
  /// In en, this message translates to:
  /// **'Body Photos'**
  String get inspBodyPhotos;

  /// No description provided for @inspBodyFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'Body - Front'**
  String get inspBodyFrontLabel;

  /// No description provided for @inspBodyLeftSideLabel.
  ///
  /// In en, this message translates to:
  /// **'Body - Left Side'**
  String get inspBodyLeftSideLabel;

  /// No description provided for @inspBodyBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Body - Back'**
  String get inspBodyBackLabel;

  /// No description provided for @inspBodyRightSideLabel.
  ///
  /// In en, this message translates to:
  /// **'Body - Right Side'**
  String get inspBodyRightSideLabel;

  /// No description provided for @inspEnginePhotos.
  ///
  /// In en, this message translates to:
  /// **'Engine Photos'**
  String get inspEnginePhotos;

  /// No description provided for @inspChassisPhotos.
  ///
  /// In en, this message translates to:
  /// **'Chassis Photos'**
  String get inspChassisPhotos;

  /// No description provided for @inspInterior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get inspInterior;

  /// No description provided for @inspInteriorPhotos.
  ///
  /// In en, this message translates to:
  /// **'Interior Photos'**
  String get inspInteriorPhotos;

  /// No description provided for @inspCabinInteriorSection.
  ///
  /// In en, this message translates to:
  /// **'Cabin Interior'**
  String get inspCabinInteriorSection;

  /// No description provided for @inspCabinInteriorPhotos.
  ///
  /// In en, this message translates to:
  /// **'Cabin Interior Photos'**
  String get inspCabinInteriorPhotos;

  /// No description provided for @inspOdometerPhotos.
  ///
  /// In en, this message translates to:
  /// **'Odometer Photos'**
  String get inspOdometerPhotos;

  /// No description provided for @inspFullRoundVideoOptional.
  ///
  /// In en, this message translates to:
  /// **'Full Round Video (Optional)'**
  String get inspFullRoundVideoOptional;

  /// No description provided for @inspUploadVideoHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a complete 360° video of the vehicle'**
  String get inspUploadVideoHint;

  /// No description provided for @inspNotRatedYet.
  ///
  /// In en, this message translates to:
  /// **'Not rated yet'**
  String get inspNotRatedYet;

  /// No description provided for @inspRateCondition.
  ///
  /// In en, this message translates to:
  /// **'Rate Condition'**
  String get inspRateCondition;

  /// No description provided for @inspFrontAxleTyres.
  ///
  /// In en, this message translates to:
  /// **'Front Axle Tyres'**
  String get inspFrontAxleTyres;

  /// No description provided for @inspRearAxleTyres.
  ///
  /// In en, this message translates to:
  /// **'Rear Axle Tyres'**
  String get inspRearAxleTyres;

  /// No description provided for @inspOdometerReading.
  ///
  /// In en, this message translates to:
  /// **'Odometer Reading'**
  String get inspOdometerReading;

  /// No description provided for @inspOdometerReadingKm.
  ///
  /// In en, this message translates to:
  /// **'Odometer Reading (KM)'**
  String get inspOdometerReadingKm;

  /// No description provided for @inspEnterOdometerReading.
  ///
  /// In en, this message translates to:
  /// **'Enter odometer reading'**
  String get inspEnterOdometerReading;

  /// No description provided for @inspSubmitInspection.
  ///
  /// In en, this message translates to:
  /// **'Submit Inspection'**
  String get inspSubmitInspection;

  /// No description provided for @inspChooseFilesMax.
  ///
  /// In en, this message translates to:
  /// **'Choose files (max {max})'**
  String inspChooseFilesMax(int max);

  /// No description provided for @inspSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get inspSuccess;

  /// No description provided for @inspError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get inspError;

  /// No description provided for @inspOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get inspOkay;

  /// No description provided for @inspSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get inspSomethingWentWrong;

  /// No description provided for @inspFailedToPickFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file. Please try again.'**
  String get inspFailedToPickFile;

  /// No description provided for @inspPleaseSelectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Please select vehicle type'**
  String get inspPleaseSelectVehicleType;

  /// No description provided for @inspPleaseSelectVehicleBrand.
  ///
  /// In en, this message translates to:
  /// **'Please select vehicle brand'**
  String get inspPleaseSelectVehicleBrand;

  /// No description provided for @inspPleaseSelectState.
  ///
  /// In en, this message translates to:
  /// **'Please select state'**
  String get inspPleaseSelectState;

  /// No description provided for @inspPleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select city'**
  String get inspPleaseSelectCity;

  /// No description provided for @inspPleaseUploadRcDocument.
  ///
  /// In en, this message translates to:
  /// **'Please upload RC document'**
  String get inspPleaseUploadRcDocument;

  /// No description provided for @inspRequestSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your inspection request has been submitted successfully.'**
  String get inspRequestSubmittedSuccessfully;

  /// No description provided for @inspFailedToSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit inspection request.'**
  String get inspFailedToSubmitRequest;

  /// No description provided for @inspPleaseLoginToViewInspections.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view inspections.'**
  String get inspPleaseLoginToViewInspections;

  /// No description provided for @inspFailedToLoadInspections.
  ///
  /// In en, this message translates to:
  /// **'Failed to load inspections.'**
  String get inspFailedToLoadInspections;

  /// No description provided for @inspEnterValidVehicleRegNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid vehicle registration number'**
  String get inspEnterValidVehicleRegNumber;

  /// No description provided for @inspFrontAxlePercentRange.
  ///
  /// In en, this message translates to:
  /// **'Front axle tyre percentage must be 0-100'**
  String get inspFrontAxlePercentRange;

  /// No description provided for @inspRearAxlePercentRange.
  ///
  /// In en, this message translates to:
  /// **'Rear axle tyre percentage must be 0-100'**
  String get inspRearAxlePercentRange;

  /// No description provided for @inspEnterValidMarketValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid market value'**
  String get inspEnterValidMarketValue;

  /// No description provided for @inspFixErrorsBeforeSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Please fix errors before submitting'**
  String get inspFixErrorsBeforeSubmitting;

  /// No description provided for @inspInspectionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Inspection Submitted'**
  String get inspInspectionSubmitted;

  /// No description provided for @inspReportSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your inspection report has been submitted successfully.'**
  String get inspReportSubmittedSuccessfully;

  /// No description provided for @inspFailedToSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit inspection report.'**
  String get inspFailedToSubmitReport;

  /// No description provided for @inspThankYouForSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Thank you for submitting!'**
  String get inspThankYouForSubmitting;

  /// No description provided for @inspTeamWillContactSoon.
  ///
  /// In en, this message translates to:
  /// **'Our team will contact you soon..!'**
  String get inspTeamWillContactSoon;

  /// No description provided for @inspServerErrorWithCode.
  ///
  /// In en, this message translates to:
  /// **'Server error: {code}'**
  String inspServerErrorWithCode(String code);

  /// No description provided for @inspMaxImagesPerCategory.
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} images per category allowed'**
  String inspMaxImagesPerCategory(int max);

  /// No description provided for @inspMaxFilesPerCategory.
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} files per category'**
  String inspMaxFilesPerCategory(int max);

  /// No description provided for @inspOnlyMoreFilesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only {remaining} more file(s) allowed. {skipped} file(s) skipped.'**
  String inspOnlyMoreFilesAllowed(int remaining, int skipped);

  /// No description provided for @inspServiceAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Service & Support'**
  String get inspServiceAndSupport;

  /// No description provided for @inspRoadsideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'24/7 roadside assistance at your fingertips'**
  String get inspRoadsideSubtitle;

  /// No description provided for @inspBreakdownAssistanceHeadline.
  ///
  /// In en, this message translates to:
  /// **'24/7 Breakdown\nAssistance'**
  String get inspBreakdownAssistanceHeadline;

  /// No description provided for @inspRoadsideDescription.
  ///
  /// In en, this message translates to:
  /// **'Instant Help. Anytime, Anywhere.\nQuick response and reliable roadside assistance at your fingertips.'**
  String get inspRoadsideDescription;

  /// No description provided for @inspContactMechanic.
  ///
  /// In en, this message translates to:
  /// **'Contact Mechanic'**
  String get inspContactMechanic;

  /// No description provided for @inspNoServiceProvidersTryAgain.
  ///
  /// In en, this message translates to:
  /// **'No service providers found near your location.\nTry again or expand your search area.'**
  String get inspNoServiceProvidersTryAgain;

  /// No description provided for @inspLocationError.
  ///
  /// In en, this message translates to:
  /// **'Location Error'**
  String get inspLocationError;

  /// No description provided for @inspUnableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your location. Please try again.'**
  String get inspUnableToGetLocation;

  /// No description provided for @inspUnableToEnableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Unable to enable location services. Please check settings.'**
  String get inspUnableToEnableLocationServices;

  /// No description provided for @inspUnableToLoadSubscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Unable to load subscription plan. Please try again.'**
  String get inspUnableToLoadSubscriptionPlan;

  /// No description provided for @inspConnectWithMechanic.
  ///
  /// In en, this message translates to:
  /// **'Connect with Mechanic'**
  String get inspConnectWithMechanic;

  /// No description provided for @inspContactUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Contact unlocked! You can now call the mechanic.'**
  String get inspContactUnlocked;

  /// No description provided for @inspSomethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get inspSomethingWentWrongTryAgain;

  /// No description provided for @inspPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get inspPhone;

  /// No description provided for @inspLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Required'**
  String get inspLocationRequired;

  /// No description provided for @inspLocationAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'This app needs location access to find service providers near you.'**
  String get inspLocationAccessNeeded;

  /// No description provided for @inspFindNearestProviders.
  ///
  /// In en, this message translates to:
  /// **'Find nearest service providers'**
  String get inspFindNearestProviders;

  /// No description provided for @inspAccurateDistanceEstimates.
  ///
  /// In en, this message translates to:
  /// **'Get accurate distance estimates'**
  String get inspAccurateDistanceEstimates;

  /// No description provided for @inspPersonalizedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Personalized recommendations'**
  String get inspPersonalizedRecommendations;

  /// No description provided for @inspEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get inspEnable;

  /// No description provided for @inspEnableGps.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS'**
  String get inspEnableGps;

  /// No description provided for @inspTurnOnGps.
  ///
  /// In en, this message translates to:
  /// **'Please turn on GPS in your device settings, then come back.'**
  String get inspTurnOnGps;

  /// No description provided for @inspPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get inspPermissionRequired;

  /// No description provided for @inspLocationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required. Please enable it in app settings.'**
  String get inspLocationPermissionRequired;

  /// No description provided for @inspSettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Settings Updated?'**
  String get inspSettingsUpdated;

  /// No description provided for @inspDidYouEnablePermission.
  ///
  /// In en, this message translates to:
  /// **'Did you enable location permission? Tap \"Retry\" to find service providers.'**
  String get inspDidYouEnablePermission;

  /// No description provided for @inspPayToGetContact.
  ///
  /// In en, this message translates to:
  /// **'Pay to get the direct contact number for {mechanicName} at {garageName}.'**
  String inspPayToGetContact(String mechanicName, String garageName);

  /// No description provided for @inspContactWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact: {phone}'**
  String inspContactWithPhone(String phone);

  /// No description provided for @inspDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String inspDistanceKm(String distance);

  /// No description provided for @inspSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get inspSelectCountry;

  /// No description provided for @inspSearchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get inspSearchCountry;

  /// No description provided for @inspLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get inspLogIn;

  /// No description provided for @inspWithOtp.
  ///
  /// In en, this message translates to:
  /// **'with OTP'**
  String get inspWithOtp;

  /// No description provided for @inspSecureQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Secure and quick access\nto your account'**
  String get inspSecureQuickAccess;

  /// No description provided for @inspNumberSafeWithUs.
  ///
  /// In en, this message translates to:
  /// **'Your number is safe with us.\nWe never share it with anyone.'**
  String get inspNumberSafeWithUs;

  /// No description provided for @inspNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get inspNeedHelp;

  /// No description provided for @inspSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to '**
  String get inspSentTo;

  /// No description provided for @inspCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get inspCompleteProfile;

  /// No description provided for @inspTellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get inspTellUsAboutYourself;

  /// No description provided for @inspCompleteProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to get started'**
  String get inspCompleteProfileSubtitle;

  /// No description provided for @inspEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get inspEnterFirstName;

  /// No description provided for @inspEnterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get inspEnterEmailAddress;

  /// No description provided for @inspSaveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get inspSaveAndContinue;

  /// No description provided for @inspMin3Characters.
  ///
  /// In en, this message translates to:
  /// **'Min 3 characters'**
  String get inspMin3Characters;

  /// No description provided for @inspEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get inspEnterValidEmail;

  /// No description provided for @inspEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get inspEmailRequired;

  /// No description provided for @inspPhoneNumberNotFound.
  ///
  /// In en, this message translates to:
  /// **'Phone number not found. Please go back and try again.'**
  String get inspPhoneNumberNotFound;

  /// No description provided for @inspOtpResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get inspOtpResentSuccessfully;

  /// No description provided for @inspFailedToResendOtpTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP. Please try again.'**
  String get inspFailedToResendOtpTryAgain;

  /// No description provided for @inspSessionExpiredRetry.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please go back and retry.'**
  String get inspSessionExpiredRetry;

  /// No description provided for @inspFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields correctly'**
  String get inspFillRequiredFields;

  /// No description provided for @inspProfileCompleted.
  ///
  /// In en, this message translates to:
  /// **'Profile completed!'**
  String get inspProfileCompleted;

  /// No description provided for @inspFailedToSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile.'**
  String get inspFailedToSaveProfile;

  /// No description provided for @inspFailedToSaveProfileTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile. Please try again.'**
  String get inspFailedToSaveProfileTryAgain;

  /// No description provided for @inspFailedToLoadStates.
  ///
  /// In en, this message translates to:
  /// **'Failed to load states'**
  String get inspFailedToLoadStates;

  /// No description provided for @inspFailedToLoadStatesTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to load states. Please try again.'**
  String get inspFailedToLoadStatesTryAgain;

  /// No description provided for @inspFailedToLoadCities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cities'**
  String get inspFailedToLoadCities;

  /// No description provided for @inspFailedToLoadCitiesTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cities. Please try again.'**
  String get inspFailedToLoadCitiesTryAgain;

  /// No description provided for @inspPleaseSelectAState.
  ///
  /// In en, this message translates to:
  /// **'Please select a state'**
  String get inspPleaseSelectAState;

  /// No description provided for @inspPleaseSelectACity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get inspPleaseSelectACity;

  /// No description provided for @inspEmptyServerResponse.
  ///
  /// In en, this message translates to:
  /// **'Empty response from server'**
  String get inspEmptyServerResponse;

  /// No description provided for @inspInvalidOtpVerificationRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP verification request'**
  String get inspInvalidOtpVerificationRequest;

  /// No description provided for @inspConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please try again.'**
  String get inspConnectionTimeout;

  /// No description provided for @inspAnErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get inspAnErrorOccurred;

  /// No description provided for @inspRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled'**
  String get inspRequestCancelled;

  /// No description provided for @inspNoInternetCheckNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get inspNoInternetCheckNetwork;

  /// No description provided for @inspAnUnexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get inspAnUnexpectedErrorOccurred;

  /// No description provided for @inspRequestFailedWithStatus.
  ///
  /// In en, this message translates to:
  /// **'Request failed with status code: {statusCode}'**
  String inspRequestFailedWithStatus(String statusCode);

  /// No description provided for @insVehicleNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number *'**
  String get insVehicleNumberLabel;

  /// No description provided for @insEnterVehicleNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle No'**
  String get insEnterVehicleNo;

  /// No description provided for @insRcDocumentLabel.
  ///
  /// In en, this message translates to:
  /// **'RC Document *'**
  String get insRcDocumentLabel;

  /// No description provided for @insFileUploadLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a file/browse multiple files'**
  String get insFileUploadLabel;

  /// No description provided for @insFileUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG & PDF (up to 12 MB)'**
  String get insFileUploadSubtitle;

  /// No description provided for @insPreviousYearPolicy.
  ///
  /// In en, this message translates to:
  /// **'Previous Year Policy'**
  String get insPreviousYearPolicy;

  /// No description provided for @insInsuranceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Insurance Type *'**
  String get insInsuranceTypeLabel;

  /// No description provided for @insClaimStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Claim Status *'**
  String get insClaimStatusLabel;

  /// No description provided for @insSelectClaimStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Claim Status'**
  String get insSelectClaimStatus;

  /// No description provided for @insAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I Accept the '**
  String get insAcceptThe;

  /// No description provided for @insAndConnector.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get insAndConnector;

  /// No description provided for @insErrVehicleNoRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle registration number'**
  String get insErrVehicleNoRequired;

  /// No description provided for @insErrRcRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload RC document'**
  String get insErrRcRequired;

  /// No description provided for @insErrInsuranceTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select insurance type'**
  String get insErrInsuranceTypeRequired;

  /// No description provided for @insErrClaimRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select claim status'**
  String get insErrClaimRequired;

  /// No description provided for @insStateLabel.
  ///
  /// In en, this message translates to:
  /// **'State *'**
  String get insStateLabel;

  /// No description provided for @insNoStatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No states available'**
  String get insNoStatesAvailable;

  /// No description provided for @insCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get insCityLabel;

  /// No description provided for @insSelectStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a state first'**
  String get insSelectStateFirst;

  /// No description provided for @insNoCitiesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No cities available'**
  String get insNoCitiesAvailable;

  /// No description provided for @insRcCopyLabel.
  ///
  /// In en, this message translates to:
  /// **'RC Copy *'**
  String get insRcCopyLabel;

  /// No description provided for @insInsuranceCopyLabel.
  ///
  /// In en, this message translates to:
  /// **'Insurance Copy *'**
  String get insInsuranceCopyLabel;

  /// No description provided for @insFleetSize.
  ///
  /// In en, this message translates to:
  /// **'Fleet Size'**
  String get insFleetSize;

  /// No description provided for @insEnterFleetSize.
  ///
  /// In en, this message translates to:
  /// **'Enter Fleet Size'**
  String get insEnterFleetSize;

  /// No description provided for @insCompanyGstIfAvailable.
  ///
  /// In en, this message translates to:
  /// **'Company GST (if Available)'**
  String get insCompanyGstIfAvailable;

  /// No description provided for @insVehicleLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Location *'**
  String get insVehicleLocationLabel;

  /// No description provided for @insApplicantDetails.
  ///
  /// In en, this message translates to:
  /// **'Applicant Details'**
  String get insApplicantDetails;

  /// No description provided for @insAadharDocumentLabel.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Document *'**
  String get insAadharDocumentLabel;

  /// No description provided for @insPanDocumentLabel.
  ///
  /// In en, this message translates to:
  /// **'PAN Document *'**
  String get insPanDocumentLabel;

  /// No description provided for @insMobileNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number *'**
  String get insMobileNumberLabel;

  /// No description provided for @insEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get insEnterMobileNumber;

  /// No description provided for @insAddCoApplicantDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Co-Applicant Details'**
  String get insAddCoApplicantDetails;

  /// No description provided for @insCoApplicantDetails.
  ///
  /// In en, this message translates to:
  /// **'Co-Applicant Details'**
  String get insCoApplicantDetails;

  /// No description provided for @insErrSelectState.
  ///
  /// In en, this message translates to:
  /// **'Please select state'**
  String get insErrSelectState;

  /// No description provided for @insErrSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select city'**
  String get insErrSelectCity;

  /// No description provided for @insErrUploadRcCopy.
  ///
  /// In en, this message translates to:
  /// **'Please upload RC copy'**
  String get insErrUploadRcCopy;

  /// No description provided for @insErrUploadInsuranceCopy.
  ///
  /// In en, this message translates to:
  /// **'Please upload insurance copy'**
  String get insErrUploadInsuranceCopy;

  /// No description provided for @insErrEnterVehicleLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle location'**
  String get insErrEnterVehicleLocation;

  /// No description provided for @insErrUploadAadhar.
  ///
  /// In en, this message translates to:
  /// **'Please upload Aadhar document'**
  String get insErrUploadAadhar;

  /// No description provided for @insErrUploadPan.
  ///
  /// In en, this message translates to:
  /// **'Please upload PAN document'**
  String get insErrUploadPan;

  /// No description provided for @insErrEnterMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get insErrEnterMobile;

  /// No description provided for @insErrUploadCoAadhar.
  ///
  /// In en, this message translates to:
  /// **'Please upload co-applicant Aadhar document'**
  String get insErrUploadCoAadhar;

  /// No description provided for @insErrUploadCoPan.
  ///
  /// In en, this message translates to:
  /// **'Please upload co-applicant PAN document'**
  String get insErrUploadCoPan;

  /// No description provided for @insErrEnterCoMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter co-applicant mobile number'**
  String get insErrEnterCoMobile;

  /// No description provided for @insMyQuotes.
  ///
  /// In en, this message translates to:
  /// **'My Quotes'**
  String get insMyQuotes;

  /// No description provided for @insMyQuotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your insurance and finance quotes'**
  String get insMyQuotesSubtitle;

  /// No description provided for @insLoadingQuotes.
  ///
  /// In en, this message translates to:
  /// **'Loading quotes...'**
  String get insLoadingQuotes;

  /// No description provided for @insNoQuotesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No quotes available'**
  String get insNoQuotesAvailable;

  /// No description provided for @insSubmitRequestToGetQuotes.
  ///
  /// In en, this message translates to:
  /// **'Submit an insurance or finance request to get quotes'**
  String get insSubmitRequestToGetQuotes;

  /// No description provided for @insQuoteCountOne.
  ///
  /// In en, this message translates to:
  /// **'{count} Quote'**
  String insQuoteCountOne(int count);

  /// No description provided for @insQuoteCountMany.
  ///
  /// In en, this message translates to:
  /// **'{count} Quotes'**
  String insQuoteCountMany(int count);

  /// No description provided for @insNoQuotesReceivedYet.
  ///
  /// In en, this message translates to:
  /// **'No quotes received yet'**
  String get insNoQuotesReceivedYet;

  /// No description provided for @insDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get insDownload;

  /// No description provided for @insLoginToSubmitInsurance.
  ///
  /// In en, this message translates to:
  /// **'Please login to submit insurance request'**
  String get insLoginToSubmitInsurance;

  /// No description provided for @insInsuranceSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Insurance request submitted successfully! Our team will review and get back to you soon.'**
  String get insInsuranceSubmittedSuccess;

  /// No description provided for @insFailedLoadStates.
  ///
  /// In en, this message translates to:
  /// **'Failed to load states'**
  String get insFailedLoadStates;

  /// No description provided for @insFailedLoadCities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cities'**
  String get insFailedLoadCities;

  /// No description provided for @insLoginToSubmitFinance.
  ///
  /// In en, this message translates to:
  /// **'Please login to submit finance request'**
  String get insLoginToSubmitFinance;

  /// No description provided for @insFinanceSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Finance request submitted successfully! Our team will review and get back to you soon.'**
  String get insFinanceSubmittedSuccess;

  /// No description provided for @insLoginToViewQuotes.
  ///
  /// In en, this message translates to:
  /// **'Please login to view quotes'**
  String get insLoginToViewQuotes;

  /// No description provided for @insFailedPickFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file. Please try again.'**
  String get insFailedPickFile;

  /// No description provided for @insDownloadLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Download link not available'**
  String get insDownloadLinkUnavailable;

  /// No description provided for @insStoragePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to download quotes'**
  String get insStoragePermissionRequired;

  /// No description provided for @insCouldNotOpenPdf.
  ///
  /// In en, this message translates to:
  /// **'Could not open the downloaded PDF'**
  String get insCouldNotOpenPdf;

  /// No description provided for @insDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get insDownloaded;

  /// No description provided for @insQuotePdfSaved.
  ///
  /// In en, this message translates to:
  /// **'Quote PDF saved successfully'**
  String get insQuotePdfSaved;

  /// No description provided for @insRequestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get insRequestTimeout;

  /// No description provided for @insNetworkErrorCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get insNetworkErrorCheckConnection;

  /// No description provided for @insQuoteFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Quote file not found.'**
  String get insQuoteFileNotFound;

  /// No description provided for @insAccessDeniedQuoteExpired.
  ///
  /// In en, this message translates to:
  /// **'Access denied. Quote may have expired.'**
  String get insAccessDeniedQuoteExpired;

  /// No description provided for @insFailedDownloadQuote.
  ///
  /// In en, this message translates to:
  /// **'Failed to download quote PDF.'**
  String get insFailedDownloadQuote;

  /// No description provided for @insFailedSaveQuote.
  ///
  /// In en, this message translates to:
  /// **'Failed to save quote PDF: {error}'**
  String insFailedSaveQuote(String error);

  /// No description provided for @insThankYouForSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Thank you for submitting!'**
  String get insThankYouForSubmitting;

  /// No description provided for @insTeamWillContactSoon.
  ///
  /// In en, this message translates to:
  /// **'Our team will contact you soon..!'**
  String get insTeamWillContactSoon;

  /// No description provided for @insOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get insOkay;

  /// No description provided for @insUnexpectedErrorShort.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get insUnexpectedErrorShort;

  /// No description provided for @insFailedLoadQuotes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load quotes'**
  String get insFailedLoadQuotes;

  /// No description provided for @insSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get insSessionExpired;

  /// No description provided for @insNoPermissionViewQuotes.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to view quotes.'**
  String get insNoPermissionViewQuotes;

  /// No description provided for @insQuotesServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Quotes service not found.'**
  String get insQuotesServiceNotFound;

  /// No description provided for @insServerErrorTryLater.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get insServerErrorTryLater;

  /// No description provided for @insFailedLoadQuotesWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load quotes: {error}'**
  String insFailedLoadQuotesWithError(String error);

  /// No description provided for @insInvalidRequestData.
  ///
  /// In en, this message translates to:
  /// **'Invalid request data'**
  String get insInvalidRequestData;

  /// No description provided for @insNoPermissionAction.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action.'**
  String get insNoPermissionAction;

  /// No description provided for @insServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service not found. Please try again later.'**
  String get insServiceNotFound;

  /// No description provided for @insValidationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get insValidationError;

  /// No description provided for @profMyAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get profMyAccount;

  /// No description provided for @profUpdatePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get profUpdatePersonalInfo;

  /// No description provided for @profViewManagePlans.
  ///
  /// In en, this message translates to:
  /// **'View and manage your plans'**
  String get profViewManagePlans;

  /// No description provided for @profChoosePreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get profChoosePreferredLanguage;

  /// No description provided for @profViewItemsWon.
  ///
  /// In en, this message translates to:
  /// **'View items you have won'**
  String get profViewItemsWon;

  /// No description provided for @profTrackBids.
  ///
  /// In en, this message translates to:
  /// **'Track your active and past bids'**
  String get profTrackBids;

  /// No description provided for @profWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profWishlist;

  /// No description provided for @profAuctionVehiclesSaved.
  ///
  /// In en, this message translates to:
  /// **'Auction vehicles you have saved'**
  String get profAuctionVehiclesSaved;

  /// No description provided for @profRequestRefund.
  ///
  /// In en, this message translates to:
  /// **'Request a refund for your orders'**
  String get profRequestRefund;

  /// No description provided for @profBuyAndSell.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell'**
  String get profBuyAndSell;

  /// No description provided for @profManageListedVehicles.
  ///
  /// In en, this message translates to:
  /// **'Manage your listed vehicles'**
  String get profManageListedVehicles;

  /// No description provided for @profItemsSaved.
  ///
  /// In en, this message translates to:
  /// **'Items you have saved'**
  String get profItemsSaved;

  /// No description provided for @profPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get profPurchaseHistory;

  /// No description provided for @profViewPastPurchases.
  ///
  /// In en, this message translates to:
  /// **'View your past purchases'**
  String get profViewPastPurchases;

  /// No description provided for @profUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profUser;

  /// No description provided for @profAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get profAgent;

  /// No description provided for @profPremiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get profPremiumMember;

  /// No description provided for @profTotalWins.
  ///
  /// In en, this message translates to:
  /// **'Total Wins'**
  String get profTotalWins;

  /// No description provided for @profVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get profVehicles;

  /// No description provided for @profActiveBids.
  ///
  /// In en, this message translates to:
  /// **'Active Bids'**
  String get profActiveBids;

  /// No description provided for @profWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get profWalletBalance;

  /// No description provided for @profRewardCoins.
  ///
  /// In en, this message translates to:
  /// **'Reward Coins'**
  String get profRewardCoins;

  /// No description provided for @profWithdrawToBank.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to Bank'**
  String get profWithdrawToBank;

  /// No description provided for @profWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get profWithdraw;

  /// No description provided for @profHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get profHistory;

  /// No description provided for @profMaxWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Max Withdrawal'**
  String get profMaxWithdrawal;

  /// No description provided for @profFiftyPercentOfBalance.
  ///
  /// In en, this message translates to:
  /// **'50% of balance'**
  String get profFiftyPercentOfBalance;

  /// No description provided for @profMaxWithdrawalIs.
  ///
  /// In en, this message translates to:
  /// **'Maximum withdrawal is ₹{amount}'**
  String profMaxWithdrawalIs(String amount);

  /// No description provided for @profMinWithdrawalIs.
  ///
  /// In en, this message translates to:
  /// **'Minimum withdrawal is ₹{amount}'**
  String profMinWithdrawalIs(String amount);

  /// No description provided for @profWithdrawRange.
  ///
  /// In en, this message translates to:
  /// **'Withdraw ₹{min} – ₹{max} (max 50% of balance)'**
  String profWithdrawRange(String min, String max);

  /// No description provided for @profBankAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Account Details'**
  String get profBankAccountDetails;

  /// No description provided for @profAmountRupees.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get profAmountRupees;

  /// No description provided for @profEnterWithdrawalAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter withdrawal amount'**
  String get profEnterWithdrawalAmount;

  /// No description provided for @profEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get profEnterValidAmount;

  /// No description provided for @profAccountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get profAccountHolderName;

  /// No description provided for @profAsPerBankRecords.
  ///
  /// In en, this message translates to:
  /// **'As per bank records'**
  String get profAsPerBankRecords;

  /// No description provided for @profEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get profEnterFullName;

  /// No description provided for @profBankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get profBankName;

  /// No description provided for @profBankNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SBI'**
  String get profBankNameHint;

  /// No description provided for @profBranchOptional.
  ///
  /// In en, this message translates to:
  /// **'Branch (opt.)'**
  String get profBranchOptional;

  /// No description provided for @profBranchNameHint.
  ///
  /// In en, this message translates to:
  /// **'Branch name'**
  String get profBranchNameHint;

  /// No description provided for @profAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get profAccountNumber;

  /// No description provided for @profEnterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter account number'**
  String get profEnterAccountNumber;

  /// No description provided for @profInvalidAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid account number'**
  String get profInvalidAccountNumber;

  /// No description provided for @profIfscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get profIfscCode;

  /// No description provided for @profIfscHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SBIN0001234'**
  String get profIfscHint;

  /// No description provided for @profInvalidIfsc.
  ///
  /// In en, this message translates to:
  /// **'Invalid IFSC'**
  String get profInvalidIfsc;

  /// No description provided for @profSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get profSubmitting;

  /// No description provided for @profRequestWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Request Withdrawal'**
  String get profRequestWithdrawal;

  /// No description provided for @profProcessedWithin.
  ///
  /// In en, this message translates to:
  /// **'Processed within 2–3 business days'**
  String get profProcessedWithin;

  /// No description provided for @profNoWithdrawalsYet.
  ///
  /// In en, this message translates to:
  /// **'No withdrawals yet'**
  String get profNoWithdrawalsYet;

  /// No description provided for @profWithdrawalRequestsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawal requests will appear here.'**
  String get profWithdrawalRequestsAppearHere;

  /// No description provided for @profPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get profPaid;

  /// No description provided for @profRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get profRejected;

  /// No description provided for @profRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get profRequested;

  /// No description provided for @profAccountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account Holder'**
  String get profAccountHolder;

  /// No description provided for @profAccountNoShort.
  ///
  /// In en, this message translates to:
  /// **'Account No.'**
  String get profAccountNoShort;

  /// No description provided for @profBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get profBank;

  /// No description provided for @profIfsc.
  ///
  /// In en, this message translates to:
  /// **'IFSC'**
  String get profIfsc;

  /// No description provided for @profPayoutId.
  ///
  /// In en, this message translates to:
  /// **'Payout ID'**
  String get profPayoutId;

  /// No description provided for @profMin3Characters.
  ///
  /// In en, this message translates to:
  /// **'Min 3 characters'**
  String get profMin3Characters;

  /// No description provided for @profPleaseSelectState.
  ///
  /// In en, this message translates to:
  /// **'Please select a state'**
  String get profPleaseSelectState;

  /// No description provided for @profPleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get profPleaseSelectCity;

  /// No description provided for @profFailedLoadStates.
  ///
  /// In en, this message translates to:
  /// **'Failed to load states'**
  String get profFailedLoadStates;

  /// No description provided for @profFailedLoadStatesTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to load states. Please try again.'**
  String get profFailedLoadStatesTryAgain;

  /// No description provided for @profFailedLoadCities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cities'**
  String get profFailedLoadCities;

  /// No description provided for @profFailedLoadCitiesTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cities. Please try again.'**
  String get profFailedLoadCitiesTryAgain;

  /// No description provided for @profFillRequiredFieldsCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields correctly'**
  String get profFillRequiredFieldsCorrectly;

  /// No description provided for @profFailedUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile.'**
  String get profFailedUpdateProfile;

  /// No description provided for @profFailedUpdateProfileTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile. Please try again.'**
  String get profFailedUpdateProfileTryAgain;

  /// No description provided for @profCashOutPlaced.
  ///
  /// In en, this message translates to:
  /// **'Cash-out request placed!'**
  String get profCashOutPlaced;

  /// No description provided for @profCashOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Cash-out request failed.'**
  String get profCashOutFailed;

  /// No description provided for @profCoinsConverted.
  ///
  /// In en, this message translates to:
  /// **'Coins converted!'**
  String get profCoinsConverted;

  /// No description provided for @profConversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed.'**
  String get profConversionFailed;

  /// No description provided for @profFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get profFillRequiredFields;

  /// No description provided for @profRefundSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Refund request submitted'**
  String get profRefundSubmitted;

  /// No description provided for @profFailedInitiateRefund.
  ///
  /// In en, this message translates to:
  /// **'Failed to initiate refund. Please try again.'**
  String get profFailedInitiateRefund;

  /// No description provided for @profSubAuctionAccessPlan.
  ///
  /// In en, this message translates to:
  /// **'Auction Access Plan'**
  String get profSubAuctionAccessPlan;

  /// No description provided for @profSubAuctionBidLimit.
  ///
  /// In en, this message translates to:
  /// **'Auction Bid Limit'**
  String get profSubAuctionBidLimit;

  /// No description provided for @profSubBidLimitPlan.
  ///
  /// In en, this message translates to:
  /// **'Bid Limit Plan'**
  String get profSubBidLimitPlan;

  /// No description provided for @profSubOwnerContactPlan.
  ///
  /// In en, this message translates to:
  /// **'Owner Contact Plan'**
  String get profSubOwnerContactPlan;

  /// No description provided for @profSubVehicleDetailsPlan.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details Plan'**
  String get profSubVehicleDetailsPlan;

  /// No description provided for @profSubInspectionPlan.
  ///
  /// In en, this message translates to:
  /// **'Inspection Plan'**
  String get profSubInspectionPlan;

  /// No description provided for @profSubMechanicContactPlan.
  ///
  /// In en, this message translates to:
  /// **'Mechanic Contact Plan'**
  String get profSubMechanicContactPlan;

  /// No description provided for @profSubAuctionAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited access to live auctions'**
  String get profSubAuctionAccessDesc;

  /// No description provided for @profSubBidLimitDesc.
  ///
  /// In en, this message translates to:
  /// **'Increase your bidding limit to place higher bids'**
  String get profSubBidLimitDesc;

  /// No description provided for @profSubOwnerContactDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect directly with vehicle owners'**
  String get profSubOwnerContactDesc;

  /// No description provided for @profSubVehicleDetailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock complete vehicle history & details'**
  String get profSubVehicleDetailsDesc;

  /// No description provided for @profSubInspectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Request professional vehicle inspection'**
  String get profSubInspectionDesc;

  /// No description provided for @profSubMechanicContactDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with certified mechanics near you'**
  String get profSubMechanicContactDesc;

  /// No description provided for @profSubMyPlans.
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get profSubMyPlans;

  /// No description provided for @profSubExplorePlans.
  ///
  /// In en, this message translates to:
  /// **'Explore Plans'**
  String get profSubExplorePlans;

  /// No description provided for @profSubComboPlans.
  ///
  /// In en, this message translates to:
  /// **'Combo Plans'**
  String get profSubComboPlans;

  /// No description provided for @profSubSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get profSubSubscription;

  /// No description provided for @profSubPaymentFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {message}'**
  String profSubPaymentFailedMsg(String message);

  /// No description provided for @profSubMonthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get profSubMonthJan;

  /// No description provided for @profSubMonthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get profSubMonthFeb;

  /// No description provided for @profSubMonthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get profSubMonthMar;

  /// No description provided for @profSubMonthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get profSubMonthApr;

  /// No description provided for @profSubMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get profSubMonthMay;

  /// No description provided for @profSubMonthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get profSubMonthJun;

  /// No description provided for @profSubMonthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get profSubMonthJul;

  /// No description provided for @profSubMonthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get profSubMonthAug;

  /// No description provided for @profSubMonthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get profSubMonthSep;

  /// No description provided for @profSubMonthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get profSubMonthOct;

  /// No description provided for @profSubMonthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get profSubMonthNov;

  /// No description provided for @profSubMonthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get profSubMonthDec;

  /// No description provided for @profSubActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profSubActive;

  /// No description provided for @profSubInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get profSubInactive;

  /// No description provided for @profSubValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get profSubValidUntil;

  /// No description provided for @profSubNeedMoreBenefits.
  ///
  /// In en, this message translates to:
  /// **'Need more benefits?'**
  String get profSubNeedMoreBenefits;

  /// No description provided for @profSubExploreOtherPlans.
  ///
  /// In en, this message translates to:
  /// **'Explore our other plans and choose the one that fits your needs.'**
  String get profSubExploreOtherPlans;

  /// No description provided for @profSubNoActivePlans.
  ///
  /// In en, this message translates to:
  /// **'No Active Plans'**
  String get profSubNoActivePlans;

  /// No description provided for @profSubNoActiveSubscriptionsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active subscriptions yet.'**
  String get profSubNoActiveSubscriptionsYet;

  /// No description provided for @profSubNoPlanSelected.
  ///
  /// In en, this message translates to:
  /// **'No plan selected'**
  String get profSubNoPlanSelected;

  /// No description provided for @profSubAuctionActivatedBrowse.
  ///
  /// In en, this message translates to:
  /// **'Auction Access Activated! You can now browse and bid.'**
  String get profSubAuctionActivatedBrowse;

  /// No description provided for @profSubContactPackActivated.
  ///
  /// In en, this message translates to:
  /// **'Contact pack activated! Fetching owner contact...'**
  String get profSubContactPackActivated;

  /// No description provided for @profSubShopContactUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Shop contact unlocked!'**
  String get profSubShopContactUnlocked;

  /// No description provided for @profSubMechanicContactUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Mechanic contact unlocked!'**
  String get profSubMechanicContactUnlocked;

  /// No description provided for @profSubVehicleDetailsUnlockedCredits.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details unlocked! You now have full details access + 5 owner contact credits.'**
  String get profSubVehicleDetailsUnlockedCredits;

  /// No description provided for @profSubActivatedPlanActive.
  ///
  /// In en, this message translates to:
  /// **'Subscription Activated! Your plan is now active.'**
  String get profSubActivatedPlanActive;

  /// No description provided for @profSubFailedLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscription plans. Please try again.'**
  String get profSubFailedLoadPlans;

  /// No description provided for @profSubFailedLoadSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscriptions. Please try again.'**
  String get profSubFailedLoadSubscriptions;

  /// No description provided for @profSubFailedLoadCombos.
  ///
  /// In en, this message translates to:
  /// **'Failed to load combos. Pull to refresh.'**
  String get profSubFailedLoadCombos;

  /// No description provided for @profSubNoPlanSelectedDot.
  ///
  /// In en, this message translates to:
  /// **'No plan selected.'**
  String get profSubNoPlanSelectedDot;

  /// No description provided for @profSubConfirmSubscription.
  ///
  /// In en, this message translates to:
  /// **'Confirm Subscription'**
  String get profSubConfirmSubscription;

  /// No description provided for @profSubPlanName.
  ///
  /// In en, this message translates to:
  /// **'{name} Plan'**
  String profSubPlanName(String name);

  /// No description provided for @profSubFeatAuction1.
  ///
  /// In en, this message translates to:
  /// **'View all auction vehicle listings'**
  String get profSubFeatAuction1;

  /// No description provided for @profSubFeatAuction2.
  ///
  /// In en, this message translates to:
  /// **'Participate in live auctions'**
  String get profSubFeatAuction2;

  /// No description provided for @profSubFeatAuction3.
  ///
  /// In en, this message translates to:
  /// **'Access complete auction history'**
  String get profSubFeatAuction3;

  /// No description provided for @profSubFeatUninterrupted.
  ///
  /// In en, this message translates to:
  /// **'{metric} of uninterrupted access'**
  String profSubFeatUninterrupted(String metric);

  /// No description provided for @profSubFeatBidUpTo.
  ///
  /// In en, this message translates to:
  /// **'Place bids up to {metric}'**
  String profSubFeatBidUpTo(String metric);

  /// No description provided for @profSubFeatBid2.
  ///
  /// In en, this message translates to:
  /// **'Unlimited bid placements'**
  String get profSubFeatBid2;

  /// No description provided for @profSubFeatBid3.
  ///
  /// In en, this message translates to:
  /// **'Real-time bid tracking'**
  String get profSubFeatBid3;

  /// No description provided for @profSubFeatBid4.
  ///
  /// In en, this message translates to:
  /// **'Priority bid notifications'**
  String get profSubFeatBid4;

  /// No description provided for @profSubFeatOwner1.
  ///
  /// In en, this message translates to:
  /// **'Seller name and contact details'**
  String get profSubFeatOwner1;

  /// No description provided for @profSubFeatOwner2.
  ///
  /// In en, this message translates to:
  /// **'Phone number and email access'**
  String get profSubFeatOwner2;

  /// No description provided for @profSubFeatOwner3.
  ///
  /// In en, this message translates to:
  /// **'Direct WhatsApp communication'**
  String get profSubFeatOwner3;

  /// No description provided for @profSubFeatOwner4.
  ///
  /// In en, this message translates to:
  /// **'View seller\'s other listings'**
  String get profSubFeatOwner4;

  /// No description provided for @profSubFeatVeh1.
  ///
  /// In en, this message translates to:
  /// **'Complete vehicle history report'**
  String get profSubFeatVeh1;

  /// No description provided for @profSubFeatVeh2.
  ///
  /// In en, this message translates to:
  /// **'Detailed technical specifications'**
  String get profSubFeatVeh2;

  /// No description provided for @profSubFeatVeh3.
  ///
  /// In en, this message translates to:
  /// **'High-resolution vehicle images'**
  String get profSubFeatVeh3;

  /// No description provided for @profSubFeatVeh4.
  ///
  /// In en, this message translates to:
  /// **'Professional inspection reports'**
  String get profSubFeatVeh4;

  /// No description provided for @profSubFeatVeh5.
  ///
  /// In en, this message translates to:
  /// **'Ownership history and documents'**
  String get profSubFeatVeh5;

  /// No description provided for @profSubFeatVeh6.
  ///
  /// In en, this message translates to:
  /// **'Market valuation insights'**
  String get profSubFeatVeh6;

  /// No description provided for @profSubFeatInsp1.
  ///
  /// In en, this message translates to:
  /// **'On-site professional inspection'**
  String get profSubFeatInsp1;

  /// No description provided for @profSubFeatInsp2.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive mechanical assessment'**
  String get profSubFeatInsp2;

  /// No description provided for @profSubFeatInsp3.
  ///
  /// In en, this message translates to:
  /// **'Body condition evaluation'**
  String get profSubFeatInsp3;

  /// No description provided for @profSubFeatInsp4.
  ///
  /// In en, this message translates to:
  /// **'Engine and transmission diagnostics'**
  String get profSubFeatInsp4;

  /// No description provided for @profSubFeatInsp5.
  ///
  /// In en, this message translates to:
  /// **'Detailed inspection report with photos'**
  String get profSubFeatInsp5;

  /// No description provided for @profSubFeatInsp6.
  ///
  /// In en, this message translates to:
  /// **'Expert recommendations and ratings'**
  String get profSubFeatInsp6;

  /// No description provided for @profSubFeatDefault1.
  ///
  /// In en, this message translates to:
  /// **'Access to premium features'**
  String get profSubFeatDefault1;

  /// No description provided for @profSubFeatValidity.
  ///
  /// In en, this message translates to:
  /// **'{metric} validity'**
  String profSubFeatValidity(String metric);

  /// No description provided for @profSubFeatDefault3.
  ///
  /// In en, this message translates to:
  /// **'Priority customer support'**
  String get profSubFeatDefault3;

  /// No description provided for @profSubWhatsIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s Included'**
  String get profSubWhatsIncluded;

  /// No description provided for @profSubOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get profSubOrderSummary;

  /// No description provided for @profSubPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get profSubPlanLabel;

  /// No description provided for @profSubValidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get profSubValidityLabel;

  /// No description provided for @profSubPlanCode.
  ///
  /// In en, this message translates to:
  /// **'Plan Code'**
  String get profSubPlanCode;

  /// No description provided for @profSubTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get profSubTotalAmount;

  /// No description provided for @profSubPay.
  ///
  /// In en, this message translates to:
  /// **'Pay {price}'**
  String profSubPay(String price);

  /// No description provided for @profSubDaysMetric.
  ///
  /// In en, this message translates to:
  /// **'{value} Days'**
  String profSubDaysMetric(String value);

  /// No description provided for @profSubLimitMetric.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} Limit'**
  String profSubLimitMetric(String amount);

  /// No description provided for @profSubError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get profSubError;

  /// No description provided for @profSubOwnerContactPacks.
  ///
  /// In en, this message translates to:
  /// **'Owner Contact Packs'**
  String get profSubOwnerContactPacks;

  /// No description provided for @profSubGetBestValue.
  ///
  /// In en, this message translates to:
  /// **'Get the best value for your money'**
  String get profSubGetBestValue;

  /// No description provided for @profSubPrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority\nSupport'**
  String get profSubPrioritySupport;

  /// No description provided for @profSubStandardSupport.
  ///
  /// In en, this message translates to:
  /// **'Standard\nSupport'**
  String get profSubStandardSupport;

  /// No description provided for @profSubEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email\nSupport'**
  String get profSubEmailSupport;

  /// No description provided for @profSubSave.
  ///
  /// In en, this message translates to:
  /// **'Save ₹{amount}'**
  String profSubSave(String amount);

  /// No description provided for @profSubPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get profSubPayNow;

  /// No description provided for @profSubBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get profSubBuy;

  /// No description provided for @profSubActivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} activated successfully!'**
  String profSubActivatedSuccessfully(String name);

  /// No description provided for @profSubPurchasedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} purchased successfully!'**
  String profSubPurchasedSuccessfully(String name);

  /// No description provided for @profSubOwnerContactsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} owner contacts'**
  String profSubOwnerContactsCount(int count);

  /// No description provided for @profSubNoComboPlans.
  ///
  /// In en, this message translates to:
  /// **'No Combo Plans'**
  String get profSubNoComboPlans;

  /// No description provided for @profSubNoComboPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No combo plans are available right now.'**
  String get profSubNoComboPlansAvailable;

  /// No description provided for @profSubChooseYourSubscription.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Subscription'**
  String get profSubChooseYourSubscription;

  /// No description provided for @profSubUnlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Access'**
  String get profSubUnlimitedAccess;

  /// No description provided for @profSubBidLimit.
  ///
  /// In en, this message translates to:
  /// **'Bid Limit'**
  String get profSubBidLimit;

  /// No description provided for @profSubSecureTrusted.
  ///
  /// In en, this message translates to:
  /// **'Secure & Trusted'**
  String get profSubSecureTrusted;

  /// No description provided for @profSubHundredSafe.
  ///
  /// In en, this message translates to:
  /// **'100% Safe'**
  String get profSubHundredSafe;

  /// No description provided for @profSubEliteBenefits.
  ///
  /// In en, this message translates to:
  /// **'Elite Benefits'**
  String get profSubEliteBenefits;

  /// No description provided for @profSubMostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get profSubMostPopular;

  /// No description provided for @profSubEliteSupport.
  ///
  /// In en, this message translates to:
  /// **'Elite Support'**
  String get profSubEliteSupport;

  /// No description provided for @profSubPremiumSupport.
  ///
  /// In en, this message translates to:
  /// **'Premium Support'**
  String get profSubPremiumSupport;

  /// No description provided for @profSubBasicSupport.
  ///
  /// In en, this message translates to:
  /// **'Basic Support'**
  String get profSubBasicSupport;

  /// No description provided for @profSubElitePlan.
  ///
  /// In en, this message translates to:
  /// **'Elite Plan'**
  String get profSubElitePlan;

  /// No description provided for @profSubPremiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get profSubPremiumPlan;

  /// No description provided for @profSubBasicPlan.
  ///
  /// In en, this message translates to:
  /// **'Basic Plan'**
  String get profSubBasicPlan;

  /// No description provided for @profSubAvailableWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Wallet Balance'**
  String get profSubAvailableWalletBalance;

  /// No description provided for @profSubPayFromWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Pay from wallet balance'**
  String get profSubPayFromWalletBalance;

  /// No description provided for @profSubProceedPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Proceed Payment {price}'**
  String profSubProceedPaymentAmount(String price);

  /// No description provided for @profSubTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profSubTermsConditions;

  /// No description provided for @profSubWalletTerm1.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance is non-transferable and can only be used for subscription payments within the app.'**
  String get profSubWalletTerm1;

  /// No description provided for @profSubWalletTerm2.
  ///
  /// In en, this message translates to:
  /// **'Once a payment is made using wallet balance, it cannot be reversed or refunded.'**
  String get profSubWalletTerm2;

  /// No description provided for @profSubWalletTerm3.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance does not carry any interest and is subject to the company\'s terms of service.'**
  String get profSubWalletTerm3;

  /// No description provided for @spareNoCategoryShopsFound.
  ///
  /// In en, this message translates to:
  /// **'No {category} shops found near your location.\nTry enabling location or check back later.'**
  String spareNoCategoryShopsFound(String category);

  /// No description provided for @spareNoSparePartsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No spare parts available'**
  String get spareNoSparePartsAvailable;

  /// No description provided for @spareCheckBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new listings'**
  String get spareCheckBackLater;

  /// No description provided for @spareSuitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suits: {suitsFor}'**
  String spareSuitsLabel(String suitsFor);

  /// No description provided for @spareHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Spare'**
  String get spareHeaderTitle;

  /// No description provided for @spareFindTrustedShops.
  ///
  /// In en, this message translates to:
  /// **'Find trusted spare part shops near your location'**
  String get spareFindTrustedShops;

  /// No description provided for @spareConstructionEquipment.
  ///
  /// In en, this message translates to:
  /// **'Construction Equipment'**
  String get spareConstructionEquipment;

  /// No description provided for @spareCommercialVehicle.
  ///
  /// In en, this message translates to:
  /// **'Commercial Vehicle'**
  String get spareCommercialVehicle;

  /// No description provided for @spareCeShopsDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse shops selling parts for JCBs, excavators, loaders & more'**
  String get spareCeShopsDesc;

  /// No description provided for @spareCvShopsDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse shops selling parts for trucks, buses, tempos & trailers'**
  String get spareCvShopsDesc;

  /// No description provided for @spareError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get spareError;

  /// No description provided for @spareLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get spareLoginRequired;

  /// No description provided for @sparePleaseLoginToShowInterest.
  ///
  /// In en, this message translates to:
  /// **'Please login to show interest'**
  String get sparePleaseLoginToShowInterest;

  /// No description provided for @spareInterestRecorded.
  ///
  /// In en, this message translates to:
  /// **'Interest Recorded'**
  String get spareInterestRecorded;

  /// No description provided for @spareInterestRecordedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your interest in \"{spareName}\" has been recorded successfully.'**
  String spareInterestRecordedMessage(String spareName);

  /// No description provided for @spareFailedToRecordInterest.
  ///
  /// In en, this message translates to:
  /// **'Failed to record interest. Please try again.'**
  String get spareFailedToRecordInterest;

  /// No description provided for @spareFailedToLoadSpareParts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load spare parts'**
  String get spareFailedToLoadSpareParts;

  /// No description provided for @spareFailedToLoadShops.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shops'**
  String get spareFailedToLoadShops;

  /// No description provided for @spareFailedToLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders'**
  String get spareFailedToLoadOrders;

  /// No description provided for @spareUnableToLoadSubscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Unable to load subscription plan. Please try again.'**
  String get spareUnableToLoadSubscriptionPlan;

  /// No description provided for @spareConnectWithShop.
  ///
  /// In en, this message translates to:
  /// **'Connect with Shop'**
  String get spareConnectWithShop;

  /// No description provided for @sparePayToGetShopContact.
  ///
  /// In en, this message translates to:
  /// **'Pay to get the direct contact number for {shopName}.'**
  String sparePayToGetShopContact(String shopName);

  /// No description provided for @spareContactUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Contact unlocked! You can now call the shop.'**
  String get spareContactUnlocked;

  /// No description provided for @spareCouldNotUnlockContact.
  ///
  /// In en, this message translates to:
  /// **'Could not unlock contact. Please try again.'**
  String get spareCouldNotUnlockContact;

  /// No description provided for @sparePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get sparePhone;

  /// No description provided for @spareContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact: {phone}'**
  String spareContactPhone(String phone);

  /// No description provided for @spareLocationError.
  ///
  /// In en, this message translates to:
  /// **'Location Error'**
  String get spareLocationError;

  /// No description provided for @spareUnableToAccessLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to access location. Please restart the app and try again.'**
  String get spareUnableToAccessLocation;

  /// No description provided for @spareLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get spareLocationPermission;

  /// No description provided for @spareLocationPermissionRationale.
  ///
  /// In en, this message translates to:
  /// **'We need your location to find nearby shops. Please grant location permission.'**
  String get spareLocationPermissionRationale;

  /// No description provided for @spareAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get spareAllow;

  /// No description provided for @spareEnableGps.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS'**
  String get spareEnableGps;

  /// No description provided for @spareGpsDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'GPS is disabled. Please enable location services to find nearby shops.'**
  String get spareGpsDisabledMessage;

  /// No description provided for @spareOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get spareOpenSettings;

  /// No description provided for @spareLocationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get spareLocationPermissionRequired;

  /// No description provided for @spareLocationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission has been permanently denied. Please enable it from app settings.'**
  String get spareLocationPermissionDeniedForever;

  /// No description provided for @spareLocationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location Updated?'**
  String get spareLocationUpdated;

  /// No description provided for @spareRetryLoadingShopsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to retry loading shops now?'**
  String get spareRetryLoadingShopsPrompt;

  /// No description provided for @spareNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get spareNotNow;

  /// No description provided for @spareFailedToLoadYourVehicles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your vehicles'**
  String get spareFailedToLoadYourVehicles;

  /// No description provided for @spareFieldNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String spareFieldNameIsRequired(String fieldName);

  /// No description provided for @spareCategoryIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get spareCategoryIsRequired;

  /// No description provided for @sparePleaseAddAtLeastOneVehicleImage.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 vehicle image'**
  String get sparePleaseAddAtLeastOneVehicleImage;

  /// No description provided for @sparePleaseUploadAtLeastOneRcDocument.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one RC document'**
  String get sparePleaseUploadAtLeastOneRcDocument;

  /// No description provided for @spareLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get spareLimitReached;

  /// No description provided for @spareMaxTenImagesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 images allowed'**
  String get spareMaxTenImagesAllowed;

  /// No description provided for @spareEachDocumentUnder12Mb.
  ///
  /// In en, this message translates to:
  /// **'Each document must be under 12 MB'**
  String get spareEachDocumentUnder12Mb;

  /// No description provided for @spareVehicleSubmittedForApproval.
  ///
  /// In en, this message translates to:
  /// **'Vehicle submitted for approval.'**
  String get spareVehicleSubmittedForApproval;

  /// No description provided for @spareFailedToSubmitVehicle.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit vehicle: {error}'**
  String spareFailedToSubmitVehicle(String error);

  /// No description provided for @spareVehicleUpdatedPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated. Changes pending admin approval.'**
  String get spareVehicleUpdatedPendingApproval;

  /// No description provided for @spareFailedToUpdateVehicle.
  ///
  /// In en, this message translates to:
  /// **'Failed to update vehicle: {error}'**
  String spareFailedToUpdateVehicle(String error);

  /// No description provided for @spareSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get spareSuccess;

  /// No description provided for @spareVehicleMarkedAsSold.
  ///
  /// In en, this message translates to:
  /// **'Vehicle marked as sold'**
  String get spareVehicleMarkedAsSold;

  /// No description provided for @spareFailedToMarkAsSold.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as sold'**
  String get spareFailedToMarkAsSold;

  /// No description provided for @spareVehicleMarkedAsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Vehicle marked as available'**
  String get spareVehicleMarkedAsAvailable;

  /// No description provided for @spareFailedToUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status'**
  String get spareFailedToUpdateStatus;

  /// No description provided for @spareNoCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get spareNoCategoriesFound;

  /// No description provided for @spareFailedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get spareFailedToLoadCategories;

  /// No description provided for @spareFailedToLoadVehicles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicles'**
  String get spareFailedToLoadVehicles;

  /// No description provided for @spareFailedToLoadSubscribedVehicles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscribed vehicles'**
  String get spareFailedToLoadSubscribedVehicles;

  /// No description provided for @spareSellerNotifiedOfInterest.
  ///
  /// In en, this message translates to:
  /// **'The seller has been notified of your interest.'**
  String get spareSellerNotifiedOfInterest;

  /// No description provided for @spareFailedToRecordInterestShort.
  ///
  /// In en, this message translates to:
  /// **'Failed to record interest.'**
  String get spareFailedToRecordInterestShort;

  /// No description provided for @spareOfferTooLowMinimumRequired.
  ///
  /// In en, this message translates to:
  /// **'Offer too low. Minimum required: ₹{amount}'**
  String spareOfferTooLowMinimumRequired(String amount);

  /// No description provided for @spareFailedToSubmitOffer.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit offer.'**
  String get spareFailedToSubmitOffer;

  /// No description provided for @spareInspectionPlanName.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get spareInspectionPlanName;

  /// No description provided for @spareProfessionalOnSiteInspectionFor.
  ///
  /// In en, this message translates to:
  /// **'Professional on-site inspection for {categoryName}'**
  String spareProfessionalOnSiteInspectionFor(String categoryName);

  /// No description provided for @sparePayToRequestInspection.
  ///
  /// In en, this message translates to:
  /// **'Pay to request a professional inspection for this vehicle.'**
  String get sparePayToRequestInspection;

  /// No description provided for @spareTeamWillContactForInspection.
  ///
  /// In en, this message translates to:
  /// **'Our team will contact you to schedule an inspection.'**
  String get spareTeamWillContactForInspection;

  /// No description provided for @spareFailedToRequestInspection.
  ///
  /// In en, this message translates to:
  /// **'Failed to request inspection.'**
  String get spareFailedToRequestInspection;

  /// No description provided for @spareVehicleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Vehicle not found.'**
  String get spareVehicleNotFound;

  /// No description provided for @spareFailedToLoadVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicle details. Please try again.'**
  String get spareFailedToLoadVehicleDetails;

  /// No description provided for @spareCouldNotAccessVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not access vehicle details.'**
  String get spareCouldNotAccessVehicleDetails;

  /// No description provided for @spareVehicleDetailsAccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details Access'**
  String get spareVehicleDetailsAccess;

  /// No description provided for @spareVehicleDetailsAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get full vehicle details + 5 owner contact credits. Pay once, use for the plan period.'**
  String get spareVehicleDetailsAccessSubtitle;

  /// No description provided for @spareOwnerContactPack.
  ///
  /// In en, this message translates to:
  /// **'Owner Contact Pack'**
  String get spareOwnerContactPack;

  /// No description provided for @spareOwnerContactPackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your contact credits are exhausted. Buy a pack to reveal owner phone numbers.'**
  String get spareOwnerContactPackSubtitle;

  /// No description provided for @spareWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get spareWishlist;

  /// No description provided for @sparePurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get sparePurchaseHistory;

  /// No description provided for @spareFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get spareFilters;

  /// No description provided for @spareReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get spareReset;

  /// No description provided for @spareNoFiltersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No filters available'**
  String get spareNoFiltersAvailable;

  /// No description provided for @spareSearchBrand.
  ///
  /// In en, this message translates to:
  /// **'Search brand'**
  String get spareSearchBrand;

  /// No description provided for @spareSearchState.
  ///
  /// In en, this message translates to:
  /// **'Search state'**
  String get spareSearchState;

  /// No description provided for @spareSelectFilter.
  ///
  /// In en, this message translates to:
  /// **'Select {filterKey}'**
  String spareSelectFilter(String filterKey);

  /// No description provided for @spareEnterFilter.
  ///
  /// In en, this message translates to:
  /// **'Enter {filterKey}'**
  String spareEnterFilter(String filterKey);

  /// No description provided for @spareTryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get spareTryAdjustingFilters;

  /// No description provided for @spareVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get spareVehicle;

  /// No description provided for @spareBuyAndSellTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell'**
  String get spareBuyAndSellTitle;

  /// No description provided for @spareBrowseAndPostCommercialVehicles.
  ///
  /// In en, this message translates to:
  /// **'Browse & post commercial vehicles'**
  String get spareBrowseAndPostCommercialVehicles;

  /// No description provided for @spareBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get spareBuy;

  /// No description provided for @spareSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get spareSell;

  /// No description provided for @spareYourPostedVehicleListings.
  ///
  /// In en, this message translates to:
  /// **'Your posted vehicle listings'**
  String get spareYourPostedVehicleListings;

  /// No description provided for @spareMarkAsSold.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sold'**
  String get spareMarkAsSold;

  /// No description provided for @spareMarkVehicleAsSoldPrompt.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{name}\" as sold?'**
  String spareMarkVehicleAsSoldPrompt(String name);

  /// No description provided for @spareMarkAsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Mark as Available'**
  String get spareMarkAsAvailable;

  /// No description provided for @spareMarkVehicleAsAvailablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{name}\" as available?'**
  String spareMarkVehicleAsAvailablePrompt(String name);

  /// No description provided for @spareConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get spareConfirm;

  /// No description provided for @spareMarkSold.
  ///
  /// In en, this message translates to:
  /// **'Mark Sold'**
  String get spareMarkSold;

  /// No description provided for @spareMarkAvailable.
  ///
  /// In en, this message translates to:
  /// **'Mark Available'**
  String get spareMarkAvailable;

  /// No description provided for @spareNoPostedVehiclesYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any vehicles yet'**
  String get spareNoPostedVehiclesYet;

  /// No description provided for @spareTapSellToPostVehicle.
  ///
  /// In en, this message translates to:
  /// **'Tap Sell on any category to post your vehicle'**
  String get spareTapSellToPostVehicle;

  /// No description provided for @spareSubscribedVehicles.
  ///
  /// In en, this message translates to:
  /// **'Subscribed Vehicles'**
  String get spareSubscribedVehicles;

  /// No description provided for @spareVehiclesWithPremiumAccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicles you have premium access to'**
  String get spareVehiclesWithPremiumAccess;

  /// No description provided for @sparePremiumAccess.
  ///
  /// In en, this message translates to:
  /// **'Premium Access'**
  String get sparePremiumAccess;

  /// No description provided for @spareNoSubscribedVehicles.
  ///
  /// In en, this message translates to:
  /// **'No subscribed vehicles'**
  String get spareNoSubscribedVehicles;

  /// No description provided for @spareSubscribedVehiclesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Vehicles you get premium access to will appear here'**
  String get spareSubscribedVehiclesAppearHere;

  /// No description provided for @spareVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get spareVehicles;

  /// No description provided for @spareBrowseAvailableListings.
  ///
  /// In en, this message translates to:
  /// **'Browse available listings'**
  String get spareBrowseAvailableListings;

  /// No description provided for @spareViewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get spareViewMore;

  /// No description provided for @spareSellVehicle.
  ///
  /// In en, this message translates to:
  /// **'Sell Vehicle'**
  String get spareSellVehicle;

  /// No description provided for @sparePostYourVehicleForSale.
  ///
  /// In en, this message translates to:
  /// **'Post your vehicle for sale'**
  String get sparePostYourVehicleForSale;

  /// No description provided for @spareSearchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search category...'**
  String get spareSearchCategory;

  /// No description provided for @spareSubmittingYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Submitting your vehicle...'**
  String get spareSubmittingYourVehicle;

  /// No description provided for @sparePleaseWaitProcessingListing.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we process your listing'**
  String get sparePleaseWaitProcessingListing;

  /// No description provided for @spareNoFormFieldsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No form fields available.'**
  String get spareNoFormFieldsAvailable;

  /// No description provided for @sparePhotosAndDocuments.
  ///
  /// In en, this message translates to:
  /// **'Photos & Documents'**
  String get sparePhotosAndDocuments;

  /// No description provided for @spareAutoFilled.
  ///
  /// In en, this message translates to:
  /// **'Auto-filled'**
  String get spareAutoFilled;

  /// No description provided for @spareExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. {example}'**
  String spareExampleHint(String example);

  /// No description provided for @spareTenDigitMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get spareTenDigitMobileNumber;

  /// No description provided for @spareSearchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get spareSearchCity;

  /// No description provided for @spareSelectStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select state first'**
  String get spareSelectStateFirst;

  /// No description provided for @spareConfirmedCheck.
  ///
  /// In en, this message translates to:
  /// **'Confirmed ✓'**
  String get spareConfirmedCheck;

  /// No description provided for @spareCouldNotOpenPicker.
  ///
  /// In en, this message translates to:
  /// **'Could not open picker: {error}'**
  String spareCouldNotOpenPicker(String error);

  /// No description provided for @spareTapToAddVehiclePhotos.
  ///
  /// In en, this message translates to:
  /// **'Tap to add vehicle photos'**
  String get spareTapToAddVehiclePhotos;

  /// No description provided for @spareTapToAddMore.
  ///
  /// In en, this message translates to:
  /// **'Tap to add more'**
  String get spareTapToAddMore;

  /// No description provided for @spareUpTo10PhotosFormats.
  ///
  /// In en, this message translates to:
  /// **'Up to 10 photos  •  JPG, PNG'**
  String get spareUpTo10PhotosFormats;

  /// No description provided for @spareTapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get spareTapToUpload;

  /// No description provided for @spareMultipleFilesAllowedFormats.
  ///
  /// In en, this message translates to:
  /// **'Multiple files allowed  •  Max 12 MB each  •  JPG, PNG'**
  String get spareMultipleFilesAllowedFormats;

  /// No description provided for @spareUpdateVehicle.
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle'**
  String get spareUpdateVehicle;

  /// No description provided for @spareShareVehicle.
  ///
  /// In en, this message translates to:
  /// **'Share Vehicle'**
  String get spareShareVehicle;

  /// No description provided for @sparePriceOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Price on request'**
  String get sparePriceOnRequest;

  /// No description provided for @spareSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get spareSold;

  /// No description provided for @spareApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get spareApproved;

  /// No description provided for @spareRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get spareRejected;

  /// No description provided for @spareUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get spareUnknown;

  /// No description provided for @spareCouldNotRevealContact.
  ///
  /// In en, this message translates to:
  /// **'Could not reveal contact.'**
  String get spareCouldNotRevealContact;

  /// No description provided for @profCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get profCustomer;

  /// No description provided for @profVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get profVendor;

  /// No description provided for @profMechanic.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get profMechanic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'hi',
    'kn',
    'ml',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
