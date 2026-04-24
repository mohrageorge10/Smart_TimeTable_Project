import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routing/app_routes.dart';
import 'package:frontend/features/schedule/data/repos/schedule_repository.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/presentation/dashboard_screen.dart';
import 'package:frontend/features/schedule/presentation/details_screen.dart';
import 'package:frontend/features/schedule/presentation/mode_selection_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.modeSelection:
        return MaterialPageRoute(
          builder: (context) => const ModeSelectionScreen(),
        );
      // case AppRoutes.scheduleScreen:
      //   return MaterialPageRoute(builder: (context) => const ScheduleScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => ScheduleCubit(ScheduleRepository()),
            child: const DashboardScreen(),
          ),
        );
     case AppRoutes.details:
  final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (context) => BlocProvider.value(
      value: args['cubit'] as ScheduleCubit, 
      child: DetailsScreen(
        itemName: args['itemName'],
        details: args['details'],
        cubit: args['cubit'],
      ),
    ),
  );
      default:
        return MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            );
          },
        );
    }
  }
}
