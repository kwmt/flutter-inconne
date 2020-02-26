import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageUtils {
  static Widget circle(String imageUrl,
      {double radius = 20.0, String text, double fontSize = 10.0}) {
    ImageProvider imageProvider = (imageUrl != null || imageUrl == 'null')
        ? NetworkImage(imageUrl)
        : null;

    text = imageProvider != null ? null : text;

    return _circleImageProviderImpl(imageProvider,
        radius: radius,
        child: text != null && text.isNotEmpty
            ? Text(text.substring(0, 1), style: _createTextStyle(fontSize))
            : null);
  }

  static Widget circleImageProvider(ImageProvider provider,
      {double radius = 20.0, String text, double fontSize = 50.0}) {
    return _circleImageProviderImpl(provider,
        radius: radius,
        child: text != null && text.isNotEmpty
            ? Text(text.substring(0, 1), style: _createTextStyle(fontSize))
            : null);
  }

  static Widget _circleImageProviderImpl(ImageProvider provider,
      {double radius = 20.0, Widget child}) {
    return CircleAvatar(
      child: child,
      backgroundColor: Colors.grey[300],
      backgroundImage: provider,
      radius: radius,
    );
  }

  /// 角丸画像
  static Widget roundedImage(String imageUrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: cachedImage(imageUrl, fit: BoxFit.cover));
  }

  static CachedNetworkImage cachedImage(String imageUrl, {fit}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
//          placeholder: Container(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: fit,
    );
  }

  static TextStyle _createTextStyle(double fontSize) {
    return TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      fontFamily: 'Roboto',
      letterSpacing: 0.5,
      fontSize: fontSize,
    );
  }
}
