import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/demo/fake_database.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../customer/models/ground_model.dart';
import '../../shared/widgets/mini_map_preview.dart';

class OwnerGroundManagementScreen extends ConsumerStatefulWidget {
  const OwnerGroundManagementScreen({super.key});

  @override
  ConsumerState<OwnerGroundManagementScreen> createState() =>
      _OwnerGroundManagementScreenState();
}

class _OwnerGroundManagementScreenState
    extends ConsumerState<OwnerGroundManagementScreen> {
  bool _acceptingBookings = true;
  bool _weekdayOpen = true;
  bool _weekendOpen = true;
  bool _peakHourSurcharge = true;

  GroundModel? _selectedGround;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _surfaceController;
  late TextEditingController _addressController;

  final Set<String> _activeFacilities = {
    'Floodlights',
    'Changing Rooms',
    'Parking',
    'Cafeteria',
    'Bibs & Balls',
    'First Aid',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _surfaceController = TextEditingController(text: 'Artificial Grass 50mm');
    _addressController = TextEditingController(
      text: 'Plot 14, Sector F-7 Markaz, Islamabad',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _surfaceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _syncSelectedGround(GroundModel ground) {
    _selectedGround = ground;
    _nameController.text = ground.name;
    _priceController.text = ground.pricePerHour.toInt().toString();
    _addressController.text = ground.address.isNotEmpty
        ? ground.address
        : ground.location;
    _activeFacilities.clear();
    _activeFacilities.addAll(ground.facilities);
    _acceptingBookings = ground.isActive;
  }

  Future<void> _handleSaveGround() async {
    if (_selectedGround == null) return;

    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a ground name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive hourly rate (PKR)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final updated = _selectedGround!.copyWith(
      name: name,
      pricePerHour: price,
      address: address,
      location: address.contains(',')
          ? address.split(',').last.trim()
          : address,
      facilities: _activeFacilities.toList(),
      isActive: _acceptingBookings,
    );

    final groundRepo = ref.read(groundRepositoryProvider);
    await groundRepo.updateGround(updated);

    setState(() {
      _selectedGround = updated;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ground settings and slot timings updated successfully!'),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  Future<void> _handleDeleteGround() async {
    if (_selectedGround == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Ground',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${_selectedGround!.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final groundRepo = ref.read(groundRepositoryProvider);
      await groundRepo.deleteGround(_selectedGround!.id);
      setState(() {
        _selectedGround = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ground deleted successfully'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAddGroundDialog(String ownerId) {
    final addNameController = TextEditingController();
    final addPriceController = TextEditingController(text: '4000');
    final addAddressController = TextEditingController(
      text: 'Sector E-11/4, Islamabad',
    );
    SportType addSport = SportType.futsal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Ground',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormField('Ground Name', addNameController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sport Type',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<SportType>(
                            initialValue: addSport,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceSecondaryLight,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                            ),
                            items: SportType.values
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s.displayName,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setModalState(() => addSport = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormField(
                        'Hourly Rate (PKR)',
                        addPriceController,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormField('Address / Location', addAddressController),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final name = addNameController.text.trim();
                      final price =
                          double.tryParse(addPriceController.text.trim()) ??
                          4000.0;
                      final addr = addAddressController.text.trim();

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a ground name'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      final newGround = GroundModel(
                        id: 'ground_${DateTime.now().millisecondsSinceEpoch}',
                        ownerId: ownerId,
                        name: name,
                        sportType: addSport,
                        location: addr.contains(',')
                            ? addr.split(',').last.trim()
                            : addr,
                        address: addr,
                        pricePerHour: price,
                        rating: 5.0,
                        reviewsCount: 1,
                        openTime: '07:00',
                        closeTime: '02:00',
                        facilities: [
                          'Floodlights',
                          'Changing Rooms',
                          'Parking',
                          'Cafeteria',
                        ],
                        images: [AppAssets.groundFutsalRawal],
                        description: 'Premier sports arena verified and managed by venue owner on GroundZero.',
                        isActive: true,
                      );

                      final groundRepo = ref.read(groundRepositoryProvider);
                      await groundRepo.addGround(newGround);

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedGround = newGround;
                        _syncSelectedGround(newGround);
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"$name" added successfully!'),
                            backgroundColor: AppColors.emerald,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Create Ground',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationPickerModal() {
    final presetLocations = [
      {
        'name': 'F-7 Markaz, Islamabad',
        'address': 'Plot 14, College Road, Sector F-7 Markaz, Islamabad',
      },
      {
        'name': 'E-11/4, Islamabad',
        'address': 'Main Margalla Hill Road, Sector E-11/4, Islamabad',
      },
      {
        'name': 'F-10/2, Islamabad',
        'address': 'Street 22, Sector F-10/2, Islamabad',
      },
      {
        'name': 'Blue Area, Islamabad',
        'address': 'Jinnah Avenue, Blue Area, Islamabad',
      },
      {
        'name': 'Chaklala Scheme 3, Rawalpindi',
        'address': 'Airport Road, Chaklala Scheme 3, Rawalpindi',
      },
      {
        'name': 'Bahria Town Phase 4, Rawalpindi',
        'address': 'Civic Center Boulevard, Phase 4, Bahria Town, Rawalpindi',
      },
      {
        'name': 'Ayub Park, Rawalpindi',
        'address': 'Gate 3, Jhelum Road, Rawalpindi',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.pin_drop_rounded,
                      color: AppColors.emerald,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Select Location on Map',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Pick a verified sports zone in Rawalpindi / Islamabad:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: presetLocations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final loc = presetLocations[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.emeraldDark,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loc['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.navy,
                      ),
                    ),
                    subtitle: Text(
                      loc['address']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                    ),
                    onTap: () {
                      setState(() {
                        _addressController.text = loc['address']!;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Location updated to ${loc['name']}'),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);
    final authState = ref.watch(authProvider);
    final ownerId = authState.user?.id ?? 'owner_sport_demo';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          'Manage Ground',
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add New Ground',
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.emerald,
              size: 24,
            ),
            onPressed: () => _showAddGroundDialog(ownerId),
          ),
          IconButton(
            tooltip: 'Delete Ground',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 24,
            ),
            onPressed: _handleDeleteGround,
          ),
          IconButton(
            tooltip: 'Save Ground Details',
            icon: const Icon(
              Icons.check_rounded,
              color: AppColors.emerald,
              size: 24,
            ),
            onPressed: _handleSaveGround,
          ),
        ],
      ),
      body: FutureBuilder<List<GroundModel>>(
        future: groundRepo.getGroundsByOwner(ownerId),
        builder: (context, snapshot) {
          final grounds = snapshot.data ?? [];

          // If no ground owned yet, fallback to all grounds for demo
          final availableGrounds = grounds.isNotEmpty
              ? grounds
              : FakeDatabase.grounds;

          if (_selectedGround == null && availableGrounds.isNotEmpty) {
            _syncSelectedGround(availableGrounds.first);
          } else if (_selectedGround != null &&
              !availableGrounds.any((g) => g.id == _selectedGround!.id)) {
            if (availableGrounds.isNotEmpty) {
              _syncSelectedGround(availableGrounds.first);
            }
          }

          final primaryGround =
              _selectedGround ??
              (availableGrounds.isNotEmpty ? availableGrounds.first : null);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ground Selector Card with Popup Menu to switch grounds
                PopupMenuButton<GroundModel>(
                  color: cardColor,
                  onSelected: (g) {
                    setState(() => _syncSelectedGround(g));
                  },
                  itemBuilder: (ctx) => availableGrounds.map((g) {
                    return PopupMenuItem<GroundModel>(
                      value: g,
                      child: Row(
                        children: [
                          Icon(
                            Icons.stadium,
                            color: g.id == primaryGround?.id
                                ? AppColors.emerald
                                : (isDark ? Colors.white70 : AppColors.navy),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              g.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: g.id == primaryGround?.id
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: g.id == primaryGround?.id
                                    ? AppColors.emerald
                                    : textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceSecondaryDark
                          : AppColors.surfaceSecondaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.stadium,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                primaryGround?.name ?? 'No Ground Registered',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                primaryGround?.location ??
                                    'Tap to select or add ground',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.unfold_more, color: subtextColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Accepting Bookings Switch Banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _acceptingBookings
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _acceptingBookings
                          ? AppColors.emerald
                          : AppColors.error,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _acceptingBookings
                                ? Icons.check_circle
                                : Icons.pause_circle,
                            color: _acceptingBookings
                                ? AppColors.emeraldDark
                                : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _acceptingBookings
                                    ? 'Accepting Bookings'
                                    : 'Bookings Paused',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _acceptingBookings
                                      ? AppColors.emeraldDark
                                      : AppColors.error,
                                ),
                              ),
                              const Text(
                                'Slots visible to players',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _acceptingBookings,
                        activeThumbColor: AppColors.emerald,
                        onChanged: (val) =>
                            setState(() => _acceptingBookings = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Venue Photos Section
                Text(
                  'Venue Photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPhotoCard(
                        primaryGround?.primaryImage ??
                            AppAssets.groundFutsalRawal,
                      ),
                      const SizedBox(width: 10),
                      _buildPhotoCard(AppAssets.groundFootballMargalla),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Device photo gallery opened'),
                            ),
                          );
                        },
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceSecondaryDark
                                : AppColors.surfaceSecondaryLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppColors.emerald,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Ground Information Fields
                Text(
                  'Ground Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFormField('Ground Name', _nameController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        'Hourly Rate (PKR)',
                        _priceController,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormField(
                        'Pitch Surface',
                        _surfaceController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormField('Address', _addressController),

                const SizedBox(height: 24),

                // Facilities & Perks Toggles
                Text(
                  'Facilities & Perks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        'Floodlights',
                        'Changing Rooms',
                        'Parking',
                        'Cafeteria',
                        'Bibs & Balls',
                        'First Aid',
                        'Showers',
                        'Spectator Stands',
                      ].map((facility) {
                        final isActive = _activeFacilities.contains(facility);
                        return FilterChip(
                          label: Text(facility),
                          selected: isActive,
                          selectedColor: AppColors.emeraldContainer,
                          checkmarkColor: AppColors.emeraldDark,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive ? AppColors.emeraldDark : textColor,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _activeFacilities.add(facility);
                              } else {
                                _activeFacilities.remove(facility);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),

                const SizedBox(height: 24),

                // Operating Timings
                Text(
                  'Operating Timings & Rules',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTimingRow(
                  'Weekday Timings',
                  '04:00 PM - 02:00 AM',
                  _weekdayOpen,
                  (v) => setState(() => _weekdayOpen = v),
                ),
                const SizedBox(height: 8),
                _buildTimingRow(
                  'Weekend Timings',
                  '02:00 PM - 03:00 AM',
                  _weekendOpen,
                  (v) => setState(() => _weekendOpen = v),
                ),
                const SizedBox(height: 8),
                _buildTimingRow(
                  'Peak Hour Surcharge (+PKR 500)',
                  '08:00 PM - 11:00 PM',
                  _peakHourSurcharge,
                  (v) => setState(() => _peakHourSurcharge = v),
                ),

                const SizedBox(height: 24),

                // Location on Map Header with Location Picker Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Location on Map',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showLocationPickerModal,
                      icon: const Icon(
                        Icons.edit_location_alt_rounded,
                        size: 16,
                        color: AppColors.emerald,
                      ),
                      label: const Text(
                        'Pick on Map',
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
                GestureDetector(
                  onTap: _showLocationPickerModal,
                  child: MiniMapPreviewWidget(
                    venueName: _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Arena Venue',
                    address: _addressController.text.isNotEmpty
                        ? _addressController.text
                        : 'Islamabad',
                  ),
                ),

                const SizedBox(height: 28),

                // Save Ground Details Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _handleSaveGround,
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: const Text(
                      'Save Ground Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(path, width: 120, height: 90, fit: BoxFit.cover),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: subtextColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 14, color: textColor),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceSecondaryDark
                : AppColors.surfaceSecondaryLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimingRow(
    String title,
    String timeRange,
    bool isOpen,
    ValueChanged<bool> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceSecondaryDark
            : AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                timeRange,
                style: TextStyle(fontSize: 11, color: subtextColor),
              ),
            ],
          ),
          Switch(
            value: isOpen,
            activeThumbColor: AppColors.emerald,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
