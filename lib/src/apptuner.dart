import 'package:flutter/material.dart';
import 'apptuner_service.dart';
import 'models/tuner_config.dart';
import 'widgets/upgrade_overlay.dart';

export 'models/tuner_config.dart' show TunerConfig;
export 'widgets/upgrade_overlay.dart' show ApptunerStyle, UpgradeOverlay;

/// Global accessor for the Apptuner singleton instance.
Apptuner get apptuner => Apptuner.instance;

/// The main class for interacting with the Apptuner SDK.
///
/// Use [init] to initialize the SDK with your API key.
/// Use [checkUpdate] to manually trigger a configuration fetch.
/// Listen to this class (it extends [ChangeNotifier]) to react to config changes.
class Apptuner extends ChangeNotifier {
  /// The singleton instance of [Apptuner].
  static final Apptuner instance = Apptuner._internal();

  Apptuner._internal();

  ApptunerService? _service;
  TunerConfig? _config;

  /// Whether maintenance mode is currently active.
  bool get isMaintenance => _config?.maintenanceActive ?? false;

  /// Whether a force upgrade is required.
  bool get forceUpgrade => _config?.forceUpgrade ?? false;

  /// The message to display to the user (e.g., maintenance message or upgrade notes).
  String? get message => _config?.message;

  /// The URL to the app on the Google Play Store.
  String? get androidSource => _config?.androidSource;

  /// The URL to the app on the Apple App Store.
  String? get appleSource => _config?.appleSource;

  /// The current configuration fetched from the Apptuner service.
  TunerConfig? get config => _config;

  /// Initialize the Apptuner SDK.
  ///
  /// [apiKey] is your Apptuner Project API Key.
  /// This method must be called before [checkUpdate] or accessing config values.
  /// It automatically triggers an initial [checkUpdate].
  Future<void> init({required String apiKey}) async {
    _service = ApptunerService(apiKey: apiKey);
    await checkUpdate();
  }

  /// Manually check for updates and fetch the latest configuration.
  ///
  /// This method is called automatically by [init] and when the app resumes
  /// from the background (if using [ApptunerWrapper]).
  Future<void> checkUpdate() async {
    if (_service == null) {
      debugPrint('Apptuner: Warning - call init() before checkUpdate()');
      return;
    }

    final config = await _service!.fetchConfig();
    if (config != null) {
      _config = config;
      notifyListeners();
    }
  }
}

/// A wrapper widget that handles displaying Apptuner overlays.
///
/// Wrap your application's root widget (e.g., in [MaterialApp.builder]) with
/// this wrapper to automatically show maintenance or force update screens
/// based on the current [Apptuner] configuration.
///
/// It also listens to app lifecycle changes to re-check for updates when
/// the app resumes.
class ApptunerWrapper extends StatefulWidget {
  /// The child widget to wrap (usually the app's root navigator).
  final Widget child;

  /// Optional style configuration for the default overlay screens.
  final ApptunerStyle? style;

  /// Optional builder to render a completely custom overlay.
  ///
  /// If provided, this builder is called when an overlay needs to be shown.
  /// It receives the current [BuildContext] and [TunerConfig].
  final Widget Function(BuildContext context, TunerConfig config)? builder;

  /// Creates an [ApptunerWrapper].
  const ApptunerWrapper({
    super.key,
    required this.child,
    this.style,
    this.builder,
  });

  @override
  State<ApptunerWrapper> createState() => _ApptunerWrapperState();
}

class _ApptunerWrapperState extends State<ApptunerWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    apptuner.addListener(_onConfigChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    apptuner.removeListener(_onConfigChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      apptuner.checkUpdate();
    }
  }

  void _onConfigChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tuner = apptuner;
    final showOverlay = tuner.isMaintenance || tuner.forceUpgrade;

    return Stack(
      children: [
        widget.child,
        if (showOverlay)
          Positioned.fill(
            child: widget.builder != null
                ? widget.builder!(context, tuner.config!)
                : UpgradeOverlay(
                    isMaintenance: tuner.isMaintenance && !tuner.forceUpgrade,
                    message: tuner.message,
                    androidSource: tuner.androidSource,
                    appleSource: tuner.appleSource,
                    style: widget.style,
                  ),
          ),
      ],
    );
  }
}
