#!/usr/bin/env bash

setup () {
    flutter clean
    flutter pub get
    flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/l10n/strings.dart
    flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/strings.dart lib/l10n/intl_messages.arb lib/l10n/intl_ja.arb
    flutter pub pub run build_runner build --delete-conflicting-outputs
    dart tool/env.dart
}

buildIos() {
    flutter -v build ios -t lib/application/main_production.dart # --no-codesign
}

deployToAppStore() {
    cd ios && bundle exec fastlane prod
}

deployToDeployGate() {
    cd ios && bundle exec fastlane gym --export_method ad-hoc --scheme Runner && bundle exec fastlane dg
}

buildApk() {
    flutter build apk -t lib/application/main_production.dart --release --flavor production #--target-platform=android-arm64
}

deployToPlayStore() {
    cd android && bundle exec fastlane beta
}

CMDNAME=`basename $0`

#if [ $# -ne 1 ]; then
#  echo "Usage: $CMDNAME ios or apk" 1>&2
#  exit 1
#fi

if [ $1 = "setup" ]; then
    setup
    exit 0
fi

if [ $1 = "ios" ]; then
   setup
   buildIos

   if [ $2 = "deploygate" ]; then
        deployToDeployGate
   fi

   if [ $2 = "appstore" ]; then
        deployToAppStore
   fi
   echo "終了"
elif [ $1 = "apk" ]; then
   setup
   buildApk

   if [ $2 = "playstore" ]; then
        deployToPlayStore
   fi

   echo "終了"
else
    echo "iosかapkを指定してください。"

fi

