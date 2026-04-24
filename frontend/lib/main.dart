import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/core/routing/app_routes.dart';
import 'package:frontend/core/utils/size_config.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/schedule/logic/modeCubit/mode_cubit.dart';
import 'features/schedule/logic/modeCubit/mode_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('scheduleBox'); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
@override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ModeCubit(),
      child: BlocBuilder<ModeCubit, ModeState>(
        builder: (context, state) {
          SizeConfig().init(context); 
          
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(state.selectedMode),
            onGenerateRoute: (settings) => AppRouter().generateRoute(settings),
            initialRoute: AppRoutes.modeSelection,
          );
        },
      ),
    );
  }
  }

