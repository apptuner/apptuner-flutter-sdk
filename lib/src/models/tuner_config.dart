class TunerConfig {
  final bool maintenanceActive;
  final bool forceUpgrade;
  final String? message;
  final String? androidSource;
  final String? appleSource;

  TunerConfig({
    required this.maintenanceActive,
    required this.forceUpgrade,
    this.message,
    this.androidSource,
    this.appleSource,
  });

  factory TunerConfig.fromJson(Map<String, dynamic> json) {
    return TunerConfig(
      maintenanceActive: json['maintenance_active'] == true,
      forceUpgrade: json['force_upgrade'] == true,
      message: json['message'] as String?,
      androidSource: json['android_source'] as String?,
      appleSource: json['apple_source'] as String?,
    );
  }
}
