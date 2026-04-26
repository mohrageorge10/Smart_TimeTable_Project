import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_state.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/basic_info_card.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/location_settings_card.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/preview_card.dart';
import 'package:frontend/features/schedule/presentation/widgets/cards/time_settings_card.dart';
import 'package:frontend/features/schedule/presentation/widgets/buttons/generate_schedule_button.dart';

class InputSection extends StatelessWidget {
  const InputSection({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final config = ModeRepository.modes[currentMode]!;

    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        final cubit = context.read<ScheduleCubit>();

        return Container(
          padding: EdgeInsets.all(3.w),
          color: Colors.grey[100],
          child: ListView(
            children: [
              const TimeSettingsCard(),
              SizedBox(height: 2.h),

              if (config.hasLocationSettings) ...[
                const LocationSettingsCard(),
                SizedBox(height: 2.h),
              ],

              const BasicInfoCard(),
              SizedBox(height: 2.h),

              const PreviewCard(),
              
              GenerateScheduleButton(cubit: cubit),

              SizedBox(height: 1.h),
              TextButton.icon(
                onPressed: () {
                  // sync cubit.currentMode from ModeCubit before filling
                  final modeFromUI = context.read<ModeCubit>().state.selectedMode;
                  cubit.currentMode = modeFromUI;
                  cubit.fillMockData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✨ Mock Data Filled Successfully!"),
                      backgroundColor: Colors.blueAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome, color: Colors.blueAccent),
                label: const Text("Fill Auto Mock Data", style: TextStyle(color: Colors.blueAccent)),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}