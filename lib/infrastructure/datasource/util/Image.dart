import 'dart:io';

import 'package:flutter_native_image/flutter_native_image.dart';

class Image {
  /// 画像を圧縮する
  /// https://stackoverflow.com/a/50998865
  /// ↓に変更
  /// https://github.com/flutter/flutter/issues/19383#issuecomment-405130684
  /// https://github.com/btastic/flutter_native_image
  /// @param file オリジナルファイル
  /// @return 圧縮されたfile
  static Future<File> compress(File file) async {
    DateTime startDateTime = DateTime.now();
//    print("startDateTime:$startDateTime");

    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(file.path);
    File compressedFile = await FlutterNativeImage.compressImage(file.path,
        quality: 80,
        targetWidth: 600,
        targetHeight: (properties.height * 600 / properties.width).round());
//    print("end - start:${startDateTime.difference(DateTime.now())}");
    return compressedFile;
  }
}
