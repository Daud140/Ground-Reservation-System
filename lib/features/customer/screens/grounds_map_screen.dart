import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../models/ground_model.dart';

/// Full-featured interactive Grounds Map screen
/// Demonstrates markers, marker tap details card, permission flow,
/// distance calculation, and error resilience without crashing.
class GroundsMapScreen extends ConsumerStatefulWidget {
  const GroundsMapScreen({super.key});

  @override
  ConsumerState<GroundsMapScreen> createState() => _GroundsMapScreenState();
}

class _GroundsMapScreenState extends ConsumerState<GroundsMapScreen> {
  GroundModel? _selectedGround;
  bool _hasLocationPermission = false;
  Offset _userLocationOffset = const Offset(
    0.48,
    0.42,
  ); // Relative (x, y) on map canvas
  final Map<String, double> _groundDistances = {};

  // Mock geographic positions normalized (0.0 to 1.0) on the map canvas
  final Map<String, Offset> _markerPositions = {
    'ground_1': const Offset(0.35, 0.28), // F-7 Markaz
    'ground_2': const Offset(0.20, 0.22), // E-11 Margalla
    'ground_3': const Offset(0.30, 0.45), // F-10 Padel
    'ground_4': const Offset(0.72, 0.70), // Ayub Park
    'ground_5': const Offset(0.45, 0.35), // Centaurus Blue Area
    'ground_6': const Offset(0.55, 0.50), // Rawal Lake
    'ground_7': const Offset(0.65, 0.58), // Chaklala Turf
    'ground_8': const Offset(0.82, 0.80), // Bahria Town
  };

  @override
  void initState() {
    super.initState();
    _computeDistances();
  }

  void _computeDistances() {
    _markerPositions.forEach((id, pos) {
      final dx = (pos.dx - _userLocationOffset.dx) * 20; // Simulated km scale
      final dy = (pos.dy - _userLocationOffset.dy) * 20;
      final dist = sqrt(dx * dx + dy * dy);
      _groundDistances[id] = (dist * 10).round() / 10.0;
    });
  }

  Future<void> _handleLocationPermissionRequest() async {
    // Show standard location permission dialog
    final granted = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_on_rounded, color: AppColors.emerald, size: 24),
            SizedBox(width: 8),
            Text(
              'Location Permission',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        content: const Text(
          'Allow GroundZero to access your device location to calculate exact distances and show nearby sports turfs in Islamabad & Rawalpindi?',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Don\'t Allow',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'While Using the App',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (granted == true) {
      setState(() {
        _hasLocationPermission = true;
        _userLocationOffset = const Offset(
          0.42,
          0.38,
        ); // Acquired coordinates near F-7
        _computeDistances();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'GPS Location acquired: Sector F-7 Markaz, Islamabad. Distances updated!',
          ),
          backgroundColor: AppColors.emerald,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _hasLocationPermission = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission denied. Showing default Islamabad city center distances without crashing.',
          ),
          backgroundColor: AppColors.navy,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<List<GroundModel>>(
        future: groundRepo.getAllGrounds(),
        builder: (context, snapshot) {
          final grounds = snapshot.data ?? [];
          final activeSelected =
              _selectedGround ?? (grounds.isNotEmpty ? grounds.first : null);

          return Stack(
            children: [
              // 1. Google Maps Styled Interactive Canvas
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;

                    return Stack(
                      children: [
                        // Custom Painter Map Background
                        CustomPaint(
                          size: Size(width, height),
                          painter: _FullMapCanvasPainter(),
                        ),

                        // User GPS Location Pin (Pulsing Blue Ring)
                        Positioned(
                          left: _userLocationOffset.dx * width - 16,
                          top: _userLocationOffset.dy * height - 16,
                          child: _buildUserLocationMarker(),
                        ),

                        // Ground Markers on Map
                        for (final ground in grounds) ...[
                          Builder(
                            builder: (ctx) {
                              final pos =
                                  _markerPositions[ground.id] ??
                                  const Offset(0.5, 0.5);
                              final isSelected =
                                  activeSelected?.id == ground.id;
                              final distance =
                                  _groundDistances[ground.id] ?? 2.5;

                              return Positioned(
                                left: pos.dx * width - (isSelected ? 36 : 28),
                                top: pos.dy * height - (isSelected ? 52 : 44),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedGround = ground;
                                    });
                                  },
                                  child: _buildGroundMarker(
                                    ground,
                                    isSelected,
                                    distance,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),

              // 2. Top Header Bar (Back button, Search title, GPS status)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.navy,
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.map_rounded,
                                color: AppColors.emerald,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Islamabad & Rawalpindi Map',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.navy,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${grounds.length} Turfs',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.emeraldDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Floating Action: My Current Location button
              Positioned(
                right: 16,
                bottom: activeSelected != null ? 180 : 32,
                child: FloatingActionButton(
                  heroTag: 'myLocationBtn',
                  backgroundColor: Colors.white,
                  foregroundColor: _hasLocationPermission
                      ? AppColors.emerald
                      : AppColors.navy,
                  elevation: 4,
                  onPressed: _handleLocationPermissionRequest,
                  child: Icon(
                    _hasLocationPermission
                        ? Icons.my_location_rounded
                        : Icons.location_searching_rounded,
                    size: 24,
                  ),
                ),
              ),

              // 4. Bottom Selected Ground Details Card
              if (activeSelected != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: _buildSelectedGroundCard(activeSelected),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserLocationMarker() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroundMarker(
    GroundModel ground,
    bool isSelected,
    double distance,
  ) {
    return AnimatedScale(
      scale: isSelected ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Price Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navy : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.emerald : AppColors.borderLight,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ground.sportType == SportType.cricket
                      ? Icons.sports_cricket
                      : Icons.sports_soccer,
                  size: 11,
                  color: isSelected ? AppColors.emerald : AppColors.navy,
                ),
                const SizedBox(width: 4),
                Text(
                  'PKR ${ground.pricePerHour.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Pin Marker Icon
          Container(
            width: isSelected ? 34 : 26,
            height: isSelected ? 34 : 26,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.emerald : AppColors.navy,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? AppColors.emerald : AppColors.navy)
                      .withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: isSelected ? 18 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedGroundCard(GroundModel ground) {
    final distance = _groundDistances[ground.id] ?? 2.8;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ground Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              ground.primaryImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ground.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        Text(
                          ' ${ground.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      color: AppColors.emerald,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$distance km away • ${ground.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PKR ${ground.pricePerHour.toInt()}/hr',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.emeraldDark,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        context.push('/customer/ground/${ground.id}');
                      },
                      child: const Text(
                        'Book Slot',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Canvas painter rendering high quality interactive styled vector roads and zones
class _FullMapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background terrain
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Green open parks
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.10, w * 0.35, h * 0.25),
        const Radius.circular(16),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.60, h * 0.55, w * 0.35, h * 0.30),
        const Radius.circular(16),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.65, h * 0.08, w * 0.28, h * 0.20),
        const Radius.circular(16),
      ),
      parkPaint,
    );

    // Water reservoir (Rawal Lake)
    final waterPaint = Paint()..color = const Color(0xFFBAE6FD);
    final lakePath = Path()
      ..moveTo(w * 0.50, h * 0.38)
      ..cubicTo(w * 0.60, h * 0.35, w * 0.68, h * 0.42, w * 0.62, h * 0.48)
      ..cubicTo(w * 0.56, h * 0.52, w * 0.46, h * 0.46, w * 0.50, h * 0.38);
    canvas.drawPath(lakePath, waterPaint);

    // City Major Arteries / Expressways (Kashmir Highway, Islamabad Expressway)
    final highwayPaint = Paint()
      ..color = const Color(0xFFFEF08A)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final hwy1 = Path()
      ..moveTo(0, h * 0.32)
      ..cubicTo(w * 0.3, h * 0.34, w * 0.7, h * 0.28, w, h * 0.40);
    canvas.drawPath(hwy1, highwayPaint);

    final hwy2 = Path()
      ..moveTo(w * 0.45, 0)
      ..cubicTo(w * 0.48, h * 0.45, w * 0.55, h * 0.75, w * 0.65, h);
    canvas.drawPath(hwy2, highwayPaint);

    // City Grid Roads (White Streets)
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    // Horizontal sectors
    for (double i = 0.18; i < 0.9; i += 0.12) {
      canvas.drawLine(Offset(0, h * i), Offset(w, h * i), streetPaint);
    }

    // Vertical sectors
    for (double i = 0.2; i < 0.9; i += 0.15) {
      canvas.drawLine(Offset(w * i, 0), Offset(w * i, h), streetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
