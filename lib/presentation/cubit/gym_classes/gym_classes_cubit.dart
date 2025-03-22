import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/entities/gym_class.dart';
import 'package:test/domain/usecases/gym_classes/get_all_classes.dart';
import 'package:test/domain/usecases/gym_classes/get_class_by_id.dart';
import 'package:test/domain/usecases/gym_classes/get_classes_by_date.dart';
import 'package:test/domain/usecases/gym_classes/get_classes_by_tag.dart';

import 'gym_classes_state.dart';

class GymClassesCubit extends Cubit<GymClassesState> {
  final GetAllClasses getAllClasses;
  final GetClassById getClassById;
  final GetClassesByDate getClassesByDate;
  final GetClassesByTag getClassesByTag;


  GymClassesCubit({
    required this.getAllClasses,
    required this.getClassById,
    required this.getClassesByDate,
    required this.getClassesByTag,

  }) : super(const GymClassesState());

  Future<void> loadClasses() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      List<GymClass> result;

      // If date is selected, load classes for that date
      if (state.selectedDate != null) {
        result = await getClassesByDate(state.selectedDate!);
      } else {
        // Otherwise load all classes
        result = await getAllClasses();
      }

      // Apply filter if needed
      final filteredClasses = _filterClasses(result);

      emit(state.copyWith(
        classes: filteredClasses,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  List<GymClass> _filterClasses(List<GymClass> classes) {
    if (state.filter == GymClassFilter.all) {
      return classes;
    }

    // Convert enum to tag string
    String tagToFilter;
    switch (state.filter) {
      case GymClassFilter.fullBody:
        tagToFilter = 'Full Body';
        break;
      case GymClassFilter.arms:
        tagToFilter = 'Arms';
        break;
      case GymClassFilter.legs:
        tagToFilter = 'Legs';
        break;
      case GymClassFilter.chest:
        tagToFilter = 'Chest';
        break;
      case GymClassFilter.cardio:
        tagToFilter = 'Cardio';
        break;
      default:
        return classes;
    }

    // Filter classes by tag
    return classes
        .where((gymClass) => gymClass.tags[tagToFilter] == true)
        .toList();
  }

  Future<void> getClassDetails(String classId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final classDetails = await getClassById(classId);

      if (classDetails != null) {
        emit(state.copyWith(
          selectedClass: classDetails,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Class not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void clearSelectedClass() {
    emit(state.copyWith(clearSelectedClass: true));
  }

  void changeFilter(GymClassFilter filter) {
    if (filter != state.filter) {
      emit(state.copyWith(filter: filter));
      loadClasses();
    }
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    loadClasses();
  }

  void clearDateFilter() {
    emit(state.copyWith(selectedDate: null));
    loadClasses();
  }

}
