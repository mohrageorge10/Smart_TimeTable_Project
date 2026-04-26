import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/details_section_card.dart';

class DetailsScreen extends StatefulWidget {
  final String itemName;
  final Map<String, dynamic> details;
  final ScheduleCubit cubit;

  const DetailsScreen({
    super.key, 
    required this.itemName, 
    required this.details, 
    required this.cubit,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late String currentItemName;

  @override
  void initState() {
    super.initState();
    currentItemName = widget.itemName; 
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ScheduleCubit>();
    
    final currentDetails = widget.cubit.addedItems[currentItemName];

    if (currentDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Item Not Found")),
        body: const Center(child: Text("This item has been deleted or renamed.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$currentItemName Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit Item",
            onPressed: () => _showSmartEditDialog(context, currentDetails),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DetailsSectionCard(
            title: "Item Configuration", 
            data: currentDetails,
          ),
        ],
      ),
    );
  }

  void _showSmartEditDialog(BuildContext context, Map<String, dynamic> details) {
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final config = ModeRepository.modes[currentMode]!;

    Map<String, dynamic> localData = Map<String, dynamic>.from(details);
    
    List<String> allDays = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];
    List<String> selectedDays = (localData['available_days'] as List?)?.map((e) => e.toString()).toList() ?? [];

    Map<String, TextEditingController> textControllers = {};
    for (var key in localData.keys) {
      if (key != 'available_days' && 
          key != 'Type' && 
          key != config.typeLabel && 
          key != 'Specialty' && 
          key != config.academicYearLabel && 
          key != config.sectionLabel) {
        textControllers[key] = TextEditingController(text: localData[key].toString());
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Item", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...localData.keys.map((key) {
                      if (key == 'available_days') return const SizedBox.shrink();

                      // 1. Dropdown for Type
                      if (key == 'Type' || key == config.typeLabel) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            value: config.types.contains(localData[key]) ? localData[key] : null,
                            decoration: InputDecoration(labelText: key, border: const OutlineInputBorder(), isDense: true),
                            items: config.types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (val) => setStateDialog(() => localData[key] = val),
                          ),
                        );
                      } 
                      // 2. Dropdown for Specialty
                      else if (key == 'Specialty' && config.specialties.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            value: config.specialties.contains(localData[key]) ? localData[key] : null,
                            decoration: InputDecoration(labelText: key, border: const OutlineInputBorder(), isDense: true),
                            items: config.specialties.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (val) => setStateDialog(() => localData[key] = val),
                          ),
                        );
                      } 
                      // 3. Dropdown for Academic Year / Level
                      else if (config.hasAcademicYear && key == config.academicYearLabel) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            value: config.academicYears?.contains(localData[key]) == true ? localData[key] : null,
                            decoration: InputDecoration(labelText: key, border: const OutlineInputBorder(), isDense: true),
                            items: config.academicYears?.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList() ?? [],
                            onChanged: (val) {
                              setStateDialog(() {
                                localData[key] = val;
                                // Reset section if level is changed
                                if (config.hasDynamicSection && localData.containsKey(config.sectionLabel)) {
                                  localData[config.sectionLabel ?? 'Section'] = null;
                                }
                              });
                            },
                          ),
                        );
                      } 
                      // 4. Dropdown for Section / Class
                      else if (config.hasDynamicSection && key == config.sectionLabel) {
                        String? currentLevel = localData[config.academicYearLabel ?? 'Level'];
                        List<String> sections = [];
                        if (currentLevel != null && config.getSectionsForLevel != null) {
                          sections = config.getSectionsForLevel!(currentLevel);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            value: sections.contains(localData[key]) ? localData[key] : null,
                            decoration: InputDecoration(labelText: key, border: const OutlineInputBorder(), isDense: true),
                            items: sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (val) => setStateDialog(() => localData[key] = val),
                          ),
                        );
                      } 
                      // 5. TextField for everything else (Name, Person, Capacity)
                      else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: textControllers[key],
                            decoration: InputDecoration(labelText: key, border: const OutlineInputBorder(), isDense: true),
                          ),
                        );
                      }
                    }),

                    const SizedBox(height: 8),
                    const Text("Available Days:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: allDays.map((day) {
                        final isSelected = selectedDays.contains(day);
                        return FilterChip(
                          label: Text(day, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setStateDialog(() {
                              if (selected) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    // Update normal texts
                    for (var key in textControllers.keys) {
                      localData[key] = textControllers[key]!.text;
                    }
                    localData['available_days'] = selectedDays;

                    String newName = localData[config.nameLabel] ?? currentItemName;

                    widget.cubit.addedItems.remove(currentItemName);
                    widget.cubit.addedItems[newName] = localData;
                    widget.cubit.refreshUI();

                    setState(() {
                      currentItemName = newName;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Item updated successfully!"), backgroundColor: Colors.green),
                    );
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