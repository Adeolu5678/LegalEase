import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ShareExpiration {
  oneHour,
  twentyFourHours,
  sevenDays,
  thirtyDays,
  never,
}

class SharedAnalysis extends Equatable {
  final String id;
  final String documentId;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String documentTitle;
  final String shareCode;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? password;
  final int viewCount;
  final bool isPasswordProtected;
  final List<String>? allowedEmails;

  const SharedAnalysis({
    required this.id,
    required this.documentId,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.documentTitle,
    required this.shareCode,
    required this.createdAt,
    this.expiresAt,
    this.password,
    this.viewCount = 0,
    this.isPasswordProtected = false,
    this.allowedEmails,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get hasExpiration => expiresAt != null;

  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  SharedAnalysis copyWith({
    String? id,
    String? documentId,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
    String? documentTitle,
    String? shareCode,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? password,
    int? viewCount,
    bool? isPasswordProtected,
    List<String>? allowedEmails,
  }) {
    return SharedAnalysis(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      documentTitle: documentTitle ?? this.documentTitle,
      shareCode: shareCode ?? this.shareCode,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      password: password ?? this.password,
      viewCount: viewCount ?? this.viewCount,
      isPasswordProtected: isPasswordProtected ?? this.isPasswordProtected,
      allowedEmails: allowedEmails ?? this.allowedEmails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'documentTitle': documentTitle,
      'shareCode': shareCode,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'password': password,
      'viewCount': viewCount,
      'isPasswordProtected': isPasswordProtected,
      'allowedEmails': allowedEmails,
    };
  }

  factory SharedAnalysis.fromJson(Map<String, dynamic> json) {
    return SharedAnalysis(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      ownerEmail: json['ownerEmail'] as String,
      documentTitle: json['documentTitle'] as String,
      shareCode: json['shareCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      password: json['password'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      isPasswordProtected: json['isPasswordProtected'] as bool? ?? false,
      allowedEmails: (json['allowedEmails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        ownerId,
        ownerName,
        ownerEmail,
        documentTitle,
        shareCode,
        createdAt,
        expiresAt,
        password,
        viewCount,
        isPasswordProtected,
        allowedEmails,
      ];
}
