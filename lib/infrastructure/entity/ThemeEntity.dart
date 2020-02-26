class ThemeEntity {
  String id;
  String primary;
  String accent;
  String name;
  int order;
  bool isDefault;

  ThemeEntity(
      {String id,
      String primary,
      String accent,
      String name,
      int order,
      bool isDefault}) {
    this.id = id ?? "theme0";
    this.primary = primary ?? "0xFF009688";
    this.accent = accent ?? "0xFFFF4081";
    this.name = name ?? 'teal';
    this.order = order ?? 1;
    this.isDefault = isDefault ?? true;
  }

  ThemeEntity.fromJSON(Map json, String id) {
    this.id = id;
    this.primary = json['primary'];
    this.accent = json['accent'];
    this.name = json['name'];
  }

  toObject() {
    return <String, dynamic>{
      'primary': primary,
      'accent': accent,
      'order': order,
      'name': name,
      'is_default': isDefault
    };
  }
}
