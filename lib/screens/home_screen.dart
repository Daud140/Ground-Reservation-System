import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class GroundItem {
  final String id;
  final String name;
  final String sport;
  final String location;
  final double rating;
  final int reviewsCount;
  final double pricePerHour;
  final List<String> availableSlots;
  final IconData sportIcon;

  GroundItem({
    required this.id,
    required this.name,
    required this.sport,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerHour,
    required this.availableSlots,
    required this.sportIcon,
  });
}

class HomeScreen extends StatefulWidget {
  final String userEmail;

  const HomeScreen({super.key, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Football',
    'Cricket',
    'Tennis',
    'Badminton',
    'Basketball',
  ];

  final List<GroundItem> _grounds = [
    GroundItem(
      id: 'g1',
      name: 'Champions FIFA Turf Arena',
      sport: 'Football',
      location: 'Central Sports Complex, Sector 4',
      rating: 4.9,
      reviewsCount: 142,
      pricePerHour: 45.0,
      availableSlots: ['06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM'],
      sportIcon: Icons.sports_soccer_rounded,
    ),
    GroundItem(
      id: 'g2',
      name: 'Greenfield Cricket Ground & Nets',
      sport: 'Cricket',
      location: 'East Avenue Sports Park',
      rating: 4.8,
      reviewsCount: 98,
      pricePerHour: 60.0,
      availableSlots: ['04:00 PM', '05:30 PM', '07:00 PM'],
      sportIcon: Icons.sports_cricket_rounded,
    ),
    GroundItem(
      id: 'g3',
      name: 'Apex Grand Tennis Court',
      sport: 'Tennis',
      location: 'North Hill Club, Block B',
      rating: 4.7,
      reviewsCount: 76,
      pricePerHour: 35.0,
      availableSlots: ['05:00 PM', '06:00 PM', '07:00 PM'],
      sportIcon: Icons.sports_tennis_rounded,
    ),
    GroundItem(
      id: 'g4',
      name: 'Skyline Indoor Badminton Arena',
      sport: 'Badminton',
      location: 'West City Stadium, 2nd Floor',
      rating: 4.9,
      reviewsCount: 180,
      pricePerHour: 28.0,
      availableSlots: ['03:00 PM', '04:00 PM', '05:00 PM', '08:00 PM'],
      sportIcon: Icons.sports_tennis_outlined,
    ),
    GroundItem(
      id: 'g5',
      name: 'Urban Pro Basketball Court',
      sport: 'Basketball',
      location: 'Metro Sports Hub, Gate 2',
      rating: 4.6,
      reviewsCount: 54,
      pricePerHour: 30.0,
      availableSlots: ['06:30 PM', '07:30 PM', '08:30 PM'],
      sportIcon: Icons.sports_basketball_rounded,
    ),
  ];

  List<GroundItem> get _filteredGrounds {
    return _grounds.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.sport == _selectedCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sport.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showBookingSheet(GroundItem ground) {
    String selectedSlot = ground.availableSlots.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(ground.sportIcon, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ground.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '\$${ground.pricePerHour.toStringAsFixed(0)} / hour',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Slot Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ground.availableSlots.map((slot) {
                      final isSelected = selectedSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setSheetState(() => selectedSlot = slot);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Confirm & Reserve Ground (\$${ground.pricePerHour.toStringAsFixed(0)})',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reservation confirmed for ${ground.name} at $selectedSlot!',
                          ),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out of Ground Reservation System?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sports_soccer_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ground Reservation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Explore & Book Slots',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 18, color: AppColors.primaryDark),
            ),
            onSelected: (val) {
              if (val == 'logout') _logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Signed in as:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text(
                      widget.userEmail.isNotEmpty ? widget.userEmail : 'User',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Search and Category Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search grounds, turfs, sports...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedCategory = cat);
                              },
                              selectedColor: AppColors.primaryDark,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              backgroundColor: AppColors.inputBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide.none,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Grounds List
              Expanded(
                child: _filteredGrounds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_soccer_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              'No grounds found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try selecting another category or clear search query',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredGrounds.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final ground = _filteredGrounds[index];
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          ground.sportIcon,
                                          color: AppColors.primaryDark,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    ground.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryLight,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    ground.sport,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primaryDark,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    ground.location,
                                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(height: 1, color: AppColors.border),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 18, color: AppColors.accent),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${ground.rating}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                ' (${ground.reviewsCount})',
                                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '\$${ground.pricePerHour.toStringAsFixed(0)} / hr',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _showBookingSheet(ground),
                                        icon: const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                                        label: const Text('Book Slot', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
