import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/core/services/demo_chat_service.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/home/widgets/chat_upgrade_card.dart';
import 'package:aurenix/features/home/widgets/message_menu.dart';

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
              ? ChatNotice(
                  text: 'chat_disclaimer'.tr,
                  onClose: controller.onCloseDisclaimer,
                )
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: Obx(() {
            final messages = controller.messages;
            // One past the messages: the free-limit upgrade card closes the
            // conversation off, until the plan is paid for and it drops out.
            final showUpgrade = !ChatUpgradeCard.isPlanActive.value;
            return ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              itemCount: messages.length + (showUpgrade ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == messages.length) return const ChatUpgradeCard();
                final message = messages[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: message.isUser
                      ? _UserBubble(message: message, controller: controller)
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

/// Full-width grey strip with a note and an x to dismiss it: the AI
/// disclaimer above a chat, or what a preset cannot see.
class ChatNotice extends StatelessWidget {
  const ChatNotice({
    super.key,
    required this.text,
    required this.onClose,
    this.margin = const EdgeInsets.only(top: 12),
  });

  final String text;
  final VoidCallback onClose;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
      color: context.color.tileFill,
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              text,
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
  const _UserBubble({required this.message, required this.controller});

  final ChatMessage message;
  final HomeController controller;

  /// Opens the Copy / Select / Edit / Share card over the bubble.
  void _onLongPress(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    showMessageMenu(
      context: context,
      anchor: anchor,
      items: [
        if (message.text.isNotEmpty) ...[
          MessageMenuItem(
            icon: PhosphorIconsRegular.copy,
            label: 'chat_copy_text'.tr,
            onTap: () => controller.onCopy(message),
          ),
          MessageMenuItem(
            icon: PhosphorIconsRegular.textAlignLeft,
            label: 'chat_select_text'.tr,
            onTap: () => controller.onSelectText(message),
          ),
        ],
        MessageMenuItem(
          icon: PhosphorIconsRegular.pencilSimple,
          label: 'chat_edit_message'.tr,
          onTap: () => controller.onEditMessage(message),
        ),
        MessageMenuItem(
          icon: PhosphorIconsRegular.shareNetwork,
          label: 'chat_share'.tr,
          onTap: () => controller.onShare(message),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Builder(
          // Its own context, so the long press measures the bubble
          // rather than the whole list.
          builder: (context) => GestureDetector(
            onLongPress: () => _onLongPress(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.attachment case final file?) ...[
                  _SentAttachment(attachment: file),
                  if (message.text.isNotEmpty) const SizedBox(height: 6),
                ],
                if (message.text.isNotEmpty)
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.color.sidebarSelected,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _BubbleText(
                        text: message.text.value,
                        // Plain until "Select Texts" is picked: otherwise
                        // a long press would start a selection instead of
                        // opening the menu.
                        selectable: message.selectable.value,
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

/// The words in a sent bubble, with the selection handles only once the
/// menu has asked for them.
class _BubbleText extends StatelessWidget {
  const _BubbleText({required this.text, required this.selectable});

  final String text;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: context.color.textNatural,
      fontSize: 15,
      height: 1.3,
    );
    return selectable
        ? SelectableText(text, style: style, autofocus: true)
        : Text(text, style: style);
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

      // A picture on the way: the status line sits above a soft box the
      // size of the image, so nothing jumps when it lands.
      final drawing =
          status != null &&
          message.isStreaming.value &&
          controller.isGeneratingImage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (status != null) ...[
            _Status(text: status),
            if (drawing) ...[
              const SizedBox(height: 10),
              const _ImagePlaceholder(),
              const SizedBox(height: 12),
            ],
          ],
          for (final image in message.images) ...[
            _ReplyImage(image: image),
            const SizedBox(height: 12),
          ],
          if (text.isNotEmpty) _Markdown(text: text),
          if (error != null) ...[
            if (text.isNotEmpty) const SizedBox(height: 8),
            CustomText(error, fontSize: 14, color: context.color.error),
          ],
          if (!message.isStreaming.value) ...[
            const SizedBox(height: 4),
            _MessageActions(message: message, controller: controller),
          ],
        ],
      );
    });
  }
}

/// Width (and height) of a picture in a reply, and of the box standing in
/// for it while it is drawn.
const _imageSize = 240.0;

/// Soft rounded box shown under "Generating image" until the picture
/// lands, with a slow sheen moving across it.
class _ImagePlaceholder extends StatefulWidget {
  const _ImagePlaceholder();

  @override
  State<_ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<_ImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late final _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.color.inputFill;
    final highlight = context.color.sidebarSelected;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: _imageSize,
        height: _imageSize,
        child: AnimatedBuilder(
          animation: _sheen,
          builder: (context, _) {
            // The gradient slides from off the left edge to off the right.
            final shift = _sheen.value * 2 - 1;
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(shift - 1, -1),
                  end: Alignment(shift + 1, 1),
                  colors: [base, highlight, base],
                  stops: const [0.35, 0.5, 0.65],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A drawn picture in a reply: fixed square, rounded, fading in.
class _ReplyImage extends StatelessWidget {
  const _ReplyImage({required this.image});

  final GeneratedImage image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.memory(
        image.bytes,
        width: _imageSize,
        height: _imageSize,
        fit: BoxFit.cover,
        cacheWidth: (_imageSize * 3).round(),
        frameBuilder: (context, child, frame, wasSync) => AnimatedOpacity(
          opacity: wasSync || frame != null ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: child,
        ),
      ),
    );
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
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dim = context.color.textBody;
    final bright = context.color.textNatural;
    final text = CustomText(widget.text, fontSize: 15, color: bright);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        // A bright band travels along the words, left to right.
        final shift = _pulse.value * 2 - 1;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shift - 1, 0),
            end: Alignment(shift + 1, 0),
            colors: [dim, bright, dim],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(bounds),
          child: child,
        );
      },
      child: text,
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
  // The vote and the read-aloud mark are read here, in a build of their
  // own: the Obx around the message does not reach into a child widget,
  // so without this one the icons never changed when tapped.
  Widget build(BuildContext context) => Obx(() => _row(context));

  Widget _row(BuildContext context) {
    final liked = message.liked.value;
    final hasText = message.text.isNotEmpty;
    final speaking = controller.speakingMessage.value == message;
    final sources = message.sources;
    // The 36pt tap boxes pad the glyphs, so the row is pulled back to line
    // the first icon up with the text above it.
    return Transform.translate(
      offset: const Offset(-8, 0),
      child: Row(
        spacing: 2,
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
      ),
    );
  }
}

/// One round icon button under a reply. The whole 36pt square takes the
/// tap, so the small glyphs are still easy to hit, and the icon dips and
/// recolours as it is pressed.
class _ActionIcon extends StatefulWidget {
  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _down = false;

  void _setDown(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active
        ? context.color.buttonHighlight
        : context.color.textNatural;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => _setDown(true),
        onTapUp: (_) => _setDown(false),
        onTapCancel: () => _setDown(false),
        customBorder: const CircleBorder(),
        splashColor: color.withValues(alpha: 0.12),
        highlightColor: Colors.transparent,
        child: SizedBox(
          width: 36,
          height: 36,
          child: AnimatedScale(
            scale: _down ? 0.86 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween(begin: 0.7, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                widget.icon,
                key: ValueKey((widget.icon, widget.active)),
                size: 20,
                color: color,
              ),
            ),
          ),
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
