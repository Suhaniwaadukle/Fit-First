import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/activity_model/activity_subcategory_model.dart';
import '../../../data/repositories/activity_repository.dart';

part 'activity_subcategory_event.dart';
part 'activity_subcategory_state.dart';

class ActivitySubCategoryBloc extends Bloc<ActivitySubCategoryEvent, ActivitySubCategoryState> {
  final ActivityRepository activityRepository;

  ActivitySubCategoryBloc({required this.activityRepository}) : super(ActivitySubCategoryInitial()) {
    on<LoadSubCategories>(_onLoadSubCategories);
  }

  Future<void> _onLoadSubCategories(
    LoadSubCategories event,
    Emitter<ActivitySubCategoryState> emit,
  ) async {
    emit(ActivitySubCategoryLoading());
    try {
      final response = await activityRepository.getSubCategoriesForActivity(
        event.activityId,
        event.activityType,
      );
      if (response.status == 'success' && response.data != null) {
        emit(ActivitySubCategoryLoaded(response.data!));
      } else {
        emit(ActivitySubCategoryError(response.message));
      }
    } catch (e) {
      emit(ActivitySubCategoryError(e.toString()));
    }
  }
}
