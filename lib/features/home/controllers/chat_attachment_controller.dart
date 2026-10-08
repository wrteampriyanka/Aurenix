import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aurenix/features/home/models/chat_attachment.dart';
import 'package:aurenix/commons/widgets/app_snackbar.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// The photo or document waiting to go with the next message.
///
/// Owned by [HomeController] rather than registered on its own, so it lives
/// and dies with the chat screen.
class ChatAttachmentController {
  /// Types Gemini reads inline, by file extension.
  static const _documentTypes = {
    'pdf': 'application/pdf',
    'txt': 'text/plain',
    'md': 'text/markdown',
    'csv': 'text/csv',
    'html': 'text/html',
    'json': 'application/json',
    'xml': 'text/xml',
    'rtf': 'text/rtf',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'heic': 'image/heic',
  };

  /// Requests with more than this inline are refused by the API.
  static const _maxBytes = 15 * 1024 * 1024;

  /// Photo or document to send with the next message.
  final value = Rxn<ChatAttachment>();

  /// Picks a document to send with the next message.
  Future<void> onAttachDocument() async {
    Get.back();
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: _documentTypes.keys.toList(),
      );
      if (file == null) return;
      final mimeType = _documentTypes[file.extension?.toLowerCase()];
      if (mimeType == null) {
        AppSnackbar.error(AppStrings.chatFileUnsupported.tr);
        return;
      }
      _set(file.name, await file.readAsBytes(), mimeType);
    } catch (_) {
      AppSnackbar.error(AppStrings.chatFileFailed.tr);
    }
  }

  /// Takes a photo to send with the next message.
  Future<void> onCaptureImage() async {
    Get.back();
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (photo == null) return;
      _set(photo.name, await photo.readAsBytes(), 'image/jpeg');
    } catch (_) {
      AppSnackbar.error(AppStrings.chatCameraUnavailable.tr);
    }
  }

  void _set(String name, Uint8List bytes, String mimeType) {
    if (bytes.length > _maxBytes) {
      AppSnackbar.error(AppStrings.chatFileTooLarge.tr);
      return;
    }
    value.value = ChatAttachment(name: name, bytes: bytes, mimeType: mimeType);
  }

  void clear() => value.value = null;

  void dispose() => value.close();
}
