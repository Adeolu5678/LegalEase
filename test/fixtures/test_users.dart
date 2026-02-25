const String testUserEmail = 'test@example.com';
const String testUserPassword = 'Test123456!';
const String testUserId = 'test-user-123';
const String testUserDisplayName = 'Test User';
const String premiumTestUserId = 'premium-user-456';

class TestUserData {
  final String id;
  final String email;
  final String displayName;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? profileImageUrl;

  const TestUserData({
    required this.id,
    required this.email,
    required this.displayName,
    this.isPremium = false,
    required this.createdAt,
    this.lastLoginAt,
    this.profileImageUrl,
  });

  static TestUserData get standard => TestUserData(
        id: testUserId,
        email: testUserEmail,
        displayName: testUserDisplayName,
        isPremium: false,
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 15),
      );

  static TestUserData get premium => TestUserData(
        id: premiumTestUserId,
        email: 'premium@example.com',
        displayName: 'Premium User',
        isPremium: true,
        createdAt: DateTime(2024, 1, 15),
        lastLoginAt: DateTime(2024, 6, 20),
      );

  static TestUserData get newuser => TestUserData(
        id: 'new-user-789',
        email: 'newuser@example.com',
        displayName: 'New User',
        isPremium: false,
        createdAt: DateTime(2024, 6, 1),
        lastLoginAt: null,
      );

  static TestUserData get withProfileImage => TestUserData(
        id: testUserId,
        email: testUserEmail,
        displayName: testUserDisplayName,
        isPremium: false,
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 15),
        profileImageUrl: 'https://example.com/profile/test-user.png',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'isPremium': isPremium,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'profileImageUrl': profileImageUrl,
      };

  factory TestUserData.fromJson(Map<String, dynamic> json) => TestUserData(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        isPremium: json['isPremium'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastLoginAt: json['lastLoginAt'] != null
            ? DateTime.parse(json['lastLoginAt'] as String)
            : null,
        profileImageUrl: json['profileImageUrl'] as String?,
      );
}