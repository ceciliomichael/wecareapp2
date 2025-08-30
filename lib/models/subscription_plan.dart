class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationInDays;
  final String currency;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInDays,
    this.currency = 'PHP',
    this.isActive = true,
  });

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      durationInDays: map['duration_in_days'] ?? 0,
      currency: map['currency'] ?? 'PHP',
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_in_days': durationInDays,
      'currency': currency,
      'is_active': isActive,
    };
  }

  String get formattedPrice {
    return '₱${price.toStringAsFixed(0)}';
  }

  String get formattedDuration {
    if (durationInDays <= 30) {
      return '${(durationInDays / 7).round()} week${durationInDays > 7 ? 's' : ''}';
    } else {
      final months = (durationInDays / 30).round();
      return '$months month${months > 1 ? 's' : ''}';
    }
  }

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? durationInDays,
    String? currency,
    bool? isActive,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationInDays: durationInDays ?? this.durationInDays,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
    );
  }
}
