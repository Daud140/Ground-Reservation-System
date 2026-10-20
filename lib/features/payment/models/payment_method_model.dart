enum PaymentType {
  card,
  easypaisa,
  jazzcash,
  cash;

  String get displayName {
    switch (this) {
      case PaymentType.card:
        return 'Debit / Credit Card';
      case PaymentType.easypaisa:
        return 'EasyPaisa Mobile Account';
      case PaymentType.jazzcash:
        return 'JazzCash Wallet';
      case PaymentType.cash:
        return 'Cash on Arrival';
    }
  }
}

class PaymentMethodModel {
  final String id;
  final String title;
  final String subtitle;
  final PaymentType type;
  final bool isDefault;
  final String? lastFour;
  final String? accountHolder;

  const PaymentMethodModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isDefault = false,
    this.lastFour,
    this.accountHolder,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    PaymentType? type,
    bool? isDefault,
    String? lastFour,
    String? accountHolder,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      lastFour: lastFour ?? this.lastFour,
      accountHolder: accountHolder ?? this.accountHolder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'isDefault': isDefault,
      'lastFour': lastFour,
      'accountHolder': accountHolder,
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      type: PaymentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PaymentType.cash,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      lastFour: json['lastFour'] as String?,
      accountHolder: json['accountHolder'] as String?,
    );
  }
}
