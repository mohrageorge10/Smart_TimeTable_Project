import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routing/app_routes.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:frontend/features/schedule/data/models/mode_model.dart';
import 'package:frontend/features/schedule/data/repos/schedule_repository.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/buttons/model_button.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final List<AppMode> modes = [
      AppMode(title: "College", icon: Icons.school, color: Colors.indigo),
      AppMode(
        title: "Hospital",
        icon: Icons.local_hospital,
        color: Colors.teal,
      ),
      AppMode(title: "School", icon: Icons.menu_book, color: Colors.orange),
      AppMode(title: "Event", icon: Icons.event, color: Colors.purple),
    ];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Select Organization Type",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: (7.w).clamp(24.0, 40.0),
                ),
              ),
              SizedBox(height: 5.h),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: modes
                        .map(
                          (mode) => Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 1.h,
                              horizontal: 16,
                            ),
                            child: ModelButton(
                              title: mode.title,
                              icon: mode.icon,
                              color: mode.color,
                              onPressed: () {
                                final selectedMode = mode.title;

                                context.read<ModeCubit>().selectMode(
                                  selectedMode,
                                );

                                final scheduleCubit = ScheduleCubit(
                                  ScheduleRepository(),
                                );
                                scheduleCubit.currentMode = selectedMode;

                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.dashboard,
                                  arguments: scheduleCubit,
                                );
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
