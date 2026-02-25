import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TeamRole { admin, member, viewer }

class TeamMember extends Equatable {
  final String id;
  final String teamId;
  final String userId;
  final String displayName;
  final String email;
  final String? photoUrl;
  final TeamRole role;
  final DateTime joinedAt;

  const TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.role,
    required this.joinedAt,
  });

  bool get isAdmin => role == TeamRole.admin;
  bool get isMember => role == TeamRole.member;
  bool get isViewer => role == TeamRole.viewer;

  String get roleLabel {
    switch (role) {
      case TeamRole.admin:
        return 'Admin';
      case TeamRole.member:
        return 'Member';
      case TeamRole.viewer:
        return 'Viewer';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'userId': userId,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'role': role.name,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      role: TeamRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => TeamRole.member,
      ),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, teamId, userId, displayName, email, photoUrl, role, joinedAt];
}

class Team extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int memberCount;

  const Team({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    this.updatedAt,
    this.memberCount = 1,
  });

  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? ownerName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'memberCount': memberCount,
      };

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      memberCount: json['memberCount'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [id, name, description, ownerId, ownerName, createdAt, updatedAt, memberCount];
}

class TeamDocument extends Equatable {
  final String id;
  final String teamId;
  final String documentId;
  final String title;
  final String uploadedBy;
  final String uploadedByName;
  final DateTime uploadedAt;
  final int redFlagCount;
  final String status;

  const TeamDocument({
    required this.id,
    required this.teamId,
    required this.documentId,
    required this.title,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.uploadedAt,
    required this.redFlagCount,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'documentId': documentId,
        'title': title,
        'uploadedBy': uploadedBy,
        'uploadedByName': uploadedByName,
        'uploadedAt': uploadedAt.toIso8601String(),
        'redFlagCount': redFlagCount,
        'status': status,
      };

  factory TeamDocument.fromJson(Map<String, dynamic> json) {
    return TeamDocument(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      documentId: json['documentId'] as String,
      title: json['title'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadedByName: json['uploadedByName'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      redFlagCount: json['redFlagCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
    );
  }

  @override
  List<Object?> get props => [id, teamId, documentId, title, uploadedBy, uploadedByName, uploadedAt, redFlagCount, status];
}