// use user preferences to get the class suggestion
import 'dart:developer';
import 'package:test/domain/repositories/gym_class_repository.dart';
import 'package:test/domain/usecases/gym_classes/get_classes_by_date_range.dart';
import 'package:test/domain/usecases/user_trends/get_user_prefered_day.dart';
import 'package:test/domain/usecases/user_trends/get_user_prefered_workout.dart';
import 'package:test/domain/entities/gym_class.dart';

class GetClassSuggestion {
  final GymClassRepository gymClassRepository;
  final GetClassesByDateRange getClassesByDateRange;
  final GetUserPreferedDays getUserPreferedDays;
  final GetUserPreferedWorkout getUserPreferedWorkout;

  GetClassSuggestion({
    required this.gymClassRepository,
    required this.getClassesByDateRange,
    required this.getUserPreferedDays,
    required this.getUserPreferedWorkout,
  });

  // returns map of integer (1-3, 3 being most suited to user) and gym class
  Future<Map<GymClass, int>> call(String userId, int limit) async {
    final recommendedClasses = <GymClass, int>{};

    final classes = await getClassesByDateRange(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 7)),
    );

    final preferredWorkoutDays = await getUserPreferedDays(userId, 3);
    log('Preferred workout days: ${preferredWorkoutDays.toString()}');
    final preferredWorkoutTypes = await getUserPreferedWorkout(userId, 3);

    for (var gymClass in classes) {
      var classScore = 0;
      var workoutTypeInClass = gymClass.tags.keys
          .where((tag) => gymClass.tags[tag] == true)
          .toList();

      // Add score for preferred day
      if (preferredWorkoutDays.contains(gymClass.dayOfWeek)) {
        classScore++;
      }

      // Add score for each preferred workout type (up to max score of 3)
      for (var type in workoutTypeInClass) {
        if (preferredWorkoutTypes.contains(type)) {
          classScore++;

          // Cap the total score at 3
          if (classScore >= 3) {
            classScore = 3;
            break;
          }
        }
      }

      recommendedClasses[gymClass] = classScore;
    }

    final sortedEntries = recommendedClasses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final limitedEntries = sortedEntries.take(limit);

    return Map.fromEntries(limitedEntries);
  }
}

// Score 1: Class is on preferred day OR class has one preferred workout type
// Score 2: Class is on preferred day AND has one preferred workout type OR class has two preferred workout types
// Score 3: Class has optimal combination of preferred day and workout types


