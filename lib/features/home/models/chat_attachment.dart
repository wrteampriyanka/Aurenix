import 'dart:typed_data';

/// A photo or document sent along with a message.
class ChatAttachment {
  const ChatAttachment({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;

  bool get isImage => mimeType.startsWith('image/');
}
