import 'package:get/get.dart';

class DataControlController extends GetxController {
  final improveModel = true.obs;
  final includeVoiceData = false.obs;

  void onImproveModel(bool value) => improveModel.value = value;

  void onIncludeVoiceData(bool value) => includeVoiceData.value = value;

  // TODO: wire these up once the data control API exists.
  void onExportData() {}
  void onDeleteConversationData() {}
  void onDeleteVoiceData() {}
  void onArchiveAllChats() {}
  void onDeleteAllChats() {}
  void onDeleteAccount() {}
}
