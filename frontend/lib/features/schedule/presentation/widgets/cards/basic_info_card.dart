import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_data.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:frontend/features/schedule/data/models/schedule_model.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/buttons/custom_action_button.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/section_card.dart';
import 'package:frontend/features/schedule/presentation/widgets/custom_dropdown.dart';
import 'package:frontend/features/schedule/presentation/widgets/custom_text_field.dart';

class BasicInfoCard extends StatefulWidget {
  const BasicInfoCard({super.key});

  @override
  State<BasicInfoCard> createState() => _BasicInfoCardState();
}

class _BasicInfoCardState extends State<BasicInfoCard> {
  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _personController   = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  List<String> _currentSections = [];

  @override
  void dispose() {
    _nameController.dispose();
    _personController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _onLevelChanged(String? level, ScheduleModeConfig config, ScheduleCubit cubit) {
    setState(() {
      cubit.selectedYear    = level;
      cubit.selectedSection = null;
      if (config.hasDynamicSection && level != null && config.getSectionsForLevel != null) {
        _currentSections = config.getSectionsForLevel!(level);
      } else {
        _currentSections = [];
      }
    });
  }

  Widget _buildDaysSelector(ScheduleCubit cubit, List<String> availableDays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Days:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 0.5.h),
        Wrap(
          spacing: 4,
          runSpacing: 0,
          children: availableDays.map((day) {
            final isSelected = cubit.itemAvailableDays.contains(day);
            return FilterChip(
              label: Text(day.substring(0, 3), style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    cubit.itemAvailableDays.add(day);
                  } else {
                    cubit.itemAvailableDays.remove(day);
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  void _clearForm(ScheduleCubit cubit) {
    _nameController.clear();
    _personController.clear();
    _capacityController.clear();
    setState(() {
      cubit.courseName       = '';
      cubit.lecturerName     = '';
      cubit.studentsCount    = 0;
      cubit.selectedType     = null;
      cubit.selectedSpecialty = null;
      cubit.selectedYear     = null;
      cubit.targetAudience   = null;
      cubit.selectedSection  = null;
      cubit.itemAvailableDays = [];
      _currentSections       = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit        = context.read<ScheduleCubit>();
    final currentMode  = context.read<ModeCubit>().state.selectedMode;
    final config       = ModeRepository.modes[currentMode]!;

    final availableDays = AppData.allDays
        .where((d) => !config.excludedDays.contains(d))
        .toList();

    return SectionCard(
      title: AppStrings.basicInfo,
      icon: Icons.info_outline,
      children: [

        CustomTextField(
          controller: _nameController,
          labelText: config.nameLabel,
          prefixIcon: Icons.menu_book,
          onChanged: (v) => cubit.courseName = v,
        ),
        SizedBox(height: 1.5.h),

        CustomTextField(
          controller: _personController,
          labelText: config.personLabel,
          prefixIcon: Icons.person,
          onChanged: (v) => cubit.lecturerName = v,
        ),
        SizedBox(height: 1.5.h),

        // ── Capacity + Type ──────────────────────────────────
        Row(
          children: [
            if (config.hasCapacity) ...[
              Expanded(
                child: CustomTextField(
                  controller: _capacityController,
                  labelText: "Capacity",
                  prefixIcon: Icons.groups,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => cubit.studentsCount = int.tryParse(v) ?? 0,
                ),
              ),
              SizedBox(width: 2.w),
            ],
            Expanded(
              child: CustomDropdown(
                labelText: config.typeLabel ?? "Type",
                prefixIcon: Icons.category,
                items: config.types,
                value: cubit.selectedType,
                onChanged: (val) => setState(() => cubit.selectedType = val),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

        // ── Specialty ────────────────────────────────────────
        if (config.specialties.isNotEmpty) ...[
          CustomDropdown(
            labelText: "Specialty",
            prefixIcon: Icons.star,
            items: config.specialties,
            value: cubit.selectedSpecialty,
            onChanged: (val) => setState(() => cubit.selectedSpecialty = val),
          ),
          SizedBox(height: 1.5.h),
        ],

        // ── Level (Academic Year / School Level) ─────────────
        if (config.hasAcademicYear && config.academicYears != null) ...[
          CustomDropdown(
            labelText: config.academicYearLabel ?? "Level",
            prefixIcon: Icons.school,
            items: config.academicYears!,
            value: cubit.selectedYear,
            onChanged: (val) => _onLevelChanged(val, config, cubit),
          ),
          SizedBox(height: 1.5.h),
        ],

        if (config.hasDynamicSection && _currentSections.isNotEmpty) ...[
          CustomDropdown(
            labelText: config.sectionLabel ?? "Section",
            prefixIcon: currentMode == 'School' ? Icons.class_ : Icons.group_work,
            items: _currentSections,
            value: cubit.selectedSection,
            onChanged: (val) => setState(() => cubit.selectedSection = val),
          ),
          SizedBox(height: 1.5.h),
        ],

        // ── Available Days (per item) ─────────────────────────
        if (config.hasAvailableDays && availableDays.isNotEmpty)
          _buildDaysSelector(cubit, availableDays),

        // ── Save Button ──────────────────────────────────────
        CustomActionButton(
          icon: Icons.add_task,
          label: "Save Item",
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Please enter ${config.nameLabel}!"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            cubit.addItemToList();
            _clearForm(cubit);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Item added successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
  }
}
