import 'package:flutter/material.dart';

/// Who can open the project.
enum ProjectAccess { onlyInvited, anyoneWithLink }

/// What a collaborator may do. The owner's role cannot be changed.
enum CollaboratorRole { owner, canEdit, viewOnly }

/// Someone the project is shared with.
class Collaborator {
  const Collaborator({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.color,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String initials;
  final Color color;
  final CollaboratorRole role;

  Collaborator copyWith({CollaboratorRole? role}) => Collaborator(
    id: id,
    name: name,
    email: email,
    initials: initials,
    color: color,
    role: role ?? this.role,
  );
}
