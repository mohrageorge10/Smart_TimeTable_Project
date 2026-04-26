import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/modeCubit/mode_cubit.dart';
import 'package:frontend/features/schedule/presentation/widgets/input_section.dart'; 
import 'package:frontend/features/schedule/presentation/widgets/schedule_table.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMode = context.read<ModeCubit>().state.selectedMode;
    final String itemsLabel = AppStrings.getLabel(currentMode);

    // sync cubit.currentMode with ModeCubit to guarantee fillMockData uses correct mode
    context.read<ScheduleCubit>().currentMode = currentMode;

    SizeConfig().init(context);


    if (SizeConfig.screenWidth > 800) {
      return Scaffold(
        appBar: AppBar(title: Text("Add New $itemsLabel")),
        body: const Row(
          children: [
            Expanded(flex: 1, child: InputSection()),
            Expanded(flex: 2, child: ScheduleTable()),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.getLabel(context.read<ModeCubit>().state.selectedMode),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit), text: "Inputs"),
              Tab(icon: Icon(Icons.table_chart), text: "Schedule"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            InputSection(),
            ScheduleTable(),
          ],
        ),
      ),
    );
  }
}