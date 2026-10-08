import 'package:flutter/material.dart';

/// A past conversation listed under "Chats".
class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.title,
    this.authorInitials,
    this.authorColor,
  });

  final String id;
  final String title;

  /// Initials of whoever started the chat, shown on the project screen;
  /// null for chats that are not in a shared project.
  final String? authorInitials;
  final Color? authorColor;

  ChatSummary copyWith({String? title}) => ChatSummary(
    id: id,
    title: title ?? this.title,
    authorInitials: authorInitials,
    authorColor: authorColor,
  );
}
