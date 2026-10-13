import 'package:flutter/material.dart';
import '../../customer/models/ground_model.dart';
import '../../../core/constants/app_colors.dart';

enum BookingStatus {
  pending,
  confirmed,
  rejected,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending Approval';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (this) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.emerald;
      case BookingStatus.rejected:
        return AppColors.error;
      case BookingStatus.completed:
        return AppColors.info;
      case BookingStatus.cancelled:
        return AppColors.textMutedLight;
    }
  }

  Color get containerColor {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFFEF3C7);
      case BookingStatus.confirmed:
        return AppColors.emeraldContainer;
      case BookingStatus.rejected:
        return const Color(0xFFFEE2E2);
      case BookingStatus.completed:
        return const Color(0xFFDBEAFE);
      case BookingStatus.cancelled:
        return const Color(0xFFF1F5F9);
    }
  }
}

/// Time slot representation for booking calendar
class TimeSlotModel {
  final String slotString; // e.g., "18:00 - 19:00"
  final String startTime;  // "18:00"
  final String endTime;    // "19:00"
  final bool isAvailable;
  final bool isBooked;
  final bool isBlocked;

  const TimeSlotModel({
    required this.slotString,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.isBooked = false,
    this.isBlocked = false,
  });
}

/// Reservation record stored in Hive
class BookingModel {
  final String id;
  final String groundId;
  final String groundName;
  final String groundLocation;
  final SportType sportType;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String ownerId;
  final String date; // e.g. "2026-10-15"
  final String timeSlot; // e.g. "18:00 - 19:00"
  final double totalPrice;
  final BookingStatus status;
  final String paymentMethod;
  final String qrCodeData;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.groundId,
    required this.groundName,
    required this.groundLocation,
    required this.sportType,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.ownerId,
    required this.date,
    required this.timeSlot,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.qrCodeData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groundId': groundId,
      'groundName': groundName,
      'groundLocation': groundLocation,
      'sportType': sportType.name,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'ownerId': ownerId,
      'date': date,
      'timeSlot': timeSlot,
      'totalPrice': totalPrice,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'qrCodeData': qrCodeData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      groundId: json['groundId'] as String,
      groundName: json['groundName'] as String,
      groundLocation: json['groundLocation'] as String? ?? '',
      sportType: SportType.values.firstWhere(
        (s) => s.name == json['sportType'],
        orElse: () => SportType.futsal,
      ),
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String? ?? '+92 300 1234567',
      ownerId: json['ownerId'] as String,
      date: json['date'] as String,
      timeSlot: json['timeSlot'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] as String? ?? 'EasyPaisa',
      qrCodeData: json['qrCodeData'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  BookingModel copyWith({
    String? id,
    String? groundId,
    String? groundName,
    String? groundLocation,
    SportType? sportType,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? ownerId,
    String? date,
    String? timeSlot,
    double? totalPrice,
    BookingStatus? status,
    String? paymentMethod,
    String? qrCodeData,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      groundId: groundId ?? this.groundId,
      groundName: groundName ?? this.groundName,
      groundLocation: groundLocation ?? this.groundLocation,
      sportType: sportType ?? this.sportType,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      ownerId: ownerId ?? this.ownerId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
