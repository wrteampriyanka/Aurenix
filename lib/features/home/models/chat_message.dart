import 'package:get/get.dart';

import 'package:aurenix/core/services/demo_chat_service.dart';
import 'package:aurenix/features/home/models/chat_attachment.dart';

/// A message in the current conversation.
class ChatMessage {
  ChatMessage.user(String text, {this.attachment})
    : isUser = true,
      text = text.obs,
      isStreaming = false.obs;

  ChatMessage.ai()
    : isUser = false,
      attachment = null,
      text = ''.obs,
      isStreaming = true.obs;

  /// A message read back from the chat history: it is already complete, so
  /// it is not waiting on anything.
  ChatMessage.history({required this.isUser, required String text})
    : attachment = null,
      text = text.obs,
      isStreaming = false.obs;

  final bool isUser;

  /// Photo or document the user sent with the message.
  final ChatAttachment? attachment;

  /// Pictures drawn for a "Generate image" reply.
  final images = <GeneratedImage>[].obs;

  /// Grows while the reply streams in.
  final RxString text;
  final RxBool isStreaming;
  final error = RxnString();

  /// null: no vote, true: liked, false: disliked.
  final liked = RxnBool();

  /// Web pages the reply was grounded on (Research only).
  final sources = <ChatSource>[].obs;

  /// Set by "Select Texts" in the long press menu: the bubble then hands
  /// its words to the system selection handles.
  final selectable = false.obs;
}
