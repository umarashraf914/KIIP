class AppSettings {
  final bool isDarkMode;
  final double ttsSpeed;
  final bool notificationsEnabled;
  final String appLanguage;

  const AppSettings({
    this.isDarkMode = false,
    this.ttsSpeed = 0.4,
    this.notificationsEnabled = true,
    this.appLanguage = 'English',
  });

  AppSettings copyWith({
    bool? isDarkMode,
    double? ttsSpeed,
    bool? notificationsEnabled,
    String? appLanguage,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }

  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'ttsSpeed': ttsSpeed,
    'notificationsEnabled': notificationsEnabled,
    'appLanguage': appLanguage,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    isDarkMode: json['isDarkMode'] as bool? ?? false,
    ttsSpeed: (json['ttsSpeed'] as num?)?.toDouble() ?? 0.4,
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    appLanguage: json['appLanguage'] as String? ?? 'English',
  );
}
