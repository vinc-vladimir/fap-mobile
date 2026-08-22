import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('sr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FUEL AUTO PAY'**
  String get appTitle;

  /// No description provided for @fuelAutoPay.
  ///
  /// In en, this message translates to:
  /// **'FUEL AUTO PAY'**
  String get fuelAutoPay;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'The fastest way to fuel your vehicle.'**
  String get tagline;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@fap.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// No description provided for @biometricSignIn.
  ///
  /// In en, this message translates to:
  /// **'BIOMETRIC SIGN IN'**
  String get biometricSignIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUpNow.
  ///
  /// In en, this message translates to:
  /// **'Sign up now'**
  String get signUpNow;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid password'**
  String get validationPasswordInvalid;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry, it happens to all of us... just enter your email below and we\'ll help you get back on the road.'**
  String get forgotPasswordDescription;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPassword;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// No description provided for @emailSentDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions to get back on the road.'**
  String get emailSentDescription;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'BACK TO SIGN IN'**
  String get backToSignIn;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyInfoCollect.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get privacyInfoCollect;

  /// No description provided for @privacyInfoCollectBody.
  ///
  /// In en, this message translates to:
  /// **'We collect information you provide directly to us, such as your name, email address, phone number, vehicle registration details, and payment information when you create an account or use our services.'**
  String get privacyInfoCollectBody;

  /// No description provided for @privacyHowWeUse.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get privacyHowWeUse;

  /// No description provided for @privacyHowWeUseBody.
  ///
  /// In en, this message translates to:
  /// **'We use the information we collect to provide, maintain, and improve our fuel payment services, process transactions, send you transaction confirmations and receipts, and communicate with you about your account.'**
  String get privacyHowWeUseBody;

  /// No description provided for @privacyInfoSharing.
  ///
  /// In en, this message translates to:
  /// **'Information Sharing'**
  String get privacyInfoSharing;

  /// No description provided for @privacyInfoSharingBody.
  ///
  /// In en, this message translates to:
  /// **'We do not share your personal information with third parties except as necessary to process payments, comply with legal obligations, or with your explicit consent.'**
  String get privacyInfoSharingBody;

  /// No description provided for @privacyDataSecurity.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get privacyDataSecurity;

  /// No description provided for @privacyDataSecurityBody.
  ///
  /// In en, this message translates to:
  /// **'We implement industry-standard security measures to protect your personal information, including encryption of sensitive data, secure storage practices, and regular security audits.'**
  String get privacyDataSecurityBody;

  /// No description provided for @privacyYourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacyYourRights;

  /// No description provided for @privacyYourRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, update, or delete your personal information at any time through your account settings. You may also contact us directly to exercise these rights.'**
  String get privacyYourRightsBody;

  /// No description provided for @privacyContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get privacyContactUs;

  /// No description provided for @privacyContactUsBody.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us at support@fuelautopay.com.'**
  String get privacyContactUsBody;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @termsAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get termsAcceptance;

  /// No description provided for @termsAcceptanceBody.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or using the Fuel Auto Pay service, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the service.'**
  String get termsAcceptanceBody;

  /// No description provided for @termsServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get termsServiceDesc;

  /// No description provided for @termsServiceDescBody.
  ///
  /// In en, this message translates to:
  /// **'Fuel Auto Pay provides an automated fuel payment system that uses Automatic Number Plate Recognition (ANPR) technology to identify vehicles and process payments at participating gas stations without requiring physical payment at the pump.'**
  String get termsServiceDescBody;

  /// No description provided for @termsUserResp.
  ///
  /// In en, this message translates to:
  /// **'User Responsibilities'**
  String get termsUserResp;

  /// No description provided for @termsUserRespBody.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the accuracy of your account information, including vehicle registration details and payment methods. You must notify us immediately of any unauthorized use of your account.'**
  String get termsUserRespBody;

  /// No description provided for @termsPaymentAuth.
  ///
  /// In en, this message translates to:
  /// **'Payment Authorization'**
  String get termsPaymentAuth;

  /// No description provided for @termsPaymentAuthBody.
  ///
  /// In en, this message translates to:
  /// **'By registering a payment method, you authorize Fuel Auto Pay to charge the registered payment method for all fuel transactions initiated by vehicles registered to your account.'**
  String get termsPaymentAuthBody;

  /// No description provided for @termsLimitation.
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get termsLimitation;

  /// No description provided for @termsLimitationBody.
  ///
  /// In en, this message translates to:
  /// **'Fuel Auto Pay shall not be liable for any indirect, incidental, or consequential damages arising from the use or inability to use the service, including but not limited to incorrect charges or service interruptions.'**
  String get termsLimitationBody;

  /// No description provided for @termsTermination.
  ///
  /// In en, this message translates to:
  /// **'Termination'**
  String get termsTermination;

  /// No description provided for @termsTerminationBody.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to suspend or terminate your access to the service at any time for violation of these terms or any applicable laws.'**
  String get termsTerminationBody;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to get started'**
  String get createAccountSubtitle;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @repeatPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPasswordHint;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInLink;

  /// No description provided for @matchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get matchError;

  /// No description provided for @passwordReqLength.
  ///
  /// In en, this message translates to:
  /// **'8+ characters'**
  String get passwordReqLength;

  /// No description provided for @passwordReqUppercase.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get passwordReqUppercase;

  /// No description provided for @passwordReqLowercase.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get passwordReqLowercase;

  /// No description provided for @passwordReqDigit.
  ///
  /// In en, this message translates to:
  /// **'One digit'**
  String get passwordReqDigit;

  /// No description provided for @passwordReqSpecial.
  ///
  /// In en, this message translates to:
  /// **'One special character'**
  String get passwordReqSpecial;

  /// No description provided for @registrationSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a confirmation link to your email address. Open the link on this phone to activate your account.'**
  String get registrationSuccessDescription;

  /// No description provided for @registrationConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Activated'**
  String get registrationConfirmedTitle;

  /// No description provided for @registrationConfirmedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your email has been verified. Sign in to continue.'**
  String get registrationConfirmedDescription;

  /// No description provided for @registrationConfirmationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation Failed'**
  String get registrationConfirmationFailedTitle;

  /// No description provided for @registrationConfirmationFailedDescription.
  ///
  /// In en, this message translates to:
  /// **'This confirmation link is invalid or has expired. Please sign up again to receive a new link.'**
  String get registrationConfirmationFailedDescription;

  /// No description provided for @goToSignIn.
  ///
  /// In en, this message translates to:
  /// **'GO TO SIGN IN'**
  String get goToSignIn;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @errorSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorSomethingWentWrong;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabel;

  /// No description provided for @bronzeLevel.
  ///
  /// In en, this message translates to:
  /// **'Bronze Level'**
  String get bronzeLevel;

  /// No description provided for @pointsUntilSilver.
  ///
  /// In en, this message translates to:
  /// **'{points} points until Silver Status'**
  String pointsUntilSilver(Object points);

  /// No description provided for @nearbyStation.
  ///
  /// In en, this message translates to:
  /// **'Nearby Station'**
  String get nearbyStation;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMap;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String distanceAway(Object distance);

  /// No description provided for @myRewards.
  ///
  /// In en, this message translates to:
  /// **'My Rewards'**
  String get myRewards;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @redeemPoints.
  ///
  /// In en, this message translates to:
  /// **'Redeem Points'**
  String get redeemPoints;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavRefuel.
  ///
  /// In en, this message translates to:
  /// **'Refuel'**
  String get bottomNavRefuel;

  /// No description provided for @bottomNavActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get bottomNavActivity;

  /// No description provided for @bottomNavAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get bottomNavAccount;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String validUntil(Object date);

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @fuelSuper95.
  ///
  /// In en, this message translates to:
  /// **'Super 95'**
  String get fuelSuper95;

  /// No description provided for @fuelDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get fuelDiesel;

  /// No description provided for @fuelUltimate100.
  ///
  /// In en, this message translates to:
  /// **'Ultimate 100'**
  String get fuelUltimate100;

  /// No description provided for @percentOffPremium.
  ///
  /// In en, this message translates to:
  /// **'10% OFF Premium Fuels'**
  String get percentOffPremium;

  /// No description provided for @freeDeluxeWash.
  ///
  /// In en, this message translates to:
  /// **'Free Deluxe Wash'**
  String get freeDeluxeWash;

  /// No description provided for @afterRefuels.
  ///
  /// In en, this message translates to:
  /// **'After {count} more refuels'**
  String afterRefuels(Object count);

  /// No description provided for @discountValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String discountValidUntil(Object date);

  /// No description provided for @omvStationName.
  ///
  /// In en, this message translates to:
  /// **'OMV City Central'**
  String get omvStationName;

  /// No description provided for @omvStationAddress.
  ///
  /// In en, this message translates to:
  /// **'Praterstraße 42, 1020 Wien'**
  String get omvStationAddress;

  /// No description provided for @pointsValue.
  ///
  /// In en, this message translates to:
  /// **'1,240'**
  String get pointsValue;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'John Smith'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'john.smith@velocityfleet.com'**
  String get profileEmail;

  /// No description provided for @premiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get premiumMember;

  /// No description provided for @fleetAdmin.
  ///
  /// In en, this message translates to:
  /// **'Fleet Admin'**
  String get fleetAdmin;

  /// No description provided for @addNewPlate.
  ///
  /// In en, this message translates to:
  /// **'Add New Plate'**
  String get addNewPlate;

  /// No description provided for @managementSection.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get managementSection;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @licencePlates.
  ///
  /// In en, this message translates to:
  /// **'Licence Plates'**
  String get licencePlates;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get changePasswordSubtitle;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String appVersion(Object version);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @serbian.
  ///
  /// In en, this message translates to:
  /// **'Srpski'**
  String get serbian;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @changePasswordLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated 3 months ago'**
  String get changePasswordLastUpdated;

  /// No description provided for @accountManagementSection.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagementSection;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @changePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordDialogTitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently deactivate your account. This action cannot be undone.'**
  String get deleteAccountDialogBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deactivated.'**
  String get accountDeletedSuccess;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;
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
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
