import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/gallery/about.dart#L11-L33
class LinkTextSpan extends TextSpan {
  LinkTextSpan(
      {BuildContext context,
      TextStyle style,
      String url,
      String text,
      bool inAppWebView = false})
      : super(
            style: style ?? url != null
                ? TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  )
                : Theme.of(context).textTheme.body2,
            text: text ?? url,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch(url, forceWebView: inAppWebView);
              });
}
