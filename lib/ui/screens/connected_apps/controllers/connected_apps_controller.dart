import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../widgets/bottom_sheets/app_info_sheet.dart';
import '../services/connected_apps_service.dart';
import '../widgets/integration_app_logo.dart';

export '../services/connected_apps_service.dart' show IntegrationApp;

class ConnectedAppsController extends GetxController {
  final searchController = TextEditingController();
  final query = ''.obs;

  final _service = ConnectedAppsService.to;

  /// Apps the user has connected that match the search query.
  List<IntegrationApp> get connectedApps =>
      _matching.where(_service.isConnected).toList();

  /// Apps not connected yet that match the search query.
  List<IntegrationApp> get availableApps =>
      _matching.where((a) => !_service.isConnected(a)).toList();

  Iterable<IntegrationApp> get _matching {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return ConnectedAppsService.apps;
    return ConnectedAppsService.apps.where(
      (a) =>
          a.nameKey.tr.toLowerCase().contains(q) ||
          a.descriptionKey.tr.toLowerCase().contains(q),
    );
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => query.value = searchController.text);
  }

  void onApp(IntegrationApp app) {
    AppInfoSheet.show(
      logo: IntegrationAppLogo(app: app, size: 26),
      name: app.nameKey.tr,
      handle: app.handle,
      permissions: [for (final key in app.permissionKeys) key.tr],
      connected: _service.isConnected(app),
      onConnect: () => _setConnected(app, true),
      onDisconnect: () => _setConnected(app, false),
    );
  }

  void _setConnected(IntegrationApp app, bool connected) {
    Get.back();
    _service.setConnected(app, connected);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
