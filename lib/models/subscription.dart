enum SubscriptionCycle {
  monthly,
  yearly,
}

enum SubscriptionCategory {
  video,
  music,
  cloud,
  productivity,
  other,
}

class Subscription {
  final String id;
  final String name;
  final double amount;
  final SubscriptionCycle cycle;
  final int billingDay;
  final SubscriptionCategory category;
  final String? memo;
  final bool pinned;
  final String createdAt;
  final bool reminderEnabled;
  final int reminderDaysBefore;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.billingDay,
    required this.category,
    this.memo,
    this.pinned = false,
    required this.createdAt,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'cycle': cycle.name,
      'billingDay': billingDay,
      'category': category.name,
      'memo': memo,
      'pinned': pinned,
      'createdAt': createdAt,
      'reminderEnabled': reminderEnabled,
      'reminderDaysBefore': reminderDaysBefore,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      cycle: SubscriptionCycle.values.firstWhere(
        (e) => e.name == json['cycle'],
      ),
      billingDay: json['billingDay'] as int,
      category: SubscriptionCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      memo: json['memo'] as String?,
      pinned: json['pinned'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 3,
    );
  }

  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    SubscriptionCycle? cycle,
    int? billingDay,
    SubscriptionCategory? category,
    String? memo,
    bool? pinned,
    String? createdAt,
    bool? reminderEnabled,
    int? reminderDaysBefore,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      cycle: cycle ?? this.cycle,
      billingDay: billingDay ?? this.billingDay,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }
}