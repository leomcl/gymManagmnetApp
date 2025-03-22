import 'package:flutter/material.dart';
import 'package:test/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/di/injection_container.dart' as di;
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/gym_stats/gym_stats_cubit.dart';
import 'package:test/presentation/cubit/occupancy/occupancy_cubit.dart';
import 'package:test/presentation/cubit/gym_classes/gym_classes_cubit.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => di.sl<AuthCubit>(),
        ),
        BlocProvider<WorkoutCubit>(
          create: (context) => di.sl<WorkoutCubit>(),
        ),
        BlocProvider<WorkoutSelectionCubit>(
          create: (context) => di.sl<WorkoutSelectionCubit>(),
        ),
        BlocProvider<GymStatsCubit>(
          create: (context) => di.sl<GymStatsCubit>(),
        ),
        BlocProvider<OccupancyCubit>(
          create: (context) {
            final cubit = di.sl<OccupancyCubit>();
            // Load occupancy data when app starts
            cubit.loadAllData();
            return cubit;
          },
        ),
        BlocProvider<GymClassesCubit>(
          create: (context) => di.sl<GymClassesCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Gym App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: const WidgetTree(),
      ),
    );
  }
}
