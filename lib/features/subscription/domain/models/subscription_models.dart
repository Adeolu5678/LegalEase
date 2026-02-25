enum SubscriptionTier {
  free,
  premium,
}

enum SubscriptionStatus {
  inactive,
  active,
  expired,
  cancelled,
  inGracePeriod,
}

class SubscriptionPlan {
  final String id;
  final SubscriptionTier tier;
  final String name;
  final String description;
  final double price;
  final String currencyCode;
  final int durationMonths;
  final String productId;
  final bool isPopular;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.tier,
    required this.name,
    required this.description,
    required this.price,
    this.currencyCode = 'USD',
    required this.durationMonths,
    required this.productId,
    this.isPopular = false,
    this.features = const [],
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      durationMonths: json['durationMonths'] as int,
      productId: json['productId'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tier': tier.name,
      'name': name,
      'description': description,
      'price': price,
      'currencyCode': currencyCode,
      'durationMonths': durationMonths,
      'productId': productId,
      'isPopular': isPopular,
      'features': features,
    };
  }
}

class Subscription {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final String planId;
  final String productId;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? cancelledAt;
  final bool willRenew;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    required this.planId,
    required this.productId,
    required this.startDate,
    this.endDate,
    this.cancelledAt,
    this.willRenew = true,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.inGracePeriod;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.inactive,
      ),
      planId: json['planId'] as String,
      productId: json['productId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      willRenew: json['willRenew'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.name,
      'status': status.name,
      'planId': planId,
      'productId': productId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'willRenew': willRenew,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class SubscriptionOffering {
  final String identifier;
  final String description;
  final SubscriptionPlan? monthlyPlan;
  final SubscriptionPlan? yearlyPlan;

  const SubscriptionOffering({
    required this.identifier,
    required this.description,
    this.monthlyPlan,
    this.yearlyPlan,
  });

  factory SubscriptionOffering.fromJson(Map<String, dynamic> json) {
    return SubscriptionOffering(
      identifier: json['identifier'] as String,
      description: json['description'] as String,
      monthlyPlan: json['monthlyPlan'] != null
          ? SubscriptionPlan.fromJson(
              json['monthlyPlan'] as Map<String, dynamic>)
          : null,
      yearlyPlan: json['yearlyPlan'] != null
          ? SubscriptionPlan.fromJson(
              json['yearlyPlan'] as Map<String, dynamic>)
          : null,
    );
  }
}
