import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/routing/app_routes.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/section_card.dart';
import 'package:frontend/features/schedule/presentation/widgets/dynamic_edit_dialog.dart';

class PreviewCard extends StatelessWidget {
  const PreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ScheduleCubit>();

    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final String itemsLabel = AppStrings.getLabel(currentMode);

    return SectionCard(
      title: "Data Preview",
      icon: Icons.preview,
      children: [
        // ================= 1. قسم الفترات =================
        const Text(
          "🕒 Calculated Slots:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        if (cubit.calculatedSlots.isEmpty)
          const Text(
            "Press 'Calculate Slots' in Time Settings to generate.",
            style: TextStyle(color: Colors.grey),
          ),

        ...cubit.calculatedSlots.asMap().entries.map((entry) {
          int index = entry.key;
          var slot = entry.value;
          return Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.timer, color: Colors.blue),
              title: Text(
                slot["Slot"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${slot["Start"]} - ${slot["End"]}"),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DynamicEditDialog(
                      title: "Edit ${slot['Slot']}",
                      data: {
                        "Start Time": slot["Start"],
                        "End Time": slot["End"],
                      },
                      onSave: (updatedData) {
                        cubit.calculatedSlots[index]["Start"] =
                            updatedData["Start Time"];
                        cubit.calculatedSlots[index]["End"] =
                            updatedData["End Time"];
                        cubit.refreshUI();
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }),
        const Divider(height: 30),

        // ================= 2. قسم الأماكن =================
        const Text(
          "📍 Added Locations:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        if (cubit.addedLocations.isEmpty)
          const Text(
            "No locations added yet.",
            style: TextStyle(color: Colors.grey),
          ),

        ...cubit.addedLocations.asMap().entries.map((entry) {
          int index = entry.key;
          var loc = entry.value;
          return Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: const Icon(Icons.meeting_room, color: Colors.green),
              title: Text(
                loc["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Capacity: ${loc["capacity"]} | Type: ${loc["type"]}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                      final config = ModeRepository.modes[currentMode]!;

                      Map<String, List<String>>? dropdowns;
                      if (config.hasLocationType && config.locations != null) {
                        dropdowns = {"Location Type": config.locations!};
                      }

                      showDialog(
                        context: context,
                        builder: (context) => DynamicEditDialog(
                          title: "Edit Location",
                          data: {
                            "Location Name": loc["name"],
                            "Capacity": loc["capacity"],
                            if (dropdowns != null)
                              "Location Type": loc["type"] ?? "",
                          },
                          dropdownConfigs: dropdowns,
                          onSave: (updatedData) {
                            cubit.addedLocations[index]["name"] =
                                updatedData["Location Name"];
                            cubit.addedLocations[index]["capacity"] =
                                updatedData["Capacity"];
                            if (dropdowns != null) {
                              cubit.addedLocations[index]["type"] =
                                  updatedData["Location Type"];
                            }
                            cubit.refreshUI();
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      cubit.addedLocations.removeAt(index);
                      cubit.refreshUI();
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const Divider(height: 30),

        // ================= 3. قسم المواد/الشيفتات =================
        Text(
          "📝 Added $itemsLabel:",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        if (cubit.addedItems.isEmpty)
          Text(
            "No ${itemsLabel.toLowerCase()} added yet.",
            style: const TextStyle(color: Colors.grey),
          ),

        ...cubit.addedItems.entries.map(
          (entry) => Card(
            color: Colors.orange.shade50,
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.orange),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.details,
                arguments: {
                  'itemName': entry.key,
                  'details': entry.value,
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
          ),
        ),
      ],
    );
  }
}
