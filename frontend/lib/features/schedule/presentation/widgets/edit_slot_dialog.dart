import 'package:flutter/material.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';

class EditSlotDialog extends StatefulWidget {
  final ScheduleCubit cubit;
  final int index;
  final Map<String, String> currentSlot;

  const EditSlotDialog({
    super.key,
    required this.cubit,
    required this.index,
    required this.currentSlot,
  });

  @override
  State<EditSlotDialog> createState() => _EditSlotDialogState();
}

class _EditSlotDialogState extends State<EditSlotDialog> {
  late TextEditingController startCtrl;
  late TextEditingController endCtrl;

  @override
  void initState() {
    super.initState();
    startCtrl = TextEditingController(text: widget.currentSlot["Start"]);
    endCtrl = TextEditingController(text: widget.currentSlot["End"]);
  }

  @override
  void dispose() {
    startCtrl.dispose();
    endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit ${widget.currentSlot["Slot"]}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: startCtrl, decoration: const InputDecoration(labelText: "Start Time")),
          const SizedBox(height: 10),
          TextField(controller: endCtrl, decoration: const InputDecoration(labelText: "End Time")),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            widget.cubit.calculatedSlots[widget.index]["Start"] = startCtrl.text;
            widget.cubit.calculatedSlots[widget.index]["End"] = endCtrl.text;
            widget.cubit.refreshUI();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}