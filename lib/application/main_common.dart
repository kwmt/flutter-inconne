import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/AppPackageInfo.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/MainScreen.dart';
import 'package:package_info/package_info.dart';

Future<void> mainCommon(AppConfig appConfig) async {
  // https://stackoverflow.com/a/57690818/2520998
  WidgetsFlutterBinding.ensureInitialized();

  final PackageInfo info = await PackageInfo.fromPlatform();
  appConfig.appPackageInfo = AppPackageInfo(
      info.appName, info.packageName, info.version, info.buildNumber);
}

Future<void> setupCrashlyticsAndRunApp(AppConfig config) async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (config.flavor == Flavor.DEVELOPMENT) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Crashlytics.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  bool optIn = true;
  if (optIn) {
    await FlutterCrashlytics().initialize();
  } else {
    // In this case Crashlytics won't send any reports.
    // Usually handling opt in/out is required by the Privacy Regulations
  }

  runZoned<Future<Null>>(() async {
    runApp(config);
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    debugPrint(error.toString());
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppConfig appConfig = AppConfig.of(context);
    return _buildApp(context, appConfig);
  }

  Widget _buildApp(BuildContext context, AppConfig appConfig) {
    return MaterialApp(
      title: appConfig.title,
      theme: AppConfig.kTheme.copyWith(platform: Theme.of(context).platform),

      home: Injector.getInjector().get<MainScreen>(),
      // FirebaseStorageSample(storage: Injector.getInjector().get<FirebaseStorage>()), //
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        // 英語以外（日本語設定）でTextFieldを長押しすると
        // NoSuchMethodError: The getter 'cutButtonLabel' was called on null.
        // というエラーが出る対策
        // https://github.com/flutter/flutter/issues/13452#issuecomment-517021770
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('ja', 'JP'), // Japan
        // ... other locales the app supports
      ],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            return locale;
          }
        }

        return supportedLocales.first;
      },
    );
  }
}

String checkEnvironment(dynamic value) {
  if (value == null) {
    throw ArgumentError();
  }
  var str = value as String;
  if (str == null) {
    throw ArgumentError("");
  }
  return str;
}

