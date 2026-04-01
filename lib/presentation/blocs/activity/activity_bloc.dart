// lib/presentation/blocs/activity/activity_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/data/models/activity_model/activity_model.dart';
import '../../../data/repositories/activity_repository.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository activityRepository;

  ActivityBloc({required this.activityRepository}) : super(ActivityInitial()) {
    on<AddActivity>(_onAddActivity);
    on<FetchActivities>(_onFetchActivities);
  }

  Future<void> _onAddActivity(
    AddActivity event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      final response = await activityRepository.insertActivityMultipart(event.activityData);
      if (response.status == 'success') {
        emit(ActivityAddedSuccess(response));
      } else {
        emit(ActivityOperationFailure(response.message));
      }
    } catch (e) {
      emit(ActivityOperationFailure(e.toString()));
    }
  }

  Future<void> _onFetchActivities(
    FetchActivities event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      if (event.userId.isEmpty) {
        // Or check for null if userId in FetchActivities can be null
        emit(const ActivityOperationFailure(
            "User ID is invalid. Cannot fetch activities."));
        return;
      }
      
      final response = await activityRepository.getActivities(event.userId);
      if (response.status == 'success' && response.data != null) {
        emit(ActivitiesLoaded(response.data!));
      } else {
        emit(ActivityOperationFailure(response.message));
      }
    } catch (e) {
      emit(ActivityOperationFailure(e.toString()));
    }
  }
}