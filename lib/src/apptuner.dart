import 'package:flutter/material.dart';
import 'apptuner_service.dart';
import 'models/tuner_config.dart';
import 'widgets/upgrade_overlay.dart';

export 'models/tuner_config.dart' show TunerConfig;
export 'widgets/upgrade_overlay.dart' show ApptunerStyle, UpgradeOverlay;

Apptuner get apptuner => Apptuner.instance;

class Apptuner extends ChangeNotifier {
  static final Apptuner instance = Apptuner._internal();

  Apptuner._internal();

  ApptunerService? _service;
  TunerConfig? _config;

  bool get isMaintenance => _config?.maintenanceActive ?? false;
  bool get forceUpgrade => _config?.forceUpgrade ?? false;
  String? get message => _config?.message;
  String? get androidSource => _config?.androidSource;
  String? get appleSource => _config?.appleSource;

  TunerConfig? get config => _config;

  /// Initialize the Apptuner SDK
  /// [apiKey] : Your Apptuner Project API Key
  Future<void> init({required String apiKey}) async {
    _service = ApptunerService(apiKey: apiKey);
    await checkUpdate();
  }

  /// Manually check for updates/config
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

class ApptunerWrapper extends StatefulWidget {
  final Widget child;
  final ApptunerStyle? style;
  final Widget Function(BuildContext context, TunerConfig config)? builder;

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
