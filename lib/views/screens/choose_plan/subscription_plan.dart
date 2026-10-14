class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.planType,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingInterval,
    required this.trialDays,
    required this.features,
    required this.isBestValue,
  });

  final String id;
  final String name;
  final String planType;
  final String description;
  final double price;
  final String currency;
  final String billingInterval;
  final int trialDays;
  final List<String> features;
  final bool isBestValue;

  String get priceLabel => formatPlanMoney(price, currency);

  String get periodLabel => billingPeriodLabel(billingInterval);

  String? get badgeLabel {
    if (trialDays > 0) return '$trialDays-DAY FREE TRIAL';
    if (isBestValue) return 'BEST VALUE';
    return null;
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final tags = _stringList(json['tags']);
    return SubscriptionPlan(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      name: '${json['name'] ?? 'Pro'}',
      planType: '${json['planType'] ?? ''}',
      description: '${json['description'] ?? ''}'.trim(),
      price: _asDouble(json['price']),
      currency: '${json['currency'] ?? 'EUR'}'.toUpperCase(),
      billingInterval: '${json['billingInterval'] ?? json['interval'] ?? 'monthly'}',
      trialDays: _asInt(json['trialDays']),
      features: _featureLabels(json['features']),
      isBestValue: tags.any((tag) => tag.toLowerCase().contains('best')),
    );
  }

  static bool isListed(Map<String, dynamic> json) {
    if (json['isDeleted'] == true || json['deleted'] == true) return false;
    if (json['isActive'] == false || json['active'] == false) return false;
    final status = '${json['status'] ?? ''}'.toLowerCase();
    return status != 'inactive' && status != 'deleted' && status != 'disabled';
  }
}

class PromoQuote {
  const PromoQuote({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.originalPrice,
    required this.finalPrice,
    required this.trialDays,
    required this.savings,
    required this.currency,
  });

  final String code;
  final String discountType;
  final double discountValue;
  final double originalPrice;
  final double finalPrice;
  final int trialDays;
  final double savings;
  final String currency;

  bool get changesPrice =>
      (originalPrice - finalPrice).abs() >= 0.005 && savings > 0;

  String get summary {
    switch (discountType) {
      case 'percentage':
        final value = discountValue == discountValue.roundToDouble()
            ? discountValue.toStringAsFixed(0)
            : discountValue.toStringAsFixed(2);
        return '$value% off';
      case 'fixed':
        return '${formatPlanMoney(discountValue, currency)} off';
      case 'free_trial_days':
        final days = discountValue.round();
        return days == 1 ? '+1 free day' : '+$days free days';
      default:
        return 'Promo applied';
    }
  }

  String? get savingsLabel {
    if (savings <= 0) return null;
    return 'You save ${formatPlanMoney(savings, currency)}';
  }

  factory PromoQuote.fromJson(
    Map<String, dynamic> json, {
    required String fallbackCode,
    required String currency,
  }) {
    final source = json['promo'] is Map
        ? Map<String, dynamic>.from(json['promo'] as Map)
        : json;
    return PromoQuote(
      code: '${source['code'] ?? json['code'] ?? fallbackCode}'.toUpperCase(),
      discountType: '${source['discountType'] ?? json['discountType'] ?? ''}'
          .toLowerCase(),
      discountValue: _asDouble(source['discountValue'] ?? json['discountValue']),
      originalPrice: _asDouble(source['originalPrice'] ?? json['originalPrice']),
      finalPrice: _asDouble(
        source['finalPrice'] ?? json['finalPrice'] ?? source['price'],
      ),
      trialDays: _asInt(source['trialDays'] ?? json['trialDays']),
      savings: _asDouble(source['savings'] ?? json['savings']),
      currency: '${source['currency'] ?? json['currency'] ?? currency}'
          .toUpperCase(),
    );
  }
}

List<SubscriptionPlan> parsePlans(dynamic data) {
  final plans = _unwrapPlanMaps(data)
      .where(SubscriptionPlan.isListed)
      .map(SubscriptionPlan.fromJson)
      .where((plan) => plan.id.isNotEmpty)
      .toList();
  plans.sort((a, b) {
    if (a.isBestValue != b.isBestValue) return a.isBestValue ? -1 : 1;
    return a.price.compareTo(b.price);
  });
  return plans;
}

List<Map<String, dynamic>> _unwrapPlanMaps(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    for (final key in ['plans', 'result', 'results', 'docs', 'items', 'data']) {
      final value = map[key];
      if (value is List) return _unwrapPlanMaps(value);
    }
    if (map.containsKey('_id') || map.containsKey('id') || map.containsKey('price')) {
      return [map];
    }
  }
  return const [];
}

List<String> _featureLabels(dynamic raw) {
  if (raw is! List) return const [];
  final labels = <String>[];
  for (final item in raw) {
    if (item is String && item.trim().isNotEmpty) {
      labels.add(item.trim());
      continue;
    }
    if (item is! Map) continue;
    if (item['included'] == false) continue;
    final label = '${item['label'] ?? item['name'] ?? item['title'] ?? ''}'.trim();
    if (label.isNotEmpty) labels.add(label);
  }
  return labels;
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.map((item) => '$item'.trim()).where((item) => item.isNotEmpty).toList();
}

double _asDouble(dynamic raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse('$raw') ?? 0;
}

int _asInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  return int.tryParse('$raw') ?? 0;
}

String formatPlanMoney(num amount, String currency) {
  final formatted = amount.toStringAsFixed(2);
  switch (currency.toUpperCase()) {
    case 'USD':
      return '\$$formatted';
    case 'GBP':
      return '£$formatted';
    case 'EUR':
      return '€$formatted';
    default:
      return currency.isEmpty ? '€$formatted' : '$currency $formatted';
  }
}

String billingPeriodLabel(String interval) {
  switch (interval.toLowerCase()) {
    case 'monthly':
    case 'month':
      return '/month';
    case 'yearly':
    case 'annual':
    case 'annually':
    case 'year':
      return '/year';
    case 'weekly':
    case 'week':
      return '/week';
    default:
      return interval.trim().isEmpty ? '' : '/$interval';
  }
}
