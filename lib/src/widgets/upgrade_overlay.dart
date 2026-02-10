import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApptunerStyle {
  final Gradient? backgroundGradient;
  final Color? maintenanceIconColor;
  final Color? updateIconColor;
  final Color? maintenanceIconBackgroundColor;
  final Color? updateIconBackgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final Gradient? buttonGradient;
  final TextStyle? buttonTextStyle;

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

class UpgradeOverlay extends StatelessWidget {
  final bool isMaintenance;
  final String? message;
  final String? androidSource;
  final String? appleSource;
  final ApptunerStyle? style;

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
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Apptuner: Could not launch $url');
      }
    } else {
      debugPrint('Apptuner: No store URL provided for ${Platform.operatingSystem}');
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
      color: Colors.black, // Force black background for maintenance as per image
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF4444), width: 4), // Red border
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                color: Color(0xFFEF4444),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Under\nMaintenance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'We are currently upgrading our servers to provide you with a better experience.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateScreen(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.8), // Semi-transparent background
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
                  color: const Color(0xFF5A3010), // Brownish/Orange dark bg
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Color(0xFFF97316), // Orange
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Update Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A new version of the app is available. Please update to continue using the app securely.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _launchStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Update Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
