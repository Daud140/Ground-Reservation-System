import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/storage/hive_boxes.dart';
import '../../features/customer/models/ground_model.dart';

/// Abstract contract for Ground management operations
abstract class GroundRepository {
  Future<List<GroundModel>> getAllGrounds();
  Future<List<GroundModel>> getGroundsByOwner(String ownerId);
  Future<GroundModel?> getGroundById(String id);
  Future<void> addGround(GroundModel ground);
  Future<void> updateGround(GroundModel ground);
  Future<void> deleteGround(String id);
  Future<List<GroundModel>> searchGrounds({
    String? query,
    SportType? sportType,
    double? maxPrice,
    double? minRating,
  });
}

/// Offline Hive-persisted Mock implementation for Mid-Term
class MockGroundRepository implements GroundRepository {
  @override
  Future<List<GroundModel>> getAllGrounds() async {
    final groundsBox = Hive.box(HiveBoxes.groundsBox);
    final List<GroundModel> list = [];

    for (final key in groundsBox.keys) {
      final raw = groundsBox.get(key);
      if (raw != null) {
        list.add(GroundModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String))));
      }
    }
    return list;
  }

  @override
  Future<List<GroundModel>> getGroundsByOwner(String ownerId) async {
    final all = await getAllGrounds();
    return all.where((g) => g.ownerId == ownerId).toList();
  }

  @override
  Future<GroundModel?> getGroundById(String id) async {
    final groundsBox = Hive.box(HiveBoxes.groundsBox);
    final raw = groundsBox.get(id);
    if (raw == null) return null;
    return GroundModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String)));
  }

  @override
  Future<void> addGround(GroundModel ground) async {
    final groundsBox = Hive.box(HiveBoxes.groundsBox);
    await groundsBox.put(ground.id, jsonEncode(ground.toJson()));
  }

  @override
  Future<void> updateGround(GroundModel ground) async {
    final groundsBox = Hive.box(HiveBoxes.groundsBox);
    await groundsBox.put(ground.id, jsonEncode(ground.toJson()));
  }

  @override
  Future<void> deleteGround(String id) async {
    final groundsBox = Hive.box(HiveBoxes.groundsBox);
    await groundsBox.delete(id);
  }

  @override
  Future<List<GroundModel>> searchGrounds({
    String? query,
    SportType? sportType,
    double? maxPrice,
    double? minRating,
  }) async {
    final all = await getAllGrounds();
    return all.where((ground) {
      // 1. Text Query (name or location)
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final matchesName = ground.name.toLowerCase().contains(q);
        final matchesLoc = ground.location.toLowerCase().contains(q);
        if (!matchesName && !matchesLoc) return false;
      }

      // 2. Sport Type
      if (sportType != null && ground.sportType != sportType) {
        return false;
      }

      // 3. Max Price (PKR)
      if (maxPrice != null && ground.pricePerHour > maxPrice) {
        return false;
      }

      // 4. Min Rating
      if (minRating != null && ground.rating < minRating) {
        return false;
      }

      return true;
    }).toList();
  }
}
