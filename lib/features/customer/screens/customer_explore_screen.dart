import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../models/ground_model.dart';

class CustomerExploreScreen extends ConsumerStatefulWidget {
  const CustomerExploreScreen({super.key});

  @override
  ConsumerState<CustomerExploreScreen> createState() => _CustomerExploreScreenState();
}

class _CustomerExploreScreenState extends ConsumerState<CustomerExploreScreen> {
  String _query = '';
  SportType? _selectedSport;

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Explore Pitches',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<GroundModel>>(
          future: groundRepo.getAllGrounds(),
          builder: (context, snapshot) {
            final grounds = snapshot.data ?? [];
            final filtered = grounds.where((g) {
              if (_selectedSport != null && g.sportType != _selectedSport) return false;
              if (_query.isNotEmpty) {
                final q = _query.toLowerCase();
                return g.name.toLowerCase().contains(q) || g.location.toLowerCase().contains(q);
              }
              return true;
            }).toList();

            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search by arena name or sector...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMutedLight),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: AppColors.surfaceSecondaryLight,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: _selectedSport == null,
                              selectedColor: AppColors.emeraldContainer,
                              onSelected: (_) => setState(() => _selectedSport = null),
                            ),
                            const SizedBox(width: 6),
                            ...SportType.values.map((s) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    label: Text(s.displayName),
                                    selected: _selectedSport == s,
                                    selectedColor: AppColors.emeraldContainer,
                                    onSelected: (_) => setState(() => _selectedSport = s),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ground = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              ground.primaryImage,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            ground.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy),
                          ),
                          subtitle: Text(
                            '${ground.location} • PKR ${ground.pricePerHour.toInt()}/hr',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () => context.push('/customer/ground/${ground.id}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
