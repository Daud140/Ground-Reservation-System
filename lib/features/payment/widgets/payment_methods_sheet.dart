import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../models/payment_method_model.dart';
import '../providers/payment_provider.dart';

/// Shows the payment method management & selection sheet
Future<PaymentMethodModel?> showPaymentMethodsSheet(BuildContext context) {
  return showModalBottomSheet<PaymentMethodModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const PaymentMethodsSheet(),
  );
}

class PaymentMethodsSheet extends ConsumerStatefulWidget {
  const PaymentMethodsSheet({super.key});

  @override
  ConsumerState<PaymentMethodsSheet> createState() =>
      _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends ConsumerState<PaymentMethodsSheet> {
  bool _isAdding = false;
  PaymentType _newType = PaymentType.card;
  final _cardNumberController = TextEditingController();
  final _cardExpController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpController.dispose();
    _cardCvvController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  IconData _getIconForType(PaymentType type) {
    switch (type) {
      case PaymentType.card:
        return Icons.credit_card_rounded;
      case PaymentType.easypaisa:
        return Icons.phone_android_rounded;
      case PaymentType.jazzcash:
        return Icons.account_balance_wallet_rounded;
      case PaymentType.cash:
        return Icons.payments_outlined;
    }
  }

  Color _getColorForType(PaymentType type) {
    switch (type) {
      case PaymentType.card:
        return const Color(0xFF2563EB); // Blue
      case PaymentType.easypaisa:
        return const Color(0xFF10B981); // Emerald
      case PaymentType.jazzcash:
        return const Color(0xFFDC2626); // Red
      case PaymentType.cash:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  void _saveNewMethod() {
    if (!_formKey.currentState!.validate()) return;

    PaymentMethodModel newMethod;
    if (_newType == PaymentType.card) {
      final rawNum = _cardNumberController.text.replaceAll(' ', '');
      final last4 = rawNum.length >= 4
          ? rawNum.substring(rawNum.length - 4)
          : '0000';
      newMethod = PaymentMethodModel(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Debit Card •••• $last4',
        subtitle:
            '${_nameController.text.trim()} (Exp ${_cardExpController.text.trim()})',
        type: PaymentType.card,
        accountHolder: _nameController.text.trim(),
        lastFour: last4,
      );
    } else {
      final title = _newType == PaymentType.easypaisa
          ? 'EasyPaisa Wallet'
          : 'JazzCash Wallet';
      final phone = _phoneController.text.trim();
      final last4 = phone.length >= 4
          ? phone.substring(phone.length - 4)
          : '0000';
      newMethod = PaymentMethodModel(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subtitle: '$phone (${_nameController.text.trim()})',
        type: _newType,
        accountHolder: _nameController.text.trim(),
        lastFour: last4,
      );
    }

    ref.read(paymentMethodsProvider.notifier).addMethod(newMethod);
    ref.read(selectedPaymentMethodProvider.notifier).selectMethod(newMethod);

    setState(() => _isAdding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newMethod.title} added and selected!'),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methods = ref.watch(paymentMethodsProvider);
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBg = isDark
        ? const Color(0xFF0F172A)
        : AppColors.surfaceSecondaryLight;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : AppColors.borderLight;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isAdding ? 'Add Payment Method' : 'Payment Methods',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isAdding ? Icons.arrow_back_rounded : Icons.close_rounded,
                    color: textColor,
                  ),
                  onPressed: () {
                    if (_isAdding) {
                      setState(() => _isAdding = false);
                    } else {
                      Navigator.pop(context, selectedMethod);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (!_isAdding) ...[
              // List of Existing Payment Methods
              ...methods.map((method) {
                final isSelected = method.id == selectedMethod.id;
                final typeColor = _getColorForType(method.type);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? AppColors.emerald.withValues(alpha: 0.15)
                              : const Color(0xFFECFDF5))
                        : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.emerald : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      ref
                          .read(selectedPaymentMethodProvider.notifier)
                          .selectMethod(method);
                      Navigator.pop(context, method);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Type Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForType(method.type),
                              color: typeColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        method.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.emerald,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'ACTIVE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  method.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Selection radio & Delete action
                          if (methods.length > 1 && !method.isDefault)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              tooltip: 'Remove',
                              onPressed: () {
                                ref
                                    .read(paymentMethodsProvider.notifier)
                                    .removeMethod(method.id);
                              },
                            ),

                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.emerald
                                    : Colors.grey.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.emerald,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Add New Method Button
              OutlinedButton.icon(
                onPressed: () => setState(() => _isAdding = true),
                icon: const Icon(Icons.add_rounded, color: AppColors.emerald),
                label: const Text(
                  'Add New Payment Method',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.emerald, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ] else ...[
              // Form to Add New Method
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type selector chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Credit/Debit Card'),
                            selected: _newType == PaymentType.card,
                            selectedColor: AppColors.emerald,
                            labelStyle: TextStyle(
                              color: _newType == PaymentType.card
                                  ? Colors.white
                                  : textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) =>
                                setState(() => _newType = PaymentType.card),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('EasyPaisa'),
                            selected: _newType == PaymentType.easypaisa,
                            selectedColor: AppColors.emerald,
                            labelStyle: TextStyle(
                              color: _newType == PaymentType.easypaisa
                                  ? Colors.white
                                  : textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => setState(
                              () => _newType = PaymentType.easypaisa,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('JazzCash'),
                            selected: _newType == PaymentType.jazzcash,
                            selectedColor: AppColors.emerald,
                            labelStyle: TextStyle(
                              color: _newType == PaymentType.jazzcash
                                  ? Colors.white
                                  : textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) =>
                                setState(() => _newType = PaymentType.jazzcash),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account holder name
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Account / Cardholder Name',
                        hintText: 'e.g. Hamza Malik',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter account holder name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    if (_newType == PaymentType.card) ...[
                      // Card number
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: '16-digit card number',
                          counterText: '',
                          prefixIcon: const Icon(Icons.credit_card_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null ||
                              val.replaceAll(' ', '').length < 16) {
                            return 'Enter a valid 16-digit card number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cardExpController,
                              keyboardType: TextInputType.datetime,
                              maxLength: 5,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Exp Date',
                                hintText: 'MM/YY',
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || !val.contains('/')) {
                                  return 'Use MM/YY';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cardCvvController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              obscureText: true,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.length < 3) {
                                  return 'Enter CVV';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Mobile wallet number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Mobile Account Number',
                          hintText: '03001234567',
                          counterText: '',
                          prefixIcon: const Icon(Icons.phone_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 11) {
                            return 'Enter valid 11-digit mobile number';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveNewMethod,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save & Select Method',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
