import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:instantonnection/l10n/messages_all.dart';
import 'package:intl/intl.dart';

class Strings {
  static Future<Strings> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return Strings();
    });
  }

  static Strings of(BuildContext context) {
    return Localizations.of<Strings>(context, Strings);
  }


  String get home => Intl.message('Home', name: 'home' ,desc: 'Home tab title');
  String get roomTitle => Intl.message('Room List', name: 'roomTitle');
  String get profileTitle => Intl.message('Profile', name: 'profileTitle');
  String get roomSettingsTitle => Intl.message('Room Settings', name: 'roomSettingsTitle');
  String get editRoom => Intl.message('Edit Room', name: 'editRoom');
  String get editRoomTitle => Intl.message('Edit Room', name: 'editRoomTitle');
  String get joinRoom => Intl.message('Join Room', name: 'joinRoom');
  String get iAgree => Intl.message('I agree to ', name: 'iAgree');
  String get terms => Intl.message('Terms of Service', name: 'terms');
  String get privacy => Intl.message('Privacy Policy', name: 'privacy');
  String get help => Intl.message('Help', name: 'help');
  String get and => Intl.message(' and ', name: 'and');
  String get youMustAgree => Intl.message('You must agree to the terms of service and privacy policy before sign up.', name: 'youMustAgree');
  String get signInWithGoogle => Intl.message('Sign in with Google', name: 'signInWithGoogle');
  String get signInWithFacebook => Intl.message('Sign in with Facebook', name: 'signInWithFacebook');
  String get signIn => Intl.message('Sign In', name: 'signIn');
  String get enterAMessage => Intl.message('Enter a message', name: 'enterAMessage');
  String get displayRoomQrCode => Intl.message("Display Room's QR Code", name: 'displayRoomQrCode');
  String get pleaseLogin => Intl.message('Please sign in', name: 'pleaseLogin');
  String get notification => Intl.message('Notification', name: 'notification');
  String get qrCode => Intl.message('QR code', name: 'qrCode');
  String get delete => Intl.message('Delete', name: 'delete');
  String get leaveTheRoom => Intl.message('Leave', name: 'leaveTheRoom');
  String get imageHasArrived => Intl.message('An image has arrived', name: 'imageHasArrived');
  String get sentImage => Intl.message('Sent an image', name: 'sentImage');
  String get uploading => Intl.message('uploading...', name: 'uploading');
  String get save => Intl.message('Save', name: 'save', desc: 'save button');
  String get inputRoomName => Intl.message('Input room name', name: 'inputRoomName');
  String get createRoomTitle => Intl.message('Create Room', name: 'createRoomTitle');
  String get create => Intl.message('Create', name: 'create', desc: 'create button');
  String get error => Intl.message('Error', name: 'error');
  String get buyNow   => Intl.message('Buy Now', name: 'buyNow');
  String get plan   => Intl.message('Plan', name: 'plan');
  String get month   => Intl.message('month', name: 'month');
  String get aboutSubscription   => Intl.message('About Subscription', name: 'aboutSubscription');
  String get aboutSubscriptionDetailForIOS   => Intl.message('Length of subscription: 1 month. Payment will be charged to iTunes Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Account will be charged for renewal within 24 hours prior to the end of the current period at the rate of the selected plan. Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user\'s Account Settings after purchase.', name: 'aboutSubscriptionDetailForIOS');
  String get aboutSubscriptionDetailForAndroid   => Intl.message('Length of subscription: 1 month. Payment will be charged to Google Play Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Account will be charged for renewal within 24 hours prior to the end of the current period at the rate of the selected plan. Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user\'s Account Settings after purchase.', name: 'aboutSubscriptionDetailForAndroid');
  String get purchased   => Intl.message('Your current plan', name: 'purchased');
  String get pricing   => Intl.message('Pricing', name: 'pricing');
  String get email   => Intl.message('Email', name: 'email');
  String get settingColorTheme   => Intl.message('Setting Color Theme', name: 'settingColorTheme');
  String get blockedUserTitle   => Intl.message('Blocked users', name: 'blockedUserTitle');
  String get noUsersAreBlocking   => Intl.message('No users are blocking', name: 'noUsersAreBlocking');
  String get blockUser   => Intl.message('Block', name: 'blockUser');
  String get unblockUser   => Intl.message('Unblock', name: 'unblockUser');
  String get blockedUserMessage   => Intl.message('This message is blocked user message.', name: 'unblockUser');
  String get blockCheck   => Intl.message('Are you sure block?', name: 'blockCheck');
  String get editProfile   => Intl.message('Edit profile', name: 'editProfile');
  String get logout   => Intl.message('Logout', name: 'logout');
  String get contactUs   => Intl.message('Contact Us', name: 'contactUs');
  String get name   => Intl.message('Name', name: 'name');
  String get nameIsRequired   => Intl.message('Name is required.', name: 'nameIsRequired');
  String get settingColorThemeTitle   => Intl.message('Setting Color Theme', name: 'settingColorThemeTitle');
  String get changedColorTheme   => Intl.message('Changed color theme', name: 'changedColorTheme');
  String get previewTitle   => Intl.message('Preview', name: 'previewTitle');
  String get ok   => Intl.message('OK', name: 'ok');
  String get cancel   => Intl.message('Cancel', name: 'cancel');
  String get cancelToolTip   => Intl.message('Cancel', name: 'cancelToolTip');
  String get sendImage   => Intl.message('Send Image', name: 'sendImage');
  String get sendImageToolTip   => Intl.message('Send Image', name: 'sendImageToolTip');
  String get gallery   => Intl.message('Gallery', name: 'gallery');
  String get camera   => Intl.message('Camera', name: 'camera');
  String get takeQRCodeWithCamera   => Intl.message('Take a QR code with the camera.', name: 'takeQRCodeWithCamera');
  String get openQRCodeImage   => Intl.message('Open a QR code image.', name: 'openQRCodeImage');
  String get unsavedChanges   => Intl.message('Unsaved Changes', name: 'unsavedChanges');
  String get unsavedChangesMessage   => Intl.message('You have unsaved changes. Are you sure you want to cancel?', name: 'unsavedChangesMessage');
  String get changePaidPlan   => Intl.message('The plan is currently subscribed. If you press OK, the subscription plan will be canceled. Would you like to continue purchasing this way?', name: 'changePaidPlan');
  String get beCareful   => Intl.message('Please be careful', name: 'beCareful');
  String get checkLeaveRoom   => Intl.message('Are you sure you want to leave this room? If you leave this room, you\'ll no longer be able to see its caht history.', name: 'checkLeaveRoom');
  String get unknownUser  => Intl.message('Unknown User', name: 'unknownUser');
  String get report  => Intl.message('Report', name: 'report');
  String get agreeAndSend  => Intl.message('Agree & send', name: 'agreeAndSend');
  String get checkReportRoom   => Intl.message('Are you sure you want to send?', name: 'checkReportRoom');
  String get thankYouReport   => Intl.message('Thank you for your report.', name: 'thankYouReport');
  String get reportTitle  => Intl.message('Report', name: 'reportTitle');
  String get reportDescription  => Intl.message('Tell us why you are sending us this report.', name: 'reportDescription');
  String get reportCheckDescription  => Intl.message('Making a report will send the relevant user and room info to us.', name: 'reportCheckDescription');
  String get reportTypeSpam  => Intl.message('Spam/Advertising', name: 'reportTypeSpam');
  String get reportTypeSexualHarassment  => Intl.message('Sexual harassment', name: 'reportTypeSexualHarassment');
  String get reportTypeOtherHarassment  => Intl.message('Other harassment', name: 'reportTypeOtherHarassment');
  String get reportTypeOther  => Intl.message('Other', name: 'reportTypeOther');
  // エラーメッセージ
  String get networkError => Intl.message('There was a problem with the network. Please check whether it is connected to the network.', name: 'networkError');
  String get purchaseError => Intl.message('Failed to purchase this process. Since it may have already been purchased, please confirm.', name: 'purchaseError');
  String get leaveRoomError => Intl.message('Failed to leave the room. Please try again.', name: 'leaveRoomError');
  String get addMemberError => Intl.message('Failed to join the room. Please try again.', name: 'addMemberError');
  String get unknownError => Intl.message("We are sorry. Something went wrong. Please try again. If you still get an error, sorry to trouble you, but We'd be happy to let you know the situation from the inquiries in the menu on the Profile tab or on error page.", name: 'unknownError');
  String get createRoomError => Intl.message("Couldn't create a new room.", name: 'createRoomError');
  String get quoteExceededError => Intl.message("It exceeds the upper limit. Please consider paid plan.", name: 'quoteExceededError');
  String get uploadImageError => Intl.message("Couldn't upload your image.", name: 'uploadImageError');
  String get imageUploadWasCanceled => Intl.message("Image upload was canceled.", name: 'imageUploadWasCanceled');
  String get singInFailedError => Intl.message("Failed to sing in. An account with the same e-mail address and different sign-in credentials may already exist. Please try sign in using the provider associated with this email address.", name: 'singInFailedError');
  String get updateProfileError => Intl.message("Failed to update your profile. Please try again.", name: 'updateProfileError');
  String get cameraPermissionError => Intl.message("Camera permission not granted. So  please grant it on setting app to join the room with using your camera.", name: 'cameraPermissionError');
  String get userRecoverableAuthError => Intl.message("Failed to sing in. Please try again.", name: 'userRecoverableAuthError');
  String get encouragedError => Intl.message("We are sorry. An error occurred.", name: 'encouragedError');
  String get errorOccurred => Intl.message("An error occurred.", name: 'errorOccurred');
  String get roomNameIsRequired => Intl.message("Room name is required.", name: 'roomNameIsRequired');
  String get userNameIsRequired => Intl.message("Name is required.", name: 'userNameIsRequired');

  // オンボーディング
  String get onboarding1Title => Intl.message("Welcome to Inconne", name: 'onboarding1Title');
  String get onboarding1Message => Intl.message("People with different accounts can communicate!", name: 'onboarding1Message');
  String get onboarding2Title => Intl.message("Rooms", name: 'onboarding2Title');
  String get onboarding2Message => Intl.message("You can communicate in the room!", name: 'onboarding2Message');
  String get onboarding3Title => Intl.message("Join room", name: 'onboarding3Title');
  String get onboarding3Message => Intl.message("To participate in the room, you can create a room or shoot a QR code of room.", name: 'onboarding3Message');
  String get onboarding4Title => Intl.message("Now, Let’s talk!", name: 'onboarding4Title');
  String get onboarding4Message => Intl.message("You just need to talk", name: 'onboarding4Message');
  String get onboardingStartMessage => Intl.message("Start", name: 'onboardingStartMessage');

  // 定期購読
  String get litePlanTitle => Intl.message("Lite plan", name: 'litePlanTitle');
  String get litePlanDescription => Intl.message("Unlimit the maximum of 100 messages per room. Advertisements are also hidden.", name: 'litePlanDescription');
  String get proPlanTitle => Intl.message("Pro plan", name: 'proPlanTitle');
  String get proPlanDescription => Intl.message("Lite plan + images will be able to upload from about 10,000 to 50,000.", name: 'proPlanDescription');
  String get unlimitedPlanTitle => Intl.message("Unlimited plan", name: 'unlimitedPlanTitle');
  String get unlimitedPlanDescription => Intl.message("Pro plan + Image upload unlimited.", name: 'unlimitedPlanDescription');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<Strings> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ja'].contains(locale.languageCode);
  }

  @override
  Future<Strings> load(Locale locale) {
    return Strings.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Strings> old) {
    return false;
  }
}
