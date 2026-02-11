# Apptuner

[![pub package](https://img.shields.io/pub/v/apptuner.svg)](https://pub.dev/packages/apptuner)
[![GitHub stars](https://img.shields.io/github/stars/apptuner/apptuner-flutter-sdk?style=social)](https://github.com/apptuner/apptuner-flutter-sdk)
[![GitHub forks](https://img.shields.io/github/forks/apptuner/apptuner-flutter-sdk?style=social)](https://github.com/apptuner/apptuner-flutter-sdk)
[![View Source](https://img.shields.io/badge/GitHub-View%20Source-181717?style=flat&logo=github)](https://github.com/apptuner/apptuner-flutter-sdk)

Integrate **Apptuner** into your Flutter application with just a few lines of code. The SDK automatically handles **force update** and **maintenance mode** checks — including built-in overlay screens that block user interaction when required.

---

## Features

- **Force Update**: Automatically prompt users to update their app when a critical version is released.
- **Maintenance Mode**: Display a maintenance screen when your backend services are down or undergoing maintenance.
- **Cross-Platform**: Works seamlessly on both Android and iOS.
- **Customization**: Fully customizable UI for overlay screens.

---

## Installation

Add `apptuner` to your `pubspec.yaml`:

```yaml
dependencies:
  apptuner: ^1.0.0
```

Or run:

```bash
flutter pub add apptuner
```

---

## Usage

### 1. Initialize the SDK

Initialize `apptuner` in your `main()` before calling `runApp`. The SDK only requires your **API Key** — the platform and app version are detected automatically.

```dart
import 'package:apptuner/apptuner.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize apptuner with your API Key
  await apptuner.init(apiKey: 'YOUR_API_KEY');

  runApp(const MyApp());
}
```

> **Note:** `init()` fetches the latest config from the Apptuner API on startup. The SDK automatically sends the current platform (`android` / `ios`) and app version with every request.

---

### 2. Add the ApptunerWrapper

Wrap your app with `ApptunerWrapper` to automatically display a **force update** or **maintenance** overlay when needed. The easiest way is using the `builder` property of `MaterialApp`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      builder: (context, child) {
        return ApptunerWrapper(
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
```

The wrapper automatically:
- Displays a **maintenance screen** when maintenance mode is active.
- Displays a **force update dialog** when a required update is available.
- Re-checks the config every time the app is **resumed from background**.

---

### 3. Customization

#### Custom Styling

Use `ApptunerStyle` to customize the appearance of the built-in overlay screens:

```dart
ApptunerWrapper(
  style: const ApptunerStyle(
    backgroundGradient: LinearGradient(
      colors: [Colors.purple, Colors.blue],
    ),
    maintenanceIconColor: Colors.red,
    updateIconColor: Colors.orange,
    maintenanceIconBackgroundColor: Colors.black,
    updateIconBackgroundColor: Color(0xFF5A3010),
    titleStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    messageStyle: TextStyle(fontSize: 16, color: Colors.grey),
    buttonGradient: LinearGradient(
      colors: [Colors.orange, Colors.deepOrange],
    ),
    buttonTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
  child: child!,
);
```

#### Fully Custom UI with Builder

For complete control over the overlay, use the `builder` parameter to render your own widget when maintenance or a force update is active:

```dart
ApptunerWrapper(
  builder: (context, config) {
    if (config.forceUpgrade) {
      return MyCustomUpdateScreen(message: config.message);
    }
    return MyCustomMaintenanceScreen(message: config.message);
  },
  child: child!,
);
```

The `TunerConfig` object passed to the builder contains:

| Property            | Type      | Description                                    |
| ------------------- | --------- | ---------------------------------------------- |
| `maintenanceActive` | `bool`    | Whether maintenance mode is active             |
| `forceUpgrade`      | `bool`    | Whether a force update is required             |
| `message`           | `String?` | Custom message from the Apptuner dashboard     |
| `androidSource`     | `String?` | Play Store URL for the update button           |
| `appleSource`       | `String?` | App Store URL for the update button            |

---

### 4. Manual Update Check

You can manually trigger a config re-fetch at any time — for example, from a pull-to-refresh or a button tap:

```dart
IconButton(
  icon: const Icon(Icons.refresh),
  onPressed: () {
    apptuner.checkUpdate();
  },
);
```

---

### 5. Access Config Directly

If you need to read the config values without using the wrapper (e.g., for custom logic), you can access them directly:

```dart
if (apptuner.isMaintenance) {
  // App is in maintenance mode
}

if (apptuner.forceUpgrade) {
  // A required update is available
}

// Read individual fields
print(apptuner.message);
print(apptuner.androidSource);
print(apptuner.appleSource);
```

You can also listen for config changes since `Apptuner` extends `ChangeNotifier`:

```dart
apptuner.addListener(() {
  final config = apptuner.config;
  // React to config changes
});
```
