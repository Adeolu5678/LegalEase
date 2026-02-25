class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final bool isPremium;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
    this.isPremium = false,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
