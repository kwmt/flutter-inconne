# 配信

参考: https://flutter.io/fastlane-cd/

## deploygate配信

### iOS

ローカルからアップロードする方法

いったんflutter buildやったほうが良さそう。そこで pod installするので。
```sh
flutter -v build ios -t lib/application/main_production.dart --no-codesign
```

```sh
$ cd ios
($ bundle install) ←インストールしてなければ実行。してたら不要
$ bundle exec fastlane dg
```

上でだめな場合。（同じことをやってるはずだが・・・）
```sh
$ bundle exec fastlane gym --export_method ad-hoc --scheme Runner
$ bundle exec fastlane dg_local
```

### Android

```sh
$ flutter build apk -t lib/application/main_production.dart --release --flavor production
$ cd android
($ bundle install) ←インストールしてなければ実行。してたら不要
$ bundle exec fastlane dg
```

# AppStore Upload

## 開発版のアップロード

```
% bundle exec fastlane gym --export_method app-store --scheme development --configuration Release-development
```

- android
```
$ export $(grep -v '^#' .credential_development.sh | xargs -0)
% flutter build apk -t lib/application/main_development.dart --flavor development
```

## 本番のアップロード

### App Store
```bash
$ export $(grep -v '^#' .credential_production.sh | xargs -0) && ./release.sh ios appstore
```

### Play Store

```bash
$ export $(grep -v '^#' .credential_production.sh | xargs -0) && ./release.sh apk playstore
```
