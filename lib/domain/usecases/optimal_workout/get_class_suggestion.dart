// use user preferences to get the class suggestion
import 'package:test/domain/repositories/user_preferences_repository.dart';
import 'package:test/domain/repositories/gym_class_repository.dart';
import 'package:test/domain/usecases/gym_classes/get_classes_by_date_range.dart';
import 'package:test/domain/entities/gym_class.dart';

class GetClassSuggestion {
  final GymClassRepository gymClassRepository;
  final UserPreferencesRepository preferencesRepository;
  final GetClassesByDateRange getClassesByDateRange;

  GetClassSuggestion({
    required this.gymClassRepository,
    required this.preferencesRepository,
    required this.getClassesByDateRange,
  });

  // get gym classrs for this week
  Future<List<GymClass>> getGymClasseSuggestion(String userId) async {
    final userPreferences =
        await preferencesRepository.getUserPreferences(userId);

    if (userPreferences == null ||
        userPreferences.preferredWorkoutDays.isEmpty) {
      throw Exception(
          'User preferences not found or preferred workout days not set');
    }

    final classes = await getClassesByDateRange(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 7)),
    );

    return classes;
  }
}

// use prefered workout day,
// find whta they like to train based of workout history
// suggest the class based on the prefered workout day and the workout history



