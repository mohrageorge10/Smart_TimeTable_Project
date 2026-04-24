import 'package:flutter/material.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';

class PreviewButton extends StatelessWidget {
  const PreviewButton({super.key, required this.cubit});

  final ScheduleCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: OutlinedButton.icon(
        onPressed: () {
          if (cubit.courseName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please enter the name first!"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          cubit.addItemToList();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${cubit.courseName} added successfully!"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.add_task, size: 24),
        label: const Text(
          "Add to List",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}
