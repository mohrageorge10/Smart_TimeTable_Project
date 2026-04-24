import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';

// استدعاء الويدجت الجديدة (تأكدي من المسار الصحيح لديك)
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
            onPressed: () => _showEditItemDialog(context, currentDetails),
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

  void _showEditItemDialog(BuildContext context, Map<String, dynamic> details) {
    Map<String, TextEditingController> controllers = {};
    for (var entry in details.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value.toString());
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controllers.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: e.value,
                    decoration: InputDecoration(labelText: e.key),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> updatedDetails = {};
                for (var key in controllers.keys) {
                  updatedDetails[key] = controllers[key]!.text;
                }

                final currentMode = context.read<ModeCubit>().state.selectedMode;
                final config = ModeRepository.modes[currentMode]!;
                String newName = updatedDetails[config.nameLabel] ?? currentItemName;

                widget.cubit.addedItems.remove(currentItemName);
                widget.cubit.addedItems[newName] = updatedDetails;
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
  }
}