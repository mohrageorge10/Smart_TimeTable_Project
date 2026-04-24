import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';

class EditLocationDialog extends StatefulWidget {
  final ScheduleCubit cubit;
  final int index;
  final Map<String, dynamic> currentLoc;

  const EditLocationDialog({
    super.key,
    required this.cubit,
    required this.index,
    required this.currentLoc,
  });

  @override
  State<EditLocationDialog> createState() => _EditLocationDialogState();
}

class _EditLocationDialogState extends State<EditLocationDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController capCtrl;
  late String selectedType;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.currentLoc["name"]);
    capCtrl = TextEditingController(text: widget.currentLoc["capacity"].toString());
    selectedType = widget.currentLoc["type"] ?? "";
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    capCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final config = ModeRepository.modes[currentMode]!;

    return AlertDialog(
      title: const Text("Edit Location"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Location Name")),
          const SizedBox(height: 10),
          TextField(controller: capCtrl, decoration: const InputDecoration(labelText: "Capacity"), keyboardType: TextInputType.number),
          
          if (config.hasLocationType && config.locations != null) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedType.isEmpty ? null : selectedType,
              decoration: const InputDecoration(labelText: "Location Type"),
              items: config.locations!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                setState(() => selectedType = val ?? "");
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            widget.cubit.addedLocations[widget.index]["name"] = nameCtrl.text;
            widget.cubit.addedLocations[widget.index]["capacity"] = int.tryParse(capCtrl.text) ?? 0;
            widget.cubit.addedLocations[widget.index]["type"] = selectedType;
            widget.cubit.refreshUI();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}