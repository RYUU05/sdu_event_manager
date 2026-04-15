class SettingsEntity {
  final String language;

  const SettingsEntity({required this.language});

  SettingsEntity copyWith({String? language}) {
    return SettingsEntity(language: language ?? this.language);
  }

  @override
  String toString() => 'SettingsEntity(language: $language)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsEntity &&
          runtimeType == other.runtimeType &&
          language == other.language;

  @override
  int get hashCode => language.hashCode;
}
