# instantonnection

instant + connection 即席でグループ作って、連絡できるチャットアプリ

# Download the app here


<a href="https://apps.apple.com/jp/app/id1423069453">
<img style="margin: 0px 0px 0px 20px;"   width="135px"  src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/22161/dc0e452f-341f-9abf-f8cf-7b19b06238e3.png"/></a>
<a href='https://play.google.com/store/apps/details?id=com.instantonnection.app&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'>
<img style="margin: 0px 40px 0px 0px;"  width="155px"   alt='Google Play で手に入れよう' src='https://play.google.com/intl/en_us/badges/images/generic/ja_badge_web_generic.png' /></a>
<p style="clear:right;">

# How to build

- Set the following environment variables:
```
GOOGLE_APP_ID_IOS=
GOOGLE_APP_ID_ANDROID=
GOOGLE_API_KEY=
GOOGLE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
ADMOB_IDS_IOS=
ADMOB_IDS_ANDROID=
INTERSTITIAL_UNIT_IOS=
INTERSTITIAL_UNIT_ANDROID=
BASE_WEB_URL=
BASE_SUBSCRIPTION_API_URL=
```

It's easy to create .credential.sh and run the following command:
```
$ export $(grep -v '^#' .credential_development.sh | xargs -0)
```

- Create toot/.env.dart using the following command:
```
$ dart tool/env.dart
```

You may need to set path of dart command.

- For ready before build, run the following commands:
```
flutter clean
flutter pub get
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/l10n/strings.dart
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/strings.dart lib/l10n/intl_messages.arb lib/l10n/intl_ja.arb
flutter pub pub run build_runner build --delete-conflicting-outputs
dart tool/env.dart
```

- Build Android for development
    - Android
    ```
    $ flutter build apk -t lib/application/main_development.dart --flavor development
    ```
    - iOS
    ```
    $ flutter -v build ios -t lib/application/main_development.dart --flavor development
    ```
