import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';

class GenerateScheduleButton extends StatelessWidget {
  const GenerateScheduleButton({
    super.key,
    required this.cubit,
  });

  final ScheduleCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => cubit.generateSchedule(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          AppStrings.generateSchedule,
          style: const TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}