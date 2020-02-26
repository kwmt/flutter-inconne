class EnumUtil {
  // Enumの値を文字列で返す。
  // 例: enum Type {Hoge} のようなenumの場合、
  // var value = EnumUtil.getValueString(Type.Hoge);
  // assert(value == "Hoge");
  // となる。
  static String getValueString(dynamic enumType) {
    // dotがない場合などは
    // "Uncaught exception: RangeError (index): Index out of range: index should be less than 1: 1"のようなExceptionが投げられるが、
    // プログラマの責任なので、エラーチャックしない
    return enumType.toString().split('.')[1];
  }
}
