import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../models/ground_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/app_logo.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const CustomerHomeScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  SportType? _selectedSport;
  String _selectedCity = 'Islamabad, PK';
  final Set<String> _favoriteGroundIds = {'ground_1'};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FutureBuilder<List<GroundModel>>(
          future: groundRepo.getAllGrounds(),
          builder: (context, snapshot) {
            final grounds = snapshot.data ?? [];
            final filteredGrounds = grounds.where((g) {
              if (_selectedSport != null && g.sportType != _selectedSport) return false;
              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                return g.name.toLowerCase().contains(q) || g.location.toLowerCase().contains(q);
              }
              return true;
            }).toList();

            // Featured top-rated ground
            final featuredGround = grounds.isNotEmpty ? grounds.first : null;

            return CustomScrollView(
              slivers: [
                // Top App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar: Brand Logo on left, Notifications & Avatar on right
                        Row(
                          children: [
                            const GroundZeroLogo(size: 26),
                            const Spacer(),
                            // Notification bell
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(Icons.notifications_none_rounded, color: AppColors.navy, size: 18),
                                  Positioned(
                                    top: 7,
                                    right: 8,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.emerald,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // User avatar
                            GesturableAvatar(
                              name: user?.name ?? 'Player',
                              onTap: () => widget.onNavigateTab?.call(4),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Sub-bar: City Selector Chip & Greeting
                        Row(
                          children: [
                            InkWell(
                              onTap: _showCityPicker,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on, color: AppColors.emerald, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedCity,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondaryLight),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: Text(
                                'Ready to play, ${user?.name.split(' ').first ?? 'Player'}?',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Search Bar
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderLight),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                  decoration: const InputDecoration(
                                    hintText: 'Find your pitch today...',
                                    hintStyle: TextStyle(
                                      color: AppColors.textMutedLight,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(Icons.search, color: AppColors.textMutedLight, size: 22),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.emerald,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.emerald.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                                onPressed: _showFilterModal,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Sport Categories Horizontal Chips
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildSportCategoryChip(
                                label: 'All',
                                icon: Icons.sports,
                                isSelected: _selectedSport == null,
                                onTap: () => setState(() => _selectedSport = null),
                              ),
                              ...SportType.values.map((sport) {
                                return _buildSportCategoryChip(
                                  label: sport.displayName,
                                  icon: _getSportIcon(sport),
                                  isSelected: _selectedSport == sport,
                                  onTap: () => setState(() => _selectedSport = sport),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Rated Section
                if (featuredGround != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Top Rated',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                              TextButton(
                                onPressed: () => widget.onNavigateTab?.call(1),
                                child: const Text(
                                  'See all',
                                  style: TextStyle(
                                    color: AppColors.emeraldDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildFeaturedGroundCard(featuredGround),
                        ],
                      ),
                    ),
                  ),
                ],

                // Promotional Banner ("Need a quick match tonight?")
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emerald.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.lime,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'INSTANT PLAY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.navy,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Need a quick match tonight?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Find open slots available near you with GroundBot AI',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => widget.onNavigateTab?.call(3), // Open AI tab
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.emeraldDark,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // "Near You" Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Near You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          '${filteredGrounds.length} venues found',
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Near You Grounds List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ground = filteredGrounds[index];
                        return _buildGroundRowCard(ground);
                      },
                      childCount: filteredGrounds.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 90), // Bottom padding for navigation bar
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSportCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emerald : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.emerald : AppColors.borderLight,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedGroundCard(GroundModel ground) {
    final isFav = _favoriteGroundIds.contains(ground.id);

    return GestureDetector(
      onTap: () => context.push('/customer/ground/${ground.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                  child: Image.asset(
                    ground.primaryImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Rating Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${ground.rating}',
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
                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isFav) {
                          _favoriteGroundIds.remove(ground.id);
                        } else {
                          _favoriteGroundIds.add(ground.id);
                        }
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : AppColors.navy,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Bottom Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ground.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ground.sportType.displayName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emeraldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.textMutedLight, size: 15),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ground.location,
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'PKR ${ground.pricePerHour.toInt()}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.emeraldDark,
                              ),
                            ),
                            const TextSpan(
                              text: ' / hr',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/customer/ground/${ground.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 13,
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
      ),
    );
  }

  Widget _buildGroundRowCard(GroundModel ground) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/customer/ground/${ground.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  ground.primaryImage,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              // Ground Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            Text(
                              ' ${ground.rating}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ground.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PKR ${ground.pricePerHour.toInt()}/hr',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emeraldDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ground.sportType.displayName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryLight,
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
        ),
      ),
    );
  }

  IconData _getSportIcon(SportType sport) {
    switch (sport) {
      case SportType.football:
      case SportType.futsal:
        return Icons.sports_soccer_rounded;
      case SportType.cricket:
        return Icons.sports_cricket_rounded;
      case SportType.padel:
      case SportType.tennis:
        return Icons.sports_tennis_rounded;
      case SportType.basketball:
        return Icons.sports_basketball_rounded;
    }
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cities = ['Islamabad, PK', 'Rawalpindi, PK', 'Lahore, PK'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select City',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 12),
                ...cities.map((c) => ListTile(
                      title: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: _selectedCity == c ? const Icon(Icons.check, color: AppColors.emerald) : null,
                      onTap: () {
                        setState(() => _selectedCity = c);
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Pitches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text('Max Hourly Price (PKR)', style: TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: 6000,
                  min: 2000,
                  max: 10000,
                  divisions: 8,
                  activeColor: AppColors.emerald,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GesturableAvatar extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const GesturableAvatar({super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.emeraldContainer,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.emerald, width: 1.5),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: AppColors.emeraldDark,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
