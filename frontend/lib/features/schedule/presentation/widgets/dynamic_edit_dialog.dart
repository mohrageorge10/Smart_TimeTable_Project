import 'package:flutter/material.dart';

class DynamicEditDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  final Map<String, List<String>>? dropdownConfigs; 
  final void Function(Map<String, dynamic> updatedData) onSave;

  const DynamicEditDialog({
    super.key,
    required this.title,
    required this.data,
    required this.onSave,
    this.dropdownConfigs,
  });

  @override
  State<DynamicEditDialog> createState() => _DynamicEditDialogState();
}

class _DynamicEditDialogState extends State<DynamicEditDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};

  @override
  void initState() {
    super.initState();
    widget.data.forEach((key, value) {
      if (widget.dropdownConfigs?.containsKey(key) ?? false) {
        _dropdownValues[key] = value?.toString() ?? "";
      } else {
        _controllers[key] = TextEditingController(text: value?.toString() ?? "");
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.data.keys.map((key) {
            if (widget.dropdownConfigs?.containsKey(key) ?? false) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DropdownButtonFormField<String>(
                  value: _dropdownValues[key]!.isEmpty ? null : _dropdownValues[key],
                  decoration: InputDecoration(labelText: key),
                  items: widget.dropdownConfigs![key]!
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _dropdownValues[key] = val ?? "");
                  },
                ),
              );
            }
             bool isNumber = widget.data[key] is int; 
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _controllers[key],
                decoration: InputDecoration(labelText: key),
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            Map<String, dynamic> updatedData = {};
            
            for (var key in widget.data.keys) {
              if (widget.dropdownConfigs?.containsKey(key) ?? false) {
                updatedData[key] = _dropdownValues[key];
              } else {
                var originalVal = widget.data[key];
                var newVal = _controllers[key]!.text;
                updatedData[key] = (originalVal is int) ? (int.tryParse(newVal) ?? 0) : newVal;
              }
            }
            
            widget.onSave(updatedData);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}