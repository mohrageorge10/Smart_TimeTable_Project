import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routing/app_routes.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_state.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/section_card.dart';

class LocationsSetupScreen extends StatefulWidget {
  const LocationsSetupScreen({super.key});

  @override
  State<LocationsSetupScreen> createState() => _LocationsSetupScreenState();
}

class _LocationsSetupScreenState extends State<LocationsSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  String? _selectedLocationType;

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _addLocation(ScheduleCubit cubit, bool hasLocationType, List<String>? locationTypes) {
    final name = _nameController.text.trim();
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location name'), backgroundColor: Colors.red),
      );
      return;
    }

    cubit.locationName = name;
    cubit.locationCapacity = capacity;
    cubit.locationType = _selectedLocationType ?? '';
    cubit.addLocationToList();

    _nameController.clear();
    _capacityController.clear();
    setState(() => _selectedLocationType = null);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final cubit = context.read<ScheduleCubit>();
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    cubit.currentMode = currentMode; // keep in sync
    final config = ModeRepository.modes[currentMode]!;

    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Setup Locations — $currentMode'),
          ),
          body: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // ── Input Card ──────────────────────────────────────────
                SectionCard(
                  title: 'Add Location',
                  icon: Icons.add_location_alt_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Location Name',
                              prefixIcon: Icon(
                                Icons.meeting_room,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Capacity (persons)',
                              prefixIcon: Icon(
                                Icons.groups_2,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        if (config.hasLocationType && config.locations != null) ...[
                          SizedBox(width: 2.w),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedLocationType,
                              decoration: InputDecoration(
                                labelText: 'Type',
                                prefixIcon: Icon(
                                  Icons.place,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              items: config.locations!
                                  .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedLocationType = val),
                            ),
                          ),
                        ],
                        SizedBox(width: 2.w),
                        ElevatedButton.icon(
                          onPressed: () => _addLocation(
                            cubit,
                            config.hasLocationType,
                            config.locations,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // ── Locations Table ─────────────────────────────────────
                Expanded(
                  child: SectionCard(
                    title: 'Locations List',
                    icon: Icons.table_chart_outlined,
                    children: [
                      if (cubit.addedLocations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No locations added yet.\nAdd at least one location to continue.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            columns: [
                              const DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('Location Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('Capacity (persons)', style: TextStyle(fontWeight: FontWeight.bold))),
                              if (config.hasLocationType)
                                const DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: cubit.addedLocations.asMap().entries.map((entry) {
                              final i = entry.key;
                              final loc = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text('${i + 1}')),
                                  DataCell(Text(loc['name'] ?? '')),
                                  DataCell(Text(
                                    loc['capacity'] != null && loc['capacity'] != 0
                                        ? '${loc['capacity']} persons'
                                        : '—',
                                  )),
                                  if (config.hasLocationType)
                                    DataCell(Text(
                                      (loc['type'] != null && loc['type'].toString().isNotEmpty)
                                          ? loc['type']
                                          : '—',
                                    )),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        cubit.addedLocations.removeAt(i);
                                        cubit.refreshUI();
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // ── Continue Button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue to Schedule Setup'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: cubit.addedLocations.isEmpty
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.dashboard,
                              arguments: cubit,
                            );
                          },
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
