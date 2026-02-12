import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Styling configuration for the Apptuner overlay screens.
///
/// Use this class to customize the colors, gradients, and text styles
/// of the built-in maintenance and force update screens.
class ApptunerStyle {
  /// The background gradient for the entire overlay screen.
  final Gradient? backgroundGradient;

  /// The color of the maintenance icon.
  final Color? maintenanceIconColor;

  /// The color of the update icon.
  final Color? updateIconColor;

  /// The background color of the maintenance icon circle.
  final Color? maintenanceIconBackgroundColor;

  /// The background color of the update icon circle.
  final Color? updateIconBackgroundColor;

  /// Text style for the title ("Under Maintenance" or "Update Required").
  final TextStyle? titleStyle;

  /// Text style for the message body.
  final TextStyle? messageStyle;

  /// Gradient for the action button (e.g., "Update Now").
  final Gradient? buttonGradient;

  /// Text style for the action button text.
  final TextStyle? buttonTextStyle;

  /// Creates a new [ApptunerStyle].
  const ApptunerStyle({
    this.backgroundGradient,
    this.maintenanceIconColor,
    this.updateIconColor,
    this.maintenanceIconBackgroundColor,
    this.updateIconBackgroundColor,
    this.titleStyle,
    this.messageStyle,
    this.buttonGradient,
    this.buttonTextStyle,
  });
}

/// A widget that displays the maintenance or force update overlay.
///
/// This widget is used internally by [ApptunerWrapper] but is exposed
/// for manual usage if needed.
class UpgradeOverlay extends StatelessWidget {
  /// Whether to show the maintenance screen (as opposed to the update screen).
  final bool isMaintenance;

  /// The message to display.
  final String? message;

  /// The Google Play Store URL.
  final String? androidSource;

  /// The Apple App Store URL.
  final String? appleSource;

  /// Custom styling configuration.
  final ApptunerStyle? style;

  /// Creates an [UpgradeOverlay].
  const UpgradeOverlay({
    super.key,
    required this.isMaintenance,
    this.message,
    this.androidSource,
    this.appleSource,
    this.style,
  });

  Future<void> _launchStore() async {
    final url = Platform.isAndroid ? androidSource : appleSource;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: Try to launch anyway, as canLaunchUrl might return false
          // on Android 11+ if queries are missing in manifest, but intent might still work.
          debugPrint(
            'Apptuner: canLaunchUrl returned false, attempting launch anyway for $url',
          );
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Apptuner: Could not launch $url. Error: $e');
      }
    } else {
      debugPrint(
        'Apptuner: No store URL provided for ${Platform.operatingSystem}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isMaintenance) {
      return _buildMaintenanceScreen(context);
    } else {
      return _buildUpdateScreen(context);
    }
  }


  Widget _buildMaintenanceScreen(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: style?.backgroundGradient == null ? Colors.black : null,
          gradient: style?.backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: style?.maintenanceIconBackgroundColor,
                  border: Border.all(
                    color: style?.maintenanceIconColor ?? const Color(0xFFEF4444),
                    width: 4,
                  ), // Red border
                ),
                child: Icon(
                  Icons.priority_high_rounded,
                  color: style?.maintenanceIconColor ?? const Color(0xFFEF4444),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Under\nMaintenance',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ).merge(style?.titleStyle),
              ),
              const SizedBox(height: 16),
              Text(
                message ??
                    'We are currently upgrading our servers to provide you with a better experience.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 1.5,
                ).merge(style?.messageStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateScreen(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: style?.backgroundGradient == null ? Colors.black : null,
          gradient: style?.backgroundGradient,
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Dark card background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: style?.updateIconBackgroundColor ?? const Color(0xFF5A3010), // Brownish/Orange dark bg
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    color: style?.updateIconColor ?? const Color(0xFFF97316), // Orange
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Update Required',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ).merge(style?.titleStyle),
                ),
                const SizedBox(height: 12),
                Text(
                  'A new version of the app is available. Please update to continue using the app securely.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    height: 1.5,
                  ).merge(style?.messageStyle),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: style?.buttonGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _launchStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: style?.buttonGradient != null ? Colors.transparent : Colors.white,
                        foregroundColor: Colors.black,
                        shadowColor: style?.buttonGradient != null ? Colors.transparent : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Update Now',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold).merge(style?.buttonTextStyle),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
