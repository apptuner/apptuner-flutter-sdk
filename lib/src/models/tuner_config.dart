/// Represents the configuration fetched from the Apptuner service.
class TunerConfig {
  /// Whether maintenance mode is active.
  final bool maintenanceActive;

  /// Whether a force upgrade is required.
  final bool forceUpgrade;

  /// The message to display to the user.
  final String? message;

  /// The Google Play Store URL.
  final String? androidSource;

  /// The Apple App Store URL.
  final String? appleSource;

  /// Creates a [TunerConfig].
  TunerConfig({
    required this.maintenanceActive,
    required this.forceUpgrade,
    this.message,
    this.androidSource,
    this.appleSource,
  });

  /// Creates a [TunerConfig] from a JSON map.
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
