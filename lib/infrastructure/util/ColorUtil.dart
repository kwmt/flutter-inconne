import 'dart:ui';

class ColorUtil {
  /// Colorを16進数に変換する
  /// 例：Color(0xFF111111) を "0xFF111111" に変換する
  static String toHexString(Color color) =>
      '0x' + color.value.toRadixString(16).padLeft(8, '0');

  /// 16進数文字列をColorに変換する
  /// 例："0xFF111111" をColor(0xFF111111)に変換する
  static Color toColor(String hexString) => Color(int.parse(hexString));
}
