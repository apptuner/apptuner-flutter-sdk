import 'package:flutter_test/flutter_test.dart';
import 'package:apptuner/apptuner.dart';

void main() {
  group('TunerConfig', () {
    test('parses json correctly', () {
      final json = {
        'maintenance_active': true,
        'force_upgrade': false,
        'message': 'Maintenance Mode',
        'android_source': 'https://play.google.com',
        'apple_source': 'https://apps.apple.com',
      };

      final config = TunerConfig.fromJson(json);

      expect(config.maintenanceActive, true);
      expect(config.forceUpgrade, false);
      expect(config.message, 'Maintenance Mode');
      expect(config.androidSource, 'https://play.google.com');
      expect(config.appleSource, 'https://apps.apple.com');
    });

    test('handles null values', () {
      final json = {'maintenance_active': false, 'force_upgrade': true};

      final config = TunerConfig.fromJson(json);

      expect(config.maintenanceActive, false);
      expect(config.forceUpgrade, true);
      expect(config.message, null);
      expect(config.androidSource, null);
      expect(config.appleSource, null);
    });

    test('parses user provided json structure correctly', () {
      final json = {
        "force_upgrade": true,
        "maintenance_active": false,
        "message": "Please upgrade your app to continue.",
        "android_source": "https://r.mtdv.me/watch?v=klX423JTKE",
        "apple_source": "",
      };

      final config = TunerConfig.fromJson(json);

      expect(config.forceUpgrade, true);
      expect(config.maintenanceActive, false);
      expect(config.message, "Please upgrade your app to continue.");
      expect(config.androidSource, "https://r.mtdv.me/watch?v=klX423JTKE");
      expect(config.appleSource, "");
    });
  });
}
