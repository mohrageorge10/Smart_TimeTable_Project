import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/buttons/custom_action_button.dart';
import 'package:frontend/features/schedule/presentation/widgets/custom_text_field.dart';

class TimeSettingsCard extends StatefulWidget {
  const TimeSettingsCard({super.key});

  @override
  State<TimeSettingsCard> createState() => _TimeSettingsCardState();
}

class _TimeSettingsCardState extends State<TimeSettingsCard> {
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  // الدالة المعدلة لضمان ظهور AM/PM دائماً
  Future<void> _selectTime(BuildContext context, ScheduleCubit cubit) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        // إجبار الـ Picker على نظام الـ 12 ساعة
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      // حساب الوقت يدوياً لضمان الصيغة المطلوبة
      final hour = picked.hour == 0 ? 12 : (picked.hour > 12 ? picked.hour - 12 : picked.hour);
      final minute = picked.minute.toString().padLeft(2, '0');
      final amPm = picked.hour >= 12 ? 'PM' : 'AM';
      
      final formattedTime = "$hour:$minute $amPm"; 

      setState(() {
        _timeController.text = formattedTime; 
        cubit.startTime = formattedTime;      
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context, cubit),
                child: AbsorbPointer(
                  child: CustomTextField(
                    labelText: "Start Time",
                    prefixIcon: Icons.play_circle_outline,
                    controller: _timeController, 
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: CustomTextField(
                labelText: "Break (min)",
                prefixIcon: Icons.pause_circle_outline,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    cubit.breakDuration = int.tryParse(value) ?? 0,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        
       CustomActionButton(
          icon: Icons.calculate,
          label: "Calculate Slots",
          onPressed: () {
            if (cubit.startTime.isEmpty || cubit.numberOfSlots == 0 || cubit.slotDuration == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please fill all time settings first!"), backgroundColor: Colors.red),
              );
              return;
            }
            cubit.calculateSlots();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Slots calculated! Check the Preview below."), backgroundColor: Colors.green),
            );
          },
        ),
      ],
    );
  }
}