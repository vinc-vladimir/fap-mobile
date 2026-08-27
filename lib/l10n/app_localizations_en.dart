// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FUEL AUTO PAY';

  @override
  String get fuelAutoPay => 'FUEL AUTO PAY';

  @override
  String get tagline => 'The fastest way to fuel your vehicle.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'name@fap.com';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'SIGN IN';

  @override
  String get biometricSignIn => 'BIOMETRIC SIGN IN';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUpNow => 'Sign up now';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get validationEmailRequired => 'Please enter your email address';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String get validationPasswordRequired => 'Please enter your password';

  @override
  String get validationPasswordInvalid => 'Please enter a valid password';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordDescription =>
      'Don\'t worry, it happens to all of us... just enter your email below and we\'ll help you get back on the road.';

  @override
  String get resetPassword => 'RESET PASSWORD';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String get emailSentDescription =>
      'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions to get back on the road.';

  @override
  String get backToSignIn => 'BACK TO SIGN IN';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyInfoCollect => 'Information We Collect';

  @override
  String get privacyInfoCollectBody =>
      'We collect information you provide directly to us, such as your name, email address, phone number, vehicle registration details, and payment information when you create an account or use our services.';

  @override
  String get privacyHowWeUse => 'How We Use Your Information';

  @override
  String get privacyHowWeUseBody =>
      'We use the information we collect to provide, maintain, and improve our fuel payment services, process transactions, send you transaction confirmations and receipts, and communicate with you about your account.';

  @override
  String get privacyInfoSharing => 'Information Sharing';

  @override
  String get privacyInfoSharingBody =>
      'We do not share your personal information with third parties except as necessary to process payments, comply with legal obligations, or with your explicit consent.';

  @override
  String get privacyDataSecurity => 'Data Security';

  @override
  String get privacyDataSecurityBody =>
      'We implement industry-standard security measures to protect your personal information, including encryption of sensitive data, secure storage practices, and regular security audits.';

  @override
  String get privacyYourRights => 'Your Rights';

  @override
  String get privacyYourRightsBody =>
      'You have the right to access, update, or delete your personal information at any time through your account settings. You may also contact us directly to exercise these rights.';

  @override
  String get privacyContactUs => 'Contact Us';

  @override
  String get privacyContactUsBody =>
      'If you have any questions about this Privacy Policy, please contact us at support@fuelautopay.com.';

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get termsAcceptance => 'Acceptance of Terms';

  @override
  String get termsAcceptanceBody =>
      'By creating an account or using the Fuel Auto Pay service, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the service.';

  @override
  String get termsServiceDesc => 'Service Description';

  @override
  String get termsServiceDescBody =>
      'Fuel Auto Pay provides an automated fuel payment system that uses Automatic Number Plate Recognition (ANPR) technology to identify vehicles and process payments at participating gas stations without requiring physical payment at the pump.';

  @override
  String get termsUserResp => 'User Responsibilities';

  @override
  String get termsUserRespBody =>
      'You are responsible for maintaining the accuracy of your account information, including vehicle registration details and payment methods. You must notify us immediately of any unauthorized use of your account.';

  @override
  String get termsPaymentAuth => 'Payment Authorization';

  @override
  String get termsPaymentAuthBody =>
      'By registering a payment method, you authorize Fuel Auto Pay to charge the registered payment method for all fuel transactions initiated by vehicles registered to your account.';

  @override
  String get termsLimitation => 'Limitation of Liability';

  @override
  String get termsLimitationBody =>
      'Fuel Auto Pay shall not be liable for any indirect, incidental, or consequential damages arising from the use or inability to use the service, including but not limited to incorrect charges or service interruptions.';

  @override
  String get termsTermination => 'Termination';

  @override
  String get termsTerminationBody =>
      'We reserve the right to suspend or terminate your access to the service at any time for violation of these terms or any applicable laws.';

  @override
  String get createAccountTitle => 'Create Your Account';

  @override
  String get createAccountSubtitle => 'Enter your details to get started';

  @override
  String get createPassword => 'Create Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get repeatPasswordHint => 'Repeat password';

  @override
  String get createAccount => 'CREATE ACCOUNT';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signInLink => 'Sign In';

  @override
  String get matchError => 'Passwords do not match.';

  @override
  String get passwordReqLength => '8+ characters';

  @override
  String get passwordReqUppercase => 'One uppercase letter';

  @override
  String get passwordReqLowercase => 'One lowercase letter';

  @override
  String get passwordReqDigit => 'One digit';

  @override
  String get passwordReqSpecial => 'One special character';

  @override
  String get registrationSuccessDescription =>
      'We\'ve sent a confirmation link to your email address. Open the link on this phone to activate your account.';

  @override
  String get registrationConfirmedTitle => 'Account Activated';

  @override
  String get registrationConfirmedDescription =>
      'Your email has been verified. Sign in to continue.';

  @override
  String get registrationConfirmationFailedTitle => 'Confirmation Failed';

  @override
  String get registrationConfirmationFailedDescription =>
      'This confirmation link is invalid or has expired. Please sign up again to receive a new link.';

  @override
  String get goToSignIn => 'GO TO SIGN IN';

  @override
  String get retry => 'RETRY';

  @override
  String get errorSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get homeTitle => 'Home';

  @override
  String get pointsLabel => 'Points';

  @override
  String get bronzeLevel => 'Bronze Level';

  @override
  String pointsUntilSilver(Object points) {
    return '$points points until Silver Status';
  }

  @override
  String get nearbyStation => 'Nearby Station';

  @override
  String get viewMap => 'View Map';

  @override
  String distanceAway(Object distance) {
    return '$distance km away';
  }

  @override
  String get myRewards => 'My Rewards';

  @override
  String get seeAll => 'See All';

  @override
  String get redeemPoints => 'Redeem Points';

  @override
  String get navigate => 'Navigate';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavRefuel => 'Refuel';

  @override
  String get bottomNavActivity => 'Activity';

  @override
  String get bottomNavAccount => 'Account';

  @override
  String validUntil(Object date) {
    return 'Valid until $date';
  }

  @override
  String get newBadge => 'New';

  @override
  String get fuelSuper95 => 'Super 95';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelUltimate100 => 'Ultimate 100';

  @override
  String get percentOffPremium => '10% OFF Premium Fuels';

  @override
  String get freeDeluxeWash => 'Free Deluxe Wash';

  @override
  String afterRefuels(Object count) {
    return 'After $count more refuels';
  }

  @override
  String discountValidUntil(Object date) {
    return 'Valid until $date';
  }

  @override
  String get omvStationName => 'OMV City Central';

  @override
  String get omvStationAddress => 'Praterstraße 42, 1020 Wien';

  @override
  String get pointsValue => '1,240';

  @override
  String get accountTitle => 'Account';

  @override
  String get profileName => 'John Smith';

  @override
  String get profileEmail => 'john.smith@velocityfleet.com';

  @override
  String get premiumMember => 'Premium Member';

  @override
  String get fleetAdmin => 'Fleet Admin';

  @override
  String get addNewPlate => 'Add New Plate';

  @override
  String get managementSection => 'Management';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get organization => 'Organization';

  @override
  String get licencePlates => 'Licence Plates';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign Out';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordSubtitle => 'Update your account password';

  @override
  String get signOutSubtitle => 'Sign out of your account';

  @override
  String appVersion(Object version) {
    return 'v$version';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get serbian => 'Srpski';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get securitySection => 'Security';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get changePasswordLastUpdated => 'Last updated 3 months ago';

  @override
  String passwordChangedAt(Object timestamp) {
    return 'Changed: $timestamp (UTC)';
  }

  @override
  String get accountManagementSection => 'Account Management';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get changePasswordDialogTitle => 'Change Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get deleteAccountDialogTitle => 'Delete Account?';

  @override
  String get deleteAccountDialogBody =>
      'This will permanently deactivate your account. This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get passwordChangedSuccess =>
      'Your password has been changed successfully.';

  @override
  String get passwordNeverUpdated => '—';

  @override
  String get accountDeletedSuccess => 'Your account has been deactivated.';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get comingSoon => 'Coming soon';
}
