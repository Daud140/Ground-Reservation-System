import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../customer/models/ground_model.dart';
import '../../shared/widgets/mini_map_preview.dart';

class OwnerGroundManagementScreen extends ConsumerStatefulWidget {
  const OwnerGroundManagementScreen({super.key});

  @override
  ConsumerState<OwnerGroundManagementScreen> createState() => _OwnerGroundManagementScreenState();
}

class _OwnerGroundManagementScreenState extends ConsumerState<OwnerGroundManagementScreen> {
  bool _acceptingBookings = true;
  bool _weekdayOpen = true;
  bool _weekendOpen = true;
  bool _peakHourSurcharge = true;

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _surfaceController;

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
    _nameController = TextEditingController(text: 'Apex Arena 5-a-side Turf');
    _priceController = TextEditingController(text: '4500');
    _surfaceController = TextEditingController(text: 'Artificial Grass 50mm');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _surfaceController.dispose();
    super.dispose();
  }

  void _handleSaveGround() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ground settings and slot timings updated successfully!'),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage Ground',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.emerald, size: 24),
            onPressed: _handleSaveGround,
          ),
        ],
      ),
      body: FutureBuilder<List<GroundModel>>(
        future: groundRepo.getAllGrounds(),
        builder: (context, snapshot) {
          final grounds = snapshot.data ?? [];
          final primaryGround = grounds.isNotEmpty ? grounds.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ground Selector Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
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
                        child: const Icon(Icons.stadium, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primaryGround?.name ?? 'Apex Arena 5-a-side Turf',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                            const Text(
                              'Bahria Town, Islamabad',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.unfold_more, color: AppColors.textSecondaryLight),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Accepting Bookings Switch Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _acceptingBookings ? const Color(0xFFF0FDF4) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _acceptingBookings ? AppColors.emerald : AppColors.error,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _acceptingBookings ? Icons.check_circle : Icons.pause_circle,
                            color: _acceptingBookings ? AppColors.emeraldDark : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _acceptingBookings ? 'Accepting Bookings' : 'Bookings Paused',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _acceptingBookings ? AppColors.emeraldDark : AppColors.error,
                                ),
                              ),
                              const Text(
                                'Slots visible to players',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _acceptingBookings,
                        activeThumbColor: AppColors.emerald,
                        onChanged: (val) => setState(() => _acceptingBookings = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Photos Gallery Section
                const Text(
                  'Venue Photos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Photo 1
                      _buildPhotoCard(primaryGround?.primaryImage ?? 'assets/images/ground_futsal_rawal.jpg'),
                      const SizedBox(width: 10),
                      // Photo 2
                      _buildPhotoCard('assets/images/ground_football_margalla.jpg'),
                      const SizedBox(width: 10),
                      // Add Photo Box
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select image from device gallery')),
                          );
                        },
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondaryLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, color: AppColors.emerald, size: 24),
                              SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Ground Information
                const Text(
                  'Ground Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 12),
                _buildFormField('Ground Name', _nameController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildFormField('Hourly Rate (PKR)', _priceController, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFormField('Pitch Surface', _surfaceController)),
                  ],
                ),

                const SizedBox(height: 24),

                // Facilities & Perks Toggles
                const Text(
                  'Facilities & Perks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
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
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? AppColors.emeraldDark : AppColors.navy,
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

                // Operating Timings & Slots
                const Text(
                  'Operating Timings & Rules',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 12),
                _buildTimingRow('Weekday Timings', '04:00 PM - 02:00 AM', _weekdayOpen, (v) => setState(() => _weekdayOpen = v)),
                const SizedBox(height: 8),
                _buildTimingRow('Weekend Timings', '02:00 PM - 03:00 AM', _weekendOpen, (v) => setState(() => _weekendOpen = v)),
                const SizedBox(height: 8),
                _buildTimingRow('Peak Hour Surcharge (+PKR 500)', '08:00 PM - 11:00 PM', _peakHourSurcharge, (v) => setState(() => _peakHourSurcharge = v)),

                const SizedBox(height: 24),

                // Location on Map
                const Text(
                  'Location on Map',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 10),
                MiniMapPreviewWidget(
                  venueName: _nameController.text,
                  address: 'Sector B, Bahria Town Phase 4, Islamabad',
                ),

                const SizedBox(height: 32),

                // Save Ground Details Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleSaveGround,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save Ground Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
      child: Image.asset(
        path,
        width: 120,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceSecondaryLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimingRow(String title, String timeRange, bool isOpen, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
              Text(timeRange, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
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
