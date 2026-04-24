import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/buttons/custom_action_button.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/section_card.dart';
import 'package:frontend/features/schedule/presentation/widgets/custom_dropdown.dart';
import 'package:frontend/features/schedule/presentation/widgets/custom_text_field.dart';

class LocationSettingsCard extends StatefulWidget {
  const LocationSettingsCard({super.key});

  @override
  State<LocationSettingsCard> createState() => _LocationSettingsCardState();
}

class _LocationSettingsCardState extends State<LocationSettingsCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final config = ModeRepository.modes[currentMode]!;

    return SectionCard(
      title: AppStrings.locationSettings,
      icon: Icons.location_on_outlined,
      children: [
        CustomTextField(
          controller: _nameController,
          labelText: "Location Name",
          prefixIcon: Icons.meeting_room,
          onChanged: (value) => cubit.locationName = value,
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _capacityController,
                labelText: "Capacity",
                prefixIcon: Icons.groups_2,
                keyboardType: TextInputType.number,
                onChanged: (value) => cubit.locationCapacity = int.tryParse(value) ?? 0,
              ),
            ),
            if (config.hasLocationType && config.locations != null) ...[
              SizedBox(width: 2.w),
              Expanded(
                child: CustomDropdown(
                  key: ValueKey(cubit.locationType.isEmpty ? "empty" : cubit.locationType),
                  labelText: "Location Type",
                  prefixIcon: Icons.place,
                  items: config.locations!,
                  value: cubit.locationType.isEmpty ? null : cubit.locationType,
                  onChanged: (val) => cubit.locationType = val ?? "",
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 1.5.h),
       CustomActionButton(
          icon: Icons.add_location_alt,
          label: "Save Location",
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter the location name!"), backgroundColor: Colors.red),
              );
              return;
            }
            cubit.addLocationToList();
            
            _nameController.clear();
            _capacityController.clear();
            setState(() {
              cubit.locationType = ''; 
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location added successfully!"), backgroundColor: Colors.green),
            );
          },
        ),
      ],
    );
  }
}