import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../models/payment_method_model.dart';

/// Seed list of demo payment methods
final List<PaymentMethodModel> _defaultPaymentMethods = [
  const PaymentMethodModel(
    id: 'pay_jazzcash',
    title: 'JazzCash Wallet',
    subtitle: '0300 1234567 (Ali Raza)',
    type: PaymentType.jazzcash,
    isDefault: true,
    accountHolder: 'Ali Raza',
    lastFour: '4567',
  ),
  const PaymentMethodModel(
    id: 'pay_easypaisa',
    title: 'EasyPaisa Account',
    subtitle: '0333 5123456 (Hamza Malik)',
    type: PaymentType.easypaisa,
    isDefault: false,
    accountHolder: 'Hamza Malik',
    lastFour: '3456',
  ),
  const PaymentMethodModel(
    id: 'pay_hbl_card',
    title: 'HBL Visa Platinum',
    subtitle: 'Ending in •••• 4821 (Exp 09/27)',
    type: PaymentType.card,
    isDefault: false,
    accountHolder: 'Hamza Malik',
    lastFour: '4821',
  ),
  const PaymentMethodModel(
    id: 'pay_cash',
    title: 'Cash on Arrival',
    subtitle: 'Pay directly at the pitch reception desk',
    type: PaymentType.cash,
    isDefault: false,
    accountHolder: 'Cash',
  ),
];

class PaymentMethodsNotifier extends Notifier<List<PaymentMethodModel>> {
  @override
  List<PaymentMethodModel> build() {
    final rawList = LocalStorageService.instance.getRawPaymentMethods();
    if (rawList.isNotEmpty) {
      return rawList.map((m) => PaymentMethodModel.fromJson(m)).toList();
    }

    _persist(_defaultPaymentMethods);
    return _defaultPaymentMethods;
  }

  void _persist(List<PaymentMethodModel> methods) {
    LocalStorageService.instance.saveRawPaymentMethods(
      methods.map((m) => m.toJson()).toList(),
    );
  }

  void addMethod(PaymentMethodModel method) {
    final updated = [...state, method];
    state = updated;
    _persist(updated);
  }

  void removeMethod(String id) {
    if (state.length <= 1) return; // Always keep at least 1 payment method
    final updated = state.where((m) => m.id != id).toList();
    state = updated;
    _persist(updated);
  }
}

final paymentMethodsProvider =
    NotifierProvider<PaymentMethodsNotifier, List<PaymentMethodModel>>(
      PaymentMethodsNotifier.new,
    );

class SelectedPaymentMethodNotifier extends Notifier<PaymentMethodModel> {
  @override
  PaymentMethodModel build() {
    final allMethods = ref.watch(paymentMethodsProvider);
    final savedId = LocalStorageService.instance.getSelectedPaymentMethodId();

    if (savedId != null) {
      final found = allMethods.where((m) => m.id == savedId);
      if (found.isNotEmpty) return found.first;
    }

    // Default to the first method or default flag
    final defaultMethod = allMethods.firstWhere(
      (m) => m.isDefault,
      orElse: () => allMethods.isNotEmpty
          ? allMethods.first
          : _defaultPaymentMethods.first,
    );
    return defaultMethod;
  }

  void selectMethod(PaymentMethodModel method) {
    state = method;
    LocalStorageService.instance.setSelectedPaymentMethodId(method.id);
  }
}

final selectedPaymentMethodProvider =
    NotifierProvider<SelectedPaymentMethodNotifier, PaymentMethodModel>(
      SelectedPaymentMethodNotifier.new,
    );
