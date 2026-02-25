import 'package:equatable/equatable.dart';

enum CloudProvider {
  googleDrive,
  dropbox,
  oneDrive,
}

class CloudAccount extends Equatable {
  final String id;
  final String userId;
  final CloudProvider provider;
  final String displayName;
  final String email;
  final String accessToken;
  final String? refreshToken;
  final DateTime connectedAt;
  final DateTime? expiresAt;
  final bool isActive;

  const CloudAccount({
    required this.id,
    required this.userId,
    required this.provider,
    required this.displayName,
    required this.email,
    required this.accessToken,
    this.refreshToken,
    required this.connectedAt,
    this.expiresAt,
    this.isActive = true,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get providerName {
    switch (provider) {
      case CloudProvider.googleDrive:
        return 'Google Drive';
      case CloudProvider.dropbox:
        return 'Dropbox';
      case CloudProvider.oneDrive:
        return 'OneDrive';
    }
  }

  String get providerIcon {
    switch (provider) {
      case CloudProvider.googleDrive:
        return 'assets/icons/google_drive.svg';
      case CloudProvider.dropbox:
        return 'assets/icons/dropbox.svg';
      case CloudProvider.oneDrive:
        return 'assets/icons/onedrive.svg';
    }
  }

  CloudAccount copyWith({
    String? id,
    String? userId,
    CloudProvider? provider,
    String? displayName,
    String? email,
    String? accessToken,
    String? refreshToken,
    DateTime? connectedAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return CloudAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      connectedAt: connectedAt ?? this.connectedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'provider': provider.name,
      'displayName': displayName,
      'email': email,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'connectedAt': connectedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory CloudAccount.fromJson(Map<String, dynamic> json) {
    return CloudAccount(
      id: json['id'] as String,
      userId: json['userId'] as String,
      provider: CloudProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => CloudProvider.googleDrive,
      ),
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        provider,
        displayName,
        email,
        accessToken,
        refreshToken,
        connectedAt,
        expiresAt,
        isActive,
      ];
}

class CloudFile extends Equatable {
  final String id;
  final String name;
  final String? path;
  final int? size;
  final String? mimeType;
  final DateTime? modifiedAt;
  final String? thumbnailUrl;
  final bool isFolder;

  const CloudFile({
    required this.id,
    required this.name,
    this.path,
    this.size,
    this.mimeType,
    this.modifiedAt,
    this.thumbnailUrl,
    this.isFolder = false,
  });

  String get fileSizeFormatted {
    if (size == null) return 'Unknown';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    if (size! < 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isPdf => mimeType == 'application/pdf';
  bool get isImage => mimeType?.startsWith('image/') ?? false;
  bool get isDocument => isPdf || 
      mimeType == 'application/msword' ||
      mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  @override
  List<Object?> get props => [id, name, path, size, mimeType, modifiedAt, thumbnailUrl, isFolder];
}
