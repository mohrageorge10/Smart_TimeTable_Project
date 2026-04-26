import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routing/app_routes.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/section_card.dart';

class PreviewCard extends StatefulWidget {
  const PreviewCard({super.key});

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  final ScrollController _slotsController = ScrollController();
  final ScrollController _locationsController = ScrollController();

  @override
  void dispose() {
    _slotsController.dispose();
    _locationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ScheduleCubit>();
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final config = ModeRepository.modes[currentMode]!;

    if (cubit.addedLocations.isEmpty &&
        cubit.addedItems.isEmpty &&
        cubit.calculatedSlots.isEmpty) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: "Data Preview",
      icon: Icons.preview,
      children: [
        // ── Time Slots Table ─────────────────────────────────
        if (cubit.calculatedSlots.isNotEmpty) ...[
          const Text(
            "Calculated Slots:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Scrollbar(
            controller: _slotsController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _slotsController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Colors.blue.withOpacity(0.08),
                ),
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Slot',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Start',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'End',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: cubit.calculatedSlots.map((slot) {
                  return DataRow(
                    cells: [
                      DataCell(Text(slot["Slot"] ?? '')),
                      DataCell(Text(slot["Start"] ?? '')),
                      DataCell(Text(slot["End"] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Locations Table ─────────────────────────────────
        if (cubit.addedLocations.isNotEmpty) ...[
          const Text(
            "Locations:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Scrollbar(
            controller: _locationsController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _locationsController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).primaryColor.withOpacity(0.08),
                ),
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                columns: [
                  const DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'Capacity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (config.hasLocationType)
                    const DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  const DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: cubit.addedLocations.asMap().entries.map((entry) {
                  final i = entry.key;
                  final loc = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('${i + 1}')),
                      DataCell(Text(loc['name'] ?? '')),
                      DataCell(
                        Text(
                          loc['capacity'] != null && loc['capacity'] != 0
                              ? '${loc['capacity']} persons'
                              : '—',
                        ),
                      ),
                      if (config.hasLocationType)
                        DataCell(
                          Text(
                            (loc['type'] != null &&
                                    loc['type'].toString().isNotEmpty)
                                ? loc['type']
                                : '—',
                          ),
                        ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () => _showEditLocationDialog(
                                context,
                                cubit,
                                i,
                                loc,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                cubit.addedLocations.removeAt(i);
                                cubit.refreshUI();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Items List ───────────────────────────────────────
        if (cubit.addedItems.isNotEmpty) ...[
          const Text(
            "Added Items:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...cubit.addedItems.entries.map((entry) {
            final details = entry.value;
            final section = config.hasDynamicSection
                ? details[config.sectionLabel]?.toString()
                : null;
            final batch = config.hasAcademicYear
                ? details[config.academicYearLabel ?? 'Level']?.toString()
                : null;
            final rawDays = details['available_days'];
            final daysStr = (rawDays is List && rawDays.isNotEmpty)
                ? rawDays.join(', ')
                : 'All Days';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    if (batch != null) _chip('📚 $batch', Colors.blue),
                    if (section != null) _chip('👥 $section', Colors.purple),
                    _chip('📅 $daysStr', Colors.teal),
                  ],
                ),
                isThreeLine: true,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.details,
                  arguments: {
                    'itemName': entry.key,
                    'details': details,
                    'cubit': cubit,
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    cubit.addedItems.remove(entry.key);
                    cubit.refreshUI();
                  },
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _chip(String label, Color color) => Chip(
    label: Text(
      label,
      style: TextStyle(fontSize: 10, color: color.withOpacity(0.9)),
    ),
    backgroundColor: color.withOpacity(0.08),
    side: BorderSide(color: color.withOpacity(0.3)),
    padding: const EdgeInsets.symmetric(horizontal: 2),
    visualDensity: VisualDensity.compact,
  );

  void _showEditLocationDialog(
    BuildContext context,
    ScheduleCubit cubit,
    int index,
    Map<String, dynamic> loc,
  ) {
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final config = ModeRepository.modes[currentMode]!;

    TextEditingController nameCtrl = TextEditingController(text: loc['name']);
    TextEditingController capCtrl = TextEditingController(
      text: loc['capacity'].toString(),
    );

    String? selectedType = loc['type']?.toString();
    if (selectedType != null && selectedType.isEmpty) {
      selectedType = null;
    }

    List<String> typeOptions = config.locations != null
        ? List<String>.from(config.locations!)
        : [];

    if (selectedType != null && !typeOptions.contains(selectedType)) {
      typeOptions.add(selectedType);
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Location"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: capCtrl,
                      decoration: const InputDecoration(labelText: "Capacity"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    if (config.hasLocationType)
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(labelText: "Type"),
                        items: typeOptions
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setStateDialog(() => selectedType = val);
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    cubit.addedLocations[index] = {
                      "name": nameCtrl.text,
                      "capacity": int.tryParse(capCtrl.text) ?? 0,
                      "type": selectedType ?? '',
                    };
                    cubit.refreshUI();
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
