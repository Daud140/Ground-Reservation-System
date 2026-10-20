import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../models/ground_model.dart';
import '../models/review_model.dart';
import '../../shared/widgets/mini_map_preview.dart';

class GroundDetailScreen extends ConsumerStatefulWidget {
  final String groundId;

  const GroundDetailScreen({super.key, required this.groundId});

  @override
  ConsumerState<GroundDetailScreen> createState() => _GroundDetailScreenState();
}

class _GroundDetailScreenState extends ConsumerState<GroundDetailScreen> {
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);
    final reviewRepo = ref.watch(reviewRepositoryProvider);

    return FutureBuilder<GroundModel?>(
      future: groundRepo.getGroundById(widget.groundId),
      builder: (context, snapshot) {
        final ground = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
            ),
          );
        }

        if (ground == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Ground Details')),
            body: const Center(child: Text('Ground not found')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Scrollable Details Body
              CustomScrollView(
                slivers: [
                  // Hero Header with Image, Back, Share, and Favorite buttons
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Image.asset(
                            ground.primaryImage,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Top gradient overlay for button visibility
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Nav Buttons
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCircleButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () => context.pop(),
                                ),
                                Row(
                                  children: [
                                    _buildCircleButton(
                                      icon: Icons.share_outlined,
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Ground link copied to clipboard!',
                                                ),
                                              ),
                                            );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    _buildCircleButton(
                                      icon: _isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      iconColor: _isFavorite
                                          ? Colors.red
                                          : Colors.white,
                                      onTap: () => setState(
                                        () => _isFavorite = !_isFavorite,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Floating Sport tag
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sports_soccer,
                                  color: AppColors.lime,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${ground.sportType.displayName} Turf • 5v5',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Venue Title & Verified Checkmark
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ground.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navy,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.verified,
                                color: AppColors.emerald,
                                size: 22,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Rating and Reviews Count
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${ground.rating}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '(${ground.reviewsCount} reviews)',
                                style: const TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 13,
                                ),
                              ),
                              const Text(
                                '•',
                                style: TextStyle(
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                              Text(
                                'Open ${ground.openTime} - ${ground.closeTime}',
                                style: const TextStyle(
                                  color: AppColors.emeraldDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Address
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.emerald,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  ground.address,
                                  style: const TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Quick Specs Pills Row
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildSpecTag('Turf', 'FIFA Synthetic 50mm'),
                              _buildSpecTag('Size', '5-a-side / 7-a-side'),
                              _buildSpecTag('Lighting', 'High-Flux LED'),
                              _buildSpecTag('Parking', 'Free Dedicated'),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.borderLight),
                          const SizedBox(height: 16),

                          // Popular Amenities Section
                          const Text(
                            'Popular Amenities',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAmenitiesGrid(ground.facilities),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.borderLight),
                          const SizedBox(height: 16),

                          // About Venue Section
                          const Text(
                            'About Venue',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ground.description,
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded
                                ? null
                                : TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(
                              () => _isDescriptionExpanded =
                                  !_isDescriptionExpanded,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                _isDescriptionExpanded
                                    ? 'Read less'
                                    : 'Read more',
                                style: const TextStyle(
                                  color: AppColors.emeraldDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.borderLight),
                          const SizedBox(height: 16),

                          // Ratings & Reviews Section
                          FutureBuilder<List<ReviewModel>>(
                            future: reviewRepo.getReviewsForGround(ground.id),
                            builder: (context, reviewSnap) {
                              final reviews = reviewSnap.data ?? [];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Ratings & Reviews',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.navy,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${reviews.length} total',
                                        style: const TextStyle(
                                          color: AppColors.textSecondaryLight,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _buildRatingsSummary(ground.rating),
                                  const SizedBox(height: 16),
                                  if (reviews.isNotEmpty) ...[
                                    ...reviews
                                        .take(2)
                                        .map((r) => _buildReviewCard(r)),
                                  ] else ...[
                                    _buildSampleReview(
                                      name: 'Hamza Tariq',
                                      comment: 'Amazing pitch quality, floodlights are super bright and ball roll is smooth!',
                                      rating: 5.0,
                                      date: '2 days ago',
                                    ),
                                    _buildSampleReview(
                                      name: 'Zain Malik',
                                      comment: 'Well maintained locker rooms and friendly management staff.',
                                      rating: 4.8,
                                      date: '1 week ago',
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.borderLight),
                          const SizedBox(height: 16),

                          // Location & Directions Section
                          const Text(
                            'Location & Directions',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          MiniMapPreviewWidget(
                            venueName: ground.name,
                            address: ground.address,
                            onDirectionsTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Opening directions to ${ground.address}',
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(
                            height: 100,
                          ), // Bottom padding for sticky booking bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky Bottom Booking Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Price per hour',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'PKR ${ground.pricePerHour.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' / hr',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 140,
                            maxWidth: 180,
                            minHeight: 48,
                            maxHeight: 50,
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                context.push('/customer/book/${ground.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: AppColors.emerald.withValues(
                                alpha: 0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Book Slot',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }

  Widget _buildSpecTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid(List<String> facilities) {
    final defaultAmenities = [
      {'icon': Icons.bolt, 'name': 'LED Floodlights'},
      {'icon': Icons.meeting_room_outlined, 'name': 'Changing Rooms'},
      {'icon': Icons.local_parking_rounded, 'name': 'Free Parking'},
      {'icon': Icons.local_cafe_outlined, 'name': 'Sports Café'},
      {'icon': Icons.shower_outlined, 'name': 'Hot Showers'},
      {'icon': Icons.water_drop_outlined, 'name': 'Filtered Water'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: defaultAmenities.map((item) {
        return Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                color: AppColors.emerald,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                item['name'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingsSummary(double rating) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '$rating',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Pitch Score',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.88),
                _buildRatingBar(4, 0.10),
                _buildRatingBar(3, 0.02),
                _buildRatingBar(2, 0.00),
                _buildRatingBar(1, 0.00),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double factor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars ★',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: factor,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation(AppColors.emerald),
                minHeight: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.customerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.navy,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Text(
                    ' ${review.rating}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleReview({
    required String name,
    required String comment,
    required double rating,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.navy,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Text(
                    ' $rating',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
