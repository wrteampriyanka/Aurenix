import 'package:flutter/material.dart';

/// How much of the user's history a project may draw on.
enum ProjectMemory { all, projectOnly }

/// A folder of chats, listed in the sidebar and on the projects screen.
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconColor,
    this.memory = ProjectMemory.all,
    this.chatCount = 0,
    this.instructions = '',
  });

  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;

  /// How much of the user's history the project may draw on.
  final ProjectMemory memory;
  final int chatCount;

  /// What the assistant should keep in mind inside this project.
  final String instructions;

  Project copyWith({
    String? name,
    String? instructions,
    IconData? icon,
    Color? iconColor,
    int? chatCount,
  }) => Project(
    id: id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    iconColor: iconColor ?? this.iconColor,
    memory: memory,
    chatCount: chatCount ?? this.chatCount,
    instructions: instructions ?? this.instructions,
  );
}
