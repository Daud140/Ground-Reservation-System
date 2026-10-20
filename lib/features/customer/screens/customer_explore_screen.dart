import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../data/repositories/repository_providers.dart';
import '../models/ground_model.dart';

class CustomerExploreScreen extends ConsumerStatefulWidget {
  const CustomerExploreScreen({super.key});

  @override
  ConsumerState<CustomerExploreScreen> createState() =>
      _CustomerExploreScreenState();
}

class _CustomerExploreScreenState extends ConsumerState<CustomerExploreScreen> {
  String _query = '';
  SportType? _selectedSport;

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputColor = isDark
        ? const Color(0xFF0F172A)
        : AppColors.surfaceSecondaryLight;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Explore Pitches',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'View Interactive Map',
            icon: const Icon(
              Icons.map_rounded,
              color: AppColors.emerald,
              size: 24,
            ),
            onPressed: () => context.push(AppRoutes.groundsMap),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<GroundModel>>(
          future: groundRepo.getAllGrounds(),
          builder: (context, snapshot) {
            final grounds = snapshot.data ?? [];
            final filtered = grounds.where((g) {
              if (_selectedSport != null && g.sportType != _selectedSport) {
                return false;
              }
              if (_query.isNotEmpty) {
                final q = _query.toLowerCase();
                return g.name.toLowerCase().contains(q) ||
                    g.location.toLowerCase().contains(q);
              }
              return true;
            }).toList();

            return Column(
              children: [
                Container(
                  color: bgColor,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search by arena name or sector...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: subtextColor,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                            color: subtextColor,
                          ),
                          filled: true,
                          fillColor: inputColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
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
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            FilterChip(
                              label: Text(
                                'All',
                                style: TextStyle(
                                  color: _selectedSport == null
                                      ? Colors.white
                                      : textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: _selectedSport == null,
                              selectedColor: AppColors.emerald,
                              backgroundColor: cardColor,
                              side: BorderSide(
                                color: _selectedSport == null
                                    ? AppColors.emerald
                                    : borderColor,
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedSport = null),
                            ),
                            const SizedBox(width: 6),
                            ...SportType.values.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(
                                    s.displayName,
                                    style: TextStyle(
                                      color: _selectedSport == s
                                          ? Colors.white
                                          : textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  selected: _selectedSport == s,
                                  selectedColor: AppColors.emerald,
                                  backgroundColor: cardColor,
                                  side: BorderSide(
                                    color: _selectedSport == s
                                        ? AppColors.emerald
                                        : borderColor,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _selectedSport = s),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No arenas match your search.',
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final ground = filtered[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: Material(
                                color: Colors.transparent,
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${ground.location} • PKR ${ground.pricePerHour.toInt()}/hr',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtextColor,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: subtextColor,
                                  ),
                                  onTap: () => context.push(
                                    '/customer/ground/${ground.id}',
                                  ),
                                ),
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
