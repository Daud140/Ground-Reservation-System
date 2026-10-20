import 'dart:convert';

import 'package:hive/hive.dart';

import '../../core/storage/hive_boxes.dart';
import '../../features/customer/models/review_model.dart';

/// Abstract contract for Ground Reviews
abstract class ReviewRepository {
  Future<List<ReviewModel>> getReviewsForGround(String groundId);
  Future<void> addReview(ReviewModel review);
}

/// Offline Hive-persisted Mock implementation for Mid-Term
class MockReviewRepository implements ReviewRepository {
  @override
  Future<List<ReviewModel>> getReviewsForGround(String groundId) async {
    final reviewsBox = Hive.box(HiveBoxes.reviewsBox);
    final List<ReviewModel> list = [];

    for (final key in reviewsBox.keys) {
      final raw = reviewsBox.get(key);
      if (raw != null) {
        final review = ReviewModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw as String)),
        );
        if (review.groundId == groundId) {
          list.add(review);
        }
      }
    }

    // Sort by newest first
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    final reviewsBox = Hive.box(HiveBoxes.reviewsBox);
    await reviewsBox.put(review.id, jsonEncode(review.toJson()));
  }
}
