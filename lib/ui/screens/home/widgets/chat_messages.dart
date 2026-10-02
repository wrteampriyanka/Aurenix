import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../widgets/custom_text.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/home/controllers/home_controller.dart';

/// The conversation: user bubbles on the right, AI replies full width.
class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => controller.showDisclaimer.value
              ? _Disclaimer(onClose: controller.onCloseDisclaimer)
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: Obx(() {
            final messages = controller.messages;
            return ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final message = messages[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: message.isUser
                      ? _UserBubble(message: message)
                      : _AiMessage(message: message, controller: controller),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
      color: context.color.tileFill,
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              'chat_disclaimer'.tr,
              fontSize: 12,
              color: context.color.textBody,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              PhosphorIconsRegular.x,
              size: 20,
              color: context.color.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.attachment case final file?) ...[
              _SentAttachment(attachment: file),
              if (message.text.isNotEmpty) const SizedBox(height: 6),
            ],
            if (message.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: context.color.sidebarSelected,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SelectableText(
                  message.text.value,
                  style: TextStyle(
                    color: context.color.textNatural,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A photo shown as a thumbnail, a document as a file row.
class _SentAttachment extends StatelessWidget {
  const _SentAttachment({required this.attachment});

  final ChatAttachment attachment;

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          attachment.bytes,
          width: 200,
          fit: BoxFit.cover,
          cacheWidth: 600,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.color.sidebarSelected,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular.fileText,
            size: 20,
            color: context.color.textNatural,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: CustomText(
              attachment.name,
              maxLines: 1,
              fontSize: 14,
              color: context.color.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiMessage extends StatelessWidget {
  const _AiMessage({required this.message, required this.controller});

  final ChatMessage message;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = message.error.value;
      final text = message.text.value;
      final status = controller.messages.lastOrNull == message
          ? controller.pendingStatus
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (status != null) _Status(text: status),
          for (final image in message.images) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(image.bytes, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
          ],
          if (text.isNotEmpty) _Markdown(text: text),
          if (error != null) ...[
            if (text.isNotEmpty) const SizedBox(height: 8),
            CustomText(error, fontSize: 14, color: context.color.error),
          ],
          if (!message.isStreaming.value) ...[
            const SizedBox(height: 12),
            _MessageActions(message: message, controller: controller),
          ],
        ],
      );
    });
  }
}

/// "Thinking…" / "Searching Web" shimmer before the first words arrive.
class _Status extends StatefulWidget {
  const _Status({required this.text});

  final String text;

  @override
  State<_Status> createState() => _StatusState();
}

class _StatusState extends State<_Status> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_pulse),
      child: CustomText(
        widget.text,
        fontSize: 15,
        color: context.color.textBody,
      ),
    );
  }
}

class _Markdown extends StatelessWidget {
  const _Markdown({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final body = TextStyle(
      color: context.color.textNatural,
      fontSize: 15,
      height: 1.4,
    );
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: body,
        listBullet: body,
        strong: body.copyWith(fontWeight: FontWeight.w700),
        em: body.copyWith(fontStyle: FontStyle.italic),
        h1: body.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        h2: body.copyWith(fontSize: 19, fontWeight: FontWeight.w700),
        h3: body.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
        a: body.copyWith(
          color: context.color.buttonHighlight,
          decoration: TextDecoration.underline,
        ),
        code: body.copyWith(
          fontFamily: 'monospace',
          fontSize: 13,
          backgroundColor: context.color.inputFill,
        ),
        codeblockDecoration: BoxDecoration(
          color: context.color.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.color.inputBorder),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: context.color.primary, width: 3),
          ),
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.color.divider)),
        ),
        tableBorder: TableBorder.all(color: context.color.divider),
        tableBody: body,
        tableHead: body.copyWith(fontWeight: FontWeight.w700),
        pPadding: const EdgeInsets.only(bottom: 4),
      ),
    );
  }
}

/// Copy, read aloud, regenerate, share, feedback and sources under a
/// finished reply.
class _MessageActions extends StatelessWidget {
  const _MessageActions({required this.message, required this.controller});

  final ChatMessage message;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final liked = message.liked.value;
    final hasText = message.text.isNotEmpty;
    final speaking = controller.speakingMessage.value == message;
    final sources = message.sources;
    return Row(
      children: [
        if (hasText) ...[
          _ActionIcon(
            icon: PhosphorIconsRegular.copy,
            onTap: () => controller.onCopy(message),
          ),
          _ActionIcon(
            icon: speaking
                ? PhosphorIconsFill.speakerHigh
                : PhosphorIconsRegular.speakerHigh,
            active: speaking,
            onTap: () => controller.onSpeak(message),
          ),
        ],
        _ActionIcon(
          icon: PhosphorIconsRegular.arrowsClockwise,
          onTap: () => controller.onRegenerate(message),
        ),
        if (message.error.value == null) ...[
          _ActionIcon(
            icon: PhosphorIconsRegular.shareNetwork,
            onTap: () => controller.onShare(message),
          ),
          _ActionIcon(
            icon: liked == true
                ? PhosphorIconsFill.thumbsUp
                : PhosphorIconsRegular.thumbsUp,
            onTap: () => controller.onLike(message, true),
          ),
          _ActionIcon(
            icon: liked == false
                ? PhosphorIconsFill.thumbsDown
                : PhosphorIconsRegular.thumbsDown,
            onTap: () => controller.onLike(message, false),
          ),
        ],
        if (sources.isNotEmpty) ...[
          const Spacer(),
          SizedBox(
            height: 20,
            child: VerticalDivider(width: 1, color: context.color.divider),
          ),
          _SourcesButton(sources: sources, onOpen: controller.onOpenSource),
        ],
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Icon(
          icon,
          size: 20,
          color: active
              ? context.color.buttonHighlight
              : context.color.textBody,
        ),
      ),
    );
  }
}

/// Favicon of the first web source and a caret; opens the list of sources.
class _SourcesButton extends StatelessWidget {
  const _SourcesButton({required this.sources, required this.onOpen});

  final List<ChatSource> sources;
  final ValueChanged<ChatSource> onOpen;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => _showSheet(context),
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Favicon(source: sources.first, size: 22),
            const SizedBox(width: 6),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 16,
              color: context.color.textBody,
            ),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.color.sidebarBackground,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: CustomText(
                'chat_sources'.tr,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.color.textNatural,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final source in sources)
                    ListTile(
                      leading: _Favicon(source: source, size: 24),
                      title: CustomText(
                        source.title,
                        maxLines: 1,
                        fontSize: 15,
                        color: context.color.textNatural,
                      ),
                      trailing: Icon(
                        PhosphorIconsRegular.arrowUpRight,
                        size: 18,
                        color: context.color.textBody,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onOpen(source);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Site icon for a source, falling back to a globe.
class _Favicon extends StatelessWidget {
  const _Favicon({required this.source, required this.size});

  final ChatSource source;
  final double size;

  @override
  Widget build(BuildContext context) {
    final globe = Icon(
      PhosphorIconsRegular.globe,
      size: size,
      color: context.color.textBody,
    );
    // Gemini's grounding titles are the site's domain.
    return ClipOval(
      child: Image.network(
        'https://www.google.com/s2/favicons?sz=64&domain=${source.title}',
        width: size,
        height: size,
        errorBuilder: (_, _, _) => globe,
      ),
    );
  }
}
