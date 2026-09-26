import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/services/gemini_service.dart';
import 'sidebar_controller.dart';

/// A quick action chip under the orb.
class HomeAction {
  const HomeAction({required this.labelKey, required this.icon});

  /// Translation key of the label.
  final String labelKey;

  /// SVG asset path of the coloured icon.
  final String icon;
}

/// A message in the current conversation.
class ChatMessage {
  ChatMessage.user(String text)
    : isUser = true,
      text = text.obs,
      isStreaming = false.obs;

  ChatMessage.ai() : isUser = false, text = ''.obs, isStreaming = true.obs;

  final bool isUser;

  /// Grows while the reply streams in.
  final RxString text;
  final RxBool isStreaming;
  final error = RxnString();

  /// null: no vote, true: liked, false: disliked.
  final liked = RxnBool();
}

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final messages = <ChatMessage>[].obs;
  final hasText = false.obs;
  final isGenerating = false.obs;
  final showDisclaimer = true.obs;

  /// Chip picked from the welcome screen, shown as a tag in the input.
  final selectedAction = Rxn<HomeAction>();

  StreamSubscription<String>? _reply;

  static const researchAction = HomeAction(
    labelKey: 'home_research',
    icon: AppAssets.researchIcon,
  );

  /// Sidebar drawer position: 0 closed, 1 open.
  late final drawer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  final isDrawerOpen = false.obs;

  static const actions = [
    HomeAction(labelKey: 'home_code', icon: AppAssets.codeIcon),
    researchAction,
    HomeAction(labelKey: 'home_canvas', icon: AppAssets.canvasIcon),
    HomeAction(
      labelKey: 'home_generate_images',
      icon: AppAssets.generateImagesIcon,
    ),
    HomeAction(labelKey: 'home_integration', icon: AppAssets.integrationIcon),
  ];

  @override
  void onInit() {
    super.onInit();
    drawer.addListener(() => isDrawerOpen.value = drawer.value > 0);
    messageController.addListener(
      () => hasText.value = messageController.text.trim().isNotEmpty,
    );
    // Picking a chat in the sidebar (or on search) shows it here.
    ever(Get.find<SidebarController>().selectedChatId, (_) => closeDrawer());
  }

  void onMenu() => drawer.isDismissed ? drawer.forward() : closeDrawer();

  void closeDrawer() => drawer.reverse();

  /// Whether the web search tag is on for the next message.
  bool get _searchWeb => selectedAction.value == researchAction;

  /// Status line under the last message while waiting for the first words.
  String? get pendingStatus {
    final last = messages.lastOrNull;
    if (last == null || !last.isStreaming.value || last.text.isNotEmpty) {
      return null;
    }
    return _searchWeb ? 'chat_searching_web'.tr : 'chat_thinking'.tr;
  }

  void onSend() {
    final text = messageController.text.trim();
    if (text.isEmpty || isGenerating.value) return;
    messageController.clear();
    messages.add(ChatMessage.user(text));
    _generate();
  }

  /// Stops the reply that is streaming in.
  void onStop() {
    _reply?.cancel();
    _finish(messages.last);
  }

  /// Asks again for [message], replacing it with a new reply.
  void onRegenerate(ChatMessage message) {
    if (isGenerating.value) return;
    final index = messages.indexOf(message);
    if (index < 0) return;
    messages.removeRange(index, messages.length);
    _generate();
  }

  void onCopy(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.text.value));
    Get.rawSnackbar(
      message: 'chat_copied'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  void onLike(ChatMessage message, bool liked) =>
      message.liked.value = message.liked.value == liked ? null : liked;

  void _generate() {
    final history = [
      for (final m in messages)
        if (m.error.value == null && m.text.isNotEmpty)
          GeminiTurn(
            role: m.isUser ? GeminiRole.user : GeminiRole.model,
            text: m.text.value,
          ),
    ];
    final reply = ChatMessage.ai();
    messages.add(reply);
    isGenerating.value = true;
    _scrollToBottom();

    _reply = GeminiService.instance
        .streamReply(history, searchWeb: _searchWeb)
        .listen(
          (chunk) {
            reply.text.value += chunk;
            _scrollToBottom();
          },
          onError: (Object e) {
            reply.error.value = e is GeminiException
                ? e.message
                : 'chat_error'.tr;
            _finish(reply);
          },
          onDone: () => _finish(reply),
          cancelOnError: true,
        );
  }

  void _finish(ChatMessage reply) {
    _reply = null;
    reply.isStreaming.value = false;
    isGenerating.value = false;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void onNewChat() {
    _reply?.cancel();
    _reply = null;
    isGenerating.value = false;
    messages.clear();
    selectedAction.value = null;
    messageController.clear();
  }

  void onAction(HomeAction action) => selectedAction.value = action;

  void onClearAction() => selectedAction.value = null;

  void onCloseDisclaimer() => showDisclaimer.value = false;

  // TODO: wire these up once the menus and voice exist.
  void onModelTap() {}
  void onMore() {}
  void onAttach() {}
  void onMic() {}
  void onVoice() {}

  @override
  void onClose() {
    _reply?.cancel();
    messageController.dispose();
    scrollController.dispose();
    drawer.dispose();
    super.onClose();
  }
}
