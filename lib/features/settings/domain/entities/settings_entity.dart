class SettingsEntity {
  final String language;
  final String account;
  final String role;
  const SettingsEntity({
    required this.language,
    required this.account,
    required this.role,
  });

  SettingsEntity copyWith({String? language, String? account, String? role}) {
    return SettingsEntity(
      language: language ?? this.language,
      account: account ?? this.account,
      role: role ?? this.role,
    );
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
  int get hashCode => language.hashCode ^ role.hashCode ^ account.hashCode;
}
