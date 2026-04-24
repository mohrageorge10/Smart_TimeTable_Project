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

class BasicInfoCard extends StatefulWidget {
  const BasicInfoCard({super.key});

  @override
  State<BasicInfoCard> createState() => _BasicInfoCardState();
}

class _BasicInfoCardState extends State<BasicInfoCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _personController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final config = ModeRepository.modes[currentMode]!;

    return SectionCard(
      title: AppStrings.basicInfo,
      icon: Icons.info_outline,
      children: [
        CustomTextField(
          controller: _nameController, // ربط الـ Controller
          labelText: config.nameLabel,
          prefixIcon: Icons.menu_book,
          onChanged: (value) => cubit.courseName = value,
        ),
        SizedBox(height: 1.5.h),
        CustomTextField(
          controller: _personController, // ربط الـ Controller
          labelText: config.personLabel,
          prefixIcon: Icons.person,
          onChanged: (value) => cubit.lecturerName = value,
        ),
        SizedBox(height: 1.5.h),

        Row(
          children: [
            if (config.hasCapacity) ...[
              Expanded(
                child: CustomTextField(
                  controller: _capacityController, // ربط الـ Controller
                  labelText: "Capacity",
                  prefixIcon: Icons.groups,
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      cubit.studentsCount = int.tryParse(value) ?? 0,
                ),
              ),
              SizedBox(width: 2.w),
            ],

            Expanded(
              child: CustomDropdown(
                labelText: "Type",
                prefixIcon: Icons.category,
                items: config.types,
                value: cubit.selectedType,
                onChanged: (val) => setState(() => cubit.selectedType = val),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

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

        if (config.hasAcademicYear && config.academicYears != null) ...[
          CustomDropdown(
            labelText: config.academicYearLabel ?? "Academic Year",
            prefixIcon: Icons.school,
            items: config.academicYears!,
            value: cubit.selectedYear,
            onChanged: (val) => setState(() => cubit.selectedYear = val),
          ),
          SizedBox(height: 1.5.h),
        ],

        CustomActionButton(
          icon: Icons.add_task,
          label: "Save Item",
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter ${config.nameLabel}!"), backgroundColor: Colors.red),
              );
              return;
            }
            
            cubit.addItemToList();

            _nameController.clear();
            _personController.clear();
            _capacityController.clear();

            setState(() {
              cubit.courseName = '';
              cubit.lecturerName = '';
              cubit.studentsCount = 0;
              cubit.selectedType = null;
              cubit.selectedSpecialty = null;
              cubit.selectedYear = null;
              cubit.targetAudience = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Item added successfully!"), backgroundColor: Colors.green),
            );
          },
        ),
      ],
    );
  }
}