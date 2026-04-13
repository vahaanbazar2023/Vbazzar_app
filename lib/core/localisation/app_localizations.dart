import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
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
  /// **'( We will send you OTP to the mentioned input )'**
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
  /// **'Please enter a valid 10-digit phone number'**
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
  /// **'Please enter a valid 10-digit phone number'**
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

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
